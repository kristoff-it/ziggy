const Parser = @This();

gpa: std.mem.Allocator,
code: [:0]const u8,
tokenizer: Tokenizer,
// diagnostic: ?*Diagnostic,
fuel: u32,
events: std.ArrayListUnmanaged(Event) = .{},
filepath: ?[]const u8,

const std = @import("std");
const mem = std.mem;
const assert = std.debug.assert;
const Diagnostic = @import("Diagnostic.zig");
const Tokenizer = @import("Tokenizer.zig");
const Token = Tokenizer.Token;

pub const Tree = struct {
    tag: Tree.Tag,
    children: std.ArrayListUnmanaged(Child) = .{},

    pub const Tag = enum {
        err,
        document,
        top_level_struct,
        @"struct",
        struct_field,
        array,
        map,
        string,
        line_string,
        tag_string,
        integer,
        float,
        true,
        false,
        null,
    };

    pub fn deinit(t: *Tree, gpa: mem.Allocator) void {
        for (t.children.items) |*child| child.deinit(gpa);
        t.children.deinit(gpa);
    }

    pub fn fmt(t: Tree, code: [:0]const u8) TreeFmt {
        return .{ .code = code, .tree = t };
    }
};

pub const TreeFmt = struct {
    code: [:0]const u8,
    tree: Tree,

    pub fn format(
        tfmt: TreeFmt,
        comptime fmt_str: []const u8,
        options: std.fmt.FormatOptions,
        writer: anytype,
    ) !void {
        _ = options;
        if (mem.eql(u8, fmt_str, "pretty"))
            try tfmt.prettyPrint(writer, 0, false)
        else
            try tfmt.dump(writer, 0);
    }

    fn prettyPrintToken(
        tfmt: TreeFmt,
        token: Token,
        indent: u8,
        i: usize,
        has_trailing_comma: bool,
        writer: anytype,
    ) !void {
        switch (token.tag) {
            .identifier, .string, .integer, .float => {
                try writer.writeAll(token.loc.src(tfmt.code));
            },
            .comment, .top_comment_line => {
                try writer.writeAll(token.loc.src(tfmt.code));
                try writer.writeByte('\n');
            },
            .line_string => {
                try writer.writeByte('\n');
                try writer.writeByteNTimes(' ', indent * 4);
                try writer.writeAll(token.loc.src(tfmt.code));
                if (i + 1 == tfmt.tree.children.items.len) {
                    try writer.writeByte('\n');
                    try writer.writeByteNTimes(' ', indent * 4);
                }
            },
            else => {
                const space = token.tag == .eql;
                if (space) try writer.writeByte(' ');
                try writer.writeAll(token.tag.lexeme());
                if (has_trailing_comma and
                    (token.tag == .lsb or token.tag == .lb or token.tag == .comma))
                {
                    try writer.writeByte('\n');
                    const unindent = token.tag == .comma and
                        i + 1 < tfmt.tree.children.items.len and
                        tfmt.tree.children.items[i + 1] == .token and
                        (tfmt.tree.children.items[i + 1].token.tag == .rsb or
                        tfmt.tree.children.items[i + 1].token.tag == .rb);
                    const new_indent = (indent -| @intFromBool(unindent)) * 4;
                    try writer.writeByteNTimes(' ', new_indent);
                } else if (tfmt.tree.tag == .top_level_struct) {
                    try writer.writeByte('\n');
                } else {
                    const trailing_space =
                        token.tag == .comma or token.tag == .colon;
                    if (space or trailing_space) try writer.writeByte(' ');
                }
            },
        }
    }

    fn prettyPrint(
        tfmt: TreeFmt,
        writer: anytype,
        indent: u8,
        has_trailing_comma: bool,
    ) !void {
        var i: usize = 0;
        while (i < tfmt.tree.children.items.len) : (i += 1) {
            const child = tfmt.tree.children.items[i];
            switch (child) {
                .token => |token| try tfmt.prettyPrintToken(
                    token,
                    indent,
                    i,
                    has_trailing_comma,
                    writer,
                ),
                .tree => |tree| {
                    const mlast_child = if (tree.children.items.len < 2)
                        null
                    else
                        tree.children.items[tree.children.items.len - 2];

                    const is_container =
                        tree.tag == .array or
                        tree.tag == .@"struct" or
                        tree.tag == .map;

                    const _has_trailing_comma = is_container and
                        if (mlast_child) |last_child|
                        last_child == .token and last_child.token.tag == .comma
                    else
                        false;

                    const additional_indent = @intFromBool(_has_trailing_comma);
                    const sub_tfmt = TreeFmt{ .tree = tree, .code = tfmt.code };
                    try sub_tfmt.prettyPrint(
                        writer,
                        indent + additional_indent,
                        _has_trailing_comma,
                    );
                },
            }
        }
    }

    fn dump(tfmt: TreeFmt, writer: anytype, indent: usize) !void {
        try writer.writeByteNTimes(' ', indent * 2);
        _ = try writer.write(@tagName(tfmt.tree.tag));
        try writer.writeByte('\n');
        for (tfmt.tree.children.items) |child| {
            switch (child) {
                .token => |token| {
                    try writer.writeByteNTimes(' ', indent * 2);
                    try writer.print(
                        "  '{s}' {}:{}\n",
                        .{ token.loc.src(tfmt.code), token.loc.start, token.loc.end },
                    );
                },
                .tree => |tree| {
                    const sub_tfmt = TreeFmt{ .tree = tree, .code = tfmt.code };
                    try sub_tfmt.dump(writer, indent + 1);
                },
            }
        }
    }
};

