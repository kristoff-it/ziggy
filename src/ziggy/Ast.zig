const Ast = @This();

const std = @import("std");
const assert = std.debug.assert;
const Diagnostic = @import("Diagnostic.zig");
const Tokenizer = @import("Tokenizer.zig");
const Token = Tokenizer.Token;

const log = std.log.scoped(.ziggy_ast);

pub const Node = struct {
    tag: Tag,
    loc: Token.Loc = undefined,
    missing: bool = false,

    // 0 = root node (root node has itself as parent)
    parent_id: u32,

    // 0 = not present
    next_id: u32 = 0,
    first_child_id: u32 = 0,
    last_child_id: u32 = 0,

    pub const Tag = enum {
        root,
        top_comment,
        top_comment_line,
        braceless_struct,
        struct_or_map,
        @"struct",
        struct_field,
        identifier,
        map,
        map_field,
        map_field_key,
        array,
        string,
        multiline_string,
        line_string,
        integer,
        float,
        bool,
        null,
        tag,
        comment,
        value,

        // errros
        // error_node,
    };
};

code: [:0]const u8,
nodes: []const Node,

pub fn deinit(self: Ast, gpa: std.mem.Allocator) void {
    gpa.free(self.nodes);
}

const Parser = struct {
    gpa: std.mem.Allocator,
    code: [:0]const u8,
    tokenizer: Tokenizer,
    stop_on_first_error: bool,
    diagnostic: ?*Diagnostic,
    nodes: std.ArrayListUnmanaged(Node) = .{},
    node: *Node = undefined,
    token: Token = undefined,

    pub fn ast(p: *Parser) !Ast {
        return .{
            .code = p.code,
            .nodes = try p.nodes.toOwnedSlice(p.gpa),
        };
    }

    fn peek(p: *Parser) Token.Tag {
        return p.tokenizer.peek(p.code).tag;
    }

    fn next(p: *Parser) !void {
        const token = p.tokenizer.next(p.code);
        if (token.tag == .invalid) {
            try p.addError(.{ .invalid_token = .{ .token = token } });
        }
        p.token = token;
    }

    fn must(p: Parser, token: Token, comptime tag: Token.Tag) !void {
        return p.mustAny(token, &.{tag});
    }

    fn mustAny(p: Parser, token: Token, comptime tags: []const Token.Tag) !void {
        for (tags) |t| {
            if (t == token.tag) break;
        } else {
            try p.addError(.{
                .unexpected_token = .{
                    .token = token,
                    .expected = tags,
                },
            });
        }
    }

    pub fn addError(p: *Parser, err: Diagnostic.Error) !void {
        if (p.diagnostic) |d| {
            try d.errors.append(p.gpa, err);
        } else {
            return err.zigError();
        }
        if (p.stop_on_first_error) return err.zigError();
    }

    pub fn addChild(p: *Parser, tag: Node.Tag) !void {
        const n = p.node;
        const self_id = p.getId();
        const new_child_id: u32 = @intCast(p.nodes.items.len);
        if (n.last_child_id != 0) {
            const child = &p.nodes.items[n.last_child_id];
            std.debug.assert(child.next_id == 0);
            child.next_id = new_child_id;
        }
        if (n.first_child_id == 0) {
            std.debug.assert(n.last_child_id == 0);
            n.first_child_id = new_child_id;
        }

        n.last_child_id = new_child_id;
        const child = try p.nodes.addOne(p.gpa);
        child.* = .{ .tag = tag, .parent_id = self_id };

        p.node = child;
    }

    pub fn parent(p: *Parser) void {
        const n = p.node;
        p.node = &p.nodes.items[n.parent_id];
    }

    pub fn getId(p: Parser) u32 {
        const n = p.node;
        const idx: u32 = @intCast(
            (@intFromPtr(n) - @intFromPtr(p.nodes.items.ptr)) / @sizeOf(Node),
        );
        std.debug.assert(idx < p.nodes.items.len);
        return idx;
    }
};

