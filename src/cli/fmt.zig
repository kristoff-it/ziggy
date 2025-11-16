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
    var any_error: std.atomic.Value(bool) = .init(false);
    switch (cmd.mode) {
        .stdin => {
            var fr = Io.File.stdin().reader(io, &.{});
            var aw: std.Io.Writer.Allocating = .init(gpa);
            _ = try fr.interface.streamRemaining(&aw.writer);
            const in_bytes = try aw.toOwnedSliceSentinel(0);

            const out_bytes = try fmtZiggy(gpa, null, in_bytes);

            try std.fs.File.stdout().writeAll(out_bytes);
        },
        .stdin_supermd => {
            var fr = Io.File.stdin().reader(io, &.{});
            var aw: std.Io.Writer.Allocating = .init(gpa);
            _ = try fr.interface.streamRemaining(&aw.writer);
            const in_bytes = try aw.toOwnedSliceSentinel(0);

            const out_bytes = try fmtSuperMD(gpa, null, in_bytes);

            try std.fs.File.stdout().writeAll(out_bytes);
        },
        .stdin_schema => {
            var fr = Io.File.stdin().reader(io, &.{});
            var aw: std.Io.Writer.Allocating = .init(gpa);
            _ = try fr.interface.streamRemaining(&aw.writer);
            const in_bytes = try aw.toOwnedSliceSentinel(0);

            const out_bytes = try fmtSchema(gpa, null, in_bytes);

            try std.fs.File.stdout().writeAll(out_bytes);
        },
        .paths => |paths| {
            for (paths) |path| {
                formatDir(io, gpa, cmd.check, path, &any_error) catch |err| switch (err) {
                    error.NotDir, error.AccessDenied => {
                        const ft = FileType.detect(path) orelse {
                            std.debug.print(
                                "error: path argument '{s}' is not a directory nor a ziggy / ziggy-schema file\n",
                                .{path},
                            );
                            continue;
                        };
                        formatFile(gpa, cmd.check, try gpa.dupe(u8, path), ft, &any_error);
                    },
                    else => fatal("unable to open '{s}' as directory: {t}", .{ path, err }),
                };
            }
        },
    }

    if (any_error.load(.monotonic)) {
        std.process.exit(1);
    }
}

fn formatDir(
    io: Io,
    gpa: Allocator,
    check: bool,
    path: []const u8,
    any_error: *std.atomic.Value(bool),
) !void {
    var dir = try std.fs.cwd().openDir(path, .{ .iterate = true });
    defer dir.close();
    var walker = dir.walk(gpa) catch oom();
    defer walker.deinit();

    var g: Io.Group = .init;
    defer g.cancel(io);

    while (try walker.next()) |item| {
        switch (item.kind) {
            .file => {
                const ft = FileType.detect(item.basename) orelse continue;
                const file_path = try std.fs.path.join(gpa, &.{ path, item.path });
                g.async(io, formatFile, .{
                    gpa,
                    check,
                    file_path,
                    ft,
                    any_error,
                });
            },
            else => {},
        }
    }

    g.wait(io);
}

fn formatFile(
    gpa: Allocator,
    check: bool,
    full_path: []const u8,
    ft: FileType,
    any_error: *std.atomic.Value(bool),
) void {
    defer gpa.free(full_path);
    formatFileFallible(check, full_path, ft, any_error) catch |err| switch (err) {
        error.OutOfMemory => oom(),
        error.Syntax => any_error.store(true, .unordered),
        else => fatal("unable to access '{s}': {t}", .{
            full_path,
            err,
        }),
    };
}

threadlocal var format_arena: std.heap.ArenaAllocator = if (!builtin.single_threaded) .init(
    std.heap.smp_allocator,
) else blk: {
    const Gpa = struct {
        var impl: std.heap.GeneralPurposeAllocator(.{}) = .init;
    };
    break :blk .init(Gpa.impl.allocator());
};

/// Don't call this, call `formatFile`
fn formatFileFallible(
    check: bool,
    full_path: []const u8,
    ft: FileType,
    any_error: *std.atomic.Value(bool),
) !void {
    defer _ = format_arena.reset(.retain_capacity);
    const arena = format_arena.allocator();

    const in_bytes = try std.fs.cwd().readFileAllocOptions(
        full_path,
        arena,
        .limited(ziggy.max_size),
        .of(u8),
        0,
    );

    const out_bytes = switch (ft) {
        .supermd => try fmtSuperMD(
            arena,
            full_path,
            in_bytes,
        ),
        .ziggy => try fmtZiggy(
            arena,
            full_path,
            in_bytes,
        ),
        .ziggy_schema => try fmtSchema(
            arena,
            full_path,
            in_bytes,
        ),
    };

    if (std.mem.eql(u8, out_bytes, in_bytes)) return;

    var stdout_writer = std.fs.File.stdout().writer(&.{});
    const stdout = &stdout_writer.interface;

    if (check) any_error.store(true, .unordered) else {
        var af = try std.fs.cwd().atomicFile(full_path, .{ .write_buffer = &.{} });
        defer af.deinit();
        try af.file_writer.interface.writeAll(out_bytes);
        try af.finish();
    }

    std.debug.lockStdErr();
    defer std.debug.unlockStdErr();
    try stdout.print("{s}\n", .{full_path});
}

