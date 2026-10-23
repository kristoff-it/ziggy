const Tokenizer = @This();

const std = @import("std");
const assert = std.debug.assert;
const Writer = std.Io.Writer;

delimiter: std.meta.Tag(Delimiter),
// Set to a location within a bytes token when an invalid escape
// sequence is found. Note that the string might contain more than
// one invalid escape sequence, but the tokenizer will only annotate
// the first one.
first_invalid_escape: Token.Loc = .zero,
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
    /// is considered a semantic construct of the outer language and thus is
    /// on users to parse).
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
        bytes_no_escapes,
        bytes_with_escapes,
        bytes_line,
        integer_bin,
        integer_oct,
        integer_hex,
        integer_dec,
        float,
        nan,
        pos_inf,
        neg_inf,
        null,
        true,
        false,
        comment_line,
        eod, // ---, ```, or </script>
        eof,

        pub fn literal(t: Tag) []const u8 {
            return switch (t) {
                .comment_line,
                .eod,
                .eof,
                .bytes_no_escapes,
                .bytes_with_escapes,
                .bytes_line,
                .integer_bin,
                .integer_oct,
                .integer_hex,
                .integer_dec,
                .float,
                .union_case,
                .invalid,
                .identifier,
                => unreachable,
                .comma => ",",
                .eql => "=",
                .colon => ":",
                .rp => ")",
                .dotlb => ".{",
                .lb => "{",
                .rb => "}",
                .lsb => "[",
                .rsb => "]",
                .nan => "nan",
                .pos_inf => "inf",
                .neg_inf => "-inf",
                .null => "null",
                .true => "true",
                .false => "false",
            };
        }

        pub const Kind = enum {
            punctuation,
            comment_line,
            bytes,
            bytes_line,
            integer,
            float,
            identifier,
            eod,
            null,
            bool,
            @"enum",
        };

        pub fn kind(t: Tag) Kind {
            return switch (t) {
                .eof,
                .invalid,
                .union_case, // we always split it
                => unreachable,
                .comma, .eql, .colon, .rp, .dotlb, .lb, .rb, .lsb, .rsb => .punctuation,
                .comment_line => .comment_line,
                .bytes_no_escapes, .bytes_with_escapes => .bytes,
                .bytes_line => .bytes_line,
                .integer_bin, .integer_oct, .integer_hex, .integer_dec => .integer,
                .float, .nan, .pos_inf, .neg_inf => .float,
                .identifier => .identifier,
                .null => .null,
                .true, .false => .bool,
                .eod => .eod,
            };
        }
    };

    pub const Loc = struct {
        start: u32,
        end: u32,

        pub const zero: Loc = .{ .start = 0, .end = 0 };

        pub fn slice(loc: Loc, src: [:0]const u8) []const u8 {
            return src[loc.start..loc.end];
        }

        pub const Line = struct { line: []const u8, start: u32 };
        pub fn line(loc: Loc, src: []const u8) Line {
            if (src.len < 2) return .{ .line = "", .start = 0 };

            var idx = @min(loc.start, src.len - 2);
            const s = while (idx > 0) : (idx -= 1) {
                if (src[idx] == '\n') break idx + 1;
            } else 0;

            idx = loc.end;
            const e = while (idx < src.len) : (idx += 1) {
                if (src[idx] == '\n') break idx;
            } else src.len;

            return .{ .line = src[s..e], .start = s };
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
    integral_start,
    integral_leading_zero,
    integral_end,
    integer_bin,
    integer_oct,
    integer_hex,
    float_fraction,
    float_exponent_start,
    float_exponent_end,
    bytes,
    bytes_escape,
    bytes_escape_hex_digits,
    bytes_line_start,
    bytes_line_end,
    comment_start,
    comment,
    invalid,
};

/// Asserts that the token is valid (including all escape sequences).
pub fn parseValidBytesWithEscapes(full_src: []const u8, w: *Writer) Writer.Error!void {
    // std.debug.print("escaping \n[{s}]\n\n", .{full_src});
    assert(full_src.len >= 4);
    assert(full_src[0] == '"');
    assert(full_src[full_src.len - 1] == '"');

    const src = full_src[1 .. full_src.len - 1];

    var last_slash_idx: usize = 0;
    while (true) {
        const slash_idx = std.mem.indexOfScalarPos(u8, src, last_slash_idx, '\\') orelse {
            assert(last_slash_idx != 0); // call only on bytes_with_escapes!
            try w.writeAll(src[last_slash_idx..]);
            return;
        };

        try w.writeAll(src[last_slash_idx..slash_idx]);
        last_slash_idx = slash_idx + 2;
        switch (src[slash_idx + 1]) {
            else => unreachable,
            '"' => try w.writeByte('"'),
            '\\' => try w.writeByte('\\'),
            '/' => try w.writeByte('/'),
            'b' => try w.writeByte(0x08),
            'f' => try w.writeByte(0x0c),
            'r' => try w.writeByte('\r'),
            'n' => try w.writeByte('\n'),
            't' => try w.writeByte('\t'),
            'x' => {
                var value: u8 = 0;

                last_slash_idx += 2;
                for (src[slash_idx + 2 .. last_slash_idx]) |digit| switch (digit) {
                    '0'...'9' => {
                        value *= 16;
                        value += digit - '0';
                    },
                    'a'...'f' => {
                        value *= 16;
                        value += digit - 'a' + 10;
                    },
                    'A'...'F' => {
                        value *= 16;
                        value += digit - 'A' + 10;
                    },
                    else => unreachable,
                };

                try w.writeByte(value);
            },
            'u' => {
                var value: u32 = 0;

                last_slash_idx += 4;
                for (src[slash_idx + 2 .. last_slash_idx]) |digit| switch (digit) {
                    '0'...'9' => {
                        value *= 16;
                        value += digit - '0';
                    },
                    'a'...'f' => {
                        value *= 16;
                        value += digit - 'a' + 10;
                    },
                    'A'...'F' => {
                        value *= 16;
                        value += digit - 'A' + 10;
                    },
                    else => unreachable,
                };

                if (value > 0x10ffff) {
                    try w.writeAll("�");
                    continue;
                }

                var buf: [4]u8 = undefined;
                const len = std.unicode.utf8Encode(@intCast(value), &buf) catch {
                    try w.writeAll("�");
                    continue;
                };

                try w.writeAll(buf[0..len]);
            },
        }
    }
}

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

/// When obtaining a 'bytes' token, the caller can inspect 'first_invalid_sequence'
/// to know if the token contains any invalid sequence. Note that only the first
/// invalid sequence will be tracked, meaning that if it's meaningful to report
/// more errors at once, the caller should validate the rest of the string separately.
/// If 'first_invalid_sequence' is {0, 0} (i.e. `Token.Loc.zero`), then the string
/// is valid and requires no further validation.
pub fn next(t: *Tokenizer, src: [:0]const u8, skip_comments: bool) Token {
    var tok: Token = .{
        .tag = undefined,
        .loc = .{
            .start = t.idx,
            .end = undefined,
        },
    };

    // Used to detect misplaced underscores in numeric literals.
    var last_was_digit = true;

    // Used to count the number of hex digits in a bytes escape sequence.
    var bytes_escape_hex_digits: u8 = undefined;

    // Used to track the beginning of a bytes escape sequence.
    var bytes_escape_start: u32 = 0;

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
                // reconsume
                continue :state .integral_start;
            },
            '"' => {
                t.idx += 1;
                t.first_invalid_escape = .zero;
                continue :state .bytes;
            },
            '\\' => {
                t.idx += 1;
                continue :state .bytes_line_start;
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
                } else if (std.mem.startsWith(u8, src[t.idx..], "-inf")) {
                    tok.tag = .neg_inf;
                    tok.loc.end = t.idx + 4;
                    t.idx += 4;
                    return tok;
                }

                t.idx += 1;
                switch (src[t.idx]) {
                    '0'...'9' => {
                        continue :state .integral_start;
                    },
                    else => {
                        tok.tag = .invalid;
                        tok.loc.end = t.idx;
                        return tok;
                    },
                }
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
                } else if (std.mem.eql(u8, slice, "nan")) {
                    tok.tag = .nan;
                } else if (std.mem.eql(u8, slice, "inf")) {
                    tok.tag = .pos_inf;
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
        .integral_start => switch (src[t.idx]) {
            '0' => {
                t.idx += 1;
                continue :state .integral_leading_zero;
            },
            '1'...'9' => {
                t.idx += 1;
                continue :state .integral_end;
            },
            else => unreachable, // lookahead is expected before entering this state
        },

        .integral_leading_zero => switch (src[t.idx]) {
            'b' => {
                t.idx += 1;
                continue :state .integer_bin;
            },
            'o' => {
                t.idx += 1;
                continue :state .integer_oct;
            },
            'x' => {
                t.idx += 1;
                continue :state .integer_hex;
            },
            '.' => {
                t.idx += 1;
                last_was_digit = false;
                continue :state .float_fraction;
            },
            else => {
                tok.tag = .integer_dec;
                tok.loc.end = t.idx;
                return tok;
            },
        },

        .integral_end => switch (src[t.idx]) {
            '.' => {
                t.idx += 1;
                last_was_digit = false;
                continue :state .float_fraction;
            },
            '0'...'9' => {
                t.idx += 1;
                last_was_digit = true;
                continue :state .integral_end;
            },
            '_' => {
                if (!last_was_digit) {
                    t.idx += 1;
                    tok.tag = .invalid;
                    tok.loc.end = t.idx;
                    return tok;
                }

                t.idx += 1;
                last_was_digit = false;
                continue :state .integral_end;
            },
            else => {
                if (!last_was_digit) {
                    tok.tag = .invalid;
                    tok.loc.end = t.idx;
                    return tok;
                }

                tok.tag = .integer_dec;
                tok.loc.end = t.idx;
                return tok;
            },
        },

        .integer_bin => switch (src[t.idx]) {
            '0'...'1' => {
                t.idx += 1;
                last_was_digit = true;
                continue :state .integer_bin;
            },
            '_' => {
                if (!last_was_digit) {
                    t.idx += 1;
                    tok.tag = .invalid;
                    tok.loc.end = t.idx;
                    return tok;
                }

                t.idx += 1;
                last_was_digit = false;
                continue :state .integer_bin;
            },
            else => {
                if (!last_was_digit) {
                    tok.tag = .invalid;
                    tok.loc.end = t.idx;
                    return tok;
                }

                tok.tag = .integer_bin;
                tok.loc.end = t.idx;
                return tok;
            },
        },

        .integer_oct => switch (src[t.idx]) {
            '0'...'7' => {
                t.idx += 1;
                last_was_digit = true;
                continue :state .integer_oct;
            },
            '_' => {
                if (!last_was_digit) {
                    t.idx += 1;
                    tok.tag = .invalid;
                    tok.loc.end = t.idx;
                    return tok;
                }

                t.idx += 1;
                last_was_digit = false;
                continue :state .integer_oct;
            },
            else => {
                if (!last_was_digit) {
                    tok.tag = .invalid;
                    tok.loc.end = t.idx;
                    return tok;
                }

                tok.tag = .integer_oct;
                tok.loc.end = t.idx;
                return tok;
            },
        },

        .integer_hex => switch (src[t.idx]) {
            '0'...'9', 'a'...'f', 'A'...'F' => {
                t.idx += 1;
                last_was_digit = true;
                continue :state .integer_hex;
            },
            '_' => {
                if (!last_was_digit) {
                    t.idx += 1;
                    tok.tag = .invalid;
                    tok.loc.end = t.idx;
                    return tok;
                }

                t.idx += 1;
                last_was_digit = false;
                continue :state .integer_hex;
            },
            else => {
                if (!last_was_digit) {
                    tok.tag = .invalid;
                    tok.loc.end = t.idx;
                    return tok;
                }

                tok.tag = .integer_hex;
                tok.loc.end = t.idx;
                return tok;
            },
        },

        .float_fraction => switch (src[t.idx]) {
            '0'...'9' => {
                t.idx += 1;
                last_was_digit = true;
                continue :state .float_fraction;
            },
            '_' => {
                if (!last_was_digit) {
                    t.idx += 1;
                    tok.tag = .invalid;
                    tok.loc.end = t.idx;
                    return tok;
                }

                t.idx += 1;
                last_was_digit = false;
                continue :state .float_fraction;
            },
            'e', 'E' => {
                if (!last_was_digit) {
                    // NOTE: this check should remain even if we delete underscore support!
                    tok.tag = .invalid;
                    tok.loc.end = t.idx;
                    return tok;
                }
                t.idx += 1;
                continue :state .float_exponent_start;
            },
            else => {
                if (!last_was_digit) {
                    tok.tag = .invalid;
                    tok.loc.end = t.idx;
                    return tok;
                }

                tok.tag = .float;
                tok.loc.end = t.idx;
                return tok;
            },
        },

        .float_exponent_start => switch (src[t.idx]) {
            '-', '+', '0'...'9' => {
                t.idx += 1;
                continue :state .float_exponent_end;
            },
            else => {
                tok.tag = .invalid;
                tok.loc.end = t.idx;
                return tok;
            },
        },
        .float_exponent_end => switch (src[t.idx]) {
            '0'...'9' => {
                t.idx += 1;
                continue :state .float_exponent_end;
            },
            else => {
                tok.tag = .float;
                tok.loc.end = t.idx;
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

            '\\' => {
                bytes_escape_start = t.idx;
                t.idx += 1;
                continue :state .bytes_escape;
            },

            '"' => {
                t.idx += 1;
                tok.tag = if (bytes_escape_start == 0)
                    .bytes_no_escapes
                else
                    .bytes_with_escapes;
                tok.loc.end = t.idx;
                return tok;
            },

            else => {
                t.idx += 1;
                continue :state .bytes;
            },
        },

        .bytes_escape => switch (src[t.idx]) {
            '"', '\\', '/', 'b', 'f', 'n', 'r', 't' => {
                t.idx += 1;
                continue :state .bytes;
            },
            'u' => {
                t.idx += 1;
                bytes_escape_hex_digits = 4;
                continue :state .bytes_escape_hex_digits;
            },
            'x' => {
                t.idx += 1;
                bytes_escape_hex_digits = 2;
                continue :state .bytes_escape_hex_digits;
            },
            else => {
                if (t.first_invalid_escape.start == 0) {
                    t.first_invalid_escape = .{
                        .start = t.idx - 1,
                        .end = t.idx,
                    };
                }
                continue :state .bytes;
            },
        },

        .bytes_escape_hex_digits => switch (src[t.idx]) {
            '0'...'9', 'a'...'f', 'A'...'F' => {
                t.idx += 1;
                bytes_escape_hex_digits -= 1;
                if (bytes_escape_hex_digits == 0) {
                    continue :state .bytes;
                }
                continue :state .bytes_escape_hex_digits;
            },
            else => {
                if (t.first_invalid_escape.start == 0) {
                    t.first_invalid_escape = .{
                        .start = bytes_escape_start,
                        .end = t.idx,
                    };
                }
                continue :state .bytes;
            },
        },

        .bytes_line_start => switch (src[t.idx]) {
            '\\' => {
                t.idx += 1;
                continue :state .bytes_line_end;
            },
            0 => {
                tok.tag = .invalid;
                tok.loc.end = t.idx;
                return tok;
            },
            else => {
                t.idx += 1;
                continue :state .invalid;
            },
        },
        .bytes_line_end => switch (src[t.idx]) {
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
                continue :state .bytes_line_end;
            },
        },

        .comment_start => switch (src[t.idx]) {
            '/' => continue :state .comment,
            0 => {
                tok.tag = .invalid;
                tok.loc.end = t.idx;
                return tok;
            },
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
                if (src[t.idx] != 0) t.idx += 1;
                tok.loc.end = t.idx;
                tok.tag = .invalid;
                return tok;
            },
        },
    }

    comptime unreachable;
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

