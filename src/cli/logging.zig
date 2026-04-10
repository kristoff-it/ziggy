const std = @import("std");
const Io = std.Io;
const builtin = @import("builtin");
const folders = @import("known-folders");

pub var writer: Io.File.Writer = undefined;

pub fn logFn(
    comptime level: std.log.Level,
    comptime scope: @EnumLiteral(),
    comptime format: []const u8,
    args: anytype,
) void {
    // if (scope != .ws and scope != .network) return;

    const scope_prefix = "(" ++ @tagName(scope) ++ "): ";
    const prefix = "[" ++ @tagName(level) ++ "] " ++ scope_prefix;
    _ = std.debug.lockStderr(&.{});
    defer std.debug.unlockStdErr();

    const w = &writer.interface;
    w.print(prefix ++ format ++ "\n", args) catch return;
}

pub fn setup(io: Io, gpa: std.mem.Allocator, environ_map: std.process.Environ.Map) void {
    if (true) return;
    _ = io;
    _ = gpa;
    _ = environ_map;
    // std.debug.lockStdErr();
    // defer std.debug.unlockStdErr();

    // setupInternal(io, gpa, environ_map) catch {
    //     writer = Io.File.stderr().writerStreaming(io, &.{});
    // };
}

fn setupInternal(io: Io, gpa: std.mem.Allocator, environ_map: std.process.Environ.Map) !void {
    const cache_base = try folders.open(io, gpa, environ_map, .cache, .{}) orelse return error.Failure;
    try cache_base.makePath("ziggy");

    const log_name = "ziggy.log";
    const log_path = try std.fmt.allocPrint(gpa, "ziggy/{s}", .{log_name});
    defer gpa.free(log_path);

    const file = try cache_base.createFile(io, log_path, .{ .truncate = false });
    writer = file.writerStreaming(&.{});
}
