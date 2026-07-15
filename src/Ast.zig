const Ast = @This();

const std = @import("std");
const assert = std.debug.assert;
const Writer = std.Io.Writer;
const Allocator = std.mem.Allocator;
const ansi = @import("ansi_term");
const root = @import("root.zig");
const Tokenizer = @import("Tokenizer.zig");
const Token = Tokenizer.Token;
const Loc = Token.Loc;

const log = std.log.scoped(.ziggy_ast);

nodes: []const Node,
errors: []const Error,
has_syntax_errors: bool,
delimiter: Tokenizer.Delimiter,

pub const FieldKind = enum { @"struct", dict };
pub const Error = struct {
    tag: union(enum) {
        unexpected_token,
        missing_token: []const u8,
        wrong_field_style,
        wrong_field_separator: FieldKind,
        missing_value,
        empty_dict_key,
        pub fn format(t: @This(), w: *Writer) !void {
            switch (t) {
                .unexpected_token => {
                    try w.writeAll("unexpected token");
                },
                .missing_token => |msg| {
                    try w.print("missing token: {s}", .{msg});
                },
                .wrong_field_separator => {
                    try w.writeAll("wrong field separator");
                },
                .wrong_field_style => {
                    try w.writeAll("wrong field style: use fmt to correct automatically");
                },
                .missing_value => {
                    try w.writeAll("missing following value");
                },
                .empty_dict_key => {
                    try w.writeAll("dict keys cannot be empty");
                },
            }
        }
    },
    main_location: Loc,
};

pub const Node = struct {
    loc: Token.Loc = undefined,
    parent_idx: u32,
    next_idx: u32 = 0, // 0 = missing
    tag: Tag,
    pub const Tag = enum(u8) {
        root,
        braceless_struct,
        struct_h,
        struct_v,
        dict_h,
        dict_v,
        array_h,
        array_v,
        struct_field,
        dict_field,
        array_element,
        @"union",
        @"enum",
        bytes,
        bytes_multiline,
        integer,
        float,
        bool,
        null,

        //The following tags are never present in correct documents
        struct_v_fixup,
        missing_value,

        /// Only valid on single-token nodes.
        fn kind(t: Tag) Tokenizer.Token.Tag.Kind {
            return switch (t) {
                .root,
                .braceless_struct,
                .struct_h,
                .struct_v,
                .dict_h,
                .dict_v,
                .array_h,
                .array_v,
                .struct_field,
                .dict_field,
                .array_element,
                .@"union",
                .bytes_multiline,
                .struct_v_fixup,
                .missing_value,
                => unreachable,

                .@"enum" => .@"enum",
                .bytes => .bytes,
                .integer => .integer,
                .float => .float,
                .bool => .bool,
                .null => .null,
            };
        }
    };
};

pub const Options = struct {
    /// When parsing a SuperMD frontmatter, set to `.dashes`.
    /// See the doc comments of `Tokenizer.Delimiter` for more information on
    /// how to parse Ziggy Documents embedded in other files.
    delimiter: Tokenizer.Delimiter = .none,
};

pub fn init(
    gpa: Allocator,
    src: [:0]const u8,
    options: Options,
) error{OutOfMemory}!Ast {
    var p: Parser = .{ .gpa = gpa, .src = src, .options = options };
    defer p.deinit();
    return p.parse();
}

pub fn deinit(ast: Ast, gpa: Allocator) void {
    gpa.free(ast.nodes);
    gpa.free(ast.errors);
}

pub fn fieldName(ast: *const Ast, src: [:0]const u8, node_idx: u32) []const u8 {
    const node = ast.nodes[node_idx];
    assert(node.tag == .struct_field or node.tag == .dict_field);
    var t: Tokenizer = .{
        .idx = node.loc.start,
        .lines = 0,
        .delimiter = ast.delimiter,
    };

    const name_tok = t.next(src, true);
    const txt = name_tok.loc.slice(src);
    return switch (name_tok.tag) {
        .identifier => txt[1..],
        .bytes => txt[1 .. txt.len - 1],
        else => unreachable,
    };
}

pub fn iterator(ast: *const Ast) Iterator {
    return .{ .nodes = ast.nodes };
}

pub fn fmt(ast: *const Ast, src: [:0]const u8, rm: root.RenderMode) Format {
    return .{ .src = src, .ast = ast, .rm = rm };
}

