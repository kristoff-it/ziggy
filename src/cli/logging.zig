const std = @import("std");
const Allocator = std.mem.Allocator;
const Io = std.Io;
const builtin = @import("builtin");
const folders = @import("known-folders");

var buf: [1024]u8 = undefined;
pub var log_writer: Io.File.Writer = undefined;

pub fn logFn(
    comptime level: std.log.Level,
    comptime scope: @EnumLiteral(),
    comptime format: []const u8,
    args: anytype,
) void {
    const scope_prefix = "(" ++ @tagName(scope) ++ "): ";
    const prefix = "[" ++ @tagName(level) ++ "] " ++ scope_prefix;
    _ = std.debug.lockStderr(&.{});
    defer std.debug.unlockStderr();

    const w = &log_writer.interface;
    w.print(prefix ++ format ++ "\n", args) catch return;
    w.flush() catch return;
}

pub fn setup(io: Io, gpa: Allocator, environ_map: std.process.Environ.Map) void {
    _ = std.debug.lockStderr(&.{});
    defer std.debug.unlockStderr();

    setupInternal(io, gpa, environ_map) catch {
        log_writer = Io.File.stderr().writerStreaming(io, &.{});
    };
}

fn setupInternal(io: Io, gpa: Allocator, environ_map: std.process.Environ.Map) !void {
    const log_name = "ziggy.log";
    var cache_base = try folders.open(io, gpa, environ_map, .cache, .{}) orelse return error.Failure;
    defer cache_base.close(io);

    const f: Io.File = try cache_base.createFile(io, log_name, .{ .truncate = false });
    log_writer = f.writerStreaming(io, &buf);
}
