const Tokenizer = @This();
const std = @import("std");

want_comments: bool,
idx: u32 = 0,

pub const Token = struct {
    tag: Tag,
    loc: Loc,

    pub const Tag = enum {
        invalid,
        dot,
        comma,
        eql,
        colon,
        at,
        lp,
        rp,
        lb,
        rb,
        lsb,
        rsb,
        identifier,
        string,
        line_string,
        integer,
        float,
        null,
        true,
        false,
        top_comment_line,
        comment,
        eof,

        // never generated by the tokenizer but
        // used elsewhere
        value,
        tag_name,

        pub fn lexeme(self: Tag) []const u8 {
            return switch (self) {
                .invalid => "(invalid)",
                .top_comment_line => "(top comment)",
                .comment => "(comment)",
                .dot => ".",
                .comma => ",",
                .eql => "=",
                .colon => ":",
                .at => "@",
                .lp => "(",
                .rp => ")",
                .lb => "{",
                .rb => "}",
                .lsb => "[",
                .rsb => "]",
                .identifier => "(identifier)",
                .tag_name => "(tag name)",
                .string => "(string)",
                .line_string => "(line string)",
                .integer => "(integer)",
                .float => "(float)",
                .value => "(value)",
                .null => "null",
                .true => "true",
                .false => "false",
                .eof => "EOF",
            };
        }
    };

    pub const Loc = struct {
        start: u32,
        end: u32,

        pub fn src(self: Loc, code: []const u8) []const u8 {
            return code[self.start..self.end];
        }

        pub const Selection = struct {
            start: Position,
            end: Position,

            pub const Position = struct {
                line: u32,
                col: u32,
            };
        };

        pub fn getSelection(self: Loc, code: []const u8) Selection {
            //TODO: ziglyph
            var selection: Selection = .{
                .start = .{ .line = 1, .col = 1 },
                .end = undefined,
            };

            for (code[0..self.start]) |c| {
                if (c == '\n') {
                    selection.start.line += 1;
                    selection.start.col = 1;
                } else selection.start.col += 1;
            }

            selection.end = selection.start;
            for (code[self.start..self.end]) |c| {
                if (c == '\n') {
                    selection.end.line += 1;
                    selection.end.col = 1;
                } else selection.end.col += 1;
            }
            return selection;
        }

        pub fn unquote(self: Loc, code: []const u8) ?[]const u8 {
            const s = code[self.start..self.end];
            const quoteless = s[1 .. s.len - 1];

            for (quoteless) |c| {
                if (c == '\\') return null;
            } else {
                return quoteless;
            }
        }

        pub fn unescape(
            self: Loc,
            gpa: std.mem.Allocator,
            code: []const u8,
        ) ![]const u8 {
            const s = code[self.start..self.end];
            const quoteless = s[1 .. s.len - 1];

            for (quoteless) |c| {
                if (c == '\\') break;
            } else {
                return quoteless;
            }

            const quote = s[0];
            var out = std.ArrayList(u8).init(gpa);
            var last = quote;
            var skipped = false;
            for (quoteless) |c| {
                if (c == '\\' and last == '\\' and !skipped) {
                    skipped = true;
                    last = c;
                    continue;
                }
                if (c == quote and last == '\\' and !skipped) {
                    out.items[out.items.len - 1] = quote;
                    last = c;
                    continue;
                }
                try out.append(c);
                skipped = false;
                last = c;
            }
            return try out.toOwnedSlice();
        }
    };
};

const State = enum {
    start,
    identifier,
    number,
    string,
    line_string_start,
    line_string,
    comment_start,
    comment,
};

