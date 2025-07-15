const std = @import("std");
const builtin = @import("builtin");
const folders = @import("known-folders");

pub var log_file: ?std.fs.File = switch (builtin.target.os.tag) {
    .linux, .macos => std.fs.File.stderr(),
    else => null,
};

pub fn logFn(
    comptime level: std.log.Level,
    comptime scope: @Type(.enum_literal),
    comptime format: []const u8,
    args: anytype,
) void {
    // if (scope != .ws and scope != .network) return;

    const l = log_file orelse return;
    const scope_prefix = "(" ++ @tagName(scope) ++ "): ";
    const prefix = "[" ++ @tagName(level) ++ "] " ++ scope_prefix;
    std.debug.lockStdErr();
    defer std.debug.unlockStdErr();

    var writer = l.writer(&.{});
    const w = &writer.interface;
    w.print(prefix ++ format ++ "\n", args) catch return;
}

pub fn setup(gpa: std.mem.Allocator) void {
    std.debug.lockStdErr();
    defer std.debug.unlockStdErr();

    setupInternal(gpa) catch {
        log_file = null;
    };
}

fn setupInternal(gpa: std.mem.Allocator) !void {
    const cache_base = try folders.open(gpa, .cache, .{}) orelse return error.Failure;
    try cache_base.makePath("ziggy");

    const log_name = "ziggy.log";
    const log_path = try std.fmt.allocPrint(gpa, "ziggy/{s}", .{log_name});
    defer gpa.free(log_path);

    const file = try cache_base.createFile(log_path, .{ .truncate = false });
    const end = try file.getEndPos();
    try file.seekTo(end);

    log_file = file;
}