const Parser = struct {
    gpa: Allocator,
    src: [:0]const u8,
    options: Options,
    node_idx: u32 = 0,
    nodes: std.ArrayList(Node) = .empty,
    errors: std.ArrayList(Error) = .empty,
    meta: std.ArrayList(struct {
        last_child_idx: u32 = 0,
    }) = .empty,
    tokenizer: Tokenizer = undefined,
    tok: Token = .{ .tag = .invalid, .loc = .{ .start = 0, .end = 0 } },
    prev_loc: Loc = undefined,
    has_syntax_errors: bool = false,

    fn deinit(p: *Parser) void {
        p.nodes.deinit(p.gpa);
        p.errors.deinit(p.gpa);
        p.meta.deinit(p.gpa);
    }

    fn parse(p: *Parser) error{OutOfMemory}!Ast {
        p.tokenizer = .init(p.options.delimiter);
        try p.meta.append(p.gpa, .{});
        try p.nodes.append(p.gpa, .{
            .tag = .root,
            .loc = .{ .start = p.tokenizer.idx, .end = undefined },
            .parent_idx = 0,
        });

        p.consume();
        parse: switch (p.cur().tag) {
            .root => if (p.curIsEmpty()) switch (p.tok.tag) {
                .identifier => switch (p.peek()) {
                    .eof, .eod => {
                        // a document with a top-level enum value
                        try p.beginValue();
                        return p.finalize();
                    },
                    else => {
                        // let's consider the case of a top level struct more
                        // probable than a single enum value.
                        try p.addChild(.braceless_struct);
                        try p.addChild(.struct_field);
                        continue :parse .struct_field;
                    },
                },
                .eod, .eof => {
                    p.cur().loc.end = p.tok.loc.start;
                    return p.finalize();
                },
                else => {
                    try p.beginValue();
                    continue :parse p.cur().tag;
                },
            } else switch (p.tok.tag) {
                .eof, .eod => {
                    p.cur().loc.end = p.tok.loc.start;
                    return p.finalize();
                },
                else => {
                    try p.err(.{
                        .tag = .unexpected_token,
                        .main_location = p.tok.loc,
                    });
                    return p.finalize();
                },
            },
            .braceless_struct => {
                assert(!p.curIsEmpty());
                const peek_tok = if (p.tok.tag == .comma) p.peek() else p.tok.tag;
                const next_is_field = switch (peek_tok) {
                    .eof, .eod => {
                        if (p.tok.tag == .comma) p.consume();
                        p.cur().loc.end = p.tok.loc.start;
                        p.up();
                        assert(p.cur().tag == .root);
                        continue :parse .root;
                    },
                    .identifier => true,
                    else => false,
                };

                if (next_is_field) {
                    if (p.tok.tag == .comma) p.consume() else {
                        try p.err(.{
                            .tag = .{ .missing_token = "',' after field value" },
                            .main_location = p.prev_loc,
                        });
                    }
                    try p.addChild(.struct_field);
                    continue :parse .struct_field;
                } else {
                    if (p.tok.tag == .comma) p.consume();
                    try p.err(.{
                        .tag = .unexpected_token,
                        .main_location = p.tok.loc,
                    });
                    try p.discardUntilRestart();
                    continue :parse p.cur().tag;
                }
            },
            .struct_h, .struct_v, .struct_v_fixup, .dict_h, .dict_v => {
                const peek_tok = if (p.tok.tag == .comma) blk: {
                    if (p.curIsEmpty()) try p.err(.{
                        .tag = .unexpected_token,
                        .main_location = p.tok.loc,
                    });
                    break :blk p.peek();
                } else p.tok.tag;

                const next_is_field = switch (peek_tok) {
                    .rb => {
                        if (p.tok.tag == .comma) p.consume() else {
                            const node = p.cur();
                            node.tag = switch (node.tag) {
                                .struct_v_fixup => .struct_v_fixup,
                                .struct_v => .struct_h,
                                .dict_v => .dict_h,
                                else => unreachable,
                            };
                        }
                        p.cur().loc.end = p.tok.loc.end;
                        p.consume();
                        p.up();
                        continue :parse p.cur().tag;
                    },
                    .eof, .eod => {
                        if (p.tok.tag == .comma) p.consume();
                        try p.err(.{
                            .tag = .{ .missing_token = "'}'" },
                            .main_location = p.tok.loc,
                        });
                        return p.finalize();
                    },
                    .identifier, .bytes => true,
                    else => false,
                };

                if (next_is_field) {
                    if (!p.curIsEmpty() and p.tok.tag != .comma) {
                        try p.err(.{
                            .tag = .{ .missing_token = "',' after field value" },
                            .main_location = p.prev_loc,
                        });
                    }
                    if (p.tok.tag == .comma) p.consume();
                    switch (p.cur().tag) {
                        .struct_h, .struct_v, .struct_v_fixup => {
                            try p.addChild(.struct_field);
                            continue :parse .struct_field;
                        },
                        .dict_h, .dict_v => {
                            try p.addChild(.dict_field);
                            continue :parse .dict_field;
                        },
                        else => unreachable,
                    }
                } else {
                    if (p.tok.tag == .comma) p.consume();
                    try p.err(.{
                        .tag = .unexpected_token,
                        .main_location = p.tok.loc,
                    });
                    try p.discardUntilRestart();
                    continue :parse p.cur().tag;
                }
            },
            .struct_field, .dict_field => if (p.curIsEmpty()) {
                switch (p.tok.tag) {
                    .identifier => {},
                    .bytes => {
                        if (p.tok.loc.end - p.tok.loc.start < 3) try p.err(.{
                            .tag = .empty_dict_key,
                            .main_location = p.tok.loc,
                        });
                    },
                    .eof, .eod => {
                        // we should not be able to get here without errors
                        assert(p.errors.items.len > 0);
                        return p.finalize();
                    },
                    else => {
                        // we should not be able to get here without errors
                        assert(p.errors.items.len > 0);
                    },
                }

                const style_mismatch = switch (p.cur().tag) {
                    .struct_field => p.tok.tag == .bytes,
                    .dict_field => p.tok.tag == .identifier,
                    else => unreachable,
                };

                if (style_mismatch) {
                    try p.err(.{
                        .tag = .wrong_field_style,
                        .main_location = p.tok.loc,
                    });

                    if (p.cur().tag == .struct_field) {
                        p.nodes.items[p.cur().parent_idx].tag = .struct_v_fixup;
                    }
                }

                p.consume();
                switch (p.tok.tag) {
                    .colon, .eql => if (!style_mismatch) {
                        if ((p.cur().tag == .struct_field and p.tok.tag == .colon) or
                            (p.cur().tag == .dict_field and p.tok.tag == .eql))
                        {
                            try p.err(.{
                                .tag = .unexpected_token,
                                .main_location = p.tok.loc,
                            });
                        }
                    },
                    .eod, .eof => {
                        try p.err(.{
                            .tag = .{
                                .missing_token = switch (p.cur().tag) {
                                    .struct_field => "'=' after struct field name",
                                    .dict_field => "':' after dict field name",
                                    else => unreachable,
                                },
                            },
                            .main_location = p.prev_loc,
                        });
                        return p.finalize();
                    },
                    else => {
                        try p.err(.{
                            .tag = .{
                                .missing_token = switch (p.cur().tag) {
                                    .struct_field => "'=' after struct field name",
                                    .dict_field => "':' after dict field name",
                                    else => unreachable,
                                },
                            },
                            .main_location = p.prev_loc,
                        });
                        try p.discardUntilRestart();
                        continue :parse p.cur().tag;
                    },
                }

                p.consume();
                try p.beginValue();
                continue :parse p.cur().tag;
            } else {
                // missing commas are handled by the container
                p.cur().loc.end = if (p.tok.tag == .comma) p.tok.loc.end else p.prev_loc.end;
                p.up();
                continue :parse p.cur().tag;
            },
            .array_h, .array_v => {
                if (p.curIsEmpty() and p.tok.tag == .comma) try p.err(.{
                    .tag = .unexpected_token,
                    .main_location = p.tok.loc,
                });

                const peek_token = if (p.tok.tag == .comma) p.peek() else p.tok.tag;
                switch (peek_token) {
                    .rsb => {
                        if (p.tok.tag == .comma) p.consume() else p.cur().tag = .array_h;
                        p.cur().loc.end = p.tok.loc.end;
                        p.consume();
                        p.up();
                        continue :parse p.cur().tag;
                    },
                    .eod, .eof => {
                        try p.err(.{
                            .tag = .{ .missing_token = "']' after last array element" },
                            .main_location = p.prev_loc,
                        });
                        // p.cur().loc.end = p.tok.loc.start;
                        // p.up();
                        return p.finalize();
                    },
                    else => {},
                }

                if (!p.curIsEmpty() and p.tok.tag != .comma) {
                    try p.err(.{
                        .tag = .{ .missing_token = "',' after array value" },
                        .main_location = p.prev_loc,
                    });
                }

                if (p.tok.tag == .comma) p.consume();
                try p.addChild(.array_element);
                try p.beginValue();
                continue :parse p.cur().tag;
            },
            .array_element => {
                assert(!p.curIsEmpty());
                // missing commas are handled by the container
                p.cur().loc.end = if (p.tok.tag == .comma) p.tok.loc.end else p.prev_loc.end;
                p.up();
                continue :parse p.cur().tag;
            },
            .@"union" => if (p.curIsEmpty()) {
                assert(p.tok.tag == .union_case);
                p.consume();
                try p.beginValue();
                continue :parse p.cur().tag;
            } else {
                if (p.tok.tag == .rp) p.consume() else {
                    try p.err(.{
                        .tag = .{ .missing_token = "')' after union value" },
                        .main_location = p.prev_loc,
                    });
                }
                p.cur().loc.end = p.prev_loc.end;
                p.up();
                continue :parse p.cur().tag;
            },
            .bytes,
            .bytes_multiline,
            .integer,
            .float,
            .bool,
            .null,
            .@"enum",
            .missing_value,
            => unreachable,
        }

        comptime unreachable;
    }

    fn beginValue(p: *Parser) !void {
        switch (p.tok.tag) {
            .dotlb => {
                try p.addChild(.struct_v);
                p.consume();
                return;
            },
            .lb => {
                try p.addChild(.dict_v);
                p.consume();
                return;
            },
            .lsb => {
                try p.addChild(.array_v);
                p.consume();
                return;
            },
            .union_case => {
                try p.addChild(.@"union");
                return;
            },
            .bytes_line => {
                try p.addChild(.bytes_multiline);
                while (p.tok.tag == .bytes_line) p.consume();
                p.cur().loc.end = p.prev_loc.end;
                p.up();
                return;
            },
            .bytes => {
                try p.addChild(.bytes);
                p.cur().loc.end = p.tok.loc.end;
                p.up();
            },
            .identifier => {
                try p.addChild(.@"enum");
                p.cur().loc.end = p.tok.loc.end;
                p.up();
            },
            .integer => {
                try p.addChild(.integer);
                p.cur().loc.end = p.tok.loc.end;
                p.up();
            },
            .float => {
                try p.addChild(.float);
                p.cur().loc.end = p.tok.loc.end;
                p.up();
            },
            .pos_inf, .neg_inf, .nan => {
                try p.addChild(.float);
                p.cur().loc.end = p.tok.loc.end;
                p.up();
            },
            .true, .false => {
                try p.addChild(.bool);
                p.cur().loc.end = p.tok.loc.end;
                p.up();
            },
            .null => {
                try p.addChild(.null);
                p.cur().loc.end = p.tok.loc.end;
                p.up();
            },
            else => {
                if (p.tok.tag == .invalid) {
                    try p.err(.{
                        .tag = .unexpected_token,
                        .main_location = p.tok.loc,
                    });
                } else try p.err(.{
                    .tag = .missing_value,
                    .main_location = p.prev_loc,
                });

                try p.addChild(.missing_value);
                p.cur().loc = .{
                    .start = p.prev_loc.end,
                    .end = p.tok.loc.end,
                };
                p.up();
                try p.discardUntilRestart();
                return;
            },
        }
        p.consume();
    }

    fn discardUntilRestart(p: *Parser) !void {
        discard: switch (p.cur().tag) {
            .root => return,
            .braceless_struct => switch (p.tok.tag) {
                .identifier, .eof, .eod => return,
                else => {
                    p.consume();
                    continue :discard .braceless_struct;
                },
            },
            .struct_v => switch (p.tok.tag) {
                .comma, .identifier, .rb, .eof, .eod => return,
                else => {
                    p.consume();
                    continue :discard .struct_v;
                },
            },
            .dict_v, .struct_v_fixup => switch (p.tok.tag) {
                .comma, .bytes, .rb, .eof, .eod => return,
                else => {
                    p.consume();
                    continue :discard .dict_v;
                },
            },
            .struct_field,
            .dict_field,
            => switch (p.tok.tag) {
                .eof, .eod => return,
                .comma => {
                    p.cur().loc.end = p.tok.loc.end;
                    p.up();
                    continue :discard p.cur().tag;
                },
                .identifier, .bytes, .rb => {
                    p.cur().loc.end = p.tok.loc.start;
                    p.up();
                    continue :discard p.cur().tag;
                },
                else => {
                    p.consume();
                    // it's fine if we forget we were originally
                    // in a dict field as the handling is the same
                    // and p.up() will make us remember again when
                    // it matters
                    continue :discard .struct_field;
                },
            },
            .array_v => switch (p.tok.tag) {
                .comma, .eof, .eod => return,
                .rsb,
                => {
                    p.cur().loc.end = p.tok.loc.start;
                    p.up();
                    continue :discard p.cur().tag;
                },
                else => {
                    p.consume();
                    continue :discard .array_v;
                },
            },
            .array_element,
            => switch (p.tok.tag) {
                .eof, .eod => return,
                else => {
                    p.cur().loc.end = p.tok.loc.start;
                    // log.debug("cur = {any}", .{p.cur().*});
                    p.up();
                    continue :discard .array_v;
                },
            },
            .@"union" => switch (p.tok.tag) {
                .rp, .eof, .eod => return,
                else => {
                    p.consume();
                    continue :discard .@"union";
                },
            },
            .struct_h, .dict_h, .array_h => unreachable,
            .@"enum",
            .bytes,
            .bytes_multiline,
            .integer,
            .float,
            .bool,
            .null,
            .missing_value,
            => unreachable,
        }
    }

    fn cur(p: *Parser) *Node {
        return &p.nodes.items[p.node_idx];
    }

    fn curIsEmpty(p: *Parser) bool {
        // this is correct because we never go back to
        // evaluate older nodes.
        return p.node_idx == p.nodes.items.len - 1;
    }

    fn consume(p: *Parser) void {
        assert(p.tok.tag != .eof);
        assert(p.tok.tag != .eod);
        p.prev_loc = p.tok.loc;
        p.tok = p.tokenizer.next(p.src, true);
        // log.debug("new tok: [{t}] '{s}'", .{ p.tok.tag, p.tok.loc.slice(p.src) });
    }

    fn consumeAllowTopLevelComment(p: *Parser) void {
        assert(p.tok.tag != .eof);
        assert(p.tok.tag != .eod);
        p.prev_loc = p.tok.loc;
        p.tok = p.tokenizer.next(p.src);
        // log.debug("[tlc] new tok: [{t}] '{s}'", .{ p.tok.tag, p.tok.loc.slice(p.src) });
    }

    fn peek(p: *Parser) Token.Tag {
        var t = p.tokenizer;
        return t.next(p.src, true).tag;
    }

    fn addChild(p: *Parser, tag: Node.Tag) !void {
        const parent_idx = p.node_idx;

        p.node_idx = @intCast(p.nodes.items.len);
        try p.nodes.append(p.gpa, .{
            .tag = tag,
            .loc = .{ .start = p.tok.loc.start, .end = undefined },
            .parent_idx = parent_idx,
        });

        try p.meta.append(p.gpa, .{});
        const meta = &p.meta.items[parent_idx];
        if (meta.last_child_idx != 0) {
            p.nodes.items[meta.last_child_idx].next_idx = p.node_idx;
        }
        meta.last_child_idx = p.node_idx;
    }

    fn up(p: *Parser) void {
        const current = p.cur();
        // std.log.debug("up cur {any} tok {any}", .{ p.cur().*, p.tok });
        assert(current.loc.end >= current.loc.start);
        assert(current.loc.end <= p.src.len);
        p.node_idx = p.cur().parent_idx;
    }

    fn err(p: *Parser, e: Error) !void {
        // log.debug("err: {any}", .{e});
        switch (e.tag) {
            .wrong_field_separator,
            .wrong_field_style,
            => {},
            .unexpected_token,
            .missing_token,
            .missing_value,
            .empty_dict_key,
            => p.has_syntax_errors = true,
        }
        try p.errors.append(p.gpa, e);
    }

    fn finalize(p: *Parser) !Ast {
        switch (p.tok.tag) {
            .eof, .eod => {},
            else => try p.err(.{
                .tag = .unexpected_token,
                .main_location = p.tok.loc,
            }),
        }

        while (true) {
            p.cur().loc.end = p.tok.loc.start;
            if (p.node_idx == 0) break;
            p.up();
        }

        return .{
            .nodes = try p.nodes.toOwnedSlice(p.gpa),
            .errors = try p.errors.toOwnedSlice(p.gpa),
            .has_syntax_errors = p.has_syntax_errors,
            .delimiter = p.options.delimiter,
        };
    }
};