pub fn init(
    gpa: std.mem.Allocator,
    code: [:0]const u8,
    want_comments: bool,
    stop_on_first_error: bool,
    diagnostic: ?*Diagnostic,
) !Ast {
    var p: Parser = .{
        .gpa = gpa,
        .code = code,
        .diagnostic = diagnostic,
        .stop_on_first_error = stop_on_first_error,
        .tokenizer = .{ .want_comments = want_comments },
    };

    if (p.diagnostic) |d| {
        d.code = p.code;
    }

    errdefer p.nodes.clearAndFree(gpa);

    const root_node = try p.nodes.addOne(gpa);
    root_node.* = .{ .tag = .root, .parent_id = 0 };

    p.node = root_node;
    try p.next();
    while (true) {
        log.debug("entering '{s}'", .{@tagName(p.node.tag)});
        switch (p.node.tag) {
            .comment, .multiline_string, .top_comment_line, .line_string => unreachable,
            .root => switch (p.token.tag) {
                .top_comment_line => {
                    try p.addChild(.top_comment);
                    p.node.loc.start = p.token.loc.start;
                },
                .dot, .comment => {
                    try p.addChild(.braceless_struct);
                    p.node.loc.start = p.token.loc.start;
                },
                .eof => return p.ast(),
                else => {
                    const last_child = p.nodes.items[p.node.last_child_id];
                    switch (last_child.tag) {
                        .root, .top_comment => {
                            while (true) : (try p.next()) {
                                switch (p.token.tag) {
                                    .identifier => {
                                        if (p.peek() == .lb) {
                                            break;
                                        } else {
                                            try p.addError(.{
                                                .unexpected_token = .{
                                                    .token = p.token,
                                                    .expected = &.{},
                                                },
                                            });
                                        }
                                    },
                                    else => break,
                                }
                            }
                            try p.addChild(.value);
                        },
                        else => {
                            while (p.token.tag != .eof) : (try p.next()) {
                                try p.addError(.{
                                    .unexpected_token = .{
                                        .token = p.token,
                                        .expected = &.{},
                                    },
                                });
                            }
                            return p.ast();
                        },
                    }
                },
            },
            .top_comment => switch (p.token.tag) {
                .top_comment_line => {
                    try p.addChild(.top_comment_line);
                    p.node.loc = p.token.loc;
                    p.parent();
                    p.node.loc.end = p.token.loc.end;
                    try p.next();
                },
                else => p.parent(),
            },
            .braceless_struct => switch (p.token.tag) {
                .eof => {
                    p.node.loc.end = p.token.loc.end;
                    return p.ast();
                },
                .comment => {
                    try p.addChild(.comment);
                    p.node.loc = p.token.loc;
                    p.parent();
                    try p.next();
                },
                .rb => {
                    try p.addError(.{
                        .unexpected_token = .{
                            .token = p.token,
                            .expected = &.{},
                        },
                    });
                    try p.next();
                },
                else => {
                    try p.addChild(.struct_field);
                    p.node.loc.start = p.token.loc.start;
                },
            },

            .struct_or_map => switch (p.token.tag) {
                .comment => {
                    try p.addChild(.comment);
                    p.node.loc = p.token.loc;
                    p.parent();
                    try p.next();
                },
                .rb => {
                    p.node.loc.end = p.token.loc.end;
                    p.parent();
                    try p.next();
                },
                .dot => {
                    p.node.tag = .@"struct";
                },
                .string => {
                    p.node.tag = .map;
                },
                else => {
                    p.node.loc.end = p.token.loc.start;
                    p.parent();
                    try p.addError(.{
                        .unexpected_token = .{
                            .token = p.token,
                            .expected = &.{ .dot, .string, .rb },
                        },
                    });
                },
            },

            .@"struct" => switch (p.token.tag) {
                .comment => {
                    try p.addChild(.comment);
                    p.node.loc = p.token.loc;
                    p.parent();
                    try p.next();
                },
                .rb => {
                    p.node.loc.end = p.token.loc.end;
                    p.parent();
                    try p.next();
                },
                else => try p.addChild(.struct_field),
            },

            .struct_field => {
                const last_child = p.nodes.items[p.node.last_child_id];
                log.debug("last: '{s}'", .{
                    @tagName(last_child.tag),
                });
                switch (last_child.tag) {
                    .root => {
                        // first time entering, struct has no children
                        p.node.loc.start = p.token.loc.start;
                        if (p.token.tag == .dot) {
                            try p.next();
                        } else {
                            try p.addError(.{
                                .unexpected_token = .{
                                    .token = p.token,
                                    .expected = &.{.dot},
                                },
                            });
                        }

                        try p.addChild(.identifier);
                        if (p.token.tag == .identifier) {
                            p.node.loc = p.token.loc;
                            p.parent();
                            try p.next();
                        } else {
                            p.node.missing = true;
                            p.node.loc.start = p.token.loc.start;
                            p.node.loc.end = p.node.loc.start;
                            p.parent();
                        }

                        // Collect garbage until punctuation
                        while (true) : (try p.next()) {
                            log.debug("garbage loop: '{s}'", .{
                                @tagName(p.token.tag),
                            });
                            switch (p.token.tag) {
                                .eql,
                                .colon,
                                // start of a value
                                .lb,
                                .lsb,
                                .at,
                                .string,
                                .integer,
                                .float,
                                .true,
                                .false,
                                .null,
                                => break,
                                .identifier => {
                                    if (p.peek() == .lb) {
                                        break;
                                    } else {
                                        try p.addError(.{
                                            .unexpected_token = .{
                                                .token = p.token,
                                                .expected = &.{},
                                            },
                                        });
                                    }
                                },

                                .dot, .comma, .rb, .rsb, .eof => {
                                    p.node.loc.end = p.token.loc.end;
                                    try p.addChild(.value);
                                    p.node.missing = true;
                                    p.node.loc.start = p.token.loc.start;
                                    p.node.loc.end = p.node.loc.start;
                                    p.parent();
                                    p.parent();
                                    if (p.token.tag == .comma) {
                                        try p.next();
                                    }
                                    break;
                                },
                                else => {
                                    try p.addError(.{
                                        .unexpected_token = .{
                                            .token = p.token,
                                            .expected = &.{},
                                        },
                                    });
                                },
                            }
                        }
                        log.debug("exiting struct_field: '{s}'", .{
                            @tagName(p.node.tag),
                        });
                    },
                    .identifier => {
                        log.debug("struct field identifier", .{});
                        if (p.token.tag == .eql) {
                            try p.next();
                        } else {
                            try p.addError(.{
                                .unexpected_token = .{
                                    .token = p.token,
                                    .expected = &.{.eql},
                                },
                            });
                        }

                        while (true) : (try p.next()) {
                            switch (p.token.tag) {
                                else => break,
                                .identifier => {
                                    if (p.peek() == .lb) {
                                        break;
                                    } else {
                                        try p.addError(.{
                                            .unexpected_token = .{
                                                .token = p.token,
                                                .expected = &.{},
                                            },
                                        });
                                    }
                                },
                            }
                        }
                        try p.addChild(.value);
                    },
                    else => {
                        log.debug("struct field final", .{});
                        // Collect garbage until punctuation
                        while (true) : (try p.next()) {
                            switch (p.token.tag) {
                                .comma => {
                                    p.node.loc.end = p.token.loc.end;
                                    p.parent();
                                    try p.next();
                                    break;
                                },
                                .dot, .rb, .rsb, .eof => {
                                    p.node.loc.end = p.token.loc.start;
                                    p.parent();
                                    break;
                                },
                                else => {
                                    try p.addError(.{
                                        .unexpected_token = .{
                                            .token = p.token,
                                            .expected = &.{.comma},
                                        },
                                    });
                                },
                            }
                        }
                    },
                }
            },

            .map => switch (p.token.tag) {
                .comment => {
                    try p.addChild(.comment);
                    p.node.loc = p.token.loc;
                    p.parent();
                    try p.next();
                },
                .rb, .eof, .dot => {
                    if (p.token.tag == .rb) {
                        p.node.loc.end = p.token.loc.end;
                        try p.next();
                    } else {
                        p.node.loc.end = p.token.loc.start;
                        try p.addError(.{
                            .unexpected_token = .{
                                .token = p.token,
                                .expected = &.{.rb},
                            },
                        });
                    }
                    p.parent();
                },
                else => {
                    try p.addChild(.map_field);
                    p.node.loc.start = p.token.loc.start;
                },
            },

            .map_field => {
                const last_child = p.nodes.items[p.node.last_child_id];
                log.debug(" last: '{s}'", .{@tagName(last_child.tag)});
                switch (last_child.tag) {
                    .root => {
                        p.node.loc.start = p.token.loc.start;
                        try p.addChild(.map_field_key);
                        const first_token = p.token;
                        var found_key = false;
                        while (true) : (try p.next()) {
                            switch (p.token.tag) {
                                .eql, .colon, .comma, .rb => break,
                                .string => {
                                    if (found_key) {
                                        try p.addError(.{
                                            .unexpected_token = .{
                                                .token = p.token,
                                                .expected = &.{ .string, .rb },
                                            },
                                        });
                                    } else {
                                        found_key = true;
                                        p.node.loc = p.token.loc;
                                    }
                                },
                                else => try p.addError(.{
                                    .unexpected_token = .{
                                        .token = p.token,
                                        .expected = &.{ .string, .rb },
                                    },
                                }),
                            }
                        }

                        if (!found_key) {
                            p.node.missing = true;
                            p.node.loc.start = first_token.loc.start;
                            p.node.loc.end = p.node.loc.start + 1;
                        }

                        p.parent();
                    },
                    .map_field_key => {
                        if (p.token.tag == .colon) {
                            try p.next();
                        } else {
                            try p.addError(.{
                                .unexpected_token = .{
                                    .token = p.token,
                                    .expected = &.{.colon},
                                },
                            });
                        }
                        try p.addChild(.value);
                        while (true) : (try p.next()) {
                            switch (p.token.tag) {
                                .rsb, .invalid, .colon, .eql => try p.addError(.{
                                    .unexpected_token = .{
                                        .token = p.token,
                                        .expected = &.{.value},
                                    },
                                }),
                                .identifier => {
                                    if (p.peek() == .lb) {
                                        break;
                                    } else {
                                        try p.addError(.{
                                            .unexpected_token = .{
                                                .token = p.token,
                                                .expected = &.{},
                                            },
                                        });
                                    }
                                },
                                else => break,
                            }
                        }
                    },
                    else => {
                        while (true) : (try p.next()) {
                            switch (p.token.tag) {
                                .comma => {
                                    p.node.loc.end = p.token.loc.end;
                                    p.parent();
                                    try p.next();
                                    break;
                                },
                                .rb, .eof => {
                                    p.node.loc.end = p.token.loc.start;
                                    p.parent();
                                    break;
                                },
                                .string => {
                                    p.node.loc.end = p.token.loc.start;
                                    try p.addError(.{
                                        .unexpected_token = .{
                                            .token = p.token,
                                            .expected = &.{.comma},
                                        },
                                    });
                                    p.parent();
                                },
                                else => try p.addError(.{
                                    .unexpected_token = .{
                                        .token = p.token,
                                        .expected = &.{},
                                    },
                                }),
                            }
                        }
                    },
                }
            },
            .array => {
                const last_child = p.nodes.items[p.node.last_child_id];
                log.debug(" last: '{s}'", .{@tagName(last_child.tag)});

                // while (p.token.tag == .comment) : (try p.next()) {
                //     try p.addChild(.comment);
                //     p.node.loc = p.token.loc;
                //     p.parent();
                // }

                if (p.node.last_child_id == 0) {
                    p.node.loc.start = p.token.loc.start;
                } else {
                    if (p.token.tag == .comma) {
                        try p.next();
                    } else {
                        if (p.token.tag != .rsb) {
                            try p.addError(.{
                                .unexpected_token = .{
                                    .token = p.token,
                                    .expected = &.{.comma},
                                },
                            });
                        }
                    }
                }

                while (true) : (try p.next()) {
                    switch (p.token.tag) {
                        .rsb, .eof => {
                            if (p.token.tag == .rsb) {
                                p.node.loc.end = p.token.loc.end;
                                try p.next();
                            } else {
                                p.node.loc.end = p.token.loc.start;
                                try p.addError(.{
                                    .unexpected_token = .{
                                        .token = p.token,
                                        .expected = &.{.comma},
                                    },
                                });
                            }
                            p.parent();
                            break;
                        },
                        .colon => {
                            try p.addChild(.value);
                            p.node.missing = true;
                            p.node.loc = p.token.loc;
                            p.parent();
                            break;
                        },
                        .rb, .invalid, .eql => try p.addError(.{
                            .unexpected_token = .{
                                .token = p.token,
                                .expected = &.{.value},
                            },
                        }),
                        .identifier => {
                            if (p.peek() == .lb) {
                                break;
                            } else {
                                try p.addError(.{
                                    .unexpected_token = .{
                                        .token = p.token,
                                        .expected = &.{},
                                    },
                                });
                            }
                        },
                        else => {
                            try p.addChild(.value);
                            break;
                        },
                    }
                }
            },

            .value => switch (p.token.tag) {
                .lb => {
                    p.node.tag = .struct_or_map;
                    p.node.loc.start = p.token.loc.start;
                    try p.next();
                },
                .identifier => {
                    p.node.tag = .struct_or_map;
                    p.node.loc.start = p.token.loc.start;
                    try p.addChild(.identifier);
                    p.node.loc = p.token.loc;
                    p.parent();
                    try p.next();
                    assert(p.token.tag == .lb);
                    try p.next();
                },
                .lsb => {
                    p.node.tag = .array;
                    p.node.loc.start = p.token.loc.start;
                    try p.next();
                },
                .at => {
                    p.node.tag = .tag;
                    p.node.loc.start = p.token.loc.start;
                    const tag_token = p.token;

                    try p.next();

                    try p.addChild(.identifier);

                    if (p.token.tag == .identifier) {
                        p.node.loc = p.token.loc;
                        p.parent();
                        p.node.loc.end = p.token.loc.end;
                        try p.next();
                    } else {
                        p.node.missing = true;
                        p.node.loc = tag_token.loc;
                        p.parent();
                        p.node.loc.end = tag_token.loc.end;
                    }

                    // TODO: make resilient

                    if (p.token.tag != .lp) {
                        try p.addError(.{
                            .unexpected_token = .{
                                .token = p.token,
                                .expected = &.{.lp},
                            },
                        });
                    }

                    try p.next();
                    if (p.token.tag != .string) {
                        try p.addError(.{
                            .unexpected_token = .{
                                .token = p.token,
                                .expected = &.{.string},
                            },
                        });
                    }
                    try p.addChild(.string);
                    p.node.loc = p.token.loc;

                    try p.next();
                    if (p.token.tag != .rp) {
                        try p.addError(.{
                            .unexpected_token = .{
                                .token = p.token,
                                .expected = &.{.rp},
                            },
                        });
                    }

                    // go up 2 nodes
                    p.parent();
                    p.parent();
                    try p.next();
                },
                .string => {
                    p.node.tag = .string;
                    p.node.loc = p.token.loc;
                    p.parent();
                    try p.next();
                },
                .line_string => {
                    p.node.tag = .multiline_string;
                    p.node.loc.start = p.token.loc.start;
                    while (p.token.tag == .line_string) {
                        try p.addChild(.line_string);
                        p.node.loc = p.token.loc;
                        p.parent();
                        p.node.loc.end = p.token.loc.end;
                        try p.next();
                    }

                    p.parent();
                },
                .integer => {
                    p.node.tag = .integer;
                    p.node.loc = p.token.loc;
                    p.parent();
                    try p.next();
                },
                .float => {
                    p.node.tag = .float;
                    p.node.loc = p.token.loc;
                    p.parent();
                    try p.next();
                },
                .true, .false => {
                    p.node.tag = .bool;
                    p.node.loc = p.token.loc;
                    p.parent();
                    try p.next();
                },
                .null => {
                    p.node.tag = .null;
                    p.node.loc = p.token.loc;
                    p.parent();
                    try p.next();
                },
                else => {
                    p.node.tag = .value;
                    p.node.missing = true;
                    p.node.loc.start = p.token.loc.start;
                    p.node.loc.end = p.node.loc.start;
                    p.parent();
                    try p.addError(.{
                        .unexpected_token = .{
                            .token = p.token,
                            .expected = &.{.value},
                        },
                    });
                },
            },

            .map_field_key,
            .tag,
            .identifier,
            .string,
            .integer,
            .float,
            .bool,
            .null,
            => unreachable,
        }
    }
}

