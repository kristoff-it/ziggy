const Document = @This();

const std = @import("std");
const assert = std.debug.assert;
const ziggy = @import("ziggy");

const log = std.log.scoped(.lsp_document);

arena: std.heap.ArenaAllocator,
bytes: [:0]const u8,
diagnostic: ziggy.Diagnostic,
ast: ?ziggy.LanguageServerAst = null,
schema_path_loc: ?ziggy.Tokenizer.Token.Loc = null,
schema: ?LoadedSchema = null,

const LoadedSchema = struct {
    bytes: [:0]const u8,
    ast: ziggy.schema.Ast,
    rules: ziggy.schema.Schema,
};

pub fn deinit(doc: *Document) void {
    doc.arena.deinit();
}

pub fn init(gpa: std.mem.Allocator, bytes: [:0]const u8) error{OutOfMemory}!Document {
    var doc: Document = .{
        .arena = std.heap.ArenaAllocator.init(gpa),
        .bytes = bytes,
        .diagnostic = .{ .path = null },
    };

    const arena = doc.arena.allocator();

    log.debug("parsing ziggy ast", .{});
    const ast = ziggy.LanguageServerAst.init(
        arena,
        bytes,
        true,
        &doc.diagnostic,
    ) catch return doc;

    const schema_path = ast.findSchemaPath(bytes) orelse return doc;
    log.debug("detected schema: '{s}'", .{schema_path});

    const start_byte: u32 = @intCast(std.mem.indexOf(u8, bytes, schema_path).?);
    const schema_path_loc: ziggy.Tokenizer.Token.Loc = .{
        .start = start_byte,
        .end = @intCast(start_byte + schema_path.len),
    };
    doc.schema_path_loc = schema_path_loc;

    const schema_file = std.fs.cwd().readFileAllocOptions(
        arena,
        schema_path,
        1024 * 1024 * 1024,
        null,
        1,
        0,
    ) catch |err| {
        try doc.diagnostic.errors.append(arena, .{
            .schema = .{
                .loc = schema_path_loc,
                .err = err,
            },
        });
        return doc;
    };

    log.debug("schema: parsing", .{});
    const schema_ast = ziggy.schema.Ast.init(
        arena,
        schema_file,
        null,
    ) catch |err| {
        try doc.diagnostic.errors.append(arena, .{
            .schema = .{
                .loc = schema_path_loc,
                .err = err,
            },
        });

        return doc;
    };

    log.debug("schema: analysis", .{});
    const rules = ziggy.schema.Schema.init(
        arena,
        schema_ast.nodes.items,
        schema_file,
        null,
    ) catch |err| {
        try doc.diagnostic.errors.append(arena, .{
            .schema = .{
                .loc = schema_path_loc,
                .err = err,
            },
        });

        return doc;
    };

    doc.schema = .{
        .bytes = schema_file,
        .ast = schema_ast,
        .rules = rules,
    };

    log.debug("schema: applying", .{});
    ast.check(arena, rules, &doc.diagnostic, bytes) catch return doc;

    return doc;
}
