const std = @import("std");
const afl = @import("afl.zig");

pub fn main(init: std.process.Init) !void {
    const args = try init.minimal.args.toSlice(init.arena.allocator());

    const src: [:0]const u8 = if (args.len == 1) blk: {
        var in_reader = std.Io.File.stdin().readerStreaming(init.io, &.{});
        break :blk try in_reader.interface.allocRemainingAlignedSentinel(
            init.arena.allocator(),
            .unlimited,
            .@"1",
            0,
        );
    } else if (args.len == 2) args[1] else @panic("wrong number of arguments");

    afl.zig_fuzz_test(src.ptr, @intCast(src.len));
}