pub fn format(
    self: Ast,
    comptime fmt: []const u8,
    options: std.fmt.FormatOptions,
    out_stream: anytype,
) !void {
    _ = fmt;
    _ = options;

    try render(self.nodes, self.code, out_stream);
}

const RenderMode = enum { horizontal, vertical };
const ContainerLayout = enum { @"struct", map };
pub fn render(nodes: []const Node, code: [:0]const u8, w: anytype) anyerror!void {
    var value_idx: u32 = 1;
    const value = nodes[value_idx];
    if (value.tag == .top_comment) {
        value_idx = value.next_id;
        var line_idx = value.first_child_id;
        assert(line_idx != 0);
        while (line_idx != 0) {
            const line = nodes[line_idx];
            try w.print("{s}\n", .{line.loc.src(code)});
            line_idx = line.next_id;
        }
        try w.writeAll("\n");
    }
    try renderValue(0, nodes[value_idx], nodes, code, true, w);
}

fn renderValue(
    indent: usize,
    node: Node,
    nodes: []const Node,
    code: [:0]const u8,
    is_top_value: bool,
    w: anytype,
) anyerror!void {
    switch (node.tag) {
        .root => return,
        .braceless_struct => {
            std.debug.assert(node.first_child_id != 0);
            try renderFields(indent, .vertical, .@"struct", node.first_child_id, nodes, code, w);
        },

        .@"struct" => {
            if (node.first_child_id == 0) {
                try w.writeAll("{}");
                return;
            }

            var idx = node.first_child_id;
            if (nodes[idx].tag == .identifier) {
                try w.print("{s} ", .{nodes[idx].loc.src(code)});
                idx = nodes[idx].next_id;
            }
            const mode: RenderMode = blk: {
                if (is_top_value or
                    hasMultilineSiblings(idx, nodes))
                {
                    break :blk .vertical;
                }

                std.debug.assert(node.last_child_id != 0);
                const char = nodes[node.last_child_id].loc.end - 1;
                if (code[char] == ',') break :blk .vertical;
                break :blk .horizontal;
            };
            switch (mode) {
                .vertical => try w.writeAll("{\n"),
                .horizontal => try w.writeAll("{ "),
            }
            try renderFields(indent + 1, mode, .@"struct", idx, nodes, code, w);
            switch (mode) {
                .vertical => {
                    try printIndent(indent, w);
                },
                .horizontal => try w.writeAll(" "),
            }
            try w.writeAll("}");
        },

        .map => {
            // empty map literals are .struct_or_map nodes
            std.debug.assert(node.first_child_id != 0);

            var idx = node.first_child_id;
            const layout: ContainerLayout = if (nodes[idx].tag == .identifier) blk: {
                try w.print("{s} ", .{nodes[idx].loc.src(code)});
                idx = nodes[idx].next_id;
                break :blk .@"struct";
            } else .map;

            const mode: RenderMode = blk: {
                if (hasMultilineSiblings(idx, nodes)) {
                    break :blk .vertical;
                }
                std.debug.assert(node.last_child_id != 0);
                const char = nodes[node.last_child_id].loc.end - 1;
                if (code[char] == ',') break :blk .vertical;
                break :blk .horizontal;
            };

            switch (mode) {
                .vertical => try w.writeAll("{\n"),
                .horizontal => try w.writeAll("{ "),
            }

            try renderFields(indent + 1, mode, layout, idx, nodes, code, w);

            switch (mode) {
                .vertical => {
                    try printIndent(indent, w);
                },
                .horizontal => try w.writeAll(" "),
            }
            try w.writeAll("}");
        },

        .array => {
            if (node.first_child_id == 0) {
                try w.writeAll("[]");
                return;
            }
            const mode: RenderMode = if (hasMultilineSiblings(node.first_child_id, nodes))
                .vertical
            else blk: {
                const start = nodes[node.last_child_id].loc.end;
                const end = node.loc.end;
                if (std.mem.indexOfScalar(u8, code[start..end], ',') != null) {
                    break :blk .vertical;
                }
                break :blk .horizontal;
            };

            switch (mode) {
                .vertical => try w.writeAll("[\n"),
                .horizontal => try w.writeAll("["),
            }
            try renderArray(indent + 1, mode, node.first_child_id, nodes, code, w);
            try w.writeAll("]");
        },

        .tag => {
            const tag_name = nodes[node.first_child_id].loc.src(code);
            try w.print("@{s}(", .{tag_name});
            const value = nodes[node.last_child_id];
            try renderValue(indent, value, nodes, code, false, w);
            try w.writeAll(")");
        },

        .multiline_string => {
            var idx = node.first_child_id;
            std.debug.assert(idx != 0);
            const parent = nodes[node.parent_id];
            const in_array = parent.tag != .struct_field and
                parent.tag != .map_field;
            if (!in_array) {
                try w.writeAll("\n");
            }

            var array_first_loop = in_array;
            while (idx != 0) {
                if (array_first_loop) {
                    try printIndent(1, w);
                } else {
                    try printIndent(indent + 1, w);
                }
                array_first_loop = false;
                const line = nodes[idx];
                try w.print("{s}\n", .{line.loc.src(code)});

                idx = line.next_id;
            }
            try printIndent(indent, w);
        },
        else => {
            try w.print("{s}", .{node.loc.src(code)});
        },
    }
}

