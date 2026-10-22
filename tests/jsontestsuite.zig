const std = @import("std");
const Io = std.Io;
const ziggy = @import("ziggy");

pub fn main(init: std.process.Init) !void {
    const io = init.io;
    const arena = init.arena.allocator();

    var args = try init.minimal.args.iterateAllocator(init.gpa);
    defer args.deinit();
    _ = args.skip(); // exe

    const json_path = args.next() orelse return error.ExpectedJsonFilePath;

    const json_data = try Io.Dir.cwd().readFileAllocOptions(io, json_path, arena, .unlimited, .of(u8), 0);

    var meta: ziggy.Deserializer.Meta = .init;
    _ = ziggy.deserializeLeaky(ziggy.Dynamic, arena, json_data, &meta, .{}) catch |err| switch (err) {
        error.OutOfMemory => return err,
        else => |e| {
            var stderr_buf: [1024]u8 = undefined;
            const stderr = std.debug.lockStderr(&stderr_buf);
            defer std.debug.unlockStderr();
            try meta.reportErrors(arena, .{}, json_path, json_data, e, &stderr.file_writer.interface);
            return e;
        },
    };
}