const Child = union(enum) {
    token: Token,
    tree: Tree,

    pub fn deinit(c: *Child, gpa: mem.Allocator) void {
        if (c.* == .tree) c.tree.deinit(gpa);
    }
};

const Event = union(enum) {
    open: Tree.Tag,
    close,
    advance,
};

pub const MarkOpened = enum(usize) {
    _,
    pub fn toClosed(m: MarkOpened) MarkClosed {
        return @enumFromInt(m.toInt());
    }
    pub fn toInt(m: MarkOpened) usize {
        return @intFromEnum(m);
    }
};

pub const MarkClosed = enum(usize) {
    _,
    pub fn toOpened(m: MarkClosed) MarkOpened {
        return @enumFromInt(m.toInt());
    }
    pub fn toInt(m: MarkClosed) usize {
        return @intFromEnum(m);
    }
};

pub fn parse(
    gpa: std.mem.Allocator,
    code: [:0]const u8,
    // TODO maybe handle diagnostic
    // diagnostic: ?*Diagnostic,
    mode: enum { want_comments, no_comments },
    filepath: ?[]const u8,
) !Tree {
    var p = Parser{
        .gpa = gpa,
        .code = code,
        // .diagnostic = diagnostic,
        .fuel = 256,
        .filepath = filepath,
        .tokenizer = .{ .want_comments = mode == .want_comments },
    };
    defer p.deinit();
    p.document();
    return p.buildTree();
}

pub fn deinit(p: *Parser) void {
    p.events.deinit(p.gpa);
}

/// document = top_comment* (top_level_struct | value)?
fn document(p: *Parser) void {
    const m = p.open();
    while (p.consume(.top_comment_line)) {}

    while (true) {
        switch (p.peek(0).tag) {
            .eof => break,
            .dot, .comment => p.topLevelStruct(),
            .lb,
            .lsb,
            .at,
            .string,
            .line_string,
            .float,
            .integer,
            .true,
            .false,
            .null,
            => p.value(),
            else => p.advanceWithError("expected a top level struct or value"),
        }
    }

    _ = p.close(m, .document);
}

/// ('//' .?* '\n')*
fn comments(p: *Parser) void {
    while (p.consume(.comment)) {}
}

/// top_level_struct = struct_field (',' struct_field)* ','? comment*
fn topLevelStruct(p: *Parser) void {
    const m = p.open();
    p.structField();

    // note: we must check for eof AFTER eating a comma so that we don't
    // continue parsing struct fields after a final trailing comma
    while (p.consume(.comma) and !p.eof()) {
        p.structField();
    }

    _ = p.consume(.comma);
    p.comments();
    _ = p.close(m, .top_level_struct);
}

/// struct_field = comment* '.' identifier '=' value
fn structField(p: *Parser) void {
    const m = p.open();
    p.comments();
    p.expect(.dot);
    p.expect(.identifier);
    p.expect(.eql);
    p.value();
    _ = p.close(m, .struct_field);
}

/// value =
///   struct | map | array | tag_string | string | float
/// | integer | true | false | null
fn value(p: *Parser) void {
    std.log.debug("value {s}", .{@tagName(p.peek(0).tag)});
    const m = p.open();
    switch (p.peek(0).tag) {
        .lb => {
            switch (p.peek(1).tag) {
                .dot => {
                    p.struct_();
                    _ = p.close(m, .@"struct");
                },
                .string => {
                    p.map();
                    _ = p.close(m, .map);
                },
                else => p.advanceWithErrorNoOpen(m, "expected map or struct"),
            }
        },
        .lsb => {
            p.array();
            _ = p.close(m, .array);
        },
        .at => {
            p.tagString();
            _ = p.close(m, .tag_string);
        },
        .string => {
            p.advance();
            _ = p.close(m, .string);
        },
        .line_string => {
            p.advance();
            while (p.consume(.line_string)) {}
            _ = p.close(m, .line_string);
        },
        .integer => {
            p.advance();
            _ = p.close(m, .integer);
        },
        .float => {
            p.advance();
            _ = p.close(m, .float);
        },
        .true => {
            p.advance();
            _ = p.close(m, .true);
        },
        .false => {
            p.advance();
            _ = p.close(m, .false);
        },
        .null => {
            p.advance();
            _ = p.close(m, .null);
        },
        else => p.advanceWithErrorNoOpen(m, "expected a value"),
    }
}

