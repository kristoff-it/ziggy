const Schema = @This();

const std = @import("std");
const Allocator = std.mem.Allocator;
const fatal = std.process.fatal;
const assert = std.debug.assert;
const ziggy = @import("ziggy");

const log = std.log.scoped(.lsp_document);

src: [:0]const u8,
ast: ziggy.schema.Ast,
// didOpen / didClose, we keep schemas around even when closed if there are
// documents referencing them
open: bool,
// Number of Documents referencing this schema
refs: usize = 0,

pub fn deinit(schema: *const Schema, gpa: Allocator) void {
    schema.ast.deinit(gpa);
    gpa.free(schema.src);
}

pub fn init(gpa: Allocator, src: [:0]const u8, open: bool) Schema {
    return .{
        .src = src,
        .ast = ziggy.schema.Ast.init(gpa, src) catch fatal("oom", .{}),
        .open = open,
    };
}