pub fn next(self: *Tokenizer, code: [:0]const u8) Token {
    var state: State = .start;
    var res: Token = .{
        .tag = .invalid,
        .loc = .{
            .start = self.idx,
            .end = undefined,
        },
    };

    while (true) : (self.idx += 1) {
        const c = code[self.idx];
        switch (state) {
            .start => switch (c) {
                0 => {
                    res.tag = .eof;
                    res.loc.start = @intCast(code.len - 1);
                    res.loc.end = @intCast(code.len);
                    break;
                },
                ' ', '\n', '\r', '\t' => res.loc.start += 1,
                '.' => {
                    self.idx += 1;
                    res.tag = .dot;
                    res.loc.end = self.idx;
                    break;
                },
                ',' => {
                    self.idx += 1;
                    res.tag = .comma;
                    res.loc.end = self.idx;
                    break;
                },
                '=' => {
                    self.idx += 1;
                    res.tag = .eql;
                    res.loc.end = self.idx;
                    break;
                },
                ':' => {
                    self.idx += 1;
                    res.tag = .colon;
                    res.loc.end = self.idx;
                    break;
                },
                '@' => {
                    self.idx += 1;
                    res.tag = .at;
                    res.loc.end = self.idx;
                    break;
                },
                '(' => {
                    self.idx += 1;
                    res.tag = .lp;
                    res.loc.end = self.idx;
                    break;
                },
                ')' => {
                    self.idx += 1;
                    res.tag = .rp;
                    res.loc.end = self.idx;
                    break;
                },
                '[' => {
                    self.idx += 1;
                    res.tag = .lsb;
                    res.loc.end = self.idx;
                    break;
                },
                ']' => {
                    self.idx += 1;
                    res.tag = .rsb;
                    res.loc.end = self.idx;
                    break;
                },
                '{' => {
                    self.idx += 1;
                    res.tag = .lb;
                    res.loc.end = self.idx;
                    break;
                },
                '}' => {
                    self.idx += 1;
                    res.tag = .rb;
                    res.loc.end = self.idx;
                    break;
                },

                'a'...'z', 'A'...'Z', '_' => state = .identifier,
                '-', '0'...'9' => state = .number,
                '"', '\'' => state = .string,
                '\\' => state = .line_string_start,
                '/' => state = .comment_start,
                else => {
                    res.tag = .invalid;
                    res.loc.end = self.idx;
                    break;
                },
            },
            .identifier => switch (c) {
                'a'...'z', 'A'...'Z', '_', '0'...'9' => continue,
                else => {
                    res.loc.end = self.idx;
                    const src = res.loc.src(code);
                    if (std.mem.eql(u8, src, "true")) {
                        res.tag = .true;
                    } else if (std.mem.eql(u8, src, "false")) {
                        res.tag = .false;
                    } else if (std.mem.eql(u8, src, "null")) {
                        res.tag = .null;
                    } else {
                        res.tag = .identifier;
                    }
                    break;
                },
            },
            .number => switch (c) {
                '0'...'9', '.', '_', '-', '+', 'e', 'E' => continue,
                else => {
                    res.loc.end = self.idx;
                    // TODO: implement this natively
                    var minus_minus = res.loc;
                    if (minus_minus.src(code)[0] == '-') {
                        minus_minus.start += 1;
                    }
                    const check = std.zig.parseNumberLiteral(minus_minus.src(code));
                    res.tag = switch (check) {
                        .failure => .invalid,
                        .int, .big_int => .integer,
                        .float => .float,
                    };
                    break;
                },
            },
            .string => switch (c) {
                0, '\n' => {
                    res.tag = .invalid;
                    res.loc.end = self.idx;
                    break;
                },

                '"', '\'' => if (c == code[res.loc.start] and
                    evenSlashes(code[0..self.idx]))
                {
                    self.idx += 1;
                    res.tag = .string;
                    res.loc.end = self.idx;
                    break;
                },
                else => {},
            },
            .line_string_start => switch (c) {
                '\\' => state = .line_string,
                else => {
                    res.tag = .invalid;
                    res.loc.end = self.idx;
                    break;
                },
            },
            .line_string => switch (c) {
                0, '\n' => {
                    res.tag = .line_string;
                    res.loc.end = self.idx;
                    break;
                },
                else => {},
            },
            .comment_start => switch (c) {
                '/' => state = .comment,
                else => {
                    res.tag = .invalid;
                    res.loc.end = self.idx;
                    break;
                },
            },
            .comment => switch (c) {
                0, '\n' => {
                    if (self.want_comments) {
                        res.loc.end = self.idx;
                        if (std.mem.startsWith(u8, res.loc.src(code), "//!")) {
                            res.tag = .top_comment_line;
                        } else {
                            res.tag = .comment;
                        }
                        break;
                    } else {
                        state = .start;
                        res.loc.start = self.idx;
                        self.idx -= 1;
                    }
                },
                else => {},
            },
        }
    }

    return res;
}

