const builtin = @import("builtin");
const std = @import("std");
const Allocator = std.mem.Allocator;
const Io = std.Io;
const assert = std.debug.assert;
const ziggy = @import("ziggy");
const Diagnostic = ziggy.Diagnostic;
const Ast = ziggy.Ast;

pub fn run(io: Io, gpa: Allocator, args: []const []const u8) !void {
    var cmd = Command.parse(args);

    switch (cmd.strategy) {
        .search => {},
        .provided => |*p| {
            const src = std.fs.cwd().readFileAllocOptions(
                p.path,
                gpa,
                .limited(ziggy.max_size),
                .of(u8),
                0,
            ) catch |err| fatal("unable to read '{s}': {t}", .{ p.path, err });

            const ast = ziggy.schema.Ast.init(gpa, src) catch oom();
            if (ast.errors.len > 0) {
                for (ast.errors) |err| {
                    const sel = err.main_location.getSelection(src);
                    std.debug.print("{s}:{}:{} {f}\n", .{
                        p.path,
                        sel.start.line,
                        sel.start.col,
                        err.tag,
                    });
                }
                fatal("provided schema file contains parsing errors", .{});
            }
            p.src = src;
            p.ast = ast;
        },
    }

    var any_error: std.atomic.Value(bool) = .init(false);
    for (cmd.paths) |path| {
        checkDir(io, gpa, &any_error, &cmd, path) catch |dir_err| {
            switch (dir_err) {
                error.NotDir, error.AccessDenied => {
                    checkFile(io, gpa, &any_error, &cmd, try gpa.dupe(u8, path));
                },
                else => fatal("unable to access '{s}': {t}", .{ path, dir_err }),
            }
        };
    }

    if (any_error.load(.monotonic)) std.process.exit(1);
    std.process.cleanExit();
}

fn checkDir(
    io: Io,
    gpa: Allocator,
    any_error: *std.atomic.Value(bool),
    cmd: *Command,
    path: []const u8,
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
                if (std.mem.endsWith(u8, item.basename, ".ziggy")) {
                    const file_path = try std.fs.path.join(gpa, &.{ path, item.path });
                    g.async(io, checkFile, .{ io, gpa, any_error, cmd, file_path });
                }
            },
            else => {},
        }
    }

    g.wait(io);
}

threadlocal var check_arena: std.heap.ArenaAllocator = if (!builtin.single_threaded) .init(
    std.heap.smp_allocator,
) else blk: {
    const Gpa = struct {
        var impl: std.heap.GeneralPurposeAllocator(.{}) = .init;
    };
    break :blk .init(Gpa.impl.allocator());
};

fn checkFile(
    io: Io,
    gpa: Allocator,
    any_error: *std.atomic.Value(bool),
    cmd: *Command,
    path: []const u8,
) void {
    defer if (cmd.strategy == .provided) gpa.free(path);
    checkFileFallible(io, gpa, &cmd.strategy, path) catch |err| switch (err) {
        error.OutOfMemory => oom(),
        error.ZiggyInvalid => any_error.store(true, .unordered),
        error.MissingSchema => if (!cmd.lenient) {
            any_error.store(true, .unordered);
            std.debug.print(
                "error: unable to find matching schema for document '{s}'\n",
                .{path},
            );
        },
        else => fatal("unable to access '{s}': {t}", .{ path, err }),
    };
}

fn checkFileFallible(
    io: Io,
    gpa: Allocator,
    strat: *Command.Strategy,
    path: []const u8,
) !void {
    defer _ = check_arena.reset(.retain_capacity);
    const arena = check_arena.allocator();

    const src = try std.fs.cwd().readFileAllocOptions(
        path,
        arena,
        .limited(ziggy.max_size),
        .of(u8),
        0,
    );

    const ast = try ziggy.Ast.init(arena, src, .{});
    if (ast.errors.len > 0) {
        std.debug.lockStdErr();
        for (ast.errors) |err| {
            const sel = err.main_location.getSelection(src);
            std.debug.print("{s}:{}:{} {f}\n", .{
                path,
                sel.start.line,
                sel.start.col,
                err.tag,
            });
        }
        std.debug.unlockStdErr();
        return error.ZiggyInvalid;
    }

    const schema_src, const schema_ast = switch (strat.*) {
        .provided => |p| .{ p.src, p.ast },
        .search => |*map| blk: {
            // Same name
            const schema_path = try std.fmt.allocPrint(arena, "{s}-schema", .{path});
            const schema_src = std.fs.cwd().readFileAllocOptions(
                schema_path,
                arena,
                .limited(ziggy.max_size),
                .of(u8),
                0,
            ) catch |err| switch (err) {
                error.FileNotFound => {
                    const match = try searchDotSchema(io, gpa, map, path);
                    break :blk .{ match.src, match.ast };
                },
                else => fatal("unable to access schema '{s}': {t}", .{ schema_path, err }),
            };

            const schema_ast = ziggy.schema.Ast.init(arena, schema_src) catch oom();
            if (schema_ast.errors.len > 0) {
                for (schema_ast.errors) |err| {
                    const sel = err.main_location.getSelection(schema_src);
                    std.debug.print("{s}:{}:{} {f}\n", .{
                        schema_path,
                        sel.start.line,
                        sel.start.col,
                        err.tag,
                    });
                }
                return error.ZiggyInvalid;
            }

            break :blk .{ schema_src, schema_ast };
        },
    };

    const errors = try schema_ast.validate(arena, schema_src, ast, src);
    if (errors.len > 0) {
        std.debug.lockStdErr();
        for (errors) |err| {
            const sel = err.main_location.getSelection(src);
            std.debug.print("{s}:{}:{} {f}\n", .{
                path,
                sel.start.line,
                sel.start.col,
                err.tag,
            });
        }
        std.debug.unlockStdErr();
        return error.ZiggyInvalid;
    }
}

