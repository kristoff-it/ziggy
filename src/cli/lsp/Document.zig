const Document = @This();

const std = @import("std");
const assert = std.debug.assert;
const ziggy = @import("ziggy");
const Token = ziggy.Tokenizer.Token;
const Schema = @import("Schema.zig");

const log = std.log.scoped(.lsp_document);

arena: std.heap.ArenaAllocator,
bytes: [:0]const u8,
diagnostic: ziggy.Diagnostic,
ast: ?if (ziggy.lsp_parser == .recover) ziggy.LanguageServerAst else ziggy.LanguageServerAst.Tree = null,
schema: ?Schema,

pub fn deinit(doc: *Document) void {
    doc.arena.deinit();
}

pub fn init(
    gpa: std.mem.Allocator,
    bytes: [:0]const u8,
    schema: ?Schema,
) error{OutOfMemory}!Document {
    var doc: Document = .{
        .arena = std.heap.ArenaAllocator.init(gpa),
        .bytes = bytes,
        .diagnostic = .{ .path = null },
        .schema = schema,
    };

    const arena = doc.arena.allocator();

    if (schema) |s| {
        if (s.diagnostic.err != .none) {
            try doc.diagnostic.errors.append(arena, .{
                .schema = .{
                    .sel = (Token.Loc{ .start = 0, .end = @intCast(bytes.len) }).getSelection(bytes),
                    .err = @tagName(s.diagnostic.err),
                },
            });
            return doc;
        }
    }

    log.debug("parsing ziggy ast", .{});
    var ast = ziggy.LanguageServerAst.init(
        arena,
        bytes,
        true,
        &doc.diagnostic,
    ) catch return doc;

    log.debug("schema: applying", .{});

    if (schema) |s| {
        if (s.rules) |rules| {
            ast.check(arena, rules, &doc.diagnostic, bytes) catch return doc;
        }
    }
    doc.ast = ast;

    return doc;
}
