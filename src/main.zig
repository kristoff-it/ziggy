const std = @import("std");
const builtin = @import("builtin");
const ziggy = @import("ziggy");
const logging = @import("cli/logging.zig");
const lsp_exe = @import("cli/lsp.zig");
const fmt_exe = @import("cli/fmt.zig");
const check_exe = @import("cli/check.zig");

pub const known_folders_config = .{
    .xdg_force_default = true,
    .xdg_on_mac = true,
};

pub const std_options: std.Options = .{
    .logFn = logging.logFn,
};

pub fn panic(
    msg: []const u8,
    trace: ?*std.builtin.StackTrace,
    ret_addr: ?usize,
) noreturn {
    _ = ret_addr;
    std.log.err("{s}\n\n{?}", .{ msg, trace });
    if (builtin.mode == .Debug) @breakpoint();
    std.process.exit(1);
}

pub const Command = enum { lsp, query, fmt, check, convert, help };

pub fn main() void {
    var gpa_impl: std.heap.GeneralPurposeAllocator(.{}) = .{};
    const gpa = gpa_impl.allocator();

    logging.setup(gpa);

    const args = std.process.argsAlloc(gpa) catch fatal("oom\n", .{});
    defer std.process.argsFree(gpa, args);

    if (args.len < 2) fatalHelp();

    const cmd = std.meta.stringToEnum(Command, args[1]) orelse {
        std.debug.print("unrecognized subcommand: '{s}'\n\n", .{args[1]});
        fatalHelp();
    };

    _ = switch (cmd) {
        .lsp => lsp_exe.run(gpa, args[2..]),
        .fmt => fmt_exe.run(gpa, args[2..]),
        .check => check_exe.run(gpa, args[2..]),
        .help => fatalHelp(),
        else => @panic("TODO"),
    } catch |err| fatal("{s}\n", .{@errorName(err)});
}

fn fatal(comptime fmt: []const u8, args: anytype) noreturn {
    std.debug.print(fmt, args);
    std.process.exit(1);
}

fn fatalHelp() noreturn {
    fatal(
        \\Usage: ziggy COMMAND [OPTIONS]
        \\
        \\Commands: 
        \\  fmt          Format Ziggy files      
        \\  query, q     Query Ziggy files 
        \\  check        Check Ziggy files against a Ziggy schema 
        \\  convert      Convert between JSON, YAML, TOML files and Ziggy
        \\  lsp          Start the Ziggy LSP
        \\  help         Show this menu and exit
        \\
        \\General Options:
        \\  --help, -h   Print command specific usage
        \\
        \\
    , .{});
}
