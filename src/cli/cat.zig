const builtin = @import("builtin");
const std = @import("std");
const Io = std.Io;
const Allocator = std.mem.Allocator;
const ziggy = @import("ziggy");
const Ast = ziggy.Ast;

const FileType = enum {
    ziggy,
    ziggy_schema,
    supermd,

    fn detect(basename: []const u8) ?FileType {
        const ext = std.fs.path.extension(basename);
        if (std.mem.eql(u8, ext, ".ziggy")) return .ziggy;
        if (std.mem.eql(u8, ext, ".ziggy-schema")) return .ziggy_schema;
        if (std.mem.eql(u8, ext, ".smd")) return .supermd;
        return null;
    }
};

pub fn run(io: Io, gpa: Allocator, args: []const []const u8) !void {
    const cmd = Command.parse(args);

    const ft: FileType = switch (cmd.mode) {
        .stdin => .ziggy,
        .stdin_supermd => .supermd,
        .stdin_schema => .ziggy_schema,
        .path => |path| FileType.detect(path) orelse fatal(
            "uknown file extension '{s}'",
            .{std.fs.path.extension(path)},
        ),
    };

    const file = switch (cmd.mode) {
        .stdin, .stdin_supermd, .stdin_schema => Io.File.stdin(),
        .path => |path| Io.Dir.cwd().openFile(io, path, .{}) catch |err| {
            fatal("unable to read file '{s}': {t}", .{ path, err });
        },
    };

    var file_reader = file.readerStreaming(io, &.{});
    const src_in = file_reader.interface.allocRemainingAlignedSentinel(
        gpa,
        .limited(ziggy.max_size),
        .of(u8),
        0,
    ) catch |err| fatal("unable to read file '{s}': {t}", .{ switch (cmd.mode) {
        .stdin, .stdin_supermd, .stdin_schema => "<stdin>",
        .path => |path| path,
    }, err });
    file.close(io);

    const escapes = blk: {
        Io.File.stdout().enableAnsiEscapeCodes(io) catch |err| {
            std.debug.print("no ansi: {t}", .{err});
            break :blk false;
        };
        break :blk true;
    };

    const mode: ziggy.RenderMode = if (cmd.html)
        .html
    else if (escapes)
        .terminal
    else
        .plain;

    const src_out = try switch (ft) {
        .ziggy => catZiggy(gpa, null, src_in, mode),
        .supermd => catSuperMD(gpa, null, src_in, mode),
        .ziggy_schema => catSchema(gpa, null, src_in, mode),
    };

    Io.File.stdout().writeStreamingAll(io, src_out) catch |err| {
        fatal("error writing to stdout: {t}", .{err});
    };
}

pub fn catSuperMD(
    gpa: Allocator,
    path: ?[]const u8,
    src: [:0]const u8,
    rm: ziggy.RenderMode,
) ![]const u8 {
    const ast = try Ast.init(gpa, src, .{
        .delimiter = .{
            .dashes = blk: {
                var t: ziggy.Tokenizer = .init(.{ .dashes = 0 });
                const start = t.next(src, true);
                break :blk switch (start.tag) {
                    .eod => start.loc.end,
                    else => 0,
                };
            },
        },
    });
    defer ast.deinit(gpa);

    if (ast.errors.len > 0) {
        _ = std.debug.lockStderr(&.{});
        for (ast.errors) |err| {
            const sel = err.main_location.getSelection(src);
            std.debug.print("{s}:{}:{} {f}\n", .{
                path orelse "<stdin>",
                sel.start.line,
                sel.start.col,
                err.tag,
            });
        }
        std.debug.unlockStderr();
    }

    if (ast.has_syntax_errors) return error.Syntax;

    return std.fmt.allocPrint(gpa, "{f}", .{ast.fmt(src, rm)});
}

pub fn catZiggy(
    gpa: Allocator,
    path: ?[]const u8,
    src: [:0]const u8,
    rm: ziggy.RenderMode,
) ![]const u8 {
    const ast = try Ast.init(gpa, src, .{});
    defer ast.deinit(gpa);

    if (ast.errors.len > 0) {
        _ = std.debug.lockStderr(&.{});
        for (ast.errors) |err| {
            if (err.tag == .wrong_field_style) continue;
            const sel = err.main_location.getSelection(src);
            std.debug.print("{s}:{}:{} {f}\n", .{
                path orelse "<stdin>",
                sel.start.line,
                sel.start.col,
                err.tag,
            });
        }
        std.debug.unlockStderr();
    }

    if (ast.has_syntax_errors) return error.Syntax;
    return std.fmt.allocPrint(gpa, "{f}\n", .{ast.fmt(src, rm)});
}