/// tag_string = '@' identifier '(' string ')'
fn tagString(p: *Parser) void {
    const m = p.open();
    p.expect(.at);
    p.expect(.identifier);
    p.expect(.lp);
    p.expect(.string);
    p.expect(.rp);
    _ = p.close(m, .tag_string);
}

/// array = '[' (array_elem,  (',' array_elem)*)? ','? comment* ']'
/// array_elem = comment* value
fn array(p: *Parser) void {
    // mark open/close is handled in value()
    p.expect(.lsb);

    while (!p.atAny(&.{ .rsb, .eof })) {
        p.comments();
        p.value();
        if (!p.consume(.comma)) break;
    }

    _ = p.consume(.comma);
    p.comments();
    p.expect(.rsb);
}

/// struct = struct_name? '{' (struct_field,  (',' struct_field)* )? comment* '}'
fn struct_(p: *Parser) void {
    // mark open/close is handled in value()
    _ = p.consume(.identifier);
    p.expect(.lb);

    while (!p.atAny(&.{ .rb, .eof })) {
        p.structField();
        if (!p.consume(.comma)) break;
    }

    _ = p.consume(.comma);
    p.comments();
    p.expect(.rb);
}

/// map = '{' (map_field,  (',' map_field)* )? comment* '}'
/// map_field = comment* string ':' value
fn map(p: *Parser) void {
    // mark open/close is handled in value()
    p.expect(.lb);

    while (!p.atAny(&.{ .rb, .eof })) {
        p.comments();
        p.expect(.string);
        p.expect(.colon);
        p.value();
        if (!p.consume(.comma)) break;
    }

    _ = p.consume(.comma);
    p.comments();
    p.expect(.rb);
}

fn peek(p: *Parser, offset: u32) Token {
    if (p.fuel == 0) @panic("parser is stuck");
    p.fuel = p.fuel - 1;

    const idx = p.tokenizer.idx;
    defer p.tokenizer.idx = idx;
    var i: u32 = 0;
    var tok = p.tokenizer.next(p.code);
    while (i < offset) {
        i += 1;
        tok = p.tokenizer.next(p.code);
    }
    return tok;
}

fn consume(p: *Parser, tag: Token.Tag) bool {
    if (p.at(tag)) {
        p.advance();
        return true;
    }
    return false;
}

fn expect(p: *Parser, tag: Token.Tag) void {
    if (p.consume(tag)) return;
    p.printError("expected {s}", .{@tagName(tag)});
}

fn at(p: *Parser, tag: Token.Tag) bool {
    const tok = p.peek(0);
    std.log.debug("at({s}) {s}:'{s}'", .{ @tagName(tag), @tagName(tok.tag), tok.loc.src(p.code) });
    return tag == tok.tag;
}

fn atAny(p: *Parser, tags: []const Token.Tag) bool {
    return mem.indexOfScalar(Token.Tag, tags, p.peek(0).tag) != null;
}

fn printError(p: Parser, comptime fmt: []const u8, args: anytype) void {
    var pos: u32 = 0;
    var line: u32 = 1;
    var col: u32 = 1;
    var last_nonws_linecol = [2]u32{ line, col };
    while (pos < p.tokenizer.idx) : (pos += 1) {
        if (p.code[pos] == '\n') {
            line += 1;
            col = 1;
        } else {
            col += 1;
        }

        // TODO decide if simd is overkill here
        const u8x6 = @Vector(6, u8);
        const ws: u8x6 = std.ascii.whitespace;
        const cs: u8x6 = @splat(p.code[pos]);
        // if (std.mem.indexOfScalar(u8, &std.ascii.whitespace, p.code[pos]) == null) {
        if (@reduce(.And, cs != ws)) {
            last_nonws_linecol = .{ line, col };
        }
    }
    if (!@import("builtin").is_test) {
        // FIXME i'm not sure where to log errors
        std.debug.print(
            "{?s}:{}:{}: error: " ++ fmt ++ "\n",
            .{ p.filepath, last_nonws_linecol[0], last_nonws_linecol[1] } ++ args,
        );
    }
}

