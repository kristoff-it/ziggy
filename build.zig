const std = @import("std");
const zon = @import("build.zig.zon");
const afl = @import("afl_kit");

/// The full Ziggy parsing functionality is available at build time.
pub const ziggy = @import("src/root.zig");

/// Validates user-provided types against a Ziggy Schema.
///
/// All public top-level declarations present in the root
/// source file of the provided 'types' module will be
/// matched by name witch corresponding type definitions
/// in the provided Ziggy Schema.
///
/// You can add any other module import to your module, which
/// means that you can just re-export your type definitions in
/// the root source file of `types`.
///
/// If your Zig type name does not match the corresponding
/// Ziggy Schema type name, make sure to use a public
/// re-export that does:
///
///     pub const SchemaTypeNameA = MyZigTypeName;
///
/// See `ziggy.Options` for more information on how to
/// customize (de)serialization for a Zig type.
pub fn addTypeCheckStep(
    /// Your `*std.Build` instance.
    project: *std.Build,
    target: std.Build.ResolvedTarget,
    optimize: std.lang.OptimizeMode,
    /// A module that exposes your type definitions.
    types: *std.Build.Module,
    /// Path to the schema file
    schema_path: std.Build.LazyPath,
) *std.Build.Step {
    const ziggy_dep = project.dependencyFromBuildZig(@This(), .{
        .target = target,
        .optimize = optimize,
    });
    const ziggy_b = ziggy_dep.builder;
    return &addTypeCheckStepInternal(
        project,
        target,
        optimize,
        ziggy_b.path("build/type-checker.zig"),
        ziggy_dep.module("ziggy"),
        types,
        schema_path,
        false,
    ).step;
}

pub fn build(b: *std.Build) !void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});
    const single_threaded = b.option(
        bool,
        "single-threaded",
        "Create a single-threaded build of the Ziggy CLI tool.",
    ) orelse false;
    const version = b.option(
        []const u8,
        "version",
        "Override the version of Ziggy.",
    ) orelse zon.version;

    const options = b.addOptions();
    options.addOption([]const u8, "version", version);

    const ziggy_mod = b.addModule("ziggy", .{
        .root_source_file = b.path("src/root.zig"),
        .strip = false,
    });

    const ansi_term = b.dependency("ansi_term", .{});
    const ansi_mod = ansi_term.module("ansi_term");
    ziggy_mod.addImport("ansi_term", ansi_mod);

    const folders = b.dependency("known_folders", .{}).module("known-folders");
    const lsp = b.dependency("lsp_kit", .{}).module("lsp");
    // const yaml = b.dependency("yaml", .{
    //     .target = target,
    //     .optimize = optimize,
    // }).module("yaml");

    const cli_module = b.createModule(.{
        .root_source_file = b.path("src/main.zig"),
        .target = target,
        .optimize = optimize,
        .single_threaded = single_threaded,
        .imports = &.{
            .{ .name = "ziggy", .module = ziggy_mod },
            .{ .name = "known-folders", .module = folders },
            .{ .name = "lsp", .module = lsp },
            // .{ .name = "yaml", .module = yaml },
        },
    });
    cli_module.addOptions("options", options);

    const cli_exe = b.addExecutable(.{
        .name = "ziggy",
        .root_module = cli_module,
    });
    b.installArtifact(cli_exe);

    const run_exe = b.addRunArtifact(cli_exe);
    run_exe.addPassthruArgs();
    const run_exe_step = b.step("run", "Run the Ziggy tool");
    run_exe_step.dependOn(&run_exe.step);

    const ziggy_check = b.addExecutable(.{
        .name = "ziggy_check",
        .root_module = cli_module,
    });

    const check = b.step("check", "Check if the project compiles");
    check.dependOn(&ziggy_check.step);

    const test_step = try setupTestStep(b, target, optimize, ansi_mod, cli_exe);
    setupFuzzStep(b, target, test_step, ziggy_mod);
    setupWasmStep(b, optimize, options, ziggy_mod, lsp);

    const release = b.step("release", "Create release builds of Ziggy");
    const git_version = getGitVersion(b);
    if (git_version == .tag) {
        if (std.mem.eql(u8, version, git_version.tag[1..])) {
            setupReleaseStep(b, ziggy_mod, options, release);
        } else {
            release.dependOn(&b.addFail(b.fmt(
                "error: git tag does not match zon package version (zon: '{s}', git: '{s}')",
                .{ version, git_version.tag[1..] },
            )).step);
        }
    } else {
        release.dependOn(&b.addFail(
            "error: git tag missing, cannot make release builds",
        ).step);
    }
}