pub const Iterator = struct {
    nodes: []const Node,
    state: union(Direction) {
        enter: struct {
            from_idx: u32,
            next_idx: u32,
        },
        exit: struct {
            next_idx: u32,
            target_parent_idx: u32,
            target_idx: u32,
        },
        done: u32,
    } = .{ .enter = .{ .from_idx = 0, .next_idx = 1 } },

    pub const Direction = enum { enter, exit, done };
    pub const Event = union(Direction) {
        enter: *const Node,
        exit: *const Node,
        done,
    };

    /// Ensures the next event will exit the current node, skipping any children.
    pub fn skip(it: *Iterator) void {
        switch (it.state) {
            .enter => |enter| {
                var idx = enter.from_idx;
                switch (it.nodes[idx].tag) {
                    .bytes_multiline,
                    .@"enum",
                    .bytes,
                    .integer,
                    .float,
                    .bool,
                    .null,
                    => return,
                    else => {},
                }
                while (idx != 0) {
                    const node = it.nodes[idx];

                    if (node.next_idx != 0) {
                        it.state = .{
                            .exit = .{
                                .next_idx = enter.from_idx,
                                .target_parent_idx = node.parent_idx,
                                .target_idx = node.next_idx,
                            },
                        };
                        return;
                    }

                    idx = node.parent_idx;
                    it.state = .{ .done = enter.from_idx };
                    return;
                }
            },
            .exit, .done => {},
        }
    }

    pub fn next(it: *Iterator) Event {
        next: switch (it.state) {
            .enter => |enter| {
                assert(enter.next_idx != 0);
                const from_node = &it.nodes[enter.from_idx];
                const no_exit = switch (from_node.tag) {
                    .bytes_multiline,
                    .@"enum",
                    .bytes,
                    .integer,
                    .float,
                    .bool,
                    .null,
                    => true,
                    else => false,
                };

                if (it.nodes.len == enter.next_idx) {
                    it.state = .{
                        .done = if (no_exit) from_node.parent_idx else enter.from_idx,
                    };
                    continue :next it.state;
                }

                const next_node = &it.nodes[enter.next_idx];
                // child or current node is no_exit and next is sibling
                if (next_node.parent_idx == enter.from_idx or
                    (no_exit and next_node.parent_idx == from_node.parent_idx))
                {
                    it.state.enter = .{
                        .from_idx = enter.next_idx,
                        .next_idx = enter.next_idx + 1,
                    };
                    return .{ .enter = next_node };
                }

                assert(next_node.parent_idx <= from_node.parent_idx);
                it.state = .{
                    .exit = .{
                        .next_idx = if (no_exit) from_node.parent_idx else enter.from_idx,
                        .target_parent_idx = next_node.parent_idx,
                        .target_idx = enter.next_idx,
                    },
                };
                continue :next it.state;
            },
            .exit => |exit| {
                assert(exit.next_idx > exit.target_parent_idx);
                assert(exit.next_idx < exit.target_idx);
                const node = &it.nodes[exit.next_idx];
                if (node.parent_idx == exit.target_parent_idx) {
                    it.state = .{
                        .enter = .{
                            .from_idx = exit.target_parent_idx,
                            .next_idx = exit.target_idx,
                        },
                    };
                } else {
                    it.state.exit.next_idx = node.parent_idx;
                }
                return .{ .exit = node };
            },
            .done => |next_idx| {
                if (next_idx == 0) return .done;
                const node = &it.nodes[next_idx];
                it.state.done = node.parent_idx;
                return .{ .exit = node };
            },
        }
    }
};

