const std = @import("std");
const ziggy = @import("ziggy");
const afl = @import("afl.zig");

pub fn main(init: std.process.Init) !void {
    const args = try init.minimal.args.toSlice(init.arena.allocator());

    const raw: [:0]const u8 = if (args.len == 1) blk: {
        var in_reader = std.Io.File.stdin().readerStreaming(init.io, &.{});
        break :blk try in_reader.interface.allocRemainingAlignedSentinel(
            init.arena.allocator(),
            .unlimited,
            .@"1",
            0,
        );
    } else if (args.len == 2) args[1] else @panic("wrong number of arguments");

    const src = try afl.doc_smith.build(init.arena.allocator(), raw);

    std.debug.print("--- raw ---\n{q}[end]\n", .{raw});
    std.debug.print("--- case ---\n{s}[end]\n-----------\n\n", .{src});

    const ast = ziggy.Ast.init(init.arena.allocator(), src, .{}) catch unreachable;
    defer ast.deinit(init.arena.allocator());

    if (ast.errors.len > 0) {
        for (ast.errors) |err| {
            const sel = err.main_location.getSelection(src);
            std.debug.print("{}:{}:{f}\n", .{ sel.start.line, sel.start.col, err.tag });
        }
    }

    afl.zig_fuzz_test(src.ptr, @intCast(src.len));
}
