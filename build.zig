const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const ziggy = b.addModule("ziggy", .{
        .root_source_file = .{ .path = "src/root.zig" },
        .target = target,
        .optimize = optimize,
        .strip = false,
    });

    const treez = b.dependency("treez", .{});
    ziggy.addImport("treez", treez.module("treez"));

    const unit_tests = b.addTest(.{
        .root_source_file = .{ .path = "src/root.zig" },
        .target = target,
        .optimize = optimize,
        .strip = false,
    });

    unit_tests.root_module.addImport("treez", treez.module("treez"));
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
        .root_source_file = .{ .path = "src/main.zig" },
        .target = target,
        .optimize = optimize,
    });

    const tree_sitter = treez.artifact("tree-sitter");
    const tree_sitter_ziggy = b.dependency("tree-sitter-ziggy", .{}).artifact("tree-sitter-ziggy");
    const folders = b.dependency("known-folders", .{});
    const lsp = b.dependency("zig-lsp-kit", .{});

    ziggy_exe.root_module.addImport("ziggy", ziggy);
    ziggy_exe.root_module.addImport("known-folders", folders.module("known-folders"));
    ziggy_exe.root_module.addImport("lsp", lsp.module("lsp"));
    ziggy_exe.linkLibrary(tree_sitter);
    ziggy_exe.linkLibrary(tree_sitter_ziggy);

    const run_exe = b.addRunArtifact(ziggy_exe);
    if (b.args) |args| run_exe.addArgs(args);
    const run_exe_step = b.step("run", "Run the Ziggy tool");
    run_exe_step.dependOn(&run_exe.step);

    b.installArtifact(ziggy_exe);

    const check = b.step("check", "Check if Tigerbeetle compiles");
    check.dependOn(&ziggy_exe.step);
}