pub const Format = struct {
    src: [:0]const u8,
    ast: *const Ast,
    rm: root.RenderMode,

    pub fn format(f: Format, w: *Writer) !void {
        try f.ast.render(f.src, f.rm, w);
    }
};

fn renderComments(
    at_newline: *bool,
    indent: u32,
    last_end: u32,
    src: [:0]const u8,
    r: *Renderer,
    w: *Writer,
) !void {
    var t: Tokenizer = .{ .idx = last_end, .delimiter = .none, .lines = 0 };
    var tok = t.next(src, false);
    var first = true;
    while (tok.tag == .comment_line) : (tok = t.next(src, false)) {
        if (first) {
            if (!at_newline.*) {
                if (t.lines > 1) {
                    try w.writeAll("\n");
                    try w.splatByteAll(' ', indent * 4);
                } else try w.writeAll(" ");
            } else {
                try w.splatByteAll(' ', indent * 4);
            }
            first = false;
        } else {
            try w.splatByteAll(' ', indent * 4);
        }
        try r.token(tok);
        try w.writeAll("\n");
    }
    at_newline.* |= !first;
}

const Fixup = struct { err: Error, idx: u32 };
fn nextFixup(ast: Ast, last_idx: u32) ?Fixup {
    for (ast.errors[last_idx..], last_idx..) |err, idx| {
        switch (err.tag) {
            .wrong_field_style => return .{ .err = err, .idx = @intCast(idx + 1) },
            else => continue,
        }
    }
    return null;
}