fn evenSlashes(str: []const u8) bool {
    var i = str.len - 1;
    var even = true;
    while (true) : (i -= 1) {
        if (str[i] != '\\') break;
        even = !even;
        if (i == 0) break;
    }
    return even;
}

test "basics" {
    const case =
        \\.foo = "bar",
        \\.bar = false,
        \\.baz = { .bax = null },
    ;

    const expected: []const Token.Tag = &.{
        // zig fmt: off
        .dot, .identifier, .eql, .string, .comma,
        .dot, .identifier, .eql, .false, .comma,
        .dot, .identifier, .eql, .lb, .dot, .identifier, .eql, .null, .rb, .comma,
        // zig fmt: on
    };

    var t: Tokenizer = .{ .want_comments = false };

    for (expected, 0..) |e, idx| {
        errdefer std.debug.print("failed at index: {}\n", .{idx});
        const tok = t.next(case);
        errdefer std.debug.print("bad token: {any}\n", .{tok});
        try std.testing.expectEqual(e, tok.tag);
    }
        try std.testing.expectEqual(t.next(case).tag, .eof);
}

test "comments are skipped" {
    const case =
        \\.foo = "bar", // comment can be inline
        \\.bar = false,
        \\// bax must be null
        \\.baz = { 
        \\   // comment inside struct 
        \\   .bax = null 
        \\},
        \\// can end with a comment
        \\// or even two
    ;

    const expected: []const Token.Tag = &.{
        // zig fmt: off
        .dot, .identifier, .eql, .string, .comma,
        .dot, .identifier, .eql, .false, .comma,
        .dot, .identifier, .eql, .lb, .dot, .identifier, .eql, .null, .rb, .comma,
        // zig fmt: on
    };

    var t: Tokenizer = .{ .want_comments = false };

    for (expected, 0..) |e, idx| {
        errdefer std.debug.print("failed at index: {}\n", .{idx});
        const tok = t.next(case);
        errdefer std.debug.print("bad token: {any}\n", .{tok});
        try std.testing.expectEqual(e, tok.tag);
    }
        try std.testing.expectEqual(t.next(case).tag, .eof);
}

test "invalid comments" {
    const case =
        \\/invalid
        \\.foo = "bar",
        \\.bar = false,
        \\.baz = { .bax = null },
    ;

    const expected: []const Token.Tag = &.{
        // zig fmt: off
        .invalid, .identifier,
        .dot, .identifier, .eql, .string, .comma,
        .dot, .identifier, .eql, .false, .comma,
        .dot, .identifier, .eql, .lb, .dot, .identifier, .eql, .null, .rb, .comma,
        // zig fmt: on
    };

    var t: Tokenizer = .{ .want_comments = false };

    for (expected, 0..) |e, idx| {
        errdefer std.debug.print("failed at index: {}\n", .{idx});
        const tok = t.next(case);
        errdefer std.debug.print("bad token: {any}\n", .{tok});
        try std.testing.expectEqual(e, tok.tag);
    }
        try std.testing.expectEqual(t.next(case).tag, .eof);
}