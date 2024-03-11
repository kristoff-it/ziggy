const Ast = @This();

const std = @import("std");
const assert = std.debug.assert;
const Diagnostic = @import("Diagnostic.zig");
const Tokenizer = @import("Tokenizer.zig");
const Token = Tokenizer.Token;

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
        root_expr,
        tag_definition,
        enum_definition,
        @"struct",
        struct_field,
        doc_comment,
        doc_comment_line,

        _expr,
        array,
        map,
        struct_union,
        optional,
        identifier,
        tag,
        bytes,
        int,
        float,
        bool,
        any,
        unknown,
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

    pub fn debug(self: Node, nodes: []const Node) void {
        self.debugInternal(nodes, 0);
    }

    fn debugInternal(self: Node, nodes: []const Node, indent: usize) void {
        for (0..indent) |_| std.debug.print("  ", .{});
        std.debug.print("({s}", .{@tagName(self.tag)});
        var child_id = self.first_child_id;
        while (child_id != 0) {
            std.debug.print("\n", .{});
            const cur = nodes[child_id];
            cur.debugInternal(nodes, indent + 1);
            child_id = cur.next_id;
        }

        if (self.first_child_id != 0) {
            std.debug.print("\n", .{});
            for (0..indent) |_| std.debug.print("  ", .{});
        }

        std.debug.print(")", .{});
    }
};

code: [:0]const u8,
nodes: std.ArrayList(Node),
tokenizer: Tokenizer = .{},
diag: ?*Diagnostic,

pub fn deinit(self: Ast) void {
    self.nodes.deinit();
}