fn fixupApplies(f: ?Fixup, offset: u32) bool {
    if (f) |fixup| {
        return fixup.err.main_location.start == offset;
    }
    return false;
}

const Renderer = struct {
    w: *Writer,
    src: [:0]const u8,
    mode: root.RenderMode,
    // used for syntax-highlighting in the terminal
    ansi_style: ansi.style.Style = .{},

    fn lit(r: *Renderer, t: Tokenizer.Token.Tag) !void {
        switch (r.mode) {
            .plain => try r.w.writeAll(t.literal()),
            .html => {
                try r.w.print("<{0s}>{1s}</{0s}>", .{
                    htmlTag(t.kind()),
                    t.literal(),
                });
            },
            .terminal => {
                try r.styleUpdate(t.kind());
                try r.w.writeAll(t.literal());
                try r.styleClean();
            },
        }
    }

    fn token(r: *Renderer, tok: Tokenizer.Token) !void {
        if (tok.tag == .union_case) return r.union_case(tok);

        const tok_src = tok.loc.slice(r.src);
        switch (r.mode) {
            .plain => try r.w.writeAll(tok_src),
            .html => {
                try r.w.print("<{0s}>{1s}</{0s}>", .{
                    htmlTag(tok.tag.kind()),
                    tok_src,
                });
            },
            .terminal => {
                try r.styleUpdate(tok.tag.kind());
                try r.w.writeAll(tok_src);
                try r.styleClean();
            },
        }
    }

    fn node(r: *Renderer, n: *const Node) !void {
        const node_src = n.loc.slice(r.src);
        switch (r.mode) {
            .plain => try r.w.print("{s}", .{node_src}),
            .html => {
                try r.w.print("<{0s}>{1s}</{0s}>", .{
                    htmlTag(n.tag.kind()),
                    node_src,
                });
            },
            .terminal => {
                try r.styleUpdate(n.tag.kind());
                try r.w.writeAll(node_src);
                try r.styleClean();
            },
        }
    }

    fn identifier(r: *Renderer, name: []const u8) !void {
        switch (r.mode) {
            .plain => try r.w.print(".{s}", .{name}),
            .html => {
                try r.w.print("<{0s}>.{1s}</{0s}>", .{
                    htmlTag(.identifier),
                    name,
                });
            },
            .terminal => {
                try r.styleUpdate(.identifier);
                try r.w.print(".{s}", .{name});
                try r.styleClean();
            },
        }
    }

    fn union_case(r: *Renderer, tok: Tokenizer.Token) !void {
        const tok_src = tok.loc.slice(r.src);
        const case = tok_src[0 .. tok_src.len - 1];

        switch (r.mode) {
            .plain => try r.w.writeAll(case),
            .html => {
                try r.w.print("<{0s}>{1s}</{0s}>", .{
                    htmlTag(.@"enum"),
                    case,
                });
            },
            .terminal => {
                try r.styleUpdate(.@"enum");
                try r.w.writeAll(case);
                try r.styleClean();
            },
        }

        try r.left_paren();
    }

    fn bytes(r: *Renderer, b: []const u8) !void {
        switch (r.mode) {
            .plain => try r.w.print("\"{s}\"", .{b}),
            .html => {
                try r.w.print("<{0s}>\"{1s}\"</{0s}>", .{
                    htmlTag(.bytes),
                    b,
                });
            },
            .terminal => {
                try r.styleUpdate(.bytes);
                try r.w.print("\"{s}\"", .{b});
                try r.styleClean();
            },
        }
    }

    fn left_paren(r: *Renderer) !void {
        switch (r.mode) {
            .plain => try r.w.writeByte('('),
            .html => {
                try r.w.print("<{0s}>(</{0s}>", .{
                    htmlTag(.punctuation),
                });
            },
            .terminal => {
                try r.styleUpdate(.punctuation);
                try r.w.writeByte('(');
                try r.styleClean();
            },
        }
    }

    fn htmlTag(k: Tokenizer.Token.Tag.Kind) []const u8 {
        return switch (k) {
            .punctuation => "z-p",
            .identifier => "z-i",
            .bool => "z-b",
            .null => "z-n",
            .comment_line => "z-c",
            .bytes, .bytes_line => "z-b",
            .integer, .float => "z-n",
            .eod => "z-d",
            .@"enum" => "z-e",
        };
    }

    fn styleUpdate(r: *Renderer, k: Tokenizer.Token.Tag.Kind) !void {
        var new: ansi.style.Style = .{};

        switch (k) {
            .punctuation => {},
            .identifier => {},
            .bool => {
                new.foreground = .Red;
                new.font_style = .{
                    .bold = true,
                };
            },
            .null => {
                new.foreground = .Blue;
                new.font_style = .{
                    .bold = true,
                };
            },
            .comment_line => {
                new.font_style = .{
                    .italic = true,
                    .dim = true,
                };
            },
            .bytes, .bytes_line => {
                new.foreground = .Yellow;
            },
            .integer, .float => {
                new.foreground = .Blue;
            },
            .eod, .@"enum" => {
                new.foreground = .Yellow;
                new.font_style = .{
                    .bold = true,
                };
            },
        }

        try ansi.format.updateStyle(r.w, new, r.ansi_style);
        r.ansi_style = new;
    }

    fn styleClean(r: *Renderer) !void {
        var clean = r.ansi_style;
        clean.font_style = .{};
        try ansi.format.updateStyle(r.w, clean, r.ansi_style);
        r.ansi_style = clean;
    }

    fn done(r: *Renderer) void {
        switch (r.mode) {
            .terminal => {
                ansi.format.updateStyle(r.w, .{}, r.ansi_style) catch {};
                r.ansi_style = undefined;
            },
            else => {},
        }
    }
};