fn setupWasmStep(
    b: *std.Build,
    optimize: std.builtin.OptimizeMode,
    options: *std.Build.Step.Options,
    ziggy_mod: *std.Build.Module,
    lsp: *std.Build.Module,
) void {
    const wasm = b.step("wasm", "Generate a WASM build of the Ziggy LSP");
    const ziggy_wasm_lsp = b.addExecutable(.{
        .name = "ziggy",
        .root_module = b.createModule(.{
            .root_source_file = b.path("src/wasm.zig"),
            .target = b.resolveTargetQuery(.{
                .cpu_arch = .wasm32,
                .os_tag = .wasi,
            }),
            .optimize = optimize,
            .single_threaded = true,
            .link_libc = false,
        }),
    });

    ziggy_wasm_lsp.root_module.addImport("ziggy", ziggy_mod);
    ziggy_wasm_lsp.root_module.addImport("lsp", lsp);
    ziggy_wasm_lsp.root_module.addOptions("options", options);

    const target_output = b.addInstallArtifact(ziggy_wasm_lsp, .{
        .dest_dir = .{ .override = .{ .custom = "" } },
    });
    wasm.dependOn(&target_output.step);
}

pub fn setupReleaseStep(
    b: *std.Build,
    ziggy_module: *std.Build.Module,
    options: *std.Build.Step.Options,
    release_step: *std.Build.Step,
) void {
    const targets: []const std.Target.Query = &.{
        .{ .cpu_arch = .aarch64, .os_tag = .macos },
        .{ .cpu_arch = .aarch64, .os_tag = .linux },
        .{ .cpu_arch = .x86_64, .os_tag = .linux, .abi = .musl },
        .{ .cpu_arch = .x86_64, .os_tag = .windows },
        .{ .cpu_arch = .aarch64, .os_tag = .windows },
    };

    for (targets) |t| {
        const release_target = b.resolveTargetQuery(t);
        const optimize: std.builtin.OptimizeMode = .ReleaseFast;

        const folders = b.dependency("known_folders", .{
            .target = release_target,
            .optimize = optimize,
        }).module("known-folders");

        const lsp = b.dependency("lsp_kit", .{
            .target = release_target,
            .optimize = optimize,
        }).module("lsp");

        const release_cli_mod = b.createModule(.{
            .root_source_file = b.path("src/main.zig"),
            .target = release_target,
            .optimize = optimize,
            .imports = &.{
                .{ .name = "ziggy", .module = ziggy_module },
                .{ .name = "known-folders", .module = folders },
                .{ .name = "lsp", .module = lsp },
            },
        });
        release_cli_mod.addOptions("options", options);

        const release_exe = b.addExecutable(.{
            .name = "ziggy",
            .root_module = release_cli_mod,
        });

        switch (t.os_tag.?) {
            .macos, .windows => {
                const archive_name = b.fmt("{s}.zip", .{
                    t.zigTriple(b.allocator) catch unreachable,
                });

                const zip = b.addSystemCommand(&.{
                    "zip",
                    "-9",
                    // "-dd",
                    "-q",
                    "-j",
                });
                const archive = zip.addOutputFileArg(archive_name);
                zip.addDirectoryArg(release_exe.getEmittedBin());
                _ = zip.captureStdOut(.{});

                release_step.dependOn(&b.addInstallFileWithDir(
                    archive,
                    .{ .custom = "releases" },
                    archive_name,
                ).step);
            },
            else => {
                const archive_name = b.fmt("{s}.tar.xz", .{
                    t.zigTriple(b.allocator) catch unreachable,
                });

                const tar = b.addSystemCommand(&.{
                    "gtar",
                    "-cJf",
                });

                const archive = tar.addOutputFileArg(archive_name);
                tar.addArg("-C");

                tar.addDirectoryArg(release_exe.getEmittedBinDirectory());
                tar.addArg("ziggy");
                _ = tar.captureStdOut(.{});

                release_step.dependOn(&b.addInstallFileWithDir(
                    archive,
                    .{ .custom = "releases" },
                    archive_name,
                ).step);
            },
        }
    }

    // wasm
    {
        const release_target = b.resolveTargetQuery(.{ .cpu_arch = .wasm32, .os_tag = .wasi });
        const ziggy_wasm_lsp = b.addExecutable(.{
            .name = "ziggy",
            .root_module = b.createModule(.{
                .root_source_file = b.path("src/wasm.zig"),
                .target = release_target,
                .optimize = .ReleaseSmall,
                .single_threaded = true,
                .link_libc = false,
            }),
        });

        const folders = b.dependency("known_folders", .{
            .target = release_target,
            .optimize = .ReleaseSmall,
        }).module("known-folders");

        const lsp = b.dependency("lsp_kit", .{
            .target = release_target,
            .optimize = .ReleaseSmall,
        }).module("lsp");

        ziggy_wasm_lsp.root_module.addImport("ziggy", ziggy_module);
        ziggy_wasm_lsp.root_module.addImport("folders", folders);
        ziggy_wasm_lsp.root_module.addImport("lsp", lsp);
        ziggy_wasm_lsp.root_module.addOptions("options", options);

        const archive_name = "wasm32-wasi-lsponly.tar.xz";
        const tar = b.addSystemCommand(&.{
            "gtar",
            "-cJf",
        });
        const archive = tar.addOutputFileArg(archive_name);
        tar.addArg("-C");
        tar.addDirectoryArg(ziggy_wasm_lsp.getEmittedBinDirectory());
        tar.addArg("ziggy.wasm");
        _ = tar.captureStdOut(.{});
        release_step.dependOn(&b.addInstallFileWithDir(
            archive,
            .{ .custom = "releases" },
            archive_name,
        ).step);
    }
}

