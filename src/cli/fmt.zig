const std = @import("std");
const ziggy = @import("ziggy");
const loadSchema = @import("load_schema.zig").loadSchema;
const Diagnostic = ziggy.Diagnostic;
const Ast = ziggy.Ast;

const FileType = enum { ziggy, ziggy_schema };

pub fn run(gpa: std.mem.Allocator, args: []const []const u8) !void {
    const cmd = Command.parse(args);
    const schema = loadSchema(gpa, cmd.schema);
    var any_error = false;
    switch (cmd.mode) {
        .stdin => {
            var fr = std.fs.File.stdin().reader(&.{});
            var aw: std.Io.Writer.Allocating = .init(gpa);
            _ = try fr.interface.streamRemaining(&aw.writer);
            const in_bytes = try aw.toOwnedSliceSentinel(0);

            const out_bytes = try fmtZiggy(gpa, null, in_bytes, schema);

            try std.fs.File.stdout().writeAll(out_bytes);
        },
        .stdin_schema => {
            var fr = std.fs.File.stdin().reader(&.{});
            var aw: std.Io.Writer.Allocating = .init(gpa);
            _ = try fr.interface.streamRemaining(&aw.writer);
            const in_bytes = try aw.toOwnedSliceSentinel(0);

            const out_bytes = try fmtSchema(gpa, null, in_bytes);

            try std.fs.File.stdout().writeAll(out_bytes);
        },
        .paths => |paths| {
            // checkFile will reset the arena at the end of each call
            var arena_impl = std.heap.ArenaAllocator.init(gpa);
            for (paths) |path| {
                formatFile(
                    &arena_impl,
                    cmd.check,
                    std.fs.cwd(),
                    path,
                    path,
                    schema,
                    &any_error,
                ) catch |err| switch (err) {
                    error.IsDir, error.AccessDenied => {
                        formatDir(
                            gpa,
                            &arena_impl,
                            cmd.check,
                            path,
                            schema,
                            &any_error,
                        ) catch |dir_err| {
                            std.debug.print("Error walking dir '{s}': {t}\n", .{
                                path,
                                dir_err,
                            });
                            std.process.exit(1);
                        };
                    },
                    else => {
                        std.debug.print("Error while accessing '{s}': {t}\n", .{
                            path, err,
                        });
                        std.process.exit(1);
                    },
                };
            }
        },
    }

    if (any_error) {
        std.process.exit(1);
    }
}

fn formatDir(
    gpa: std.mem.Allocator,
    arena_impl: *std.heap.ArenaAllocator,
    check: bool,
    path: []const u8,
    schema: ziggy.schema.Schema,
    any_error: *bool,
) !void {
    var dir = try std.fs.cwd().openDir(path, .{ .iterate = true });
    defer dir.close();
    var walker = dir.walk(gpa) catch oom();
    defer walker.deinit();
    while (try walker.next()) |item| {
        switch (item.kind) {
            .file => {
                try formatFile(
                    arena_impl,
                    check,
                    item.dir,
                    item.basename,
                    item.path,
                    schema,
                    any_error,
                );
            },
            else => {},
        }
    }
}