fn printIndent(indent: usize, w: anytype) !void {
    for (0..indent) |_| try w.writeAll("    ");
}

fn hasMultilineSiblings(idx: u32, nodes: []const Node) bool {
    var current_idx = idx;
    while (current_idx != 0) {
        const node = nodes[current_idx];
        if (node.tag == .comment or
            node.tag == .multiline_string)
        {
            return true;
        }
        current_idx = node.next_id;
    }
    return false;
}

fn printComments(
    indent: usize,
    node: Node,
    nodes: []const Node,
    code: [:0]const u8,
    w: anytype,
) !?Node {
    std.debug.assert(node.tag == .comment);

    var comment = node;
    while (comment.tag == .comment) {
        try printIndent(indent, w);
        try w.writeAll(comment.loc.src(code));
        try w.writeAll("\n");
        if (comment.next_id != 0) {
            comment = nodes[comment.next_id];
        } else {
            return null;
        }
    }

    return comment;
}

fn renderArray(
    indent: usize,
    mode: RenderMode,
    idx: u32,
    nodes: []const Node,
    code: [:0]const u8,
    w: anytype,
) !void {
    var seen_values = false;
    var maybe_value: ?Node = nodes[idx];
    while (maybe_value) |value| {
        if (value.tag == .comment) {
            if (seen_values) {
                try printIndent(indent, w);
                try w.writeAll("\n");
            }
            maybe_value = try printComments(indent, value, nodes, code, w);
            continue;
        }
        seen_values = true;
        if (mode == .vertical) {
            try printIndent(indent, w);
        }
        try renderValue(indent, value, nodes, code, false, w);

        if (value.next_id != 0) {
            maybe_value = nodes[value.next_id];
        } else {
            maybe_value = null;
        }

        switch (mode) {
            .vertical => try w.writeAll(",\n"),
            .horizontal => {
                if (maybe_value != null) {
                    try w.writeAll(", ");
                }
            },
        }
    }
}