pub fn setupTestStep(
    b: *std.Build,
    target: std.Build.ResolvedTarget,
    optimize: std.builtin.OptimizeMode,
    ansi_mod: *std.Build.Module,
    cli_exe: *std.Build.Step.Compile,
) !*std.Build.Step {
    const test_step = b.step("test", "Run unit & snapshot tests");

    const ziggy_mod = b.createModule(.{
        .root_source_file = b.path("src/root.zig"),
        .target = target,
        .optimize = optimize,
    });
    ziggy_mod.addImport("ansi_term", ansi_mod);

    const unit_tests = b.addTest(.{
        .root_module = ziggy_mod,
    });

    const run_unit_tests = b.addRunArtifact(unit_tests);
    test_step.dependOn(&run_unit_tests.step);

    const diff = b.addSystemCommand(&.{
        "git",
        "diff",
        "--cached",
        "--exit-code",
    });
    diff.addDirectoryArg(b.path("tests/"));
    diff.setName("git diff tests/");
    test_step.dependOn(&diff.step);

    // We need to stage all of tests/ in order for untracked files to show up in
    // the diff. It's also not a bad automatism since it avoids the problem of
    // forgetting to stage new snapshot files.
    const git_add = b.addSystemCommand(&.{ "git", "add" });
    git_add.addDirectoryArg(b.path("tests/"));
    git_add.setName("git add tests/");
    diff.step.dependOn(&git_add.step);

    b.root.root_dir.handle.access(b.graph.io, "tests/ziggy", .{}) catch {
        const fail = b.addFail("snapshot test folder is missing, can't run tests (note: snapshot tests are not included in the ziggy manifest)");
        git_add.step.dependOn(&fail.step);
        return test_step;
    };

    // errors - ast
    {
        const base_path = b.pathJoin(&.{ "tests", "ziggy", "ast", "errors" });
        var tests_dir = try b.root.root_dir.handle.openDir(b.graph.io, base_path, .{
            .iterate = true,
        });
        defer tests_dir.close(b.graph.io);

        var it = tests_dir.iterateAssumeFirstIteration();
        while (try it.next(b.graph.io)) |entry| {
            if (entry.kind == .directory) continue;
            if (entry.name[0] == '.') continue;
            const ext = std.fs.path.extension(entry.name);
            if (!std.mem.eql(u8, ext, ".ziggy")) continue;

            const run_cli = b.addRunArtifact(cli_exe);
            run_cli.addArg("fmt");
            run_cli.addArg(entry.name);
            run_cli.setCwd(b.path(base_path));
            run_cli.addFileInput(b.path(base_path).path(b, entry.name));
            run_cli.expectExitCode(1);

            const out = run_cli.captureStdErr(.{});
            const snap_name = b.fmt("{s}_snap.txt", .{
                std.fs.path.stem(entry.name),
            });

            const update_snap = b.addUpdateSourceFiles();
            update_snap.addCopyFileToSource(out, b.pathJoin(&.{
                base_path,
                snap_name,
            }));

            git_add.step.dependOn(&update_snap.step);
        }
    }

    // errors - type driven
    {
        const base_path = b.pathJoin(&.{ "tests", "ziggy", "type-driven", "errors" });
        const tests_dir = try b.root.root_dir.handle.openDir(b.graph.io, base_path, .{
            .iterate = true,
        });

        var it = tests_dir.iterateAssumeFirstIteration();
        while (try it.next(b.graph.io)) |entry| {
            if (entry.kind == .directory) continue;
            if (entry.name[0] == '.') continue;
            const ext = std.fs.path.extension(entry.name);
            if (!std.mem.eql(u8, ext, ".ziggy")) continue;

            const basename = std.fs.path.stem(entry.name);

            const test_program = b.addExecutable(.{
                .name = b.fmt("{s}_test", .{basename}),
                .root_module = b.createModule(.{
                    .root_source_file = b.path("tests/type_driven.zig"),
                    .target = target,
                    .optimize = optimize,
                }),
            });

            const type_module_name = b.fmt("{s}.zig", .{basename});
            const type_module = b.createModule(.{
                .root_source_file = b.path(b.pathJoin(&.{
                    base_path,
                    type_module_name,
                })),
            });
            test_program.root_module.addImport("test_type", type_module);
            test_program.root_module.addImport("ziggy", ziggy_mod);

            const run_cli = b.addRunArtifact(test_program);
            run_cli.addFileArg(b.path(b.pathJoin(&.{ base_path, entry.name })));
            run_cli.expectExitCode(1);

            const out = run_cli.captureStdErr(.{});
            const snap_name = b.fmt("{s}_snap.txt", .{
                std.fs.path.stem(entry.name),
            });

            const update_snap = b.addUpdateSourceFiles();
            update_snap.addCopyFileToSource(out, b.pathJoin(&.{
                base_path,
                snap_name,
            }));

            git_add.step.dependOn(&update_snap.step);
        }
    }

    // schema - type checker
    {
        const base_path = b.pathJoin(&.{ "tests", "schema", "type-checker" });
        const tests_dir = try b.root.root_dir.handle.openDir(b.graph.io, base_path, .{
            .iterate = true,
        });

        var it = tests_dir.iterateAssumeFirstIteration();
        while (try it.next(b.graph.io)) |entry| {
            if (entry.kind != .directory) continue;
            const basename = std.fs.path.stem(entry.name);
            const types = b.createModule(.{
                .root_source_file = b.path(b.pathJoin(&.{
                    base_path,
                    basename,
                    "root.zig",
                })),
            });

            types.addImport("ziggy", ziggy_mod);

            const check = addTypeCheckStepInternal(
                b,
                target,
                optimize,
                b.path("build/type-checker.zig"),
                ziggy_mod,
                types,
                b.path(b.pathJoin(&.{
                    base_path,
                    basename,
                    "root.ziggy-schema",
                })),
                true,
            );

            check.expectExitCode(1);

            const out = check.captureStdErr(.{});

            const update_snap = b.addUpdateSourceFiles();
            update_snap.addCopyFileToSource(out, b.pathJoin(&.{
                base_path,
                basename,
                "snapshot.txt",
            }));

            git_add.step.dependOn(&update_snap.step);
        }
    }

    // JSONTestSuite
    const jsontestsuite = b.option(bool, "jsontestsuite", "Include JSONTestSuite in tests") orelse false;
    if (jsontestsuite) if (b.lazyDependency("jsontestsuite", .{})) |jsontestsuite_dep| {
        const jsontestsuite_exe = b.addExecutable(.{
            .name = "jsontestsuite",
            .root_module = b.createModule(.{
                .root_source_file = b.path("tests/jsontestsuite.zig"),
                .target = target,
                .optimize = optimize,
                .imports = &.{
                    .{ .name = "ziggy", .module = ziggy_mod },
                },
            }),
        });

        for (json_accept_files) |file| {
            const json_cmd = b.addRunArtifact(jsontestsuite_exe);
            json_cmd.addFileArg(jsontestsuite_dep.path(b.fmt("test_parsing/{s}", .{file})));
            json_cmd.setName(b.fmt("json accept {s}", .{file}));
            test_step.dependOn(&json_cmd.step);
        }

        for (json_reject_files) |file| {
            const json_cmd = b.addRunArtifact(jsontestsuite_exe);
            json_cmd.addFileArg(jsontestsuite_dep.path(b.fmt("test_parsing/{s}", .{file})));
            json_cmd.setName(b.fmt("json reject {s}", .{file}));
            _ = json_cmd.captureStdErr(.{});
            json_cmd.expectExitCode(1);
            test_step.dependOn(&json_cmd.step);
        }
    };

    return test_step;
}

