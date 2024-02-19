const std = @import("std");
const ziggy = @import("ziggy");
const Diagnostic = ziggy.Diagnostic;
const Ast = ziggy.Ast;

pub fn run(gpa: std.mem.Allocator, args: []const []const u8) !void {
    const cmd = Command.parse(args);

    if (cmd.check) @panic("TODO: --check");

    if (cmd.mode != .stdin) @panic("TODO: file mode");

    const in = std.io.getStdIn().reader();
    var buf = std.ArrayList(u8).init(gpa);
    defer buf.deinit();

    try in.readAllArrayList(&buf, 4 * 1024 * 1024 * 1024);

    const code = try buf.toOwnedSliceSentinel(0);

    var diag: Diagnostic = .{};
    const ast = Ast.init(gpa, code, null, true, &diag) catch {
        std.debug.print("{}", .{diag});
        std.process.exit(1);
    };

    var out_buffer = std.io.bufferedWriter(std.io.getStdOut().writer());
    const out = out_buffer.writer();

    try out.print("{}", .{ast});
    try out_buffer.flush();
}

pub const Command = struct {
    check: bool = false,
    mode: union(enum) {
        unknown,
        stdin,
        paths: []const []const u8,
    } = .unknown,

    fn parse(args: []const []const u8) Command {
        var cmd: Command = .{};
        var idx: usize = 0;
        while (idx < args.len) : (idx += 1) {
            const arg = args[idx];
            if (std.mem.eql(u8, arg, "--help") or
                std.mem.eql(u8, arg, "-h"))
            {
                fatalHelp();
            }

            if (std.mem.eql(u8, arg, "--check")) {
                if (cmd.check) {
                    std.debug.print("error: duplicate '--check' flag\n\n", .{});
                    std.process.exit(1);
                }

                cmd.check = true;
                continue;
            }

            if (std.mem.startsWith(u8, arg, "-")) {
                if (std.mem.eql(u8, arg, "--stdin") or
                    std.mem.eql(u8, arg, "-"))
                {
                    if (cmd.mode != .unknown) {
                        std.debug.print("unexpected flag: '{s}'\n", .{arg});
                        std.process.exit(1);
                    }

                    cmd.mode = .stdin;
                } else {
                    std.debug.print("unexpected flag: '{s}'\n", .{arg});
                    std.process.exit(1);
                }
            } else {
                const paths_start = idx;
                while (idx < args.len) : (idx += 1) {
                    if (std.mem.startsWith(u8, args[idx], "-")) {
                        break;
                    }
                }
                idx -= 1;

                if (cmd.mode != .unknown) {
                    std.debug.print(
                        "unexpected path argument(s): '{s}'...\n",
                        .{args[paths_start]},
                    );
                    std.process.exit(1);
                }

                const paths = args[paths_start .. idx + 1];
                cmd.mode = .{ .paths = paths };
            }
        }

        if (cmd.mode == .unknown) {
            std.debug.print("missing argument(s)\n\n", .{});
            fatalHelp();
        }

        return cmd;
    }

    fn fatalHelp() noreturn {
        std.debug.print(
            \\Usage: ziggy fmt PATH [PATH...] [OPTIONS]
            \\
            \\   Formats input paths inplace. If PATH is a directory, it will
            \\   be searched recursively for Ziggy files.
            \\
            \\Options:
            \\
            \\--help, -h       Prints this help and extits
            \\--stdin, -       Format bytes from stdin; ouptut to stdout 
            \\--check          List non-conforming files and exit with an
            \\                 error if the list is not empty
        , .{});

        std.process.exit(1);
    }
};
