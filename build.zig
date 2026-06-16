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

    const ziggy_module = b.addModule("ziggy", .{
        .root_source_file = b.path("src/root.zig"),
        .strip = false,
    });

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
            .{ .name = "ziggy", .module = ziggy_module },
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

    const test_step = try setupTestStep(b, target, optimize, cli_exe);
    setupFuzzStep(b, target, test_step, ziggy_module);
    setupWasmStep(b, optimize, options, ziggy_module, lsp);

    const release = b.step("release", "Create release builds of Ziggy");
    const git_version = getGitVersion(b);
    if (git_version == .tag) {
        if (std.mem.eql(u8, version, git_version.tag[1..])) {
            setupReleaseStep(b, ziggy_module, options, release);
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
    cli_exe: *std.Build.Step.Compile,
) !*std.Build.Step {
    const test_step = b.step("test", "Run unit & snapshot tests");

    const ziggy_module = b.createModule(.{
        .root_source_file = b.path("src/root.zig"),
        .target = target,
        .optimize = optimize,
    });

    const unit_tests = b.addTest(.{
        .root_module = ziggy_module,
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
            test_program.root_module.addImport("ziggy", ziggy_module);

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

            types.addImport("ziggy", ziggy_module);

            const check = addTypeCheckStepInternal(
                b,
                target,
                optimize,
                b.path("build/type-checker.zig"),
                ziggy_module,
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
            .optimize = .Debug,
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
            .optimize = .Debug,
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
