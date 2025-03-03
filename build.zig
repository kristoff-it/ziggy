const std = @import("std");

/// The full Ziggy parsing functionality is available at build time.
pub usingnamespace @import("src/root.zig");

pub fn build(b: *std.Build) !void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const ziggy = b.addModule("ziggy", .{
        .root_source_file = b.path("src/root.zig"),
        .target = target,
        .optimize = optimize,
        .strip = false,
    });

    const unit_tests = b.addTest(.{
        .root_source_file = b.path("src/root.zig"),
        .target = target,
        .optimize = optimize,
        .strip = false,
    });
    unit_tests.filters = if (b.option([]const u8, "test-filter", "test filter")) |filter|
        b.allocator.dupe([]const u8, &.{filter}) catch @panic("OOM")
    else
        &.{};

    const run_unit_tests = b.addRunArtifact(unit_tests);
    if (b.args) |args| run_unit_tests.addArgs(args);
    run_unit_tests.has_side_effects = true;

    const test_step = b.step("test", "Run unit tests");
    test_step.dependOn(&run_unit_tests.step);

    const ziggy_exe = b.addExecutable(.{
        .name = "ziggy",
        .root_source_file = b.path("src/main.zig"),
        .target = target,
        .optimize = optimize,
    });

    const folders = b.dependency("known_folders", .{});
    const lsp = b.dependency("lsp_kit", .{});

    ziggy_exe.root_module.addImport("ziggy", ziggy);
    ziggy_exe.root_module.addImport("known-folders", folders.module("known-folders"));
    ziggy_exe.root_module.addImport("lsp", lsp.module("lsp"));

    const run_exe = b.addRunArtifact(ziggy_exe);
    if (b.args) |args| run_exe.addArgs(args);
    const run_exe_step = b.step("run", "Run the Ziggy tool");
    run_exe_step.dependOn(&run_exe.step);

    b.installArtifact(ziggy_exe);

    const ziggy_check = b.addExecutable(.{
        .name = "ziggy_check",
        .root_source_file = b.path("src/main.zig"),
        .target = target,
        .optimize = optimize,
    });

    ziggy_check.root_module.addImport("ziggy", ziggy);
    ziggy_check.root_module.addImport("known-folders", folders.module("known-folders"));
    ziggy_check.root_module.addImport("lsp", lsp.module("lsp"));
    const check = b.step("check", "Check if Tigerbeetle compiles");
    check.dependOn(&ziggy_check.step);

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
        release_exe.root_module.addImport("known-folders", folders.module("known-folders"));
        release_exe.root_module.addImport("lsp", lsp.module("lsp"));

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
