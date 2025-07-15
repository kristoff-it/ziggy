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
frontmatter: bool,
ast: ?ziggy.LanguageServerAst.Tree = null,
schema: ?Schema,

pub fn deinit(doc: *Document) void {
    doc.arena.deinit();
}

pub fn init(
    gpa: std.mem.Allocator,
    src: [:0]const u8,
    frontmatter: bool,
    schema: ?Schema,
) error{OutOfMemory}!Document {
    const bytes = if (!frontmatter) src else blk: {
        var it = std.mem.tokenizeScalar(u8, src, '\n');

        if (it.next()) |first_line| {
            const eql = std.mem.eql;
            const trim = std.mem.trim;
            if (eql(u8, trim(u8, first_line, &std.ascii.whitespace), "---")) {
                while (it.next()) |close_line| {
                    if (eql(u8, trim(u8, close_line, &std.ascii.whitespace), "---")) {
                        break :blk try gpa.dupeZ(u8, src[0 .. it.index - close_line.len]);
                    }
                }

                // error.OpenFrontmatter;
            }
        }
        break :blk "";
    };

    log.debug("TRIMMED SRC = \n\n{s}\n\n", .{src});

    var doc: Document = .{
        .arena = std.heap.ArenaAllocator.init(gpa),
        .bytes = bytes,
        .frontmatter = frontmatter,
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
        frontmatter,
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