pub fn setupFuzzStep(
    b: *std.Build,
    target: std.Build.ResolvedTarget,
    test_step: *std.Build.Step,
    ziggy_module: *std.Build.Module,
) void {
    if (!(b.option(bool, "fuzz", "enable fuzzing") orelse false)) {
        return;
    }

    const afl_obj = b.addObject(.{
        .name = "fuzz",
        .root_module = b.createModule(.{
            .root_source_file = b.path("src/fuzz/afl.zig"),
            .target = target,
            .optimize = .ReleaseSafe,
            .single_threaded = true,
        }),
    });

    afl_obj.root_module.addImport("ziggy", ziggy_module);

    // Required options:
    afl_obj.root_module.stack_check = false; // not linking with compiler-rt
    afl_obj.root_module.link_libc = true; // afl runtime depends on libc
    afl_obj.root_module.fuzz = true;
    afl_obj.sanitize_coverage_trace_pc_guard = true;

    // Generate an instrumented executable:
    const afl_fuzz = afl.addInstrumentedExe(b, target, .ReleaseSafe, null, true, afl_obj, &.{});

    // Install it
    test_step.dependOn(&b.addInstallBinFile(afl_fuzz orelse return, "fuzz").step);

    const repro = b.addExecutable(.{
        .name = "fuzz-repro",
        .root_module = b.createModule(.{
            .root_source_file = b.path("src/fuzz/afl-repro.zig"),
            .target = target,
            .optimize = .debug,
            .single_threaded = true,
        }),
    });
    repro.root_module.addImport("ziggy", ziggy_module);
    test_step.dependOn(&b.addInstallArtifact(repro, .{}).step);

    const smith_repro = b.addExecutable(.{
        .name = "fuzz-repro-smith",
        .root_module = b.createModule(.{
            .root_source_file = b.path("src/fuzz/afl-repro-smith.zig"),
            .target = target,
            .optimize = .debug,
            .single_threaded = true,
        }),
    });
    smith_repro.root_module.addImport("ziggy", ziggy_module);
    test_step.dependOn(&b.addInstallArtifact(smith_repro, .{}).step);
}
const Version = union(Kind) {
    tag: []const u8,
    commit: []const u8,
    // not in a git repo
    unknown,

    pub const Kind = enum { tag, commit, unknown };

    pub fn string(v: Version) []const u8 {
        return switch (v) {
            .tag, .commit => |tc| tc,
            .unknown => "unknown",
        };
    }
};
fn getGitVersion(b: *std.Build) Version {
    const git_path = b.findProgram(.{ .names = &.{"git"} }) orelse return .unknown;
    var out: u8 = undefined;
    const git_describe = std.mem.trim(
        u8,
        b.runAllowFail(&[_][]const u8{
            git_path,               "-C",
            b.root.root_dir.path.?, "describe",
            "--match",              "*.*.*",
            "--tags",
        }, &out, .ignore) catch return .unknown,
        " \n\r",
    );

    switch (std.mem.count(u8, git_describe, "-")) {
        0 => return .{ .tag = git_describe },
        2 => {
            // Untagged development build (e.g. 0.8.0-684-gbbe2cca1a).
            var it = std.mem.splitScalar(u8, git_describe, '-');
            const tagged_ancestor = it.next() orelse unreachable;
            const commit_height = it.next() orelse unreachable;
            const commit_id = it.next() orelse unreachable;

            // Check that the commit hash is prefixed with a 'g'
            // (it's a Git convention)
            if (commit_id.len < 1 or commit_id[0] != 'g') {
                std.debug.panic("Unexpected `git describe` output: {s}\n", .{git_describe});
            }

            // The version is reformatted in accordance with
            // the https://semver.org specification.
            return .{
                .commit = b.fmt("{s}-dev.{s}+{s}", .{
                    tagged_ancestor,
                    commit_height,
                    commit_id[1..],
                }),
            };
        },
        else => std.debug.panic(
            "Unexpected `git describe` output: {s}\n",
            .{git_describe},
        ),
    }
}

