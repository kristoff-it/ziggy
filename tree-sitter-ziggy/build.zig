const std = @import("std");

pub fn build(b: *std.Build) void {
    var lib = b.addStaticLibrary(.{
        .name = "tree-sitter-ziggy",
        .target = b.standardTargetOptions(.{}),
        .optimize = b.standardOptimizeOption(.{}),
    });

    lib.linkLibC();
    lib.addCSourceFile(.{ .file = .{ .path = "src/parser.c" }, .flags = &.{} });
    lib.addIncludePath(.{ .path = "src/" });
    b.installArtifact(lib);
}