pub fn fmtSuperMD(
    gpa: Allocator,
    path: ?[]const u8,
    src: [:0]const u8,
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
        std.debug.lockStdErr();
        for (ast.errors) |err| {
            const sel = err.main_location.getSelection(src);
            std.debug.print("{s}:{}:{} {f}\n", .{
                path orelse "<stdin>",
                sel.start.line,
                sel.start.col,
                err.tag,
            });
        }
        std.debug.unlockStdErr();
    }

    if (ast.has_syntax_errors) return error.Syntax;

    return std.fmt.allocPrint(gpa, "{f}\n", .{ast.fmt(src)});
}

pub fn fmtZiggy(
    gpa: Allocator,
    path: ?[]const u8,
    src: [:0]const u8,
) ![]const u8 {
    const ast = try Ast.init(gpa, src, .{});
    defer ast.deinit(gpa);

    if (ast.errors.len > 0) {
        std.debug.lockStdErr();
        for (ast.errors) |err| {
            const sel = err.main_location.getSelection(src);
            std.debug.print("{s}:{}:{} {f}\n", .{
                path orelse "<stdin>",
                sel.start.line,
                sel.start.col,
                err.tag,
            });
        }
        std.debug.unlockStdErr();
    }

    if (ast.has_syntax_errors) return error.Syntax;

    return std.fmt.allocPrint(gpa, "{f}\n", .{ast.fmt(src)});
}

fn fmtSchema(
    gpa: Allocator,
    path: ?[]const u8,
    src: [:0]const u8,
) ![]const u8 {
    const ast = try ziggy.schema.Ast.init(gpa, src);
    defer ast.deinit(gpa);

    if (ast.errors.len > 0) {
        std.debug.lockStdErr();
        for (ast.errors) |err| {
            const sel = err.main_location.getSelection(src);
            std.debug.print("{s}:{}:{} {f}\n", .{
                path orelse "<stdin>",
                sel.start.line,
                sel.start.col,
                err.tag,
            });
        }
        std.debug.unlockStdErr();
    }

    if (ast.has_syntax_errors) return error.Syntax;
    return std.fmt.allocPrint(gpa, "{f}", .{ast.fmt(src)});
}

pub const Command = struct {
    check: bool,
    mode: Mode,

    const Mode = union(enum) {
        stdin,
        stdin_schema,
        stdin_supermd,
        paths: []const []const u8,
    };

    fn parse(args: []const []const u8) Command {
        var check: bool = false;
        var mode: ?Mode = null;

        var idx: usize = 0;
        while (idx < args.len) : (idx += 1) {
            const arg = args[idx];
            if (std.mem.eql(u8, arg, "--help") or
                std.mem.eql(u8, arg, "-h"))
            {
                fatalHelp();
            }

            if (std.mem.eql(u8, arg, "--check")) {
                if (check) {
                    std.debug.print("error: duplicate '--check' flag\n\n", .{});
                    std.process.exit(1);
                }

                check = true;
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
                const paths_start = idx;
                while (idx < args.len) : (idx += 1) {
                    if (std.mem.startsWith(u8, args[idx], "-")) {
                        break;
                    }
                }
                idx -= 1;

                if (mode != null) {
                    std.debug.print(
                        "unexpected path argument(s): '{s}'...\n",
                        .{args[paths_start]},
                    );
                    std.process.exit(1);
                }

                const paths = args[paths_start .. idx + 1];
                mode = .{ .paths = paths };
            }
        }

        const m = mode orelse {
            std.debug.print("missing argument(s)\n\n", .{});
            fatalHelp();
        };

        return .{
            .check = check,
            .mode = m,
        };
    }

    fn fatalHelp() noreturn {
        std.debug.print(
            \\Usage: ziggy fmt PATH [PATH...] [OPTIONS]
            \\
            \\Formats input paths inplace. If PATH is a directory, it will
            \\be searched recursively for Ziggy and Ziggy Schema files.
            \\     
            \\Detected extensions:     
            \\     Ziggy         .ziggy  
            \\     Ziggy Schema  .ziggy-schema 
            \\     SuperMD       .supermd  
            \\
            \\NOTE: SuperMD support is temporary until a dedicated
            \\      CLI tool is created.
            \\
            \\Options:
            \\
            \\--stdin            Format bytes from stdin and ouptut to stdout. 
            \\                   Mutually exclusive with other input aguments.    
            \\
            \\--stdin-schema     Same as --stdin but for Ziggy Schema files.
            \\
            \\--stdin-supermd     Same as --stdin but for SuperMD files.
            \\
            \\--check            List non-conforming files and exit with an
            \\                   error if the list is not empty.
            \\
            \\--help, -h         Prints this help and exits.
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