/// Formats the Ast and applies fixups. An Ast can have errors and still be
/// formatted but none of the errors can be a syntax error.
///
/// Asserts that `ast.has_syntax_errors` is false.
pub fn render(ast: Ast, src: [:0]const u8, mode: root.RenderMode, w: *Writer) Writer.Error!void {
    assert(!ast.has_syntax_errors);

    var r: Renderer = .{
        .w = w,
        .src = src,
        .mode = mode,
    };

    defer r.done();

    const nodes = ast.nodes;

    if (ast.nodes[0].loc.start != 0) {
        try w.writeAll(src[0..ast.nodes[0].loc.start]);
        try w.writeAll("\n");
    }

    var next_fixup: ?Fixup = ast.nextFixup(0);
    var it: Iterator = .{ .nodes = nodes };
    var indent: u32 = 0;
    var array_start = false;
    var at_newline = true;
    try renderComments(&at_newline, indent, 0, src, &r, w);
    while (true) {
        const ev = it.next();
        switch (ev) {
            .enter => |node| {
                switch (node.tag) {
                    .root, .missing_value => unreachable,
                    .braceless_struct => {},
                    .struct_h, .dict_h, .struct_v, .struct_v_fixup, .dict_v => {
                        switch (node.tag) {
                            .struct_v, .struct_v_fixup, .dict_v => indent += 1,
                            .struct_h, .dict_h => {},
                            else => unreachable,
                        }

                        const open_tag: Token.Tag = switch (node.tag) {
                            .struct_h, .struct_v, .struct_v_fixup => .dotlb,
                            .dict_h, .dict_v => .lb,
                            else => unreachable,
                        };

                        try r.lit(open_tag);
                        at_newline = false;
                        try renderComments(
                            &at_newline,
                            indent,
                            @intCast(node.loc.start + switch (open_tag) {
                                .dotlb => @as(u32, 2),
                                .lb => @as(u32, 1),
                                else => unreachable,
                            }),
                            src,
                            &r,
                            w,
                        );
                    },
                    .array_h, .array_v => {
                        array_start = true;
                        indent += @intFromBool(node.tag == .array_v);
                        try r.lit(.lsb);
                        at_newline = false;
                        try renderComments(&at_newline, indent, node.loc.start + 1, src, &r, w);
                    },
                    .struct_field, .dict_field => {
                        var t: Tokenizer = .{
                            .idx = node.loc.start,
                            .delimiter = .none,
                            .lines = 0,
                        };
                        const parent_tag = nodes[node.parent_idx].tag;
                        switch (parent_tag) {
                            .braceless_struct, .struct_v, .struct_v_fixup, .dict_v => {
                                if (!at_newline) try w.writeByte('\n');
                                try w.splatByteAll(' ', indent * 4);
                            },
                            .struct_h, .dict_h => try w.writeByte(' '),
                            else => unreachable,
                        }

                        const field_name = t.next(src, true);
                        const field_separator = t.next(src, true);
                        if (fixupApplies(next_fixup, field_name.loc.start)) {
                            assert(field_name.tag == switch (parent_tag) {
                                .braceless_struct, .struct_h, .struct_v, .struct_v_fixup => Token.Tag.bytes,
                                .dict_v, .dict_h => Token.Tag.identifier,
                                else => unreachable,
                            });
                            switch (parent_tag) {
                                .braceless_struct, .struct_h, .struct_v, .struct_v_fixup => {
                                    const slice = field_name.loc.slice(src);
                                    try r.identifier(slice[1 .. slice.len - 1]);
                                },
                                .dict_v, .dict_h => {
                                    const slice = field_name.loc.slice(src);
                                    try r.bytes(slice[1..]);
                                },
                                else => unreachable,
                            }
                            at_newline = false;
                            try renderComments(&at_newline, indent, field_name.loc.end, src, &r, w);
                            if (at_newline) try w.splatByteAll(' ', indent * 4);
                            assert(switch (field_separator.tag) {
                                .colon, .eql => true,
                                else => false,
                            });

                            next_fixup = ast.nextFixup(next_fixup.?.idx);
                        } else {
                            assert(field_name.tag == switch (parent_tag) {
                                .braceless_struct,
                                .struct_h,
                                .struct_v,
                                .struct_v_fixup,
                                => Token.Tag.identifier,
                                .dict_v, .dict_h => Token.Tag.bytes,
                                else => unreachable,
                            });
                            try r.token(field_name);
                            at_newline = false;
                            try renderComments(&at_newline, indent, field_name.loc.end, src, &r, w);
                            if (at_newline) try w.splatByteAll(' ', indent * 4);
                            assert(switch (field_separator.tag) {
                                .colon, .eql => true,
                                else => false,
                            });
                        }

                        switch (parent_tag) {
                            .braceless_struct, .struct_h, .struct_v, .struct_v_fixup => {
                                try w.writeByte(' ');
                                try r.lit(.eql);
                            },
                            .dict_v, .dict_h => try r.lit(.colon),
                            else => unreachable,
                        }
                        at_newline = false;
                        try renderComments(&at_newline, indent, field_separator.loc.end, src, &r, w);
                        try w.splatByteAll(' ', if (at_newline) indent * 4 else 1);
                    },
                    .array_element => {
                        if (nodes[node.parent_idx].tag == .array_v) {
                            if (!at_newline) try w.writeAll("\n");
                            try w.splatByteAll(' ', indent * 4);
                        } else if (!array_start) try w.writeAll(" ");
                        array_start = false;
                        at_newline = false;
                    },
                    .@"union" => {
                        var t: Tokenizer = .{
                            .idx = node.loc.start,
                            .delimiter = .none,
                            .lines = 0,
                        };
                        const case = t.next(src, true);
                        assert(case.tag == .union_case);
                        try r.token(case);
                        at_newline = false;
                        try renderComments(&at_newline, indent, case.loc.end, src, &r, w);
                    },
                    .bytes_multiline => {
                        var t: Tokenizer = .{
                            .idx = node.loc.start,
                            .delimiter = .none,
                            .lines = 0,
                        };
                        var line = t.next(src, false);
                        if (!at_newline) {
                            try w.writeAll("\n");
                        }
                        while (line.loc.start < node.loc.end) : (line = t.next(src, false)) {
                            try w.splatByteAll(' ', (indent + 1) * 4);
                            try r.token(line);
                            try w.writeAll("\n");
                        }
                        at_newline = true;
                        try renderComments(&at_newline, indent, node.loc.end, src, &r, w);
                    },
                    .@"enum",
                    .bytes,
                    .integer,
                    .float,
                    .bool,
                    .null,
                    => {
                        try r.node(node);
                        at_newline = false;
                        try renderComments(&at_newline, indent, node.loc.end, src, &r, w);
                    },
                }
            },
            .exit => |node| switch (node.tag) {
                .braceless_struct => {},
                .struct_h, .dict_h => {
                    const node_idx = node - ast.nodes.ptr;
                    if (ast.nodes.len > node_idx + 1 and
                        ast.nodes[node_idx + 1].parent_idx == node_idx)
                    {
                        try w.writeAll(" ");
                    }
                    try r.lit(.rb);
                    at_newline = false;
                    try renderComments(&at_newline, indent, node.loc.end, src, &r, w);
                },
                .struct_v, .struct_v_fixup, .dict_v => {
                    indent -= 1;
                    if (!at_newline) try w.writeAll("\n");
                    try w.splatByteAll(' ', indent * 4);
                    try r.lit(.rb);
                    at_newline = false;
                    try renderComments(&at_newline, indent, node.loc.end, src, &r, w);
                },
                .array_h => {
                    try r.lit(.rsb);
                    at_newline = false;
                    try renderComments(&at_newline, indent, node.loc.end, src, &r, w);
                },
                .array_v => {
                    indent -= 1;
                    if (!at_newline) try w.writeAll("\n");
                    try w.splatByteAll(' ', indent * 4);
                    try r.lit(.rsb);
                    at_newline = false;
                    try renderComments(&at_newline, indent, node.loc.end, src, &r, w);
                },
                .struct_field, .dict_field, .array_element => {
                    // Roundabout way to check if there is a comma at the
                    // end of our field. We cannot check for a literal
                    // comma because it might be the final char of a
                    // multiline string.
                    const has_comma = blk: {
                        const node_idx = node - ast.nodes.ptr;
                        assert(ast.nodes.len > node_idx + 1);
                        assert(ast.nodes[node_idx + 1].parent_idx == node_idx);
                        const child = ast.nodes[node_idx + 1];
                        break :blk (child.loc.end != node.loc.end);
                    };

                    if (has_comma or nodes[node.parent_idx].tag == .struct_v_fixup) {
                        if (at_newline) try w.splatByteAll(' ', indent * 4);
                        try r.lit(.comma);
                        at_newline = false;
                    }

                    if (has_comma) {
                        try renderComments(&at_newline, indent, node.loc.end, src, &r, w);
                    }
                },
                .@"union" => {
                    if (at_newline) try w.splatByteAll(' ', indent * 4);
                    try r.lit(.rp);
                    at_newline = false;
                    try renderComments(&at_newline, indent, node.loc.end, src, &r, w);
                },
                .root,
                .missing_value,
                .bytes_multiline,
                .@"enum",
                .bytes,
                .integer,
                .float,
                .bool,
                .null,
                => {
                    unreachable;
                },
            },
            .done => {
                try w.writeAll("\n");
                if (ast.delimiter != .none) {
                    try w.writeAll(src[ast.nodes[0].loc.end..]);
                }
                return;
            },
        }
    }
}

