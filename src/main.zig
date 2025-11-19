const std = @import("std");
const Io = std.Io;
const builtin = @import("builtin");
const folders = @import("known-folders");
const ziggy = @import("ziggy");
const logging = @import("cli/logging.zig");
const lsp_exe = @import("cli/lsp.zig");
const fmt_exe = @import("cli/fmt.zig");
const check_exe = @import("cli/check.zig");
const convert_exe = @import("cli/convert.zig");

pub const known_folders_config: folders.KnownFolderConfig = .{
    .xdg_force_default = true,
    .xdg_on_mac = true,
};

pub const std_options: std.Options = .{
    .logFn = logging.logFn,
};

var lsp_mode = false;
pub fn panic(
    msg: []const u8,
    _: ?*std.builtin.StackTrace,
    ret_addr: ?usize,
) noreturn {
    if (lsp_mode) {
        std.log.err("{s}\n", .{msg});
    } else {
        std.debug.print("{s}\n", .{msg});
    }
    blk: {
        const out = if (!lsp_mode) std.fs.File.stderr() else logging.log_file orelse break :blk;
        var writer = out.writerStreaming(&.{});
        const w = &writer.interface;

        std.debug.writeCurrentStackTrace(.{ .first_address = ret_addr }, w, .no_color) catch |err| {
            w.print("Unable to dump stack trace: {t}\n", .{err}) catch break :blk;
            break :blk;
        };
    }
    if (builtin.mode == .Debug) @breakpoint();
    std.process.exit(1);
}

pub const Command = enum { lsp, query, fmt, check, convert, help };

pub fn main() !void {
    const gpa = blk: {
        if (builtin.single_threaded) {
            const Gpa = struct {
                var impl: std.heap.GeneralPurposeAllocator(.{}) = .{};
            };
            break :blk Gpa.impl.allocator();
        } else break :blk std.heap.smp_allocator;
    };

    // Note: The Io impl must be `Threaded` because we use threadlocals
    //       for storing arena allocators in the various subcommands.
    var threaded: Io.Threaded = if (builtin.single_threaded)
        .init_single_threaded
    else
        .init(gpa);
    defer threaded.deinit();
    const io = threaded.io();

    logging.setup(io, gpa);

    const args = std.process.argsAlloc(gpa) catch fatal("oom\n", .{});
    defer std.process.argsFree(gpa, args);

    if (args.len < 2) fatalHelp();

    const cmd = std.meta.stringToEnum(Command, args[1]) orelse {
        std.debug.print("unrecognized subcommand: '{s}'\n\n", .{args[1]});
        fatalHelp();
    };

    if (cmd == .lsp) lsp_mode = true;

    _ = switch (cmd) {
        .lsp => {
            threaded.cpu_count = 1;
            lsp_exe.run(io, gpa, std.fs.cwd(), args[2..]) catch @panic("err");
        },
        .fmt => fmt_exe.run(io, gpa, args[2..]),
        .check => check_exe.run(io, gpa, args[2..]),
        .convert => convert_exe.run(io, gpa, args[2..]),
        .help => fatalHelp(),
        else => std.debug.panic("TODO cmd={s}", .{@tagName(cmd)}),
    } catch |err| fatal("unexpected error: {s}\n", .{@errorName(err)});
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
        \\  fmt          Format Ziggy Documents      
        \\  query, q     Query Ziggy Documents 
        \\  check        Check Ziggy Documents against a Ziggy Schema 
        \\  convert      Convert between JSON, YAML, TOML and Ziggy Documents
        \\  lsp          Start the Ziggy LSP
        \\  help         Show this menu and exit
        \\
        \\General Options:
        \\  --help, -h   Print command specific usage
        \\
        \\
    , .{});
}