fn addTypeCheckStepInternal(
    project: *std.Build,
    target: std.Build.ResolvedTarget,
    optimize: std.lang.OptimizeMode,
    root_source_file: std.Build.LazyPath,
    ziggy_mod: *std.Build.Module,
    types: *std.Build.Module,
    schema_path: std.Build.LazyPath,
    comptime test_mode_enabled: bool,
) *std.Build.Step.Run {
    const check = project.addExecutable(.{
        .name = "type_checker",
        .root_module = project.createModule(.{
            .root_source_file = root_source_file,
            .target = target,
            .optimize = optimize,
        }),
    });

    check.root_module.addImport("types", types);
    check.root_module.addImport("ziggy", ziggy_mod);

    const test_mode = project.addOptions();
    test_mode.addOption(bool, "enabled", test_mode_enabled);
    check.root_module.addOptions("test_mode", test_mode);

    const run = project.addRunArtifact(check);
    run.addFileArg(schema_path);
    if (project.root.root_dir.path) |root_path| {
        run.addArg(root_path);
    }

    return run;
}

const json_accept_files: []const []const u8 = &.{
    "y_array_arraysWithSpaces.json",
    "y_array_empty-string.json",
    "y_array_empty.json",
    "y_array_ending_with_newline.json",
    "y_array_false.json",
    "y_array_heterogeneous.json",
    "y_array_null.json",
    "y_array_with_1_and_newline.json",
    "y_array_with_leading_space.json",
    "y_array_with_several_null.json",
    "y_array_with_trailing_space.json",
    "y_number.json",
    "y_number_0e+1.json",
    "y_number_0e1.json",
    "y_number_after_space.json",
    "y_number_double_close_to_zero.json",
    "y_number_int_with_exp.json",
    "y_number_minus_zero.json",
    "y_number_negative_int.json",
    "y_number_negative_one.json",
    "y_number_negative_zero.json",
    "y_number_real_capital_e.json",
    "y_number_real_capital_e_neg_exp.json",
    "y_number_real_capital_e_pos_exp.json",
    "y_number_real_exponent.json",
    "y_number_real_fraction_exponent.json",
    "y_number_real_neg_exp.json",
    "y_number_real_pos_exponent.json",
    "y_number_simple_int.json",
    "y_number_simple_real.json",
    "y_object.json",
    "y_object_basic.json",
    "y_object_duplicated_key.json",
    "y_object_duplicated_key_and_value.json",
    "y_object_empty.json",
    "y_object_empty_key.json",
    "y_object_escaped_null_in_key.json",
    "y_object_extreme_numbers.json",
    "y_object_long_strings.json",
    "y_object_simple.json",
    "y_object_string_unicode.json",
    "y_object_with_newlines.json",
    "y_string_1_2_3_bytes_UTF-8_sequences.json",
    "y_string_accepted_surrogate_pair.json",
    "y_string_accepted_surrogate_pairs.json",
    "y_string_allowed_escapes.json",
    "y_string_backslash_and_u_escaped_zero.json",
    "y_string_backslash_doublequotes.json",
    "y_string_comments.json",
    "y_string_double_escape_a.json",
    "y_string_double_escape_n.json",
    "y_string_escaped_control_character.json",
    "y_string_escaped_noncharacter.json",
    "y_string_in_array.json",
    "y_string_in_array_with_leading_space.json",
    "y_string_last_surrogates_1_and_2.json",
    "y_string_nbsp_uescaped.json",
    "y_string_nonCharacterInUTF-8_U+10FFFF.json",
    "y_string_nonCharacterInUTF-8_U+FFFF.json",
    "y_string_null_escape.json",
    "y_string_one-byte-utf-8.json",
    "y_string_pi.json",
    "y_string_reservedCharacterInUTF-8_U+1BFFF.json",
    "y_string_simple_ascii.json",
    "y_string_space.json",
    "y_string_surrogates_U+1D11E_MUSICAL_SYMBOL_G_CLEF.json",
    "y_string_three-byte-utf-8.json",
    "y_string_two-byte-utf-8.json",
    "y_string_u+2028_line_sep.json",
    "y_string_u+2029_par_sep.json",
    "y_string_uEscape.json",
    "y_string_uescaped_newline.json",
    "y_string_unescaped_char_delete.json",
    "y_string_unicode.json",
    "y_string_unicodeEscapedBackslash.json",
    "y_string_unicode_2.json",
    "y_string_unicode_U+1FFFE_nonchar.json",
    "y_string_unicode_U+10FFFE_nonchar.json",
    "y_string_unicode_U+200B_ZERO_WIDTH_SPACE.json",
    "y_string_unicode_U+2064_invisible_plus.json",
    "y_string_unicode_U+FDD0_nonchar.json",
    "y_string_unicode_U+FFFE_nonchar.json",
    "y_string_unicode_escaped_double_quote.json",
    "y_string_utf8.json",
    "y_string_with_del_character.json",
    "y_structure_lonely_false.json",
    "y_structure_lonely_int.json",
    "y_structure_lonely_negative_real.json",
    "y_structure_lonely_null.json",
    "y_structure_lonely_string.json",
    "y_structure_lonely_true.json",
    "y_structure_string_empty.json",
    "y_structure_trailing_newline.json",
    "y_structure_true_in_array.json",
    "y_structure_whitespace_array.json",

    // Discretionary test cases
    "i_number_double_huge_neg_exp.json",
    "i_number_huge_exp.json",
    "i_number_neg_int_huge_exp.json",
    "i_number_pos_double_huge_exp.json",
    "i_number_real_neg_overflow.json",
    "i_number_real_pos_overflow.json",
    "i_number_real_underflow.json",
    "i_number_too_big_neg_int.json",
    "i_number_too_big_pos_int.json",
    "i_number_very_big_negative_int.json",
    "i_object_key_lone_2nd_surrogate.json",
    "i_string_1st_surrogate_but_2nd_missing.json",
    "i_string_1st_valid_surrogate_2nd_invalid.json",
    "i_string_incomplete_surrogate_and_escape_valid.json",
    "i_string_incomplete_surrogate_pair.json",
    "i_string_incomplete_surrogates_escape_valid.json",
    "i_string_invalid_lonely_surrogate.json",
    "i_string_invalid_surrogate.json",
    "i_string_invalid_utf-8.json",
    "i_string_inverted_surrogates_U+1D11E.json",
    "i_string_iso_latin_1.json",
    "i_string_lone_second_surrogate.json",
    "i_string_lone_utf8_continuation_byte.json",
    "i_string_not_in_unicode_range.json",
    "i_string_overlong_sequence_2_bytes.json",
    "i_string_overlong_sequence_6_bytes_null.json",
    "i_string_overlong_sequence_6_bytes.json",
    "i_string_truncated-utf-8.json",
    // "i_string_UTF-16LE_with_BOM.json",
    "i_string_UTF-8_invalid_sequence.json",
    // "i_string_utf16BE_no_BOM.json",
    // "i_string_utf16LE_no_BOM.json",
    "i_string_UTF8_surrogate_U+D800.json",
    "i_structure_500_nested_arrays.json",
    // "i_structure_UTF-8_BOM_empty_object.json",
};

