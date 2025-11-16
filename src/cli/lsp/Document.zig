const Document = @This();

const std = @import("std");
const Allocator = std.mem.Allocator;
const assert = std.debug.assert;
const ziggy = @import("ziggy");
const Token = ziggy.Tokenizer.Token;
const Schema = @import("Schema.zig");
const Language = @import("logic.zig").Language;

const log = std.log.scoped(.lsp_document);

src: [:0]const u8,
ast: ziggy.Ast,
schema_uri: ?[]const u8 = null,
language: Language,

pub fn deinit(doc: *const Document, gpa: Allocator) void {
    doc.ast.deinit(gpa);
    gpa.free(doc.src);
}

pub fn init(
    gpa: Allocator,
    language: Language,
    src: [:0]const u8,
) error{OutOfMemory}!Document {
    return .{
        .src = src,
        .language = language,
        .ast = try .init(gpa, src, .{
            .delimiter = switch (language) {
                .ziggy_schema => unreachable,
                .ziggy => .none,
                .supermd => blk: {
                    var t: ziggy.Tokenizer = .init(.{ .dashes = 0 });
                    const start = t.next(src, true);
                    break :blk switch (start.tag) {
                        .eod => .{ .dashes = start.loc.end },
                        else => .{ .dashes = 0 },
                    };
                },
            },
        }),
    };
}
