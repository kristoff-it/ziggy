const std = @import("std");
const Io = std.Io;
const ziggy = @import("ziggy");
const test_type = @import("test_type");
const CaseType = test_type.Case;

pub fn main(init: std.process.Init) !void {
    const arena = init.arena.allocator();

    const args = try init.minimal.args.toSlice(arena);
    const case = try Io.Dir.cwd().readFileAllocOptions(
        init.io,
        args[1],
        arena,
        .limited(ziggy.max_size),
        .of(u8),
        0,
    );

    var diag: ziggy.Diagnostic = .{ .path = null };
    _ = ziggy.parseLeaky(CaseType, arena, case, .{
        .diagnostic = &diag,
    }) catch |err| {
        if (err != error.Syntax) @panic("wrong error!");
        std.debug.print("{f}", .{diag.fmt(case)});
        std.process.exit(1);
    };

    @panic("unreachable");
}
