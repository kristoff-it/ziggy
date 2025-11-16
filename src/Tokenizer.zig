const Tokenizer = @This();

const std = @import("std");

delimiter: std.meta.Tag(Delimiter),
lines: u32,
idx: u32,

/// When parsing Ziggy Documents embedded in external files, the *CLOSING*
/// delimiter to expect after the Ziggy Document ends.
pub const Delimiter = union(enum) {
    /// No delimiter, tokenization will start from the first byte and continue
    /// to the end.
    none,
    /// For all the following cases, tokenization will begin at the provided
    /// offset and continue until the specified delimiter is encountered.
    ///
    /// The starting offset must be set to *AFTER* the opening delimiter (which
    /// might or might not be the same as the closing delimiter, and since it's
    /// on you to parse it, it makes no difference).
    ///
    /// The Ziggy tokenizer will start tokenizing from this position and you
    /// won't need to adjust any offset / line count in error messages.
    ///
    /// This means that it's up to you to ensure that the opening delimiter is
    /// present before you start parsing a Ziggy Document. It also means that
    /// you will have to handle empty files.
    ///
    /// Dashes (---) are normally the frontmatter delimiter of Markdown and SuperMD
    /// documents.
    dashes: u32,
    /// Backticks (```) are the delimiter of code blocks in Markdown and SuperMD.
    /// It's also common to have extra syntax on the same line where the opening
    /// delimiter is, like so:
    ///    ```python foo=bar
    ///    my = ["python", "code"]
    ///    ```
    /// In such cases it's necessary to provide a starting offset that points
    /// the end of the line.
    backticks: u32,
};

pub const Token = struct {
    tag: Tag,
    loc: Loc,

    pub const Tag = enum {
        invalid,
        comma,
        eql,
        colon,
        rp, // left paren is only in union_case
        dotlb, // .{
        lb,
        rb,
        lsb,
        rsb,
        identifier,
        union_case,
        bytes,
        bytes_line,
        integer,
        float,
        null,
        true,
        false,
        comment_line,
        eod, // ---, ```, or </script>
        eof,
    };

    pub const Loc = struct {
        start: u32,
        end: u32,

        pub fn slice(loc: Loc, src: [:0]const u8) []const u8 {
            return src[loc.start..loc.end];
        }

        pub const Selection = struct {
            start: Position,
            end: Position,

            pub const Position = struct {
                line: u32,
                col: u32,
            };
        };

        pub fn getSelection(loc: Loc, code: [:0]const u8) Selection {
            //TODO: ziglyph
            var selection: Selection = .{
                .start = .{ .line = 1, .col = 1 },
                .end = undefined,
            };

            for (code[0..loc.start]) |c| {
                if (c == '\n') {
                    selection.start.line += 1;
                    selection.start.col = 1;
                } else selection.start.col += 1;
            }

            selection.end = selection.start;
            for (code[loc.start..loc.end]) |c| {
                if (c == '\n') {
                    selection.end.line += 1;
                    selection.end.col = 1;
                } else selection.end.col += 1;
            }
            return selection;
        }
    };
};

const State = enum {
    start,
    builtin,
    identifier,
    number,
    bytes,
    line_bytes_start,
    bytes_line,
    comment_start,
    comment,
    invalid,
};

pub fn init(delimiter: Delimiter) Tokenizer {
    return .{
        .delimiter = delimiter,
        .lines = 0,
        .idx = switch (delimiter) {
            .none => 0,
            inline else => |offset| offset,
        },
    };
}

