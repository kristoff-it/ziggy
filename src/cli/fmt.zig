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

    try in.readAllArrayList(&buf, ziggy.max_size);

    const code = try buf.toOwnedSliceSentinel(0);

    var out_buffer = std.io.bufferedWriter(std.io.getStdOut().writer());
    const out = out_buffer.writer();

    switch (cmd.fmt_type) {
        .schema => {
            var diag: ziggy.schema.Diagnostic = .{ .path = null };
            const ast = ziggy.schema.Ast.init(gpa, code, &diag) catch {
                std.debug.print("{}", .{diag});
                std.process.exit(1);
            };

            try out.print("{}", .{ast});
        },
        .doc, .unset => {
            var diag: Diagnostic = .{ .path = null };
            const doc = try Ast.init(gpa, code, true, false, &diag);

            const schema = loadSchema(gpa, cmd.schema);

            try schema.check(gpa, doc, &diag, code);

            if (diag.errors.items.len != 0) {
                std.debug.print("{}", .{diag});
                std.process.exit(1);
            }

            try out.print("{}", .{doc});
        },
    }
    try out_buffer.flush();
}

fn loadSchema(gpa: std.mem.Allocator, path: ?[]const u8) ziggy.schema.Schema {
    const p = path orelse return defaultSchema();

    var diag: ziggy.schema.Diagnostic = .{ .path = p };

    const schema_file = std.fs.cwd().readFileAllocOptions(
        gpa,
        p,
        ziggy.max_size,
        null,
        1,
        0,
    ) catch |err| {
        std.debug.print("error while reading the --schema file: {s}\n\n", .{
            @errorName(err),
        });
        std.process.exit(1);
    };

    const schema_ast = ziggy.schema.Ast.init(
        gpa,
        schema_file,
        &diag,
    ) catch |err| {
        std.debug.print("error while parsing the --schema file: {s}\n\n", .{
            @errorName(err),
        });
        std.debug.print("{}\n", .{diag});
        std.process.exit(1);
    };

    const schema = ziggy.schema.Schema.init(
        gpa,
        schema_ast.nodes.items,
        schema_file,
        &diag,
    ) catch |err| {
        std.debug.print("error while parsing the --schema file: {s}\n\n", .{
            @errorName(err),
        });
        std.debug.print("{}\n", .{diag});
        std.process.exit(1);
    };

    return schema;
}

fn defaultSchema() ziggy.schema.Schema {
    return .{
        .root = .{ .node = 1 },
        .code = "any",
        .allows_unknown_literals = true,
        .nodes = &.{
            .{
                .tag = .root,
                .loc = .{
                    .start = 0,
                    .end = "any".len,
                },
                .parent_id = 0,
            },
            .{
                .tag = .any,
                .loc = .{
                    .start = 0,
                    .end = "any".len,
                },
                .parent_id = 0,
            },
        },
    };
}

pub const Command = struct {
    check: bool = false,
    schema: ?[]const u8 = null,
    fmt_type: FmtType = .unset,

    mode: union(enum) {
        unknown,
        stdin,
        paths: []const []const u8,
    } = .unknown,

    const FmtType = enum { unset, doc, schema };

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

            if (std.mem.eql(u8, arg, "--schema")) {
                if (cmd.schema != null) {
                    std.debug.print("error: duplicate '--schema' option\n\n", .{});
                    std.process.exit(1);
                }

                idx += 1;
                if (idx == args.len) {
                    std.debug.print("error: missing '--schema' option value\n\n", .{});
                    std.process.exit(1);
                }

                cmd.schema = args[idx];
                continue;
            }

            if (std.mem.eql(u8, arg, "--type")) {
                if (cmd.fmt_type != .unset) {
                    std.debug.print("error: duplicate '--type' option\n\n", .{});
                    std.process.exit(1);
                }

                idx += 1;
                if (idx == args.len) {
                    std.debug.print("error: missing '--type' option value\n\n", .{});
                    std.process.exit(1);
                }

                cmd.fmt_type = std.meta.stringToEnum(FmtType, args[idx]) orelse {
                    std.debug.print("error: invalid '--type' option value, expected 'doc' or 'schema'\n\n", .{});
                    std.process.exit(1);
                };
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

        if (cmd.fmt_type == .schema and cmd.schema != null) {
            std.debug.print("error: '--type schema' and --schema are mutually exclusive\n", .{});
            std.process.exit(1);
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
            \\--stdin, -         Format bytes from stdin and ouptut to stdout,
            \\                   defaults to assuming --type is 'doc'. Mutually
            \\                   exclusive with the presence of PATH arguments.    
            \\
            \\--type doc|schema  Sets the type of file(s) being formatted. When
            \\                   PATH is a file, the file extension will be 
            \\                   ignored. When PATH is a directory, makes the 
            \\                   command only format files of the corresponding
            \\                   type by checking their file extension.
            \\
            \\--schema PATH      Path to a Ziggy schema file that will be used
            \\                   to check all Ziggy doc files.
            \\                  
            \\--check            List non-conforming files and exit with an
            \\                   error if the list is not empty.
            \\
            \\--help, -h         Prints this help and extits.
        , .{});

        std.process.exit(1);
    }
};
