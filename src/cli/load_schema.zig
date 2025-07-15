const std = @import("std");
const ziggy = @import("ziggy");

pub fn loadSchema(gpa: std.mem.Allocator, path: ?[]const u8) ziggy.schema.Schema {
    const p = path orelse return defaultSchema();

    var diag: ziggy.schema.Diagnostic = .{ .lsp = false, .path = p };

    const schema_file = std.fs.cwd().readFileAllocOptions(
        gpa,
        p,
        ziggy.max_size,
        null,
        .of(u8),
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
        std.debug.print("{f}\n", .{diag});
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
        std.debug.print("{f}\n", .{diag});
        std.process.exit(1);
    };

    return schema;
}

pub fn defaultSchema() ziggy.schema.Schema {
    return .{
        .root = .{ .node = 1 },
        .code = "unknown",
        .nodes = &.{
            .{
                .tag = .root,
                .loc = .{
                    .start = 0,
                    .end = "unknown".len,
                },
                .parent_id = 0,
            },
            .{
                .tag = .any,
                .loc = .{
                    .start = 0,
                    .end = "unknown".len,
                },
                .parent_id = 0,
            },
        },
    };
}
