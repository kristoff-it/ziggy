const std = @import("std");
const ziggy = @import("ziggy");
const logging = @import("logging.zig");
const lsp_exe = @import("lsp.zig");
const fmt_exe = @import("fmt.zig");

pub const known_folders_config = .{
    .xdg_force_default = true,
    .xdg_on_mac = true,
};

pub const std_options: std.Options = .{
    .logFn = logging.logFn,
};

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
        \\  fmt          Formats Ziggy files      
        \\  query, q     Queries Ziggy files 
        \\  check        Checks Ziggy files against a Ziggy schema 
        \\  convert      Converts JSON, YAML, TOML files from and to Ziggy
        \\  lsp          Starts the Ziggy LSP
        \\  help         Shows this menu and exits
        \\
        \\General Options:
        \\ --help, -h    Print command specific usage
        \\
        \\
    , .{});
}
