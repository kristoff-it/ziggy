const std = @import("std");
const ziggy = @import("ziggy");
const Diagnostic = ziggy.Diagnostic;
const Ast = ziggy.Ast;

pub fn run(gpa: std.mem.Allocator, args: []const []const u8) !void {
    const cmd = Command.parse(args);

    const schema_file = std.fs.cwd().readFileAllocOptions(
        gpa,
        cmd.schema_path,
        ziggy.max_size,
        null,
        1,
        0,
    ) catch |err| {
        std.debug.print("Error reading '{s}': {s}\n", .{
            cmd.schema_path,
            @errorName(err),
        });
        std.process.exit(1);
    };

    var schema_diag: ziggy.schema.Diagnostic = .{ .path = cmd.schema_path };
    const schema_ast = ziggy.schema.Ast.init(
        gpa,
        schema_file,
        &schema_diag,
    ) catch fatalDiag(schema_diag);
    const schema = ziggy.schema.Schema.init(
        gpa,
        schema_ast.nodes.items,
        schema_file,
        &schema_diag,
    ) catch fatalDiag(schema_diag);

    // checkFile will reset the arena at the end of the call
    var arena_impl = std.heap.ArenaAllocator.init(gpa);
    for (cmd.doc_paths) |path| {
        checkFile(&arena_impl, std.fs.cwd(), path, schema) catch |err| switch (err) {
            error.IsDir, error.AccessDenied => {
                checkDir(gpa, &arena_impl, path, schema) catch |dir_err| {
                    std.debug.print("Error walking dir '{s}': {s}\n", .{
                        path,
                        @errorName(dir_err),
                    });
                };
            },
            else => {
                std.debug.print("Error while accessing '{s}': {s}\n", .{
                    path, @errorName(err),
                });
            },
        };
    }
}

fn checkDir(
    gpa: std.mem.Allocator,
    arena_impl: *std.heap.ArenaAllocator,
    path: []const u8,
    schema: ziggy.schema.Schema,
) !void {
    var dir = try std.fs.cwd().openDir(path, .{ .iterate = true });
    defer dir.close();
    var walker = dir.walk(gpa) catch oom();
    defer walker.deinit();
    while (try walker.next()) |item| {
        switch (item.kind) {
            .file => {
                if (std.mem.endsWith(u8, item.basename, ".ziggy")) {
                    try checkFile(arena_impl, item.dir, item.basename, schema);
                }
            },
            else => {},
        }
    }
}

fn checkFile(
    arena_impl: *std.heap.ArenaAllocator,
    base_dir: std.fs.Dir,
    sub_path: []const u8,
    schema: ziggy.schema.Schema,
) !void {
    defer _ = arena_impl.reset(.retain_capacity);
    const arena = arena_impl.allocator();

    const doc_file = try base_dir.readFileAllocOptions(
        arena,
        sub_path,
        ziggy.max_size,
        null,
        1,
        0,
    );
    var diag: ziggy.Diagnostic = .{ .path = sub_path };
    const doc_ast = ziggy.Ast.init(
        arena,
        doc_file,
        true,
        true,
        &diag,
    ) catch fatalDiag(diag);

    doc_ast.check(arena, schema, &diag) catch fatalDiag(diag);
    std.debug.print("{}\n", .{diag});
}

fn fatalDiag(diag: anytype) noreturn {
    std.debug.print("{}\n", .{diag});
    std.process.exit(1);
}

fn oom() noreturn {
    std.debug.print("Out of memory\n", .{});
    std.process.exit(1);
}

pub const Command = struct {
    schema_path: []const u8,
    doc_paths: []const []const u8,

    fn parse(args: []const []const u8) Command {
        var idx: usize = 0;
        while (idx < args.len) : (idx += 1) {
            const arg = args[idx];
            if (std.mem.eql(u8, arg, "--help") or
                std.mem.eql(u8, arg, "-h"))
            {
                fatalHelp();
            }
        }

        if (args.len < 2) {
            std.debug.print("missing argument(s)\n\n", .{});
            fatalHelp();
        }

        const cmd: Command = .{
            .schema_path = args[0],
            .doc_paths = args[1..],
        };

        return cmd;
    }

    fn fatalHelp() noreturn {
        std.debug.print(
            \\Usage: ziggy check SCHEMA DOC [DOC...] [OPTIONS]
            \\
            \\   Checks input paths against a Ziggy Schema.
            \\   If DOC is a directory, it will be searched  
            \\   recursively for Ziggy files. 
            \\
            \\Options:
            \\
            \\--help, -h       Print this help and exit.
        , .{});

        std.process.exit(1);
    }
};