pub fn next(t: *Tokenizer, src: [:0]const u8, skip_comments: bool) Token {
    var tok: Token = .{
        .tag = undefined,
        .loc = .{
            .start = t.idx,
            .end = undefined,
        },
    };

    // defer std.debug.print("returning '{s}' {t} \n", .{ tok.loc.slice(src), tok.tag });
    state: switch (State.start) {
        .start => switch (src[t.idx]) {
            0 => {
                tok.tag = .eof;
                tok.loc.start = @intCast(src.len); // code.len may == 0
                tok.loc.end = @intCast(src.len);
                return tok;
            },
            ' ', '\t', '\r' => {
                t.idx += 1;
                tok.loc.start += 1;
                continue :state .start;
            },
            '\n' => {
                t.idx += 1;
                t.lines += 1;
                tok.loc.start += 1;
                continue :state .start;
            },
            ',' => {
                t.idx += 1;
                tok.tag = .comma;
                tok.loc.end = t.idx;
                return tok;
            },
            '=' => {
                t.idx += 1;
                tok.tag = .eql;
                tok.loc.end = t.idx;
                return tok;
            },
            ':' => {
                t.idx += 1;
                tok.tag = .colon;
                tok.loc.end = t.idx;
                return tok;
            },
            ')' => {
                t.idx += 1;
                tok.tag = .rp;
                tok.loc.end = t.idx;
                return tok;
            },
            '[' => {
                t.idx += 1;
                tok.tag = .lsb;
                tok.loc.end = t.idx;
                return tok;
            },
            ']' => {
                t.idx += 1;
                tok.tag = .rsb;
                tok.loc.end = t.idx;
                return tok;
            },
            '{' => {
                t.idx += 1;
                tok.tag = .lb;
                tok.loc.end = t.idx;
                return tok;
            },
            '}' => {
                t.idx += 1;
                tok.tag = .rb;
                tok.loc.end = t.idx;
                return tok;
            },
            '.' => {
                t.idx += 1;
                if (src[t.idx] != '{') continue :state .identifier;

                t.idx += 1;
                tok.tag = .dotlb;
                tok.loc.end = t.idx;
                return tok;
            },

            '0'...'9' => {
                t.idx += 1;
                continue :state .number;
            },
            '"' => {
                t.idx += 1;
                continue :state .bytes;
            },
            '\\' => {
                t.idx += 1;
                continue :state .line_bytes_start;
            },
            '/' => {
                t.idx += 1;
                continue :state .comment_start;
            },

            'a'...'z', 'A'...'Z', '_' => {
                t.idx += 1;
                continue :state .builtin;
            },
            '-' => {
                if (t.delimiter == .dashes and std.mem.startsWith(u8, src[t.idx..], "---")) {
                    tok.tag = .eod;
                    tok.loc.end = t.idx + 3;
                    t.idx = @intCast(src.len);
                    return tok;
                }

                continue :state .number;
            },
            '`' => {
                if (t.delimiter == .backticks and std.mem.startsWith(u8, src[t.idx..], "```")) {
                    tok.tag = .eod;
                    tok.loc.end = t.idx + 3;
                    t.idx = @intCast(src.len);

                    return tok;
                }

                continue :state .invalid;
            },
            // '<' => {
            //     if (t.delimiter == .script and std.mem.startsWith(u8, src[t.idx..], "</script>")) {
            //         tok.tag = .eod;
            //         tok.loc.end = t.idx + 9;
            //         t.idx = @intCast(src.len);
            //         return tok;
            //     }

            //     continue :state .invalid;
            // },

            else => {
                t.idx += 1;
                tok.tag = .invalid;
                tok.loc.end = t.idx;
                return tok;
            },
        },
        .builtin => switch (src[t.idx]) {
            'a'...'z', 'A'...'Z', '_', '0'...'9' => {
                t.idx += 1;
                continue :state .builtin;
            },
            else => {
                tok.loc.end = t.idx;

                const slice = tok.loc.slice(src);
                if (std.mem.eql(u8, slice, "true")) {
                    tok.tag = .true;
                } else if (std.mem.eql(u8, slice, "false")) {
                    tok.tag = .false;
                } else if (std.mem.eql(u8, slice, "null")) {
                    tok.tag = .null;
                } else tok.tag = .invalid;

                return tok;
            },
        },

        .identifier => switch (src[t.idx]) {
            'a'...'z', 'A'...'Z', '_', '0'...'9' => {
                t.idx += 1;
                continue :state .identifier;
            },
            '(' => {
                t.idx += 1;
                tok.tag = .union_case;
                tok.loc.end = t.idx;
                return tok;
            },
            else => {
                tok.loc.end = t.idx;
                tok.tag = if (tok.loc.end - tok.loc.start == 1) .invalid else .identifier;
                return tok;
            },
        },

        .number => switch (src[t.idx]) {
            '0'...'9', '.', '_', '-', '+', 'e', 'E' => {
                t.idx += 1;
                continue :state .number;
            },
            else => {
                t.finishNumber(&tok, src);
                return tok;
            },
        },

        .bytes => switch (src[t.idx]) {
            0 => {
                tok.tag = .invalid;
                tok.loc.end = t.idx;
                return tok;
            },
            '\n' => {
                t.lines += 1;
                tok.tag = .invalid;
                tok.loc.end = t.idx;
                t.idx += 1;
                return tok;
            },

            '"' => {
                const slice = src[0..t.idx];
                t.idx += 1;
                if (!evenSlashes(slice)) continue :state .bytes;
                tok.tag = .bytes;
                tok.loc.end = t.idx;
                return tok;
            },

            else => {
                t.idx += 1;
                continue :state .bytes;
            },
        },

        .line_bytes_start => switch (src[t.idx]) {
            '\\' => {
                t.idx += 1;
                continue :state .bytes_line;
            },
            else => {
                t.idx += 1;
                continue :state .invalid;
            },
        },
        .bytes_line => switch (src[t.idx]) {
            0 => {
                tok.tag = .bytes_line;
                tok.loc.end = t.idx;
                return tok;
            },
            '\n' => {
                tok.tag = .bytes_line;
                tok.loc.end = t.idx;
                t.lines += 1;
                t.idx += 1;
                return tok;
            },
            else => {
                t.idx += 1;
                continue :state .bytes_line;
            },
        },

        .comment_start => switch (src[t.idx]) {
            '/' => continue :state .comment,
            else => {
                t.idx += 1;
                continue :state .invalid;
            },
        },
        .comment => switch (src[t.idx]) {
            0 => {
                if (!skip_comments) {
                    tok.loc.end = t.idx;
                    tok.tag = .comment_line;
                    return tok;
                }

                tok.tag = .eof;
                tok.loc.start = t.idx - 1;
                tok.loc.end = t.idx;
                return tok;
            },
            '\n' => {
                t.lines += 1;
                if (!skip_comments) {
                    tok.loc.end = t.idx;
                    tok.tag = .comment_line;
                    t.idx += 1;
                    return tok;
                }
                t.idx += 1;
                tok.loc.start = t.idx;
                continue :state .start;
            },
            else => {
                t.idx += 1;
                continue :state .comment;
            },
        },
        .invalid => switch (src[t.idx]) {
            'a'...'z', 'A'...'Z', '_', '0'...'9' => {
                t.idx += 1;
                continue :state .invalid;
            },
            else => {
                tok.loc.end = t.idx;

                tok.tag = .invalid;
                return tok;
            },
        },
    }

    comptime unreachable;
}