fn advanceWithError(p: *Parser, err: []const u8) void {
    const m = p.open();
    p.advanceWithErrorNoOpen(m, err);
}

fn advanceWithErrorNoOpen(p: *Parser, m: MarkOpened, err: []const u8) void {
    p.printError("{s}", .{err});
    p.advance();
    _ = p.close(m, .err);
}

fn advance(p: *Parser) void {
    assert(!p.eof());
    p.fuel = 256;
    p.events.append(p.gpa, .advance) catch @panic("OOM");
    _ = p.tokenizer.next(p.code);
}

fn eof(p: *Parser) bool {
    return p.peek(0).tag == .eof;
}

fn open(p: *Parser) MarkOpened {
    std.log.debug("open", .{});
    const mark: MarkOpened = @enumFromInt(p.events.items.len);
    p.events.append(p.gpa, .{ .open = .err }) catch @panic("OOM");
    return mark;
}

// fn openBefore(p: *Parser, m: MarkClosed) MarkOpened {
//     const mark = m.toOpened();
//     p.events.insert(p.gpa, m.toInt(), .{ .open = .err }) catch @panic("OOM");
//     return mark;
// }

fn close(p: *Parser, m: MarkOpened, tag: Tree.Tag) MarkClosed {
    std.log.debug("close {s}", .{@tagName(tag)});
    p.events.items[m.toInt()] = .{ .open = tag };
    p.events.append(p.gpa, .close) catch @panic("OOM");
    return m.toClosed();
}

fn buildTree(p: *Parser) !Tree {
    assert(p.events.pop() == .close);
    p.tokenizer.idx = 0;
    var stack = std.ArrayList(Tree).init(p.gpa);
    defer stack.deinit();
    for (p.events.items) |event| {
        // std.log.debug("build_tree() event={}", .{event});
        switch (event) {
            .open => |tag| try stack.append(.{ .tag = tag }),
            .close => {
                const tree = stack.pop();
                try stack.items[stack.items.len - 1].children.append(
                    p.gpa,
                    .{ .tree = tree },
                );
            },
            .advance => {
                try stack.items[stack.items.len - 1].children.append(
                    p.gpa,
                    .{ .token = p.tokenizer.next(p.code) },
                );
            },
        }
    }

    const tree = stack.pop();
    assert(stack.items.len == 0);
    assert(p.tokenizer.next(p.code).tag == .eof);
    return tree;
}

fn expectFmt(case: [:0]const u8) !void {
    var tree = try parse(std.testing.allocator, case, .want_comments, null);
    defer tree.deinit(std.testing.allocator);
    try std.testing.expectFmt(case, "{pretty}", .{tree.fmt(case)});
}

test "basics" {
    try expectFmt(
        \\.foo = "bar",
        \\.bar = [1, 2, 3],
        \\
    );
}

test "vertical" {
    try expectFmt(
        \\.foo = "bar",
        \\.bar = [
        \\    1,
        \\    2,
        \\    3,
        \\],
        \\
    );
}

test "complex" {
    try expectFmt(
        \\.foo = "bar",
        \\.bar = [
        \\    1,
        \\    23.45,
        \\    {
        \\        "abc": "foo",
        \\        "baz": ["foo", "bar"],
        \\    },
        \\],
        \\.t = true,
        \\.f = false,
        \\.n = null,
        \\.date = @date("2020-10-01T00:00:00"),
        \\
    );
}

test "comments" {
    try expectFmt(
        \\//! top comment
        \\//! top comment2
        \\// foo field comment
        \\// foo field comment2
        \\.foo = "bar",
        \\// bar field comment
        \\// bar field comment2
        \\.bar = null
    );
}

test "top level non-struct values" {
    try expectFmt("true");
    try expectFmt("false");
    try expectFmt("null");
    try expectFmt(
        \\"top str"
    );
    try expectFmt("123");
    try expectFmt("123.45");
    try expectFmt("{.a = 1, .b = 2}");
    try expectFmt(
        \\{"a": 1, "b": 2}
    );
    try expectFmt(
        \\[true, false, null, "str", 123, {.a = 1, .b = 2}, {"a": 1, "b": 2}]
    );
}

test "misc" {
    try expectFmt("[]");
    // FIXME: re-enable this test case which panics @Tokenizer.zig:190:55
    // try testCase("");
    try expectFmt("{}");
}

test "line string" {
    try expectFmt(
        \\{
        \\    "extended_description": 
        \\    \\Lorem ipsum dolor something something,
        \\    \\this is a multiline string literal.
        \\    ,
        \\}
    );
}

test "invalid" {
    try expectFmt(".a = , ");
    try expectFmt(".a = 1,\n, ");
}