test "struct - empty" {
    const case =
        \\{}
    ;

    const ast = try Ast.init(std.testing.allocator, case, .{});
    defer ast.deinit(std.testing.allocator);

    errdefer std.debug.print("errors {any}", .{ast.errors});
    try std.testing.expect(ast.errors.len == 0);
}

test "dict - empty" {
    const case =
        \\{}
        \\
    ;

    const ast = try Ast.init(std.testing.allocator, case, .{});
    defer ast.deinit(std.testing.allocator);
    try std.testing.expectFmt(case, "{f}", .{ast.fmt(case, .plain)});
}

test "array - empty" {
    const case =
        \\[]
        \\
    ;

    const ast = try Ast.init(std.testing.allocator, case, .{});
    defer ast.deinit(std.testing.allocator);
    try std.testing.expectFmt(case, "{f}", .{ast.fmt(case, .plain)});
}

test "struct - basic" {
    const case =
        \\.{
        \\    .foo = 1,
        \\    .bar = 2,
        \\    .baz = 3,
        \\}
        \\
    ;

    const ast = try Ast.init(std.testing.allocator, case, .{});
    defer ast.deinit(std.testing.allocator);
    try std.testing.expectFmt(case, "{f}", .{ast.fmt(case, .plain)});
}

test "array - basic" {
    const case =
        \\[
        \\    1,
        \\    2,
        \\    3,
        \\]
        \\
    ;

    const ast = try Ast.init(std.testing.allocator, case, .{});
    defer ast.deinit(std.testing.allocator);
    try std.testing.expectFmt(case, "{f}", .{ast.fmt(case, .plain)});
}

