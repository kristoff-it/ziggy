const Schema = @This();

const std = @import("std");
const assert = std.debug.assert;
const ziggy = @import("ziggy");

const log = std.log.scoped(.lsp_document);

arena: std.heap.ArenaAllocator,
bytes: [:0]const u8,
diagnostic: ziggy.schema.Diagnostic,
ast: ?ziggy.schema.Ast = null,
rules: ?ziggy.schema.Schema = null,

pub fn deinit(doc: *Schema) void {
    doc.arena.deinit();
}

pub fn init(gpa: std.mem.Allocator, bytes: [:0]const u8) Schema {
    var schema: Schema = .{
        .arena = std.heap.ArenaAllocator.init(gpa),
        .bytes = bytes,
        .diagnostic = .{ .path = null },
    };

    const arena = schema.arena.allocator();

    log.debug("schema: parsing", .{});
    const ast = ziggy.schema.Ast.init(arena, bytes, &schema.diagnostic) catch return schema;
    if (schema.diagnostic.err != .none) return schema;

    schema.ast = ast;

    log.debug("schema: analysis", .{});
    const rules = ziggy.schema.Schema.init(
        arena,
        ast.nodes.items,
        bytes,
        &schema.diagnostic,
    ) catch return schema;

    schema.rules = rules;

    log.debug("schema: done", .{});
    return schema;
}