fn renderFields(
    indent: usize,
    mode: RenderMode,
    layout: ContainerLayout,
    idx: u32,
    nodes: []const Node,
    code: [:0]const u8,
    w: anytype,
) !void {
    assert(idx != 0);
    var seen_fields = false;
    var maybe_field: ?Node = nodes[idx];
    while (maybe_field) |field| {
        if (field.tag == .comment) {
            // if (seen_fields) {
            //     try printIndent(indent, w);
            //     try w.writeAll("\n");
            // }
            maybe_field = try printComments(indent, field, nodes, code, w);
            continue;
        }
        seen_fields = true;

        assert(field.tag == .struct_field or field.tag == .map_field);
        const field_name = if (layout == .@"struct" and field.tag == .map_field)
            nodes[field.first_child_id].loc.unquote(code) orelse @panic("TODO: string to identifier")
        else
            nodes[field.first_child_id].loc.src(code);

        if (mode == .vertical) {
            try printIndent(indent, w);
        }

        const symbols: [2][]const u8 = switch (layout) {
            .@"struct" => .{ ".", " =" },
            .map => .{ "", ":" },
        };

        try w.print("{s}{s}{s} ", .{ symbols[0], field_name, symbols[1] });
        try renderValue(indent, nodes[field.last_child_id], nodes, code, false, w);

        if (field.next_id != 0) {
            maybe_field = nodes[field.next_id];
        } else {
            maybe_field = null;
        }

        switch (mode) {
            .vertical => try w.writeAll(",\n"),
            .horizontal => {
                if (maybe_field != null) {
                    try w.writeAll(", ");
                }
            },
        }
    }
}