const json_reject_files: []const []const u8 = &.{
    "n_array_1_true_without_comma.json",
    "n_array_a_invalid_utf8.json",
    "n_array_colon_instead_of_comma.json",
    "n_array_comma_after_close.json",
    "n_array_comma_and_number.json",
    "n_array_double_comma.json",
    "n_array_double_extra_comma.json",
    "n_array_extra_close.json",
    // "n_array_extra_comma.json",
    "n_array_incomplete_invalid_value.json",
    "n_array_incomplete.json",
    "n_array_inner_array_no_comma.json",
    "n_array_invalid_utf8.json",
    "n_array_items_separated_by_semicolon.json",
    "n_array_just_comma.json",
    "n_array_just_minus.json",
    "n_array_missing_value.json",
    "n_array_newlines_unclosed.json",
    // "n_array_number_and_comma.json",
    "n_array_number_and_several_commas.json",
    "n_array_spaces_vertical_tab_formfeed.json",
    "n_array_star_inside.json",
    "n_array_unclosed_trailing_comma.json",
    "n_array_unclosed_with_new_lines.json",
    "n_array_unclosed_with_object_inside.json",
    "n_array_unclosed.json",
    "n_incomplete_false.json",
    "n_incomplete_null.json",
    "n_incomplete_true.json",
    "n_multidigit_number_then_00.json",
    "n_number_-01.json",
    "n_number_-1.0..json",
    "n_number_-2..json",
    "n_number_-NaN.json",
    "n_number_.-1.json",
    "n_number_.2e-3.json",
    "n_number_++.json",
    "n_number_+1.json",
    "n_number_+Inf.json",
    "n_number_0_capital_E.json",
    "n_number_0_capital_E+.json",
    "n_number_0.1.2.json",
    "n_number_0.3e.json",
    "n_number_0.3e+.json",
    "n_number_0.e1.json",
    "n_number_0e.json",
    "n_number_0e+.json",
    "n_number_1_000.json",
    "n_number_1.0e-.json",
    "n_number_1.0e.json",
    "n_number_1.0e+.json",
    "n_number_1eE2.json",
    "n_number_2.e-3.json",
    "n_number_2.e+3.json",
    "n_number_2.e3.json",
    "n_number_9.e+.json",
    "n_number_expression.json",
    // "n_number_hex_1_digit.json",
    // "n_number_hex_2_digits.json",
    "n_number_Inf.json",
    "n_number_infinity.json",
    "n_number_invalid-negative-real.json",
    "n_number_invalid-utf-8-in-bigger-int.json",
    "n_number_invalid-utf-8-in-exponent.json",
    "n_number_invalid-utf-8-in-int.json",
    "n_number_invalid+-.json",
    "n_number_minus_infinity.json",
    "n_number_minus_sign_with_trailing_garbage.json",
    "n_number_minus_space_1.json",
    "n_number_NaN.json",
    "n_number_neg_int_starting_with_zero.json",
    "n_number_neg_real_without_int_part.json",
    "n_number_neg_with_garbage_at_end.json",
    "n_number_real_garbage_after_e.json",
    "n_number_real_with_invalid_utf8_after_e.json",
    "n_number_real_without_fractional_part.json",
    "n_number_starting_with_dot.json",
    "n_number_U+FF11_fullwidth_digit_one.json",
    "n_number_with_alpha_char.json",
    "n_number_with_alpha.json",
    "n_number_with_leading_zero.json",
    "n_object_bad_value.json",
    "n_object_bracket_key.json",
    "n_object_comma_instead_of_colon.json",
    "n_object_double_colon.json",
    "n_object_emoji.json",
    "n_object_garbage_at_end.json",
    "n_object_key_with_single_quotes.json",
    // "n_object_lone_continuation_byte_in_key_and_trailing_comma.json",
    "n_object_missing_colon.json",
    "n_object_missing_key.json",
    "n_object_missing_semicolon.json",
    "n_object_missing_value.json",
    "n_object_no-colon.json",
    "n_object_non_string_key_but_huge_number_instead.json",
    "n_object_non_string_key.json",
    "n_object_repeated_null_null.json",
    "n_object_several_trailing_commas.json",
    "n_object_single_quote.json",
    // "n_object_trailing_comma.json",
    "n_object_trailing_comment_open.json",
    "n_object_trailing_comment_slash_open_incomplete.json",
    // "n_object_trailing_comment_slash_open.json",
    "n_object_trailing_comment.json",
    "n_object_two_commas_in_a_row.json",
    "n_object_unquoted_key.json",
    "n_object_unterminated-value.json",
    "n_object_with_single_string.json",
    "n_object_with_trailing_garbage.json",
    "n_single_space.json",
    "n_string_1_surrogate_then_escape_u.json",
    "n_string_1_surrogate_then_escape_u1.json",
    "n_string_1_surrogate_then_escape_u1x.json",
    "n_string_1_surrogate_then_escape.json",
    "n_string_accentuated_char_no_quotes.json",
    "n_string_backslash_00.json",
    // "n_string_escape_x.json",
    "n_string_escaped_backslash_bad.json",
    "n_string_escaped_ctrl_char_tab.json",
    "n_string_escaped_emoji.json",
    "n_string_incomplete_escape.json",
    "n_string_incomplete_escaped_character.json",
    "n_string_incomplete_surrogate_escape_invalid.json",
    "n_string_incomplete_surrogate.json",
    "n_string_invalid_backslash_esc.json",
    "n_string_invalid_unicode_escape.json",
    "n_string_invalid_utf8_after_escape.json",
    "n_string_invalid-utf-8-in-escape.json",
    "n_string_leading_uescaped_thinspace.json",
    "n_string_no_quotes_with_bad_escape.json",
    "n_string_single_doublequote.json",
    "n_string_single_quote.json",
    "n_string_single_string_no_double_quotes.json",
    "n_string_start_escape_unclosed.json",
    "n_string_unescaped_ctrl_char.json",
    "n_string_unescaped_newline.json",
    "n_string_unescaped_tab.json",
    "n_string_unicode_CapitalU.json",
    "n_string_with_trailing_garbage.json",
    "n_structure_100000_opening_arrays.json",
    "n_structure_angle_bracket_..json",
    "n_structure_angle_bracket_null.json",
    "n_structure_array_trailing_garbage.json",
    "n_structure_array_with_extra_array_close.json",
    "n_structure_array_with_unclosed_string.json",
    "n_structure_ascii-unicode-identifier.json",
    "n_structure_capitalized_True.json",
    "n_structure_close_unopened_array.json",
    "n_structure_comma_instead_of_closing_brace.json",
    "n_structure_double_array.json",
    "n_structure_end_array.json",
    "n_structure_incomplete_UTF8_BOM.json",
    "n_structure_lone-invalid-utf-8.json",
    "n_structure_lone-open-bracket.json",
    "n_structure_no_data.json",
    "n_structure_null-byte-outside-string.json",
    "n_structure_number_with_trailing_garbage.json",
    "n_structure_object_followed_by_closing_object.json",
    "n_structure_object_unclosed_no_value.json",
    "n_structure_object_with_comment.json",
    "n_structure_object_with_trailing_garbage.json",
    "n_structure_open_array_apostrophe.json",
    "n_structure_open_array_comma.json",
    "n_structure_open_array_object.json",
    "n_structure_open_array_open_object.json",
    "n_structure_open_array_open_string.json",
    "n_structure_open_array_string.json",
    "n_structure_open_object_close_array.json",
    "n_structure_open_object_comma.json",
    "n_structure_open_object_open_array.json",
    "n_structure_open_object_open_string.json",
    "n_structure_open_object_string_with_apostrophes.json",
    "n_structure_open_object.json",
    "n_structure_open_open.json",
    "n_structure_single_eacute.json",
    "n_structure_single_star.json",
    "n_structure_trailing_#.json",
    "n_structure_U+2060_word_joined.json",
    "n_structure_uescaped_LF_before_string.json",
    "n_structure_unclosed_array_partial_null.json",
    "n_structure_unclosed_array_unfinished_false.json",
    "n_structure_unclosed_array_unfinished_true.json",
    "n_structure_unclosed_array.json",
    "n_structure_unclosed_object.json",
    "n_structure_unicode-identifier.json",
    "n_structure_UTF8_BOM_no_data.json",
    "n_structure_whitespace_formfeed.json",
    "n_structure_whitespace_U+2060_word_joiner.json",
};