// test "fuzz" {
//     const Context = struct {
//         fn testOne(_: @This(), input: []const u8) anyerror!void {
//             const src = try std.testing.allocator.dupeZ(u8, input);
//             defer std.testing.allocator.free(src);

//             if (@import("builtin").fuzz) std.debug.print("---begin---\n{s}\n-------\n", .{input});
//             var t: Tokenizer = .init(.none);
//             while (true) {
//                 if (t.next(src, false).tag == .eof) break;
//             }
//         }
//     };
//     try std.testing.fuzz(Context{}, Context.testOne, .{});
// }

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
        .identifier, .eql, .bytes_no_escapes, .comma,
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
        .identifier, .eql, .bytes_no_escapes, .comma,
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
        .identifier, .eql, .bytes_no_escapes, .comma,
        .identifier, .eql, .false, .comma,
        .identifier, .eql, .lb, .bytes_no_escapes, .colon, .null, .rb, .comma,
        .eof,
    }, true, .none);
    // zig fmt: on

}

test "invalid bytes" {
    try testCase(
        \\["a "b"]
    , &.{ .lsb, .bytes_no_escapes, .invalid, .invalid, .eof }, true, .none);
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
        .identifier, .eql, .bytes_no_escapes, .comma,
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
        .identifier, .eql, .bytes_no_escapes, .comma,
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
        .bytes_no_escapes, .comma,
        .comment_line,
        .bytes_no_escapes, .comma,
        .bytes_no_escapes, .comma,
        .comment_line,
        .comment_line,
        .comment_line,
        .bytes_no_escapes, .comma,
        .rsb, .comma,
        .eof,
    }, false, .none);
    // zig fmt: on

}

