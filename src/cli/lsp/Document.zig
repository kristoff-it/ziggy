const Document = @This();

const std = @import("std");
const Allocator = std.mem.Allocator;
const assert = std.debug.assert;
const ziggy = @import("ziggy");
const Token = ziggy.Tokenizer.Token;
const Schema = @import("Schema.zig");

const log = std.log.scoped(.lsp_document);

src: [:0]const u8,
ast: ziggy.Ast,
schema_uri: ?[]const u8 = null,

pub fn deinit(doc: *const Document, gpa: Allocator) void {
    doc.ast.deinit(gpa);
    gpa.free(doc.src);
}

pub fn init(
    gpa: std.mem.Allocator,
    src: [:0]const u8,
) error{OutOfMemory}!Document {
    return .{
        .src = src,
        .ast = try .init(gpa, src, .{}),
    };
}
