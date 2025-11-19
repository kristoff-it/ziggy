const std = @import("std");
const zon = @import("build.zig.zon");

/// The full Ziggy parsing functionality is available at build time.
pub const ziggy = @import("src/root.zig");

pub fn build(b: *std.Build) !void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});
    const ziggy_module = b.addModule("ziggy", .{
        .root_source_file = b.path("src/root.zig"),
        .target = target,
        .optimize = optimize,
        .strip = false,
    });

    try setupTests(b, ziggy_module);
}

pub fn setupTests(b: *std.Build, ziggy_module: *std.Build.Module) !void {
    const test_step = b.step("test", "Run unit & snapshot tests");

    const unit_tests = b.addTest(.{
        .root_module = ziggy_module,
        .filters = b.args orelse &.{},
    });

    const run_unit_tests = b.addRunArtifact(unit_tests);
    // if (b.args) |args| run_unit_tests.addArgs(args);
    test_step.dependOn(&run_unit_tests.step);
}
