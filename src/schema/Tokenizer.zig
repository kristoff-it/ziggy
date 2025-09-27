const Tokenizer = @This();
const std = @import("std");

idx: u32 = 0,

pub const Token = struct {
    tag: Tag,
    loc: Loc,

    pub const Tag = enum {
        invalid,
        union_kw,
        struct_kw,
        any_kw,
        int_kw,
        float_kw,
        root_sigil,
        slice_sigil,
        dict_sigil,
        bytes_kw,
        bool_kw,
        lb,
        rb,
        eq,
        colon,
        comma,
        qmark,
        identifier,
        doc_comment_line,
        eof,

        pub fn isExpr(t: Token.Tag) bool {
            return switch (t) {
                .qmark,
                .slice_sigil,
                .dict_sigil,
                .bytes_kw,
                .int_kw,
                .float_kw,
                .bool_kw,
                .any_kw,
                .identifier,
                => true,
                else => false,
            };
        }

        pub fn lexeme(self: Tag) []const u8 {
            return switch (self) {
                .invalid => "(invalid)",
                .root_sigil => "$",
                .union_kw => "union",
                .struct_kw => "struct",
                .any_kw => "any",
                .slice_sigil => "[]",
                .dict_sigil => "{:}",
                .comma => ",",
                .eq => "=",
                .colon => ":",
                .lb => "{",
                .rb => "}",
                .qmark => "?",
                .identifier => "(identifier)",
                .doc_comment_line => "(doc comment)",
                .bytes_kw => "bytes",
                .int_kw => "int",
                .float_kw => "float",
                .bool_kw => "bool",
                .eof => "EOF",
            };
        }
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

        pub fn getSelection(self: Loc, code: [:0]const u8) Selection {
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
    };
};

const State = enum {
    start,
    identifier,
    doc_comment_start,
    doc_comment,
};

pub fn next(t: *Tokenizer, src: [:0]const u8) Token {
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
                tok.loc.start = @intCast(src.len);
                tok.loc.end = @intCast(src.len);
                return tok;
            },
            ' ', '\n', '\r', '\t' => {
                t.idx += 1;
                tok.loc.start += 1;
                continue :state .start;
            },
            '$' => {
                t.idx += 1;
                tok.tag = .root_sigil;
                tok.loc.end = t.idx;
                return tok;
            },
            ',' => {
                t.idx += 1;
                tok.tag = .comma;
                tok.loc.end = t.idx;
                return tok;
            },
            '=' => {
                t.idx += 1;
                tok.tag = .eq;
                tok.loc.end = t.idx;
                return tok;
            },
            ':' => {
                t.idx += 1;
                tok.tag = .colon;
                tok.loc.end = t.idx;
                return tok;
            },
            '[' => {
                t.idx += 1;
                if (src[t.idx] == ']') {
                    t.idx += 1;
                    tok.tag = .slice_sigil;
                    tok.loc.end = t.idx;
                    return tok;
                }

                tok.tag = .invalid;
                tok.loc.end = t.idx;
                return tok;
            },
            '{' => {
                t.idx += 1;
                if (src[t.idx] == ':') {
                    t.idx += 1;
                    if (src[t.idx] == '}') {
                        t.idx += 1;
                        tok.tag = .dict_sigil;
                        tok.loc.end = t.idx;
                        return tok;
                    }

                    tok.tag = .invalid;
                    tok.loc.end = t.idx;
                    return tok;
                }

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
            '?' => {
                t.idx += 1;
                tok.tag = .qmark;
                tok.loc.end = t.idx;
                return tok;
            },
            'a'...'z', 'A'...'Z', '_' => {
                t.idx += 1;
                continue :state .identifier;
            },
            '/' => {
                t.idx += 1;
                continue :state .doc_comment_start;
            },
            else => {
                t.idx += 1;
                tok.tag = .invalid;
                tok.loc.end = t.idx;
                return tok;
            },
        },
        .identifier => switch (src[t.idx]) {
            'a'...'z', 'A'...'Z', '_', '0'...'9' => {
                t.idx += 1;
                continue :state .identifier;
            },
            else => {
                tok.loc.end = t.idx;
                const slice = tok.loc.slice(src);
                if (std.mem.eql(u8, slice, "bytes")) {
                    tok.tag = .bytes_kw;
                } else if (std.mem.eql(u8, slice, "bool")) {
                    tok.tag = .bool_kw;
                } else if (std.mem.eql(u8, slice, "int")) {
                    tok.tag = .int_kw;
                } else if (std.mem.eql(u8, slice, "float")) {
                    tok.tag = .float_kw;
                } else if (std.mem.eql(u8, slice, "struct")) {
                    tok.tag = .struct_kw;
                } else if (std.mem.eql(u8, slice, "union")) {
                    tok.tag = .union_kw;
                } else if (std.mem.eql(u8, slice, "any")) {
                    tok.tag = .any_kw;
                } else {
                    tok.tag = .identifier;
                }
                return tok;
            },
        },
        .doc_comment_start => switch (src[t.idx]) {
            '/' => {
                if (!std.mem.startsWith(u8, src[t.idx..], "//")) {
                    tok.tag = .invalid;
                    tok.loc.end = t.idx;
                    return tok;
                }

                t.idx += 1;
                continue :state .doc_comment;
            },
            else => {
                tok.tag = .invalid;
                tok.loc.end = t.idx;
                return tok;
            },
        },
        .doc_comment => switch (src[t.idx]) {
            0, '\n' => {
                tok.tag = .doc_comment_line;
                tok.loc.end = t.idx;
                t.idx += @intFromBool(src[t.idx] != 0);
                return tok;
            },
            else => {
                t.idx += 1;
                continue :state .doc_comment;
            },
        },
    }

    comptime unreachable;
}