test "braceless struct - basic" {
    const case =
        \\.foo = "hello",
        \\.bar = [1, 2, 3],
        \\
    ;

    const ast = try Ast.init(std.testing.allocator, case, .{});
    defer ast.deinit(std.testing.allocator);
    try std.testing.expectFmt(case, "{f}", .{ast.fmt(case, .plain)});
}

test "braceless struct - vertical" {
    const case =
        \\.foo = "hello",
        \\.bar = [
        \\    1,
        \\    2,
        \\    3,
        \\],
        \\.baz = {
        \\    "a": 1,
        \\    "b": 2,
        \\    "c": 3,
        \\},
        \\
    ;
    const ast = try Ast.init(std.testing.allocator, case, .{});
    defer ast.deinit(std.testing.allocator);
    try std.testing.expectFmt(case, "{f}", .{ast.fmt(case, .plain)});
}

test "braceless struct - complex" {
    const case =
        \\.foo = "bar",
        \\.bar = [
        \\    1,
        \\    2,
        \\    {
        \\        "abc": "foo",
        \\        "baz": ["foo", "bar"],
        \\    },
        \\    [
        \\        123456789,
        \\    ],
        \\],
        \\
    ;

    const ast = try Ast.init(std.testing.allocator, case, .{});
    defer ast.deinit(std.testing.allocator);
    try std.testing.expectFmt(case, "{f}", .{ast.fmt(case, .plain)});
}

test "frontmatter - complex" {
    const case =
        \\---
        \\.foo = "bar",
        \\.bar = [
        \\    1,
        \\    2,
        \\    {
        \\        "abc": "foo",
        \\        "baz": ["foo", "bar"],
        \\    },
        \\    [
        \\        123456789,
        \\    ],
        \\],
        \\---
        \\
    ;

    const ast = try Ast.init(std.testing.allocator, case, .{ .delimiter = .{ .dashes = 3 } });
    defer ast.deinit(std.testing.allocator);
    try std.testing.expectFmt(case, "{f}", .{ast.fmt(case, .plain)});
}

test "multiline in union" {
    const case =
        \\.foo = [
        \\    .myunion(
        \\        \\arstarst
        \\        \\arstarst
        \\        \\arstarst
        \\    ),
        \\],
        \\
    ;

    const ast = try Ast.init(std.testing.allocator, case, .{});
    defer ast.deinit(std.testing.allocator);
    try std.testing.expectFmt(case, "{f}", .{ast.fmt(case, .plain)});
}