fn formatFile(
    arena_impl: *std.heap.ArenaAllocator,
    check: bool,
    base_dir: std.fs.Dir,
    sub_path: []const u8,
    full_path: []const u8,
    schema: ziggy.schema.Schema,
    any_error: *bool,
) !void {
    defer _ = arena_impl.reset(.retain_capacity);
    const arena = arena_impl.allocator();

    const in_bytes = try base_dir.readFileAllocOptions(
        arena,
        sub_path,
        ziggy.max_size,
        null,
        .of(u8),
        0,
    );

    const file_type: FileType = blk: {
        const ext = std.fs.path.extension(sub_path);
        if (std.mem.eql(u8, ext, ".ziggy") or
            std.mem.eql(u8, ext, ".zgy"))
        {
            break :blk .ziggy;
        }

        if (std.mem.eql(u8, ext, ".ziggy-schema") or
            std.mem.eql(u8, ext, ".zgy-schema"))
        {
            break :blk .ziggy_schema;
        }
        return;
    };

    const out_bytes = switch (file_type) {
        .ziggy => try fmtZiggy(
            arena,
            full_path,
            in_bytes,
            schema,
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

    if (check) {
        any_error.* = true;
        try stdout.print("{s}\n", .{full_path});
        return;
    }

    var af = try base_dir.atomicFile(sub_path, .{ .write_buffer = &.{} });
    defer af.deinit();

    try af.file_writer.interface.writeAll(out_bytes);
    try af.finish();
    try stdout.print("{s}\n", .{full_path});
}

pub fn fmtZiggy(
    gpa: std.mem.Allocator,
    path: ?[]const u8,
    code: [:0]const u8,
    schema: ziggy.schema.Schema,
) ![]const u8 {
    var diag: Diagnostic = .{ .path = path };
    const doc = Ast.init(gpa, code, true, false, false, &diag) catch {
        if (diag.errors.items.len != 0) {
            std.debug.print("{f}\n", .{diag.fmt(code)});
        }
        std.process.exit(1);
    };

    doc.check(gpa, schema, &diag) catch {
        if (diag.errors.items.len != 0) {
            std.debug.print("{f}\n", .{diag.fmt(code)});
        }
        std.process.exit(1);
    };

    return std.fmt.allocPrint(gpa, "{f}\n", .{doc});
}

fn fmtSchema(
    gpa: std.mem.Allocator,
    path: ?[]const u8,
    code: [:0]const u8,
) ![]const u8 {
    var diag: ziggy.schema.Diagnostic = .{ .lsp = false, .path = path };
    const ast = ziggy.schema.Ast.init(gpa, code, &diag) catch {
        std.debug.print("{f}\n", .{diag});
        std.process.exit(1);
    };

    return std.fmt.allocPrint(gpa, "{f}", .{ast});
}

fn oom() noreturn {
    std.debug.print("Out of memory\n", .{});
    std.process.exit(1);
}

pub const Command = struct {
    check: bool,
    schema: ?[]const u8,
    mode: Mode,

    const Mode = union(enum) {
        stdin,
        stdin_schema,
        paths: []const []const u8,
    };

    fn parse(args: []const []const u8) Command {
        var check: bool = false;
        var schema: ?[]const u8 = null;
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

            if (std.mem.eql(u8, arg, "--schema")) {
                if (schema != null) {
                    std.debug.print("error: duplicate '--schema' option\n\n", .{});
                    std.process.exit(1);
                }

                idx += 1;
                if (idx == args.len) {
                    std.debug.print("error: missing '--schema' option value\n\n", .{});
                    std.process.exit(1);
                }

                schema = args[idx];
                continue;
            }

            if (std.mem.startsWith(u8, arg, "-")) {
                if (std.mem.eql(u8, arg, "--stdin") or
                    std.mem.eql(u8, arg, "-"))
                {
                    if (mode != null) {
                        std.debug.print("unexpected flag: '{s}'\n", .{arg});
                        std.process.exit(1);
                    }

                    mode = .stdin;
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
            .schema = schema,
            .mode = m,
        };
    }

    fn fatalHelp() noreturn {
        std.debug.print(
            \\Usage: ziggy fmt PATH [PATH...] [OPTIONS]
            \\
            \\   Formats input paths inplace. If PATH is a directory, it will
            \\   be searched recursively for Ziggy and Ziggy Schema files.
            \\     
            \\   Detected extensions:     
            \\        Ziggy         .ziggy, .zgy  
            \\        Ziggy Schema  .ziggy-schema, .zgy-schema 
            \\
            \\Options:
            \\
            \\--stdin            Format bytes from stdin and ouptut to stdout. 
            \\                   Mutually exclusive with other input aguments.    
            \\
            \\--stdin-schema     Same as --stdin but for Ziggy Schema files.
            \\
            \\--schema PATH      Path to a Ziggy schema file used when formatting
            \\                   Ziggy files.
            \\                  
            \\--check            List non-conforming files and exit with an
            \\                   error if the list is not empty.
            \\
            \\--help, -h         Prints this help and extits.
        , .{});

        std.process.exit(1);
    }
};