pub fn init(
    gpa: std.mem.Allocator,
    code: [:0]const u8,
    diagnostic: ?*Diagnostic,
) !Ast {
    var ast: Ast = .{
        .code = code,
        .diag = diagnostic,
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
            .root => {
                try ast.must(token, .root_kw);
                node = try node.addChild(&ast.nodes, .root_expr);
                node.loc.start = token.loc.start;
                _ = try ast.nextMust(.eq);
                node = try node.addChild(&ast.nodes, ._expr);
                token = try ast.next();
            },
            .root_expr => {
                node.loc.end = ast.nodes.items[node.last_child_id].loc.end;

                if (token.tag == .eof) {
                    return ast;
                }

                node = try node.parent(&ast.nodes).addChild(&ast.nodes, .tag_definition);
            },

            .tag_definition => {
                if (node.last_child_id == 0) {
                    node.loc.start = token.loc.start;
                }

                if (token.tag == .doc_comment_line) {
                    assert(node.last_child_id == 0);

                    node = try node.addChild(&ast.nodes, .doc_comment);
                    node.loc.start = token.loc.start;
                    continue;
                }

                try ast.mustAny(token, &.{ .at, .struct_kw });

                if (token.tag == .struct_kw) {
                    node.tag = .@"struct";
                    continue;
                }

                assert(token.tag == .at);

                token = try ast.nextMust(.identifier);
                node = try node.addChild(&ast.nodes, .identifier);
                node.loc = token.loc;
                node = node.parent(&ast.nodes);

                _ = try ast.nextMust(.eq);

                token = try ast.nextMustAny(&.{ .bytes, .enum_kw });

                switch (token.tag) {
                    .bytes => {
                        node = try node.addChild(&ast.nodes, .bytes);
                        node.loc = token.loc;
                        node = node.parent(&ast.nodes);
                    },
                    .enum_kw => {
                        node = try node.addChild(&ast.nodes, .enum_definition);
                        node.loc.start = token.loc.start;
                        _ = try ast.nextMust(.lb);
                        token = try ast.nextMustAny(&.{ .identifier, .rb });
                        while (token.tag == .identifier) {
                            node = try node.addChild(&ast.nodes, .identifier);
                            node.loc = token.loc;
                            node = node.parent(&ast.nodes);

                            token = try ast.next();
                            if (token.tag == .comma) {
                                token = try ast.nextMustAny(&.{ .identifier, .rb });
                            } else {
                                try ast.mustAny(token, &.{.rb});
                            }
                        }
                        assert(token.tag == .rb);
                        node.loc.end = token.loc.end;
                        node = node.parent(&ast.nodes);
                    },
                    else => unreachable,
                }

                token = try ast.nextMust(.comma);
                node.loc.end = token.loc.end;

                token = try ast.next();
                if (token.tag == .eof) {
                    return ast;
                }
                node = try node.parent(&ast.nodes).addChild(&ast.nodes, .tag_definition);
            },

            .@"struct" => {
                if (node.last_child_id == 0) {
                    node.loc.start = token.loc.start;
                }

                if (token.tag == .doc_comment_line) {
                    assert(node.last_child_id == 0);

                    node = try node.addChild(&ast.nodes, .doc_comment);
                    node.loc.start = token.loc.start;
                    continue;
                }

                try ast.must(token, .struct_kw);

                token = try ast.nextMust(.identifier);
                node = try node.addChild(&ast.nodes, .identifier);
                node.loc = token.loc;

                node = node.parent(&ast.nodes);
                _ = try ast.nextMust(.lb);

                token = try ast.next();
                if (token.tag == .rb) {
                    node.loc.end = token.loc.end;
                    token = try ast.next();
                    if (token.tag == .eof) {
                        return ast;
                    }

                    node = try node.parent(&ast.nodes).addChild(&ast.nodes, .@"struct");
                    continue;
                }

                node = try node.addChild(&ast.nodes, .struct_field);
            },

            .struct_field => {
                if (node.last_child_id == 0) {
                    node.loc.start = token.loc.start;
                    if (token.tag == .doc_comment_line) {
                        assert(node.last_child_id == 0);

                        node = try node.addChild(&ast.nodes, .doc_comment);
                        node.loc.start = token.loc.start;
                        continue;
                    }
                }

                if (node.last_child_id == 0 or
                    ast.nodes.items[node.last_child_id].tag == .doc_comment)
                {
                    try ast.must(token, .identifier);
                    node = try node.addChild(&ast.nodes, .identifier);
                    node.loc = token.loc;
                    node = node.parent(&ast.nodes);

                    _ = try ast.nextMust(.colon);

                    node = try node.addChild(&ast.nodes, ._expr);
                    token = try ast.next();
                    continue;
                }

                // returning from parsing an expr

                try ast.must(token, .comma);
                node.loc.end = token.loc.end;

                token = try ast.next();
                if (token.tag == .rb) {
                    node = node.parent(&ast.nodes);
                    node.loc.end = token.loc.end;

                    token = try ast.next();
                    if (token.tag == .eof) {
                        return ast;
                    }

                    node = try node.parent(&ast.nodes).addChild(&ast.nodes, .@"struct");
                    continue;
                }
                node = try node.parent(&ast.nodes).addChild(&ast.nodes, .struct_field);
            },

            .doc_comment => switch (token.tag) {
                .doc_comment_line => {
                    node.loc.end = token.loc.end;
                    node = try node.addChild(&ast.nodes, .doc_comment_line);
                    node.loc = token.loc;
                    node = node.parent(&ast.nodes);
                    token = try ast.next();
                },
                else => {
                    node = node.parent(&ast.nodes);
                },
            },

            .array, .map => {
                try ast.must(token, .rsb);
                node.loc.end = token.loc.end;
                node = node.parent(&ast.nodes);
                token = try ast.next();
            },

            .optional => {
                assert(node.last_child_id != 0);
                node.loc.end = ast.nodes.items[node.last_child_id].loc.end;
                node = node.parent(&ast.nodes);
            },

            ._expr => switch (token.tag) {
                .at => {
                    node.tag = .tag;
                    node.loc.start = token.loc.start;
                    token = try ast.nextMust(.identifier);
                    node.loc.end = token.loc.end;
                    node = node.parent(&ast.nodes);
                    token = try ast.next();
                },
                .any_kw => {
                    node.tag = .any;
                    node.loc = token.loc;
                    node = node.parent(&ast.nodes);
                    token = try ast.next();
                },
                .unknown_kw => {
                    node.tag = .unknown;
                    node.loc = token.loc;
                    node = node.parent(&ast.nodes);
                    token = try ast.next();
                },
                .bool => {
                    node.tag = .bool;
                    node.loc = token.loc;
                    node = node.parent(&ast.nodes);
                    token = try ast.next();
                },
                .int => {
                    node.tag = .int;
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
                .bytes => {
                    node.tag = .bytes;
                    node.loc = token.loc;
                    node = node.parent(&ast.nodes);
                    token = try ast.next();
                },
                .lsb => {
                    node.tag = .array;
                    node.loc.start = token.loc.start;
                    node = try node.addChild(&ast.nodes, ._expr);
                    token = try ast.next();
                },
                .map_kw => {
                    node.tag = .map;
                    node.loc.start = token.loc.start;
                    _ = try ast.nextMust(.lsb);
                    node = try node.addChild(&ast.nodes, ._expr);
                    token = try ast.next();
                },
                .qmark => {
                    node.tag = .optional;
                    node.loc.start = token.loc.start;
                    node = try node.addChild(&ast.nodes, ._expr);
                    token = try ast.next();
                },
                .identifier => {
                    var pipe = try ast.next();
                    if (pipe.tag != .pipe) {
                        node.tag = .identifier;
                        node.loc = token.loc;
                        node = node.parent(&ast.nodes);
                        token = pipe;
                        continue;
                    }

                    node.tag = .struct_union;
                    node.loc.start = token.loc.start;
                    node = try node.addChild(&ast.nodes, .identifier);
                    node.loc = token.loc;
                    node = node.parent(&ast.nodes);

                    while (pipe.tag == .pipe) {
                        token = try ast.nextMust(.identifier);
                        node = try node.addChild(&ast.nodes, .identifier);
                        node.loc = token.loc;
                        node = node.parent(&ast.nodes);
                        pipe = try ast.next();
                    }

                    node.loc.end = token.loc.end;
                    node = node.parent(&ast.nodes);
                    token = pipe;
                },
                else => try ast.must(token, .expr),
            },
            .enum_definition,
            .struct_union,
            .identifier,
            .tag,
            .doc_comment_line,
            .float,
            .int,
            .bool,
            .unknown,
            .any,
            .bytes,
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

fn nextMust(self: *Ast, comptime tag: Token.Tag) error{Syntax}!Tokenizer.Token {
    return self.nextMustAny(&.{tag});
}

fn nextMustAny(self: *Ast, comptime tags: []const Token.Tag) error{Syntax}!Tokenizer.Token {
    const token = try self.next();
    try self.mustAny(token, tags);
    return token;
}

pub fn must(
    self: *Ast,
    tok: Token,
    comptime tag: Token.Tag,
) !void {
    return self.mustAny(tok, &.{tag});
}

pub fn mustAny(
    self: *Ast,
    tok: Token,
    comptime tags: []const Token.Tag,
) !void {
    for (tags) |t| {
        if (t == tok.tag) break;
    } else {
        if (self.diag) |d| {
            d.tok = tok;
            d.err = .{
                .unexpected_token = .{
                    .expected = tags,
                },
            };
        }

        return error.Syntax;
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

    try render(self.nodes.items, self.code, out_stream);
}

const RenderMode = enum { horizontal, vertical };
pub fn render(nodes: []const Node, code: [:0]const u8, w: anytype) !void {
    // root expression
    const root_expr = nodes[1];
    try w.writeAll("root = ");
    try renderExpr(root_expr.last_child_id, nodes, code, w);
    try w.writeAll("\n\n");

    var idx = root_expr.next_id;
    while (idx != 0) {
        const next_tag = nodes[idx];
        if (next_tag.tag == .@"struct") break;
        assert(next_tag.tag == .tag_definition);

        var ident = nodes[next_tag.first_child_id];

        if (ident.tag == .doc_comment) {
            try renderDocComment(ident.first_child_id, false, nodes, code, w);
            ident = nodes[ident.next_id];
        }

        assert(ident.tag == .identifier);
        try w.print("@{s} = ", .{ident.loc.src(code)});

        const expr = nodes[ident.next_id];
        switch (expr.tag) {
            else => unreachable,
            .bytes => try w.writeAll("bytes,\n"),
            .enum_definition => {
                try w.writeAll("enum { ");
                var enum_name_id = expr.first_child_id;
                while (enum_name_id != 0) {
                    const enum_name = nodes[enum_name_id];
                    try w.writeAll(enum_name.loc.src(code));
                    enum_name_id = enum_name.next_id;
                    if (enum_name_id != 0) {
                        try w.writeAll(", ");
                    }
                }

                try w.writeAll(" },\n");
            },
        }

        idx = next_tag.next_id;
    }

    while (idx != 0) {
        const next_struct = nodes[idx];
        assert(next_struct.tag == .@"struct");

        try w.writeAll("\n");

        var ident = nodes[next_struct.first_child_id];
        if (ident.tag == .doc_comment) {
            try renderDocComment(ident.first_child_id, false, nodes, code, w);
            ident = nodes[ident.next_id];
        }

        try w.print("struct {s} {{\n", .{ident.loc.src(code)});

        var field_id = ident.next_id;
        while (field_id != 0) {
            const field = nodes[field_id];

            var field_ident = nodes[field.first_child_id];
            if (field_ident.tag == .doc_comment) {
                try renderDocComment(field_ident.first_child_id, true, nodes, code, w);
                field_ident = nodes[field_ident.next_id];
            }

            try w.print("    {s}: ", .{field_ident.loc.src(code)});
            try renderExpr(field_ident.next_id, nodes, code, w);
            try w.writeAll(",\n");

            field_id = field.next_id;
        }

        try w.writeAll("}\n");
        idx = next_struct.next_id;
    }
}

fn renderDocComment(
    idx: u32,
    indent: bool,
    nodes: []const Node,
    code: [:0]const u8,
    w: anytype,
) !void {
    assert(idx != 0);

    var i = idx;
    while (i != 0) {
        const line = nodes[i];
        assert(line.tag == .doc_comment_line);
        if (indent) {
            try w.writeAll("    ");
        }
        try w.writeAll(line.loc.src(code));
        try w.writeAll("\n");
        i = line.next_id;
    }
}

fn renderExpr(idx: u32, nodes: []const Node, code: [:0]const u8, w: anytype) !void {
    const expr = nodes[idx];

    switch (expr.tag) {
        else => unreachable,
        .struct_union => {
            var i = expr.first_child_id;
            assert(i != 0);
            while (i != 0) {
                const next_ident = nodes[i];
                try w.writeAll(next_ident.loc.src(code));
                i = next_ident.next_id;
                if (i != 0) {
                    try w.writeAll(" | ");
                }
            }
        },
        .array => {
            try w.writeAll("[");
            try renderExpr(expr.last_child_id, nodes, code, w);
            try w.writeAll("]");
        },

        .map => {
            try w.writeAll("map[");
            try renderExpr(expr.last_child_id, nodes, code, w);
            try w.writeAll("]");
        },
        .optional => {
            try w.writeAll("?");
            try renderExpr(expr.last_child_id, nodes, code, w);
        },
        .tag,
        .identifier,
        .bytes,
        .int,
        .float,
        .bool,
        .any,
        .unknown,
        => try w.writeAll(expr.loc.src(code)),
    }
}

test "basics" {
    const case =
        \\root = Frontmatter
        \\
        \\/// Doc comment 1a
        \\/// Doc comment 1b
        \\@date = bytes,
        \\
        \\/// Doc comment 2a
        \\/// Doc comment 2b
        \\struct Frontmatter {
        \\    /// Doc comment 3a
        \\    /// Doc comment 3b
        \\    title: bytes,
        \\    date: @date,
        \\    custom: map[any],
        \\    custom: map[Foo | Bar | Baz],
        \\}
        \\
    ;

    var diag: Diagnostic = .{ .path = null };
    errdefer std.debug.print("diag: {}", .{diag});
    const ast = try Ast.init(std.testing.allocator, case, &diag);
    defer ast.deinit();

    try std.testing.expectFmt(case, "{}", .{ast});
}
