const std = @import("std");
const Io = std.Io;
const builtin = @import("builtin");
const lsp_exe = @import("cli/lsp.zig");

pub fn main() !void {
    const gpa = std.heap.wasm_allocator;

    var threaded: Io.Threaded = if (builtin.single_threaded)
        .init_single_threaded
    else
        .init(gpa);
    defer threaded.deinit();
    const io = threaded.io();

    const preopens = try std.fs.wasi.preopensAlloc(gpa);
    defer {
        for (preopens.names) |n| gpa.free(n);
        gpa.free(preopens.names);
    }

    const root: std.fs.Dir = for (preopens.names[3..], 3..) |name, fd| {
        if (std.mem.eql(u8, name, "/")) break .{ .fd = @intCast(fd) };
    } else std.process.fatal(
        "WASI build of Ziggy LSP requires directory '/' " ++
            "to be mounted and all file URIs to be relative to it.",
        .{},
    );

    const args = std.process.argsAlloc(gpa) catch std.process.fatal("oom", .{});
    defer std.process.argsFree(gpa, args);
    try lsp_exe.run(io, gpa, root, args[1..]);
}