test "basics" {
    const case =
        \\.foo = "bar",
        \\.bar = [1, 2, 3],
        \\
    ;

    var diag: Diagnostic = .{ .path = null };
    errdefer std.debug.print("diag: {}", .{diag});
    const ast = try Ast.init(std.testing.allocator, case, true, true, &diag);
    defer ast.deinit(std.testing.allocator);
    try std.testing.expectFmt(case, "{}", .{ast});
}

test "vertical" {
    const case =
        \\.foo = "bar",
        \\.bar = [
        \\    1,
        \\    2,
        \\    3,
        \\],
        \\
    ;

    var diag: Diagnostic = .{ .path = null };
    errdefer std.debug.print("diag: {}", .{diag});
    const ast = try Ast.init(std.testing.allocator, case, true, true, &diag);
    defer ast.deinit(std.testing.allocator);
    try std.testing.expectFmt(case, "{}", .{ast});
}

test "complex" {
    const case =
        \\.foo = "bar",
        \\.bar = [
        \\    1,
        \\    2,
        \\    {
        \\        "abc": "foo",
        \\        "baz": ["foo", "bar"],
        \\    },
        \\],
        \\
    ;

    var diag: Diagnostic = .{ .path = null };
    errdefer std.debug.print("diag: {}", .{diag});
    const ast = try Ast.init(std.testing.allocator, case, true, true, &diag);
    defer ast.deinit(std.testing.allocator);
    try std.testing.expectFmt(case, "{}", .{ast});
}
