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

    const json_src = try Io.Dir.cwd().readFileAllocOptions(
        io,
        json_path,
        arena,
        .unlimited,
        .of(u8),
        0,
    );

    var meta: ziggy.Deserializer.Meta = .init;
    _ = ziggy.deserializeLeaky(ziggy.Dynamic, arena, json_src, &meta, .{}) catch |err| switch (err) {
        error.OutOfMemory => return err,
        error.DuplicateField, error.Overflow => {
            // Json can have duplicate fields, it's ok for the Ziggy deserializer
            // to report that as an error, but it has no bearing on Ziggy's status
            // as a superset of json, so we ignore this error.
            // Similarly, we skip errors about huge numbers.
        },
        else => |e| {
            std.debug.print("{f}", .{meta.reportErrorsFmt(arena, .{}, json_path, json_src, e)});
            return e;
        },
    };
}
