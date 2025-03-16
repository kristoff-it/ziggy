const std = @import("std");
const Build = std.Build;

/// The full Ziggy parsing functionality is available at build time.
pub usingnamespace @import("src/root.zig");

pub fn build(b: *Build) !void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const ziggy = b.addModule("ziggy", .{
        .root_source_file = b.path("src/root.zig"),
        .target = target,
        .optimize = optimize,
        .strip = false,
    });

    const cli = b.addExecutable(.{
        .name = "ziggy",
        .root_source_file = b.path("src/main.zig"),
        .target = target,
        .optimize = optimize,
    });

    const folders = b.dependency("known_folders", .{}).module("known-folders");
    const lsp = b.dependency("lsp_kit", .{}).module("lsp");

    cli.root_module.addImport("ziggy", ziggy);
    cli.root_module.addImport("known-folders", folders);
    cli.root_module.addImport("lsp", lsp);

    const run_exe = b.addRunArtifact(cli);
    if (b.args) |args| run_exe.addArgs(args);
    const run_exe_step = b.step("run", "Run the Ziggy tool");
    run_exe_step.dependOn(&run_exe.step);

    b.installArtifact(cli);

    const ziggy_check = b.addExecutable(.{
        .name = "ziggy_check",
        .root_source_file = b.path("src/main.zig"),
        .target = target,
        .optimize = optimize,
    });

    ziggy_check.root_module.addImport("ziggy", ziggy);
    ziggy_check.root_module.addImport("known-folders", folders);
    ziggy_check.root_module.addImport("lsp", lsp);
    const check = b.step("check", "Check if the project compiles");
    check.dependOn(&ziggy_check.step);

    try setupTests(b, target, optimize, ziggy, cli);
    try setupReleaseStep(b, ziggy, folders, lsp);
}

pub fn setupReleaseStep(
    b: *Build,
    ziggy: *Build.Module,
    folders: *Build.Module,
    lsp: *Build.Module,
) !void {
    const release_step = b.step("release", "Create releases for the Ziggy CLI tool");

    const targets: []const std.Target.Query = &.{
        .{ .cpu_arch = .aarch64, .os_tag = .macos },
        .{ .cpu_arch = .aarch64, .os_tag = .linux },
        .{ .cpu_arch = .x86_64, .os_tag = .macos },
        .{ .cpu_arch = .x86_64, .os_tag = .linux, .abi = .musl },
        .{ .cpu_arch = .x86_64, .os_tag = .windows },
        .{ .cpu_arch = .aarch64, .os_tag = .windows },
    };

    for (targets) |t| {
        const release_target = b.resolveTargetQuery(t);

        const release_exe = b.addExecutable(.{
            .name = "ziggy",
            .root_source_file = b.path("src/main.zig"),
            .target = release_target,
            .optimize = .ReleaseFast,
        });

        release_exe.root_module.addImport("ziggy", ziggy);
        release_exe.root_module.addImport("known-folders", folders);
        release_exe.root_module.addImport("lsp", lsp);

        const target_output = b.addInstallArtifact(release_exe, .{
            .dest_dir = .{
                .override = .{
                    .custom = try t.zigTriple(b.allocator),
                },
            },
        });

        release_step.dependOn(&target_output.step);
    }
}

pub fn setupTests(
    b: *Build,
    target: std.Build.ResolvedTarget,
    optimize: std.builtin.OptimizeMode,
    ziggy: *Build.Module,
    cli: *Build.Step.Compile,
) !void {
    const test_step = b.step("test", "Run unit & snapshot tests");

    const unit_tests = b.addTest(.{
        .root_source_file = b.path("src/root.zig"),
        .target = target,
        .optimize = optimize,
        .filters = b.option([]const []const u8, "test-filter", "test filter") orelse &.{},
    });

    const run_unit_tests = b.addRunArtifact(unit_tests);
    if (b.args) |args| run_unit_tests.addArgs(args);
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

    b.build_root.handle.access("tests/ziggy", .{}) catch {
        const fail = b.addFail("snapshot test folder is missing, can't run tests (note: snapshot tests are not included in the ziggy manifest)");
        git_add.step.dependOn(&fail.step);
        return;
    };

    // errors - ast
    {
        const base_path = b.pathJoin(&.{ "tests", "ziggy", "ast", "errors" });
        const tests_dir = try b.build_root.handle.openDir(base_path, .{
            .iterate = true,
        });

        var it = tests_dir.iterateAssumeFirstIteration();
        while (try it.next()) |entry| {
            if (entry.kind == .directory) continue;
            if (entry.name[0] == '.') continue;
            const ext = std.fs.path.extension(entry.name);
            if (!std.mem.eql(u8, ext, ".ziggy")) continue;

            const run_cli = b.addRunArtifact(cli);
            run_cli.addArg("fmt");
            run_cli.addArg(entry.name);
            run_cli.setCwd(b.path(base_path));
            run_cli.expectExitCode(1);
            run_cli.has_side_effects = true;

            const out = run_cli.captureStdErr();
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
        const tests_dir = try b.build_root.handle.openDir(base_path, .{
            .iterate = true,
        });

        var it = tests_dir.iterateAssumeFirstIteration();
        while (try it.next()) |entry| {
            if (entry.kind == .directory) continue;
            if (entry.name[0] == '.') continue;
            const ext = std.fs.path.extension(entry.name);
            if (!std.mem.eql(u8, ext, ".ziggy")) continue;

            const basename = std.fs.path.stem(entry.name);

            const test_program = b.addExecutable(.{
                .name = b.fmt("{s}_test", .{basename}),
                .root_source_file = b.path("tests/type_driven.zig"),
                .target = target,
                .optimize = optimize,
            });

            const type_module_name = b.fmt("{s}.zig", .{basename});
            const type_module = b.createModule(.{
                .root_source_file = b.path(b.pathJoin(&.{
                    base_path,
                    type_module_name,
                })),
            });
            test_program.root_module.addImport("test_type", type_module);
            test_program.root_module.addImport("ziggy", ziggy);

            const run_cli = b.addRunArtifact(test_program);
            run_cli.addFileArg(b.path(b.pathJoin(&.{ base_path, entry.name })));
            run_cli.expectExitCode(1);

            const out = run_cli.captureStdErr();
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
}
