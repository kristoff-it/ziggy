const Ast = @This();

const std = @import("std");
const assert = std.debug.assert;
const Diagnostic = @import("Diagnostic.zig");
const Tokenizer = @import("Tokenizer.zig");

pub const Node = struct {
    tag: Tag,
    loc: Tokenizer.Token.Loc = undefined,

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
        array,
        array_comma,
        string,
        multiline_string,
        line_string,
        integer,
        float,
        bool,
        null,
        tag,
        comment,
        _value,
    };

    pub fn addChild(
        self: *Node,
        nodes: *std.ArrayList(Node),
        tag: Node.Tag,
    ) !*Node {
        const self_id = self.getId(nodes);
        const new_child_id: u32 = @intCast(nodes.items.len);
        if (self.last_child_id != 0) {
            const child = &nodes.items[self.last_child_id];
            std.debug.assert(child.next_id == 0);

            child.next_id = new_child_id;
        }
        if (self.first_child_id == 0) {
            std.debug.assert(self.last_child_id == 0);
            self.first_child_id = new_child_id;
        }

        self.last_child_id = new_child_id;
        const child = try nodes.addOne();
        child.* = .{ .tag = tag, .parent_id = self_id };

        return child;
    }

    pub fn parent(self: *Node, nodes: *std.ArrayList(Node)) *Node {
        return &nodes.items[self.parent_id];
    }

    pub fn getId(self: *Node, nodes: *std.ArrayList(Node)) u32 {
        const idx: u32 = @intCast(
            (@intFromPtr(self) - @intFromPtr(nodes.items.ptr)) / @sizeOf(Node),
        );
        std.debug.assert(idx < nodes.items.len);
        return idx;
    }
};

code: [:0]const u8,
nodes: std.ArrayList(Node),
tokenizer: Tokenizer,
diag: ?*Diagnostic,

pub fn deinit(self: Ast) void {
    self.nodes.deinit();
}