fn catSchema(
    gpa: Allocator,
    path: ?[]const u8,
    src: [:0]const u8,
    rm: ziggy.RenderMode,
) ![]const u8 {
    _ = rm;
    const ast = try ziggy.schema.Ast.init(gpa, src);
    defer ast.deinit(gpa);

    if (ast.errors.len > 0) {
        _ = std.debug.lockStderr(&.{});
        for (ast.errors) |err| {
            const sel = err.main_location.getSelection(src);
            std.debug.print("{s}:{}:{} {f}\n", .{
                path orelse "<stdin>",
                sel.start.line,
                sel.start.col,
                err.tag,
            });
        }
        std.debug.unlockStderr();
    }

    if (ast.has_syntax_errors) return error.Syntax;
    return std.fmt.allocPrint(gpa, "{f}", .{ast.fmt(src)});
}

pub const Command = struct {
    mode: Mode,
    html: bool,

    const Mode = union(enum) {
        stdin,
        stdin_schema,
        stdin_supermd,
        path: []const u8,
    };

    fn parse(args: []const []const u8) Command {
        var mode: ?Mode = null;
        var html: bool = false;

        var idx: usize = 0;
        while (idx < args.len) : (idx += 1) {
            const arg = args[idx];
            if (std.mem.eql(u8, arg, "--help") or
                std.mem.eql(u8, arg, "-h"))
            {
                fatalHelp();
            }

            if (std.mem.eql(u8, arg, "--html")) {
                if (html) {
                    std.debug.print("error: duplicate '--html' flag\n\n", .{});
                    std.process.exit(1);
                }

                html = true;
                continue;
            }

            // if (std.mem.eql(u8, arg, "--schema")) {
            //     if (schema != null) {
            //         std.debug.print("error: duplicate '--schema' option\n\n", .{});
            //         std.process.exit(1);
            //     }

            //     idx += 1;
            //     if (idx == args.len) {
            //         std.debug.print("error: missing '--schema' option value\n\n", .{});
            //         std.process.exit(1);
            //     }

            //     schema = args[idx];
            //     continue;
            // }

            if (std.mem.startsWith(u8, arg, "-")) {
                if (std.mem.eql(u8, arg, "--stdin") or
                    std.mem.eql(u8, arg, "-"))
                {
                    if (mode != null) {
                        std.debug.print("unexpected flag: '{s}'\n", .{arg});
                        std.process.exit(1);
                    }

                    mode = .stdin;
                } else if (std.mem.eql(u8, arg, "--stdin-supermd") or
                    std.mem.eql(u8, arg, "-"))
                {
                    if (mode != null) {
                        std.debug.print("unexpected flag: '{s}'\n", .{arg});
                        std.process.exit(1);
                    }

                    mode = .stdin_supermd;
                } else if (std.mem.eql(u8, arg, "--stdin-schema")) {
                    if (mode != null) {
                        std.debug.print("unexpected flag: '{s}'\n", .{arg});
                        std.process.exit(1);
                    }

                    mode = .stdin_schema;
                } else {
                    std.debug.print("unexpected flag: '{s}'\n", .{arg});
                    std.process.exit(1);
                }
            } else {
                if (mode != null) {
                    std.debug.print(
                        "unexpected path argument: '{s}'\n",
                        .{arg},
                    );
                    std.process.exit(1);
                }
                mode = .{ .path = arg };
            }
        }

        const m = mode orelse {
            std.debug.print("missing argument(s)\n\n", .{});
            fatalHelp();
        };

        return .{
            .mode = m,
            .html = html,
        };
    }

    fn fatalHelp() noreturn {
        std.debug.print(
            \\Usage: ziggy cat FILE [OPTIONS]
            \\
            \\Formats and optionally syntax-highlights FILE to stdout.
            \\Supports also outputting HTML syntax-highlighting.
            \\
            \\Detected extensions:
            \\     Ziggy         .ziggy
            \\     Ziggy Schema  .ziggy-schema
            \\     SuperMD       .smd
            \\
            \\NOTE: SuperMD support is temporary until a dedicated
            \\      CLI tool is created.
            \\
            \\Command specific options:
            \\  --html           Output syntax-highlighted HTML
            \\  --stdin          Format bytes from stdin and output to stdout
            \\                   Mutually exclusive with other input arguments
            \\  --stdin-schema   Same as --stdin but for Ziggy Schema files
            \\  --stdin-supermd  Same as --stdin but for SuperMD files
            \\  --help, -h       Print this menu and exit
            \\
            \\
        , .{});

        std.process.exit(1);
    }
};

fn fatal(comptime fmt: []const u8, args: anytype) noreturn {
    std.debug.print("fatal error: " ++ fmt ++ "\n", args);
    if (builtin.mode == .Debug) @breakpoint();
    std.process.exit(1);
}

fn oom() noreturn {
    fatal("out of memory", .{});
}