test "special float values" {
    // zig fmt: off
    try testCase(
        \\.pos_inf1 = inf,
        \\.neg_inf = -inf,
        \\.nan = nan
    , &.{
        .identifier, .eql, .pos_inf, .comma,
        .identifier, .eql, .neg_inf, .comma,
        .identifier, .eql, .nan,
        .eof,
    }, false, .none);
    // zig fmt: on
}

test "numeric literals" {
    // zig fmt: off
    try testCase(
        \\.int1 = 0,
        \\.int2 = 1,
        \\.int3 = 1000,
        \\.int4 = 1_000,
        \\.int5 = 1_000_000,
        \\.int6 = 0b0101,
        \\.int7 = 0o777,
        \\.int8 = 0xffffff42,
        \\.float1 = 0.001,
        \\.float2 = 0.0_0_1,
        \\.float3 = 0.001e10,
        \\.float4 = 0.001e+10,
        \\.float5 = 0.001e-10,
    , &.{
        .identifier, .eql, .integer_dec, .comma,
        .identifier, .eql, .integer_dec, .comma,
        .identifier, .eql, .integer_dec, .comma,
        .identifier, .eql, .integer_dec, .comma,
        .identifier, .eql, .integer_dec, .comma,
        .identifier, .eql, .integer_bin, .comma,
        .identifier, .eql, .integer_oct, .comma,
        .identifier, .eql, .integer_hex, .comma,
        .identifier, .eql, .float, .comma,
        .identifier, .eql, .float, .comma,
        .identifier, .eql, .float, .comma,
        .identifier, .eql, .float, .comma,
        .identifier, .eql, .float, .comma,
        .eof,
    }, false, .none);
    // zig fmt: on
}
// NOTE: invalid escape sequences still result in a bytes token
test "string escapes" {
    // zig fmt: off
    try testCase(
        \\.foo = "this is foo \\",
        \\.bar = "this \" is bar",
        \\.baz = "this is \xff \uaabb baz",
        \\.invalid1 = "this is \xf wrong",
        \\.invalid2 = "this is also \u123 wrong",
        \\.invalid3 = "this is also also \z wrong",
    , &.{
        .identifier, .eql, .bytes_with_escapes, .comma,
        .identifier, .eql, .bytes_with_escapes, .comma,
        .identifier, .eql, .bytes_with_escapes, .comma,
        .identifier, .eql, .bytes_with_escapes, .comma,
        .identifier, .eql, .bytes_with_escapes, .comma,
        .identifier, .eql, .bytes_with_escapes, .comma,
        .eof,
    }, false, .none);
    // zig fmt: on
}