test "basics" {
    const case =
        \\$ = Frontmatter
        \\
        \\struct Frontmatter {
        \\    title: bytes      
        \\}
    ;

    // zig fmt: off
    const expected: []const Token.Tag = &.{
        .root_sigil, .eq, .identifier,
        
        .struct_kw, .identifier, .lb,
            .identifier, .colon, .bytes_kw,
        .rb,
    };
    // zig fmt: on

    var t: Tokenizer = .{};

    for (expected, 0..) |e, idx| {
        errdefer std.debug.print("failed at index: {}\n", .{idx});
        const tok = t.next(case);
        errdefer std.debug.print("bad token: {any}\n", .{tok});
        try std.testing.expectEqual(e, tok.tag);
    }

    try std.testing.expectEqual(t.next(case).tag, .eof);
}

test "more" {
    const case =
        \\$ = Message
        \\
        \\struct Message {
        \\    id: UUID,
        \\    time: int,
        \\    payload: Payload,
        \\    
        \\    union UUID {
        \\        uuid: bytes,
        \\    }
        \\}
        \\
        \\
        \\union Payload {
        \\    command: Command,
        \\    notification: Notification,
        \\}
        \\
        \\struct Command {
        \\    id: Id,
        \\    sender: bytes,
        \\    roles: []bytes,
        \\    /// Optional metadata. 
        \\    extra: ?{:}bytes,
        \\
        \\    union Id {
        \\        clear_chat,
        \\        send_message,
        \\    }
        \\}
    ;

    // zig fmt: off
    const expected: []const Token.Tag = &.{
        .root_sigil, .eq, .identifier,
        
        .struct_kw, .identifier, .lb,
            .identifier, .colon, .identifier, .comma,
            .identifier, .colon, .int_kw, .comma,
            .identifier, .colon, .identifier, .comma,
            
            .union_kw, .identifier, .lb,
                .identifier, .colon, .bytes_kw, .comma,
            .rb,
        .rb,
        
        .union_kw, .identifier, .lb,
            .identifier, .colon, .identifier, .comma,
            .identifier, .colon, .identifier, .comma,
        .rb,

        
        .struct_kw, .identifier, .lb,
            .identifier, .colon, .identifier, .comma,
            .identifier, .colon, .bytes_kw, .comma,
            .identifier, .colon, .slice_sigil, .bytes_kw, .comma,
            .doc_comment_line,
            .identifier, .colon, .qmark, .dict_sigil, .bytes_kw, .comma,
            
            .union_kw, .identifier, .lb,
                .identifier, .comma, 
                .identifier, .comma, 
            .rb,
        .rb,
    };
    // zig fmt: on

    var t: Tokenizer = .{};

    for (expected, 0..) |e, idx| {
        errdefer std.debug.print("failed at index: {} \n---\n{s}\n---\n", .{ idx, case[t.idx..] });
        const tok = t.next(case);
        errdefer std.debug.print("bad token: {any}\n", .{tok});
        try std.testing.expectEqual(e, tok.tag);
    }
    try std.testing.expectEqual(t.next(case).tag, .eof);
}
test "sigil errors" {
    const case =
        \\[{:}
        \\[]]
        \\[{:}]
        \\[[]]
        \\{[]}
        \\{:[]}
        \\{[]:}
        \\{:[]:}
        \\{:[]
        \\{:{:}
        \\{:{:}}
        \\{:{:}:}
    ;

    // zig fmt: off
    const expected: []const Token.Tag = &.{
        .invalid, .dict_sigil,
        .slice_sigil, .invalid,
        .invalid, .dict_sigil, .invalid,
        .invalid, .slice_sigil, .invalid,
        .lb, .slice_sigil, .rb,
        .invalid, .slice_sigil, .rb,
        .lb, .slice_sigil, .colon, .rb,
        .invalid, .slice_sigil, .colon, .rb,
        .invalid, .slice_sigil,
        .invalid, .dict_sigil,
        .invalid, .dict_sigil, .rb,
        .invalid, .dict_sigil, .colon, .rb,
    };
    // zig fmt: on

    var t: Tokenizer = .{};

    for (expected, 0..) |e, idx| {
        errdefer std.debug.print("failed at index: {} \n---\n{s}\n---\n", .{ idx, case[t.idx..] });
        const tok = t.next(case);
        errdefer std.debug.print("bad token: {any}\n", .{tok});
        try std.testing.expectEqual(e, tok.tag);
    }
    try std.testing.expectEqual(t.next(case).tag, .eof);
}

test "fuzz" {
    const Context = struct {
        fn testOne(_: @This(), input: []const u8) anyerror!void {
            const src = try std.testing.allocator.dupeZ(u8, input);
            defer std.testing.allocator.free(src);

            if (@import("builtin").fuzz) std.debug.print("---begin---\n{s}\n-------\n", .{input});
            var t: Tokenizer = .{};
            while (true) {
                if (t.next(src).tag == .eof) break;
            }
        }
    };
    try std.testing.fuzz(Context{}, Context.testOne, .{});
}
