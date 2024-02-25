const Document = @This();

const std = @import("std");
const assert = std.debug.assert;
const ziggy = @import("ziggy");

const log = std.log.scoped(.lsp_document);

arena: std.heap.ArenaAllocator,
bytes: [:0]const u8,
diagnostic: ziggy.Diagnostic,
ast: ?ziggy.Ast = null,
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

pub fn init(gpa: std.mem.Allocator, bytes: [:0]const u8) Document {
    var doc: Document = .{
        .arena = std.heap.ArenaAllocator.init(gpa),
        .bytes = bytes,
        .diagnostic = .{ .path = null },
    };

    const arena = doc.arena.allocator();

    log.debug("parsing ziggy ast", .{});
    const ast = ziggy.Ast.init(
        arena,
        bytes,
        true,
        &doc.diagnostic,
    ) catch return doc;

    if (doc.diagnostic.err != .none) return doc;

    log.debug("ziggy parsing ok, looking for schema", .{});

    const schema_path = findSchemaPath(ast, bytes) orelse return doc;
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
        doc.diagnostic.tok = .{
            .tag = .identifier,
            .loc = schema_path_loc,
        };
        doc.diagnostic.err = .{
            .schema = .{
                .err = err,
            },
        };

        return doc;
    };

    log.debug("schema: parsing", .{});
    const schema_ast = ziggy.schema.Ast.init(
        arena,
        schema_file,
        null,
    ) catch |err| {
        doc.diagnostic.tok = .{
            .tag = .identifier,
            .loc = schema_path_loc,
        };
        doc.diagnostic.err = .{
            .schema = .{ .err = err },
        };
        return doc;
    };

    log.debug("schema: analysis", .{});
    const rules = ziggy.schema.Schema.init(
        arena,
        schema_ast.nodes.items,
        schema_file,
        null,
    ) catch |err| {
        doc.diagnostic.tok = .{
            .tag = .identifier,
            .loc = schema_path_loc,
        };
        doc.diagnostic.err = .{
            .schema = .{ .err = err },
        };
        return doc;
    };

    doc.schema = .{
        .bytes = bytes,
        .ast = schema_ast,
        .rules = rules,
    };

    log.debug("schema: applying", .{});
    rules.check(gpa, schema_ast, ast, &doc.diagnostic) catch return doc;

    return doc;
}

fn findSchemaPath(ast: ziggy.Ast, bytes: [:0]const u8) ?[]const u8 {
    const top_comments = ast.nodes.items[1];
    if (top_comments.tag == .top_comment) {
        assert(top_comments.first_child_id != 0);
        const schema_line = ast.nodes.items[top_comments.first_child_id];
        const src = schema_line.loc.src(bytes);
        var it = std.mem.tokenizeScalar(u8, src, ' ');
        var state: enum { start, comment, schema, colon } = .start;
        while (it.next()) |tok| switch (state) {
            .start => {
                if (std.mem.eql(u8, tok, "//!")) {
                    state = .comment;
                } else if (std.mem.eql(u8, tok, "//!ziggy-schema")) {
                    state = .schema;
                } else if (std.mem.eql(u8, tok, "//!ziggy-schema:")) {
                    state = .colon;
                } else {
                    return null;
                }
            },
            .comment => {
                if (std.mem.eql(u8, tok, "ziggy-schema")) {
                    state = .schema;
                } else if (std.mem.eql(u8, tok, "ziggy-schema:")) {
                    state = .colon;
                } else {
                    return null;
                }
            },
            .schema => {
                if (std.mem.eql(u8, tok, ":")) {
                    state = .colon;
                } else {
                    return null;
                }
            },

            .colon => {
                return tok;
            },
        };
    }
    return null;
}
