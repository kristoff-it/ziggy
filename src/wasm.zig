const std = @import("std");
const Io = std.Io;
const builtin = @import("builtin");
const lsp_exe = @import("cli/lsp.zig");

pub fn main(init: std.process.Init) !void {
    const root = init.preopens.get("/") orelse std.process.fatal(
        "WASI build of Ziggy LSP requires directory '/' " ++
            "to be mounted and all file URIs to be relative to it.",
        .{},
    );

    const args = init.minimal.args.toSlice(init.arena.allocator()) catch std.process.fatal("oom", .{});
    try lsp_exe.run(init.io, init.gpa, root.dir, args[1..]);
}