fn finishNumber(t: Tokenizer, tok: *Token, src: [:0]const u8) void {
    tok.loc.end = t.idx;
    // TODO: implement this natively
    var minus_minus = tok.loc;
    if (minus_minus.slice(src)[0] == '-') {
        minus_minus.start += 1;
    }
    const check = std.zig.parseNumberLiteral(minus_minus.slice(src));
    tok.tag = switch (check) {
        .failure => .invalid,
        .int, .big_int => .integer,
        .float => .float,
    };
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

test "fuzz" {
    const Context = struct {
        fn testOne(_: @This(), input: []const u8) anyerror!void {
            const src = try std.testing.allocator.dupeZ(u8, input);
            defer std.testing.allocator.free(src);

            if (@import("builtin").fuzz) std.debug.print("---begin---\n{s}\n-------\n", .{input});
            var t: Tokenizer = .init(.none);
            while (true) {
                if (t.next(src, false).tag == .eof) break;
            }
        }
    };
    try std.testing.fuzz(Context{}, Context.testOne, .{});
}

fn testCase(
    case: [:0]const u8,
    expected: []const Token.Tag,
    skip_comments: bool,
    delimiter: Delimiter,
) !void {
    var t: Tokenizer = .init(delimiter);

    var success = true;
    for (expected, 0..) |e, idx| {
        errdefer std.debug.print("failed at index: {}\n", .{idx});
        const tok = t.next(case, skip_comments);
        errdefer std.debug.print("bad token: {s} '{s}'\n", .{ @tagName(tok.tag), tok.loc.slice(case) });
        try std.testing.expectEqual(e, tok.tag);

        if (e == .invalid) success = false;
    }

    try std.testing.expect(t.next(case, skip_comments).tag == .eof);
    if (success) {
        const lines: u32 = @intCast(std.mem.count(u8, case, "\n"));
        try std.testing.expectEqual(lines, t.lines);
    }
}

test "basics" {
    // zig fmt: off
    try testCase(
        \\.foo = "bar",
        \\.bar = false,
        \\.baz = { .bax = null },
    , &.{
        .identifier, .eql, .bytes, .comma,
        .identifier, .eql, .false, .comma,
        .identifier, .eql, .lb, .identifier, .eql, .null, .rb, .comma,
        .eof,
    }, true, .none);
    // zig fmt: on

}

test "comments are skipped" {
    // zig fmt: off
    try testCase(
        \\.foo = "bar", // comment can be inline
        \\.bar = false,
        \\// bax must be null
        \\.baz = { 
        \\   // comment inside struct 
        \\   .bax = null 
        \\},
        \\// can end with a comment
        \\// or even two
    ,
     &.{
        .identifier, .eql, .bytes, .comma,
        .identifier, .eql, .false, .comma,
        .identifier, .eql, .lb, .identifier, .eql, .null, .rb, .comma,
        .eof,
    }, true, .none);
    // zig fmt: on
}

test "invalid comments" {
    // zig fmt: off
    try testCase(
        \\/invalid
        \\.foo = "bar",
        \\.bar = false,
        \\.baz = { "bax" : null },
    , &.{
        .invalid,
        .identifier, .eql, .bytes, .comma,
        .identifier, .eql, .false, .comma,
        .identifier, .eql, .lb, .bytes, .colon, .null, .rb, .comma,
        .eof,
    }, true, .none);
    // zig fmt: on

}

test "invalid bytes" {
    try testCase(
        \\["a "b"]
    , &.{ .lsb, .bytes, .invalid, .invalid, .eof }, true, .none);
}

test "want comments + trailing" {
    try testCase(
        \\// comment
    , &.{ .comment_line, .eof }, false, .none);
}

test "multiline bytes" {
    try testCase(
        \\.str =
        \\  \\fst
        \\  \\snd
        \\,
    , &.{ .identifier, .eql, .bytes_line, .bytes_line, .comma, .eof }, false, .none);
}

test "frontmatter" {
    // zig fmt: off
    try testCase(
        \\---
        \\.foo = "bar",
        \\.bar = false,
        \\.baz = .{ .bax = null },
        \\---
    , &.{
        .identifier, .eql, .bytes, .comma,
        .identifier, .eql, .false, .comma,
        .identifier, .eql, .dotlb, .identifier, .eql, .null, .rb, .comma,
        .eod,
        .eof,
    }, true, .{.dashes = 3});
    // zig fmt: on

}

test "frontmatter newline" {
    // zig fmt: off
    try testCase(
        \\---
        \\.foo = "bar",
        \\.bar = false,
        \\.baz = .{ .bax = null },
        \\---
    , &.{
        .identifier, .eql, .bytes, .comma,
        .identifier, .eql, .false, .comma,
        .identifier, .eql, .dotlb, .identifier, .eql, .null, .rb, .comma,
        .eod,
    }, true, .{.dashes = 3});
    // zig fmt: on

}
test "comment in array" {
    // zig fmt: off
    try testCase(
        \\.aliases = [
        \\  "/another_index.html",
        \\  // None of these aliases should collide because they're all relative:
        \\  "foo/bar/baz.html",
        \\  "foo/bar/baz1.html",
        \\  // None of these aliases should collide because they're all relative:
        \\  // None of these aliases should collide because they're all relative:
        \\  // None of these aliases should collide because they're all relative:
        \\  "foo/bar.html",
        \\],
    , &.{
        .identifier, .eql, .lsb,
        .bytes, .comma,
        .comment_line,
        .bytes, .comma,
        .bytes, .comma,
        .comment_line,
        .comment_line,
        .comment_line,
        .bytes, .comma,
        .rsb, .comma,
        .eof,
    }, false, .none);
    // zig fmt: on

}