pub fn init(
    gpa: std.mem.Allocator,
    code: [:0]const u8,
    want_comments: bool,
    diag: ?*Diagnostic,
) !Ast {
    var ast: Ast = .{
        .code = code,
        .diag = diag,
        .tokenizer = .{ .want_comments = want_comments },
        .nodes = std.ArrayList(Node).init(gpa),
    };
    errdefer ast.nodes.clearAndFree();

    if (ast.diag) |d| {
        d.code = code;
    }

    const root_node = try ast.nodes.addOne();
    root_node.* = .{ .tag = .root, .parent_id = 0 };

    var node = root_node;
    var token = try ast.next();
    while (true) {
        switch (node.tag) {
            .comment, .multiline_string, .top_comment_line, .line_string => unreachable,
            .root => switch (token.tag) {
                .top_comment_line => {
                    node = try node.addChild(&ast.nodes, .top_comment);
                    node.loc.start = token.loc.start;
                },
                .dot, .comment => {
                    node = try node.addChild(&ast.nodes, .braceless_struct);
                    node.loc.start = token.loc.start;
                },
                .eof => return ast,
                else => {
                    node = try node.addChild(&ast.nodes, ._value);
                },
            },
            .top_comment => switch (token.tag) {
                .top_comment_line => {
                    assert(node.tag == .top_comment);
                    node = try node.addChild(&ast.nodes, .top_comment_line);
                    node.loc = token.loc;
                    node = node.parent(&ast.nodes);
                    node.loc.end = token.loc.end;
                    token = try ast.next();
                },
                else => node = node.parent(&ast.nodes),
            },
            .braceless_struct => switch (token.tag) {
                .eof => {
                    node.loc.end = token.loc.end;
                    return ast;
                },
                .comment => {
                    node = try node.addChild(&ast.nodes, .comment);
                    node.loc = token.loc;
                    node = node.parent(&ast.nodes);
                    token = try ast.next();
                },
                .dot => {
                    node = try node.addChild(&ast.nodes, .struct_field);
                    node.loc.start = token.loc.start;
                    token = try ast.next();
                },
                else => {
                    if (ast.diag) |d| {
                        d.tok = token;
                        d.err = .{
                            .unexpected_token = .{
                                .expected = &.{ .eof, .dot },
                            },
                        };
                    }
                    return error.Syntax;
                },
            },

            .struct_or_map => switch (token.tag) {
                .comment => {
                    node = try node.addChild(&ast.nodes, .comment);
                    node.loc = token.loc;
                    node = node.parent(&ast.nodes);
                    token = try ast.next();
                },
                .rb => {
                    node.loc.end = token.loc.end;
                    node = node.parent(&ast.nodes);
                    token = try ast.next();
                },
                .dot => {
                    node.tag = .@"struct";
                },
                .string => {
                    node.tag = .map;
                },
                else => {
                    if (ast.diag) |d| {
                        d.tok = token;
                        d.err = .{
                            .unexpected_token = .{
                                .expected = &.{ .dot, .string, .rb },
                            },
                        };
                    }
                    return error.Syntax;
                },
            },

            .@"struct" => switch (token.tag) {
                .comment => {
                    node = try node.addChild(&ast.nodes, .comment);
                    node.loc = token.loc;
                    node = node.parent(&ast.nodes);
                    token = try ast.next();
                },
                .dot => {
                    node = try node.addChild(&ast.nodes, .struct_field);
                    node.loc.start = token.loc.start;
                    token = try ast.next();
                },
                .rb => {
                    node.loc.end = token.loc.end;
                    node = node.parent(&ast.nodes);
                    token = try ast.next();
                },
                else => {
                    if (ast.diag) |d| {
                        d.tok = token;
                        d.err = .{
                            .unexpected_token = .{
                                .expected = &.{ .dot, .rb },
                            },
                        };
                    }
                    return error.Syntax;
                },
            },

            .struct_field => {
                if (node.first_child_id == 0) {
                    if (token.tag == .identifier) {
                        node = try node.addChild(&ast.nodes, .identifier);
                        node.loc = token.loc;
                        node = node.parent(&ast.nodes);
                    } else {
                        if (ast.diag) |d| {
                            d.tok = token;
                            d.err = .{
                                .unexpected_token = .{
                                    .expected = &.{.identifier},
                                },
                            };
                        }
                        return error.Syntax;
                    }

                    const t = try ast.next();
                    if (t.tag != .eql) {
                        if (ast.diag) |d| {
                            d.tok = t;
                            d.err = .{
                                .unexpected_token = .{
                                    .expected = &.{.eql},
                                },
                            };
                        }
                        return error.Syntax;
                    }

                    node = try node.addChild(&ast.nodes, ._value);
                    token = try ast.next();
                } else {
                    node.loc.end = token.loc.end;

                    if (token.tag == .comma) {
                        token = try ast.next();
                    } else {
                        if (token.tag != .rb and token.tag != .eof) {
                            if (ast.diag) |d| {
                                d.tok = token;
                                d.err = .{
                                    .unexpected_token = .{
                                        .expected = &.{.comma},
                                    },
                                };
                            }
                            return error.Syntax;
                        }
                    }

                    node = node.parent(&ast.nodes);
                }
            },

            .map => switch (token.tag) {
                .comment => {
                    node = try node.addChild(&ast.nodes, .comment);
                    node.loc = token.loc;
                    node = node.parent(&ast.nodes);
                    token = try ast.next();
                },
                .string => {
                    node = try node.addChild(&ast.nodes, .map_field);
                    node.loc.start = token.loc.start;
                },
                .rb => {
                    node.loc.end = token.loc.end;
                    node = node.parent(&ast.nodes);
                    token = try ast.next();
                },
                else => {
                    if (ast.diag) |d| {
                        d.tok = token;
                        d.err = .{
                            .unexpected_token = .{
                                .expected = &.{ .string, .rb },
                            },
                        };
                    }
                    return error.Syntax;
                },
            },

            .map_field => {
                if (node.first_child_id == 0) {
                    if (token.tag == .string) {
                        node = try node.addChild(&ast.nodes, .string);
                        node.loc = token.loc;
                        node = node.parent(&ast.nodes);
                    } else {
                        if (ast.diag) |d| {
                            d.tok = token;
                            d.err = .{
                                .unexpected_token = .{
                                    .expected = &.{.string},
                                },
                            };
                        }
                        return error.Syntax;
                    }

                    const t = try ast.next();
                    if (t.tag != .colon) {
                        if (ast.diag) |d| {
                            d.tok = token;
                            d.err = .{
                                .unexpected_token = .{
                                    .expected = &.{.colon},
                                },
                            };
                        }
                        return error.Syntax;
                    }

                    node = try node.addChild(&ast.nodes, ._value);
                    token = try ast.next();
                } else {
                    node.loc.end = token.loc.end;
                    if (token.tag == .comma) {
                        token = try ast.next();
                    } else {
                        if (token.tag != .rb) {
                            if (ast.diag) |d| {
                                d.tok = token;
                                d.err = .{
                                    .unexpected_token = .{
                                        .expected = &.{.comma},
                                    },
                                };
                            }
                            return error.Syntax;
                        }
                    }

                    node = node.parent(&ast.nodes);
                }
            },
            .array => {
                if (node.last_child_id != 0 and
                    ast.nodes.items[node.last_child_id].tag != .comment)
                {
                    if (token.tag == .comma) {
                        token = try ast.next();
                        if (token.tag == .rsb) {
                            node.tag = .array_comma;
                        }
                    } else {
                        if (token.tag != .rsb) {
                            if (ast.diag) |d| {
                                d.tok = token;
                                d.err = .{
                                    .unexpected_token = .{
                                        .expected = &.{.comma},
                                    },
                                };
                            }
                            return error.Syntax;
                        }
                    }
                }

                while (token.tag == .comment) : (token = try ast.next()) {
                    node = try node.addChild(&ast.nodes, .comment);
                    node.loc = token.loc;
                    node = node.parent(&ast.nodes);
                }

                if (token.tag == .rsb) {
                    node.loc.end = token.loc.end;
                    node = node.parent(&ast.nodes);
                    token = try ast.next();
                } else {
                    node = try node.addChild(&ast.nodes, ._value);
                }
            },

            ._value => switch (token.tag) {
                .lb => {
                    node.tag = .struct_or_map;
                    node.loc.start = token.loc.start;
                    token = try ast.next();
                },
                .identifier => {
                    {
                        const src = token.loc.src(code);
                        switch (src[0]) {
                            'A'...'Z' => {},
                            else => {
                                if (ast.diag) |d| {
                                    d.tok = token;
                                    d.err = .{
                                        .unexpected_token = .{
                                            .expected = &.{.value},
                                        },
                                    };
                                }
                                return error.Syntax;
                            },
                        }
                    }
                    node.tag = .struct_or_map;
                    node.loc.start = token.loc.start;
                    node = try node.addChild(&ast.nodes, .identifier);
                    node.loc = token.loc;
                    node = node.parent(&ast.nodes);
                    token = try ast.next();
                    if (token.tag != .lb) {
                        if (ast.diag) |d| {
                            d.tok = token;
                            d.err = .{
                                .unexpected_token = .{
                                    .expected = &.{.lb},
                                },
                            };
                        }
                        return error.Syntax;
                    }
                    token = try ast.next();
                },
                .lsb => {
                    node.tag = .array;
                    node.loc.start = token.loc.start;
                    token = try ast.next();
                },
                .at => {
                    node.tag = .tag;
                    node.loc.start = token.loc.start;

                    token = try ast.next();
                    if (token.tag != .identifier) {
                        if (ast.diag) |d| {
                            d.tok = token;
                            d.err = .{
                                .unexpected_token = .{
                                    .expected = &.{.identifier},
                                },
                            };
                        }
                        return error.Syntax;
                    }
                    const src = token.loc.src(code);
                    for (src) |ch| {
                        switch (ch) {
                            else => {},
                            'A'...'Z' => {
                                if (ast.diag) |d| {
                                    d.tok = token;
                                    d.err = .{
                                        .unexpected_token = .{
                                            .expected = &.{.tag_name},
                                        },
                                    };
                                }
                                return error.Syntax;
                            },
                        }
                    }

                    node = try node.addChild(&ast.nodes, .identifier);
                    node.loc = token.loc;
                    node = node.parent(&ast.nodes);
                    node.loc.end = token.loc.end;

                    token = try ast.next();
                    if (token.tag != .lp) {
                        if (ast.diag) |d| {
                            d.tok = token;
                            d.err = .{
                                .unexpected_token = .{
                                    .expected = &.{.lp},
                                },
                            };
                        }
                        return error.Syntax;
                    }

                    token = try ast.next();
                    if (token.tag != .string) {
                        if (ast.diag) |d| {
                            d.tok = token;
                            d.err = .{
                                .unexpected_token = .{
                                    .expected = &.{.string},
                                },
                            };
                        }
                        return error.Syntax;
                    }
                    node = try node.addChild(&ast.nodes, .string);
                    node.loc = token.loc;

                    token = try ast.next();
                    if (token.tag != .rp) {
                        if (ast.diag) |d| {
                            d.tok = token;
                            d.err = .{
                                .unexpected_token = .{
                                    .expected = &.{.rp},
                                },
                            };
                        }
                        return error.Syntax;
                    }

                    node = node.parent(&ast.nodes).parent(&ast.nodes);
                    token = try ast.next();
                },
                .string => {
                    node.tag = .string;
                    node.loc = token.loc;
                    node = node.parent(&ast.nodes);
                    token = try ast.next();
                },
                .line_string => {
                    node.tag = .multiline_string;
                    node.loc.start = token.loc.start;
                    while (token.tag == .line_string) {
                        node = try node.addChild(&ast.nodes, .line_string);
                        node.loc = token.loc;
                        node = node.parent(&ast.nodes);
                        node.loc.end = token.loc.end;
                        token = try ast.next();
                    }

                    node = node.parent(&ast.nodes);
                },
                .integer => {
                    node.tag = .integer;
                    node.loc = token.loc;
                    node = node.parent(&ast.nodes);
                    token = try ast.next();
                },
                .float => {
                    node.tag = .float;
                    node.loc = token.loc;
                    node = node.parent(&ast.nodes);
                    token = try ast.next();
                },
                .true, .false => {
                    node.tag = .bool;
                    node.loc = token.loc;
                    node = node.parent(&ast.nodes);
                    token = try ast.next();
                },
                .null => {
                    node.tag = .null;
                    node.loc = token.loc;
                    node = node.parent(&ast.nodes);
                    token = try ast.next();
                },
                else => {
                    if (ast.diag) |d| {
                        d.tok = token;
                        d.err = .{
                            .unexpected_token = .{
                                .expected = &.{.value},
                            },
                        };
                    }
                    return error.Syntax;
                },
            },

            // only set at .rsb
            .array_comma,

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

fn next(self: *Ast) error{Syntax}!Tokenizer.Token {
    const token = self.tokenizer.next(self.code);
    if (token.tag == .invalid) {
        if (self.diag) |d| {
            d.tok = token;
            d.err = .invalid_token;
        }
        return error.Syntax;
    }
    return token;
}

pub fn format(
    self: Ast,
    comptime fmt: []const u8,
    options: std.fmt.FormatOptions,
    out_stream: anytype,
) !void {
    _ = fmt;
    _ = options;

    try render(self.nodes.items, self.code, out_stream);
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
            const mode: RenderMode = if (hasMultilineSiblings(node.first_child_id, nodes)) blk: {
                break :blk .vertical;
            } else .horizontal;

            try w.writeAll("[");
            try renderArray(indent + 1, mode, node.first_child_id, nodes, code, w);
            try w.writeAll("]");
        },
        .array_comma => {
            std.debug.assert(node.first_child_id != 0);

            try w.writeAll("[\n");
            try renderArray(indent + 1, .vertical, node.first_child_id, nodes, code, w);
            try printIndent(indent, w);
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
    const ast = try Ast.init(std.testing.allocator, case, true, &diag);
    defer ast.deinit();
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
    const ast = try Ast.init(std.testing.allocator, case, true, &diag);
    defer ast.deinit();
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
    const ast = try Ast.init(std.testing.allocator, case, true, &diag);
    defer ast.deinit();
    try std.testing.expectFmt(case, "{}", .{ast});
}