pub const Match = struct {
    src: [:0]const u8,
    ast: ziggy.schema.Ast,
};

var lock: Io.Mutex = .init;
fn searchDotSchema(
    io: Io,
    gpa: Allocator,
    map: *std.StringHashMapUnmanaged(?Match),
    path: []const u8,
) !Match {
    try lock.lock(io);
    defer lock.unlock(io);

    const arena = check_arena.allocator();
    var path_dir = path;
    assert(std.mem.endsWith(u8, path_dir, ".ziggy"));
    while (true) {
        path_dir = std.fs.path.dirname(path_dir) orelse return error.MissingSchema;

        const gop = try map.getOrPut(gpa, path_dir);
        if (gop.found_existing) return gop.value_ptr.* orelse continue;
        gop.value_ptr.* = null;

        const path_schema = try std.fs.path.join(arena, &.{ path_dir, ".ziggy-schema" });
        defer arena.free(path_schema);

        const schema_src = std.fs.cwd().readFileAllocOptions(
            path_schema,
            gpa,
            .limited(ziggy.max_size),
            .of(u8),
            0,
        ) catch |err| switch (err) {
            error.FileNotFound => continue,
            else => fatal("unable to access schema '{s}': {t}", .{ path_schema, err }),
        };

        const schema_ast = ziggy.schema.Ast.init(gpa, schema_src) catch oom();
        if (schema_ast.errors.len > 0) {
            for (schema_ast.errors) |err| {
                const sel = err.main_location.getSelection(schema_src);
                std.debug.print("{s}:{}:{} {f}\n", .{
                    path_schema,
                    sel.start.line,
                    sel.start.col,
                    err.tag,
                });
            }
            fatal("found parsing errors in a dot ziggy schema file", .{});
        }

        gop.value_ptr.* = .{ .src = schema_src, .ast = schema_ast };
        return gop.value_ptr.*.?;
    }
}

pub const Command = struct {
    strategy: Strategy,
    lenient: bool,
    paths: []const []const u8,

    pub const Strategy = union(enum) {
        provided: struct {
            path: []const u8,
            src: [:0]const u8 = undefined,
            ast: ziggy.schema.Ast = undefined,
        },
        search: std.StringHashMapUnmanaged(?Match),
    };
    fn parse(args: []const []const u8) Command {
        var strategy: ?Strategy = null;
        var lenient: ?bool = null;
        var paths_start_idx: usize = 0;

        var idx: usize = 0;
        while (idx < args.len) : (idx += 1) {
            const arg = args[idx];
            if (std.mem.eql(u8, arg, "--help") or
                std.mem.eql(u8, arg, "-h"))
            {
                fatalHelp();
            }

            if (std.mem.startsWith(u8, arg, "--schema")) {
                if (strategy != null) fatal("duplicate '--schema' argument", .{});
                if (std.mem.eql(u8, arg, "--schema")) {
                    if (idx != 0) fatal("if present, '--schema' must be the first argument", .{});
                    idx += 1;
                    if (idx == args.len) fatal("missing argument to '--schema'", .{});
                    strategy = .{
                        .provided = .{ .path = args[idx] },
                    };
                    paths_start_idx = idx + 1;
                } else if (std.mem.startsWith(u8, arg, "--schema=")) {
                    if (idx != 0) fatal("if present, '--schema' must be the first argument", .{});
                    strategy = .{
                        .provided = .{ .path = args[idx]["--schema=".len..] },
                    };
                    paths_start_idx = idx + 1;
                }
            }

            if (std.mem.eql(u8, arg, "--lenient")) {
                if (idx != 0) fatal("if present, '--lenient' must be the first argument", .{});
                if (lenient != null) fatal("duplicate '--lenient' flag", .{});
                lenient = true;
                paths_start_idx = idx + 1;
            }
        }

        if (paths_start_idx == args.len) {
            std.debug.print("fatal error: missing PATH argument(s)\n\n", .{});
            fatalHelp();
        }

        const cmd: Command = .{
            .strategy = strategy orelse .{ .search = .empty },
            .lenient = lenient orelse false,
            .paths = args[paths_start_idx..],
        };
        assert(cmd.paths.len > 0);

        return cmd;
    }

    fn fatalHelp() noreturn {
        std.debug.print(
            \\Usage: ziggy check [--schema=PATH | --lenient]  PATH [PATH...]
            \\
            \\Check input paths for schema coherence.
            \\
            \\If PATH is a directory, it will be searched recursively
            \\for Ziggy Documents.
            \\
            \\You can optionally specify a Ziggy Schema that will be
            \\used for all found documents, or leave it unspecified
            \\to have the tool detect schemas automatically using the
            \\following logic: 
            \\
            \\  1. Schema file with the same name as the document
            \\     placed next to it, for example:
            \\          'foo.ziggy' => 'foo.ziggy-schema'
            \\
            \\  2. Schema file named '.ziggy-schema' in the same
            \\     directory, or any directory above (closest wins).
            \\
            \\Documents that contain syntax errors, that do not match
            \\their schema or for which there is no matching schema,
            \\will cause a non-zero exit code.
            \\
            \\Options:
            \\--schema PATH    Override schema detection and use the
            \\                 same schema for all documents. Must be
            \\                 the first agument if present (mutually
            \\                 exclusive with '--lenient').
            \\--lenient        Ignore Ziggy Documents for which there
            \\                 is no matching Ziggy Schema instead of
            \\                 reporting an error (a warning line 
            \\                 will still be printed). Must be the  
            \\                 first argument if present (mutually 
            \\                 exclusive with '--schema').
            \\--help, -h       Print this help and exit.
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
