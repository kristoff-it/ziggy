const Ast = @This();

const std = @import("std");
const Writer = std.Io.Writer;
const Allocator = std.mem.Allocator;
const assert = std.debug.assert;
const ZiggyAst = @import("../Ast.zig");
const ZiggyTokenizer = @import("../Tokenizer.zig");
const Tokenizer = @import("Tokenizer.zig");
const Token = Tokenizer.Token;
const Loc = Token.Loc;
const log = std.log.scoped(.ast);

has_syntax_errors: bool,
nodes: []const Node,
errors: []const Error,
scopes: Scopes = .empty,

/// Validating a Ziggy Document AST is necessary to detect duplicate fields.
/// A Ziggy Document that doesn't have a specific schema can always be matched
/// with the default `$ = any` schema, which is what `validateDefault` makes
/// convenient to do.
///
/// Asserts that the schema does not contain errors.
/// Asserts that the document does not contain errors.
/// Caller owns returned memory.
pub fn validateDefault(
    gpa: Allocator,
    ziggy_ast: ZiggyAst,
    ziggy_src: [:0]const u8,
) ![]const ValidationError {
    return default.validate(gpa, default_src, ziggy_ast, ziggy_src);
}

pub const default_src = "$ = any";
pub const default: Ast = .{
    .has_syntax_errors = false,
    .errors = &.{},
    .nodes = &.{
        .{
            .tag = .root,
            .parent_idx = 0,
            .loc = .{ .start = 0, .end = default_src.len },
        },
        .{
            .tag = .root_expr,
            .parent_idx = 0,
            .loc = .{ .start = 0, .end = default_src.len },
        },
        .{
            .tag = .type_expr,
            .parent_idx = 1,
            .loc = .{ .start = "$ = ".len, .end = default_src.len },
        },
    },
};

pub const Scopes = std.AutoArrayHashMapUnmanaged(u32, struct {
    fields: std.StringArrayHashMapUnmanaged(struct {
        loc: Loc,
        idx: u32,
    }),
    types: std.StringArrayHashMapUnmanaged(u32),
});

pub const Error = struct {
    main_location: Loc,
    tag: union(enum) {
        unexpected_token,
        missing_root_expr,
        missing_token: []const u8,
        missing_terminal_type,
        field_after_decl,
        unbound_docs,
        duplicate_field_name: Loc, // the original
        duplicate_type_definition: u32, // node idx of the original
        /// same as duplicate_type_definition but when the collision
        /// happens with a name from an outer scope.
        type_name_collision: u32, // node idx of the original
        undeclared_identifier,
        infinite_loop_container: ContainerKind,
        infinite_loop_field,
        empty_union,
        unreachable_type, // TODO

        pub fn format(t: @This(), w: *Writer) !void {
            switch (t) {
                .unexpected_token => {
                    try w.print("unexpected token", .{});
                },
                .missing_root_expr => {
                    try w.print("missing root type expression", .{});
                },
                .missing_token => |msg| {
                    try w.print("missing {s}", .{msg});
                },
                .missing_terminal_type => {
                    try w.print(
                        "type expressions must terminate in a struct/union name or a type keyword",
                        .{},
                    );
                },
                .field_after_decl => {
                    try w.print("fields must be above nested struct/union declarations", .{});
                },
                .unbound_docs => {
                    try w.print("doc comments can only be placed above type declarations or struct/union fields", .{});
                },
                .duplicate_field_name => {
                    try w.print("duplicate field name", .{});
                },
                .duplicate_type_definition => {
                    try w.print("duplicate type definition", .{});
                },
                .type_name_collision => {
                    try w.print("type name collides with one in an outer scope", .{});
                },
                .undeclared_identifier => {
                    try w.print("undeclared identifier", .{});
                },
                .infinite_loop_container => |kind| switch (kind) {
                    .@"struct" => try w.print("this struct is part of an infinite loop", .{}),
                    .@"union" => try w.print("all fields of this union lead to a type part of an infinite loop", .{}),
                },
                .infinite_loop_field => {
                    try w.print("this field leads to a type part of an infinite loop", .{});
                },
                .empty_union => {
                    try w.print("unions must have at least one field", .{});
                },
                .unreachable_type => {
                    try w.print("unreferenced nested type", .{});
                },
            }
        }
    },
};

pub const Node = struct {
    tag: Tag,
    loc: Loc = undefined,
    // 0 = not present
    // To disambiguate doc comments that start at index zero, when the field is
    // set it points at the second slash in `///` so you must subtract 1 before
    // retokenizing.
    docs_offset: u32 = 0,

    parent_idx: u32,
    next_idx: u32 = 0,

    /// MUST NOT be called on a node copied outside of 'nodes'.
    fn childIdx(n: *const Node, nodes: []const Node) ?u32 {
        assert(@intFromPtr(n) > @intFromPtr(nodes.ptr));
        const node_idx = n - nodes.ptr;
        assert(node_idx < nodes.len);
        if (node_idx == nodes.len - 1) return null;
        const maybe_child_idx: u32 = @intCast(node_idx + 1);
        const maybe_child = nodes[maybe_child_idx];
        return if (maybe_child.parent_idx == node_idx)
            maybe_child_idx
        else
            null;
    }

    pub const Tag = enum {
        root,
        root_expr,
        type_expr,
        @"struct",
        struct_field,
        @"union",
        union_field,
    };
};

pub fn deinit(ast: Ast, gpa: Allocator) void {
    gpa.free(ast.nodes);
    gpa.free(ast.errors);
    for (ast.scopes.values()) |*v| {
        v.fields.deinit(gpa);
        v.types.deinit(gpa);
    }
    @constCast(&ast.scopes).deinit(gpa);
}

pub fn init(gpa: Allocator, src: [:0]const u8) !Ast {
    var p: Parser = .{ .gpa = gpa, .src = src };
    return p.parse();
}

const ContainerKind = enum { @"struct", @"union" };
const Parser = struct {
    gpa: Allocator,
    src: [:0]const u8,
    tokenizer: Tokenizer = .{},
    node_idx: u32 = 0,
    prev_loc: Loc = .{ .start = 0, .end = 0 },
    tok: Token = undefined,
    has_syntax_errors: bool = false,
    docs_offset: u32 = 0,
    refs: std.ArrayList(Ref) = .empty,
    meta: std.ArrayList(NodeMeta) = .empty,

    scopes: Scopes = .empty,
    nodes: std.ArrayList(Node) = .empty,
    errors: std.ArrayList(Error) = .empty,

    const Ref = struct {
        /// 0 means that this is a ref in the root expression
        /// in all other cases it should indicate a node id of
        /// type struct or union
        container_idx: u32,
        loc: Loc,
    };

    const NodeMeta = struct {
        node_idx: if (std.debug.runtime_safety) u32 else void,
        last_child_idx: u32 = 0,
        container_idx: u32 = 0,
        scope_slot: u32 = 0,

        // used only by container structs
        state: enum {
            container_head,
            container_fields,
            container_decls,
        } = .container_head,
    };

    fn deinit(p: *Parser) void {
        p.meta.deinit(p.gpa);
        p.nodes.deinit(p.gpa);
        p.errors.deinit(p.gpa);
        p.refs.deinit(p.gpa);
        for (p.scopes.values()) |*v| {
            v.fields.deinit(p.gpa);
            v.types.deinit(p.gpa);
        }
        p.scopes.deinit(p.gpa);
    }

    fn parse(p: *Parser) error{OutOfMemory}!Ast {
        defer p.deinit();

        p.consume();
        try p.addRoot();
        parse: switch (Node.Tag.root) {
            .root => {
                if (p.nodes.items.len == 1 and p.errors.items.len == 0) {
                    root: switch (p.tok.tag) {
                        .eof => {
                            try p.err(.{
                                .tag = .missing_root_expr,
                                .main_location = .{
                                    .start = p.prev_loc.end,
                                    .end = p.tok.loc.start,
                                },
                            });

                            return p.finalize();
                        },
                        .doc_comment_line => {
                            p.setDocs(p.tok.loc);
                            while (p.tok.tag == .doc_comment_line) : (p.consume()) {}
                            continue :root p.tok.tag;
                        },

                        .root_sigil => {
                            assert(p.node().tag == .root);
                            try p.addChild(.root_expr);
                            p.consume();
                        },

                        .eq,
                        .qmark,
                        .slice_sigil,
                        .dict_sigil,
                        .identifier,
                        .any_kw,
                        .bytes_kw,
                        .bool_kw,
                        .int_kw,
                        .float_kw,
                        => {
                            try p.err(.{
                                .tag = .{ .missing_token = "root" },
                                .main_location = .{
                                    .start = p.prev_loc.end,
                                    .end = p.tok.loc.start,
                                },
                            });
                            // intentional fallthrough
                        },
                        .struct_kw, .union_kw => {
                            try p.err(.{
                                .tag = .missing_root_expr,
                                .main_location = .{
                                    .start = p.prev_loc.end,
                                    .end = p.tok.loc.start,
                                },
                            });

                            const t: Node.Tag = if (p.tok.tag == .struct_kw) .@"struct" else .@"union";
                            try p.addChild(t);
                            continue :parse t;
                        },
                        else => {
                            try p.err(.{
                                .tag = .unexpected_token,
                                .main_location = p.tok.loc,
                            });

                            p.discardUntilDeclaration();
                            switch (p.tok.tag) {
                                else => unreachable,
                                .struct_kw => {
                                    try p.addChild(.@"struct");
                                    continue :parse .@"struct";
                                },
                                .union_kw => {
                                    try p.addChild(.@"union");
                                    continue :parse .@"union";
                                },
                                .eof => {
                                    return p.finalize();
                                },
                            }
                        },
                    }

                    switch (p.tok.tag) {
                        .eq => {
                            if (p.node().tag == .root) {
                                try p.addChild(.root_expr);
                            }
                            p.consume();
                        },
                        .qmark,
                        .slice_sigil,
                        .dict_sigil,
                        .identifier,
                        .any_kw,
                        .bytes_kw,
                        .bool_kw,
                        .int_kw,
                        .float_kw,
                        => {
                            try p.err(.{
                                .tag = .{ .missing_token = "=" },
                                .main_location = .{
                                    .start = p.prev_loc.end,
                                    .end = p.tok.loc.start,
                                },
                            });
                            // intentional fallthrough
                        },
                        else => {
                            assert(p.node().tag == .root_expr);
                            p.node().loc.end = p.prev_loc.end;
                            p.up();

                            try p.err(.{
                                .tag = .unexpected_token,
                                .main_location = p.tok.loc,
                            });

                            p.discardUntilDeclaration();
                            switch (p.tok.tag) {
                                else => unreachable,
                                .struct_kw => {
                                    try p.addChild(.@"struct");
                                    continue :parse .@"struct";
                                },
                                .union_kw => {
                                    try p.addChild(.@"union");
                                    continue :parse .@"union";
                                },
                                .eof => {
                                    return p.finalize();
                                },
                            }
                        },
                    }

                    assert(p.node().tag == .root_expr);
                    switch (p.tok.tag) {
                        .qmark,
                        .slice_sigil,
                        .dict_sigil,
                        .identifier,
                        .any_kw,
                        .bytes_kw,
                        .bool_kw,
                        .int_kw,
                        .float_kw,
                        => {
                            // type_expr will finalize the root_expr node
                            try p.addChild(.type_expr);
                            continue :parse .type_expr;
                        },
                        else => {
                            p.node().loc.end = p.prev_loc.end;
                            p.up();

                            try p.err(.{
                                .tag = .unexpected_token,
                                .main_location = p.tok.loc,
                            });

                            p.discardUntilDeclaration();
                            switch (p.tok.tag) {
                                else => unreachable,
                                .struct_kw => {
                                    try p.addChild(.@"struct");
                                    continue :parse .@"struct";
                                },
                                .union_kw => {
                                    try p.addChild(.@"union");
                                    continue :parse .@"union";
                                },
                                .eof => {
                                    return p.finalize();
                                },
                            }
                        },
                    }
                } else {
                    p.consume();
                    if (p.tok.tag != .eof) try p.err(.{
                        .tag = .unexpected_token,
                        .main_location = p.tok.loc,
                    });
                    return p.finalize();
                }
            },
            .root_expr => unreachable,
            .type_expr => {
                while (true) : (p.consume()) switch (p.tok.tag) {
                    .qmark, .slice_sigil, .dict_sigil => continue,

                    .bytes_kw,
                    .int_kw,
                    .float_kw,
                    .bool_kw,
                    .any_kw,
                    .identifier,
                    => {
                        if (p.tok.tag == .identifier) try p.ref();
                        p.node().loc.end = p.tok.loc.end;
                        p.consume();
                        break;
                    },

                    .eof => {
                        p.node().loc.end = p.tok.loc.end;
                        try p.err(.{
                            .tag = .missing_terminal_type,
                            .main_location = p.node().loc,
                        });
                        return p.finalize();
                    },

                    else => {
                        p.node().loc.end = p.prev_loc.end;
                        try p.err(.{
                            .tag = .missing_terminal_type,
                            .main_location = p.node().loc,
                        });
                        break;
                    },
                };

                p.up();
                switch (p.node().tag) {
                    .root_expr => {
                        p.node().loc.end = p.prev_loc.end;
                        p.up(); // root

                        discard: switch (p.tok.tag) {
                            else => {
                                try p.err(.{
                                    .tag = .unexpected_token,
                                    .main_location = p.tok.loc,
                                });
                                p.discardUntilDeclaration();
                                continue :discard p.tok.tag;
                            },
                            .doc_comment_line => {
                                p.setDocs(p.tok.loc);
                                while (p.tok.tag == .doc_comment_line) : (p.consume()) {}
                                continue :discard p.tok.tag;
                            },
                            .struct_kw => {
                                try p.addChild(.@"struct");
                                continue :parse .@"struct";
                            },
                            .union_kw => {
                                try p.addChild(.@"union");
                                continue :parse .@"union";
                            },
                            .eof => {
                                return p.finalize();
                            },
                        }
                    },
                    .union_field, .struct_field => {
                        if (p.tok.tag == .comma) {
                            p.node().loc.end = p.tok.loc.end;
                            p.consume();
                        } else {
                            p.node().loc.end = p.prev_loc.end;
                            if (p.tok.tag == .identifier) {
                                try p.err(.{
                                    .tag = .{ .missing_token = "comma after field" },
                                    .main_location = p.prev_loc,
                                });
                            }
                        }
                        p.up(); // container element
                        continue :parse p.node().tag;
                    },
                    else => unreachable,
                }
            },
            .@"struct", .@"union" => {
                const m = p.getMeta();
                container: switch (m.state) {
                    .container_head => {
                        assert(p.node().tag == .@"struct" or p.node().tag == .@"union");
                        assert(m.last_child_idx == 0);
                        p.consume();
                        switch (p.tok.tag) {
                            .identifier => p.consume(),
                            .lb => {
                                try p.err(.{
                                    .tag = .{ .missing_token = "identifier after container keyword" },
                                    .main_location = p.prev_loc,
                                });
                            },
                            else => {
                                p.node().loc.end = p.prev_loc.end;
                                p.up();

                                try p.err(.{
                                    .tag = .unexpected_token,
                                    .main_location = p.tok.loc,
                                });
                                p.discardUntilDeclaration();
                                switch (p.tok.tag) {
                                    else => unreachable,
                                    .struct_kw => {
                                        try p.addChild(.@"struct");
                                        continue :parse .@"struct";
                                    },
                                    .union_kw => {
                                        try p.addChild(.@"union");
                                        continue :parse .@"union";
                                    },
                                    .eof => {
                                        return p.finalize();
                                    },
                                }
                            },
                        }

                        switch (p.tok.tag) {
                            .lb => p.consume(),
                            else => {
                                p.node().loc.end = p.prev_loc.end;
                                p.up();

                                try p.err(.{
                                    .tag = .unexpected_token,
                                    .main_location = p.tok.loc,
                                });
                                p.discardUntilDeclaration();
                                switch (p.tok.tag) {
                                    else => unreachable,
                                    .struct_kw => {
                                        try p.addChild(.@"struct");
                                        continue :parse .@"struct";
                                    },
                                    .union_kw => {
                                        try p.addChild(.@"union");
                                        continue :parse .@"union";
                                    },
                                    .eof => {
                                        return p.finalize();
                                    },
                                }
                            },
                        }

                        if (p.tok.tag == .rb) {
                            try p.rejectDocs();
                            p.node().loc.end = p.tok.loc.end;
                            p.up();
                            p.consume();
                            discard: switch (p.tok.tag) {
                                else => {
                                    try p.err(.{
                                        .tag = .unexpected_token,
                                        .main_location = p.tok.loc,
                                    });
                                    p.discardUntilDeclaration();
                                    continue :discard p.tok.tag;
                                },
                                .rb => {
                                    try p.rejectDocs();
                                    continue :parse p.node().tag;
                                },
                                .doc_comment_line => {
                                    p.setDocs(p.tok.loc);
                                    while (p.tok.tag == .doc_comment_line) : (p.consume()) {}
                                    continue :discard p.tok.tag;
                                },
                                .struct_kw => {
                                    try p.addChild(.@"struct");
                                    continue :parse .@"struct";
                                },
                                .union_kw => {
                                    try p.addChild(.@"union");
                                    continue :parse .@"union";
                                },
                                .eof => {
                                    return p.finalize();
                                },
                            }
                        }

                        m.state = .container_fields;
                        continue :container .container_fields;
                    },

                    .container_fields,
                    .container_decls,
                    => switch (p.tok.tag) {
                        .doc_comment_line => {
                            p.setDocs(p.tok.loc);
                            while (p.tok.tag == .doc_comment_line) : (p.consume()) {}
                            continue :container m.state;
                        },
                        .identifier => {
                            switch (m.state) {
                                else => unreachable,
                                .container_decls => {
                                    try p.err(.{
                                        .tag = .field_after_decl,
                                        .main_location = p.tok.loc,
                                    });
                                },
                                .container_fields => {
                                    const gop = try p.scopes.getPtr(p.node_idx).?.fields.getOrPut(p.gpa, p.tok.loc.slice(p.src));
                                    if (gop.found_existing) {
                                        try p.err(.{
                                            .tag = .{ .duplicate_field_name = gop.value_ptr.loc },
                                            .main_location = p.tok.loc,
                                        });
                                    } else gop.value_ptr.* = .{
                                        .loc = p.tok.loc,
                                        .idx = @intCast(p.nodes.items.len),
                                    };
                                },
                            }

                            const t: Node.Tag = if (p.node().tag == .@"struct") .struct_field else .union_field;
                            try p.addChild(t);
                            continue :parse t;
                        },
                        .struct_kw, .union_kw => {
                            m.state = .container_decls;
                            const t: Node.Tag = if (p.tok.tag == .struct_kw) .@"struct" else .@"union";
                            try p.addChild(t);
                            continue :parse t;
                        },
                        .comma => {
                            try p.err(.{
                                .tag = .unexpected_token,
                                .main_location = p.tok.loc,
                            });
                            p.consume();
                            continue :container m.state;
                        },
                        .rb => {
                            p.node().loc.end = p.prev_loc.end;
                            p.up();
                            try p.rejectDocs();
                            p.consume();
                            continue :parse p.node().tag;
                        },
                        else => {
                            p.node().loc.end = p.prev_loc.end;
                            p.up();
                            try p.err(.{
                                .tag = .unexpected_token,
                                .main_location = p.tok.loc,
                            });

                            try p.rejectDocs();
                            p.discardUntilDeclaration();
                            switch (p.tok.tag) {
                                else => unreachable,
                                .struct_kw => {
                                    m.state = .container_decls;
                                    try p.addChild(.@"struct");
                                    continue :parse .@"struct";
                                },
                                .union_kw => {
                                    m.state = .container_decls;
                                    try p.addChild(.@"union");
                                    continue :parse .@"union";
                                },
                                .eof => {
                                    return p.finalize();
                                },
                            }
                        },
                    },
                }
            },

            .struct_field, .union_field => {
                assert(p.tok.tag == .identifier);
                p.consume();
                switch (p.tok.tag) {
                    .colon => p.consume(),

                    .qmark,
                    .slice_sigil,
                    .dict_sigil,
                    .bytes_kw,
                    .int_kw,
                    .float_kw,
                    .bool_kw,
                    .any_kw,
                    .identifier,
                    => {
                        try p.err(.{
                            .tag = .{ .missing_token = "colon after field name" },
                            .main_location = p.prev_loc,
                        });
                    },

                    .comma, .rb => {
                        if (p.node().tag == .struct_field) {
                            try p.err(.{
                                .tag = .{ .missing_token = "type expression after field name" },
                                .main_location = p.prev_loc,
                            });
                        }
                        p.node().loc.end = p.prev_loc.end;
                        p.up();
                        if (p.tok.tag == .comma) p.consume();
                        continue :parse p.node().tag;
                    },

                    .struct_kw, .union_kw => {
                        switch (p.node().tag) {
                            else => unreachable,
                            .struct_field => {
                                try p.err(.{
                                    .tag = .{ .missing_token = "type expression after field name" },
                                    .main_location = p.prev_loc,
                                });
                            },
                            .union_field => {
                                try p.err(.{
                                    .tag = .{ .missing_token = "comma after field" },
                                    .main_location = p.prev_loc,
                                });
                            },
                        }

                        p.node().loc.end = p.prev_loc.end;
                        p.up();
                        continue :parse p.node().tag;
                    },

                    else => {
                        p.node().loc.end = p.prev_loc.end;
                        p.up();
                        try p.err(.{
                            .tag = .unexpected_token,
                            .main_location = p.tok.loc,
                        });

                        try p.rejectDocs();
                        p.discardUntilDeclaration();
                        switch (p.tok.tag) {
                            else => unreachable,
                            .struct_kw, .union_kw => {
                                continue :parse .@"union";
                            },
                            .eof => {
                                return p.finalize();
                            },
                        }
                    },
                }

                switch (p.tok.tag) {
                    .qmark,
                    .slice_sigil,
                    .dict_sigil,
                    .bytes_kw,
                    .int_kw,
                    .float_kw,
                    .bool_kw,
                    .any_kw,
                    .identifier,
                    => {
                        try p.addChild(.type_expr);
                        continue :parse .type_expr;
                    },

                    .comma, .rb => {
                        try p.err(.{
                            .tag = .{ .missing_token = "type expression" },
                            .main_location = p.prev_loc,
                        });
                        p.node().loc.end = p.prev_loc.end;
                        p.up();
                        if (p.tok.tag == .comma) p.consume();
                        continue :parse p.node().tag;
                    },

                    .struct_kw, .union_kw => {
                        switch (p.node().tag) {
                            else => unreachable,
                            .struct_field => {
                                try p.err(.{
                                    .tag = .{ .missing_token = "type expression" },
                                    .main_location = p.prev_loc,
                                });
                            },
                            .union_field => {
                                try p.err(.{
                                    .tag = .{ .missing_token = "comma after field" },
                                    .main_location = p.prev_loc,
                                });
                            },
                        }

                        p.node().loc.end = p.prev_loc.end;
                        p.up();
                        continue :parse p.node().tag;
                    },

                    else => {
                        p.node().loc.end = p.prev_loc.end;
                        p.up();
                        try p.err(.{
                            .tag = .unexpected_token,
                            .main_location = p.tok.loc,
                        });

                        try p.rejectDocs();
                        p.discardUntilDeclaration();
                        switch (p.tok.tag) {
                            else => unreachable,
                            .struct_kw, .union_kw => {
                                continue :parse p.node().tag;
                            },
                            .eof => {
                                return p.finalize();
                            },
                        }
                    },
                }
            },
        }

        comptime unreachable;
    }

    fn addRoot(p: *Parser) !void {
        assert(p.meta.items.len == 0);
        assert(p.nodes.items.len == 0);
        const gop = try p.scopes.getOrPut(p.gpa, 0);
        assert(!gop.found_existing);
        gop.value_ptr.* = .{ .fields = .empty, .types = .empty };

        try p.meta.append(p.gpa, .{
            .node_idx = if (std.debug.runtime_safety) 0 else {},
            .scope_slot = @intCast(gop.index),
        });
        try p.nodes.append(p.gpa, .{
            .tag = .root,
            .parent_idx = 0,
            .loc = .{ .start = 0, .end = @intCast(p.src.len) },
        });
    }

    fn consume(p: *Parser) void {
        p.prev_loc = p.tok.loc;
        p.tok = p.tokenizer.next(p.src);
    }

    fn node(p: *Parser) *Node {
        return &p.nodes.items[p.node_idx];
    }

    fn addChild(p: *Parser, tag: Node.Tag) !void {
        assert(p.nodes.items.len > 0);
        assert(p.meta.items.len > 0);
        assert(p.node().next_idx == 0);

        const parent_meta = p.getMeta();
        const parent_idx = p.node_idx;
        p.node_idx = @intCast(p.nodes.items.len);
        if (parent_meta.last_child_idx != 0) {
            const prev = &p.nodes.items[parent_meta.last_child_idx];
            assert(prev.next_idx == 0);
            prev.next_idx = p.node_idx;
        }
        parent_meta.last_child_idx = p.node_idx;

        const container_idx, const scope_slot: u32 = switch (tag) {
            .@"struct", .@"union" => blk: {
                add_to_parent_scope: {
                    var t: Tokenizer = .{ .idx = p.tok.loc.end };
                    const name_tok = t.next(p.src);
                    if (name_tok.tag != .identifier) break :add_to_parent_scope;
                    const name = name_tok.loc.slice(p.src);
                    const gop = try p.scopes.values()[parent_meta.scope_slot].types.getOrPut(p.gpa, name);
                    if (gop.found_existing) {
                        try p.err(.{
                            .tag = .{ .duplicate_type_definition = gop.value_ptr.* },
                            .main_location = name_tok.loc,
                        });
                    } else gop.value_ptr.* = p.node_idx;
                }

                const gop = try p.scopes.getOrPut(p.gpa, p.node_idx);
                assert(!gop.found_existing);
                gop.value_ptr.* = .{ .fields = .empty, .types = .empty };
                break :blk .{ p.node_idx, @intCast(gop.index) };
            },
            else => .{ parent_meta.container_idx, parent_meta.scope_slot },
        };

        if (p.docs_offset != 0) assert(tag != .type_expr);
        try p.nodes.append(p.gpa, .{
            .tag = tag,
            .loc = .{ .start = p.tok.loc.start, .end = undefined },
            .parent_idx = parent_idx,
            .docs_offset = p.popDocs(),
        });
        try p.meta.append(p.gpa, .{
            .node_idx = if (std.debug.runtime_safety) p.node_idx else {},
            .container_idx = container_idx,
            .scope_slot = scope_slot,
        });
    }

    fn getMeta(p: *Parser) *NodeMeta {
        assert(p.nodes.items.len > 0);
        assert(p.meta.items.len > 0);
        const m = &p.meta.items[p.meta.items.len - 1];
        if (std.debug.runtime_safety) assert(m.node_idx == p.node_idx);
        return m;
    }

    fn up(p: *Parser) void {
        assert(p.meta.items.len > 1);
        assert(p.node().next_idx == 0);
        assert(p.node().loc.end != 0);
        assert(p.meta.pop().?.node_idx == if (std.debug.runtime_safety) p.node_idx else {});
        p.node_idx = p.node().parent_idx;
    }

    fn discardUntilDeclaration(p: *Parser) void {
        while (p.tok.tag != .struct_kw and
            p.tok.tag != .union_kw and
            p.tok.tag != .eof)
        {
            if (p.tok.tag == .doc_comment_line) {
                p.setDocs(p.tok.loc);
                while (p.tok.tag == .doc_comment_line) : (p.consume()) {}
            } else {
                p.docs_offset = 0;
                p.consume();
            }
        }
    }

    fn ref(p: *Parser) !void {
        assert(p.tok.tag == .identifier);
        assert(p.node().tag == .type_expr);
        try p.refs.append(p.gpa, .{
            .container_idx = p.getMeta().container_idx,
            .loc = p.tok.loc,
        });
    }

    fn err(p: *Parser, e: Error) !void {
        switch (e.tag) {
            .unbound_docs,
            .missing_token,
            .field_after_decl,
            => {
                p.has_syntax_errors = true;
            },
            .unexpected_token => {
                p.has_syntax_errors = true;
                p.docs_offset = 0;
            },

            .missing_root_expr,
            .missing_terminal_type,
            .undeclared_identifier,
            .duplicate_field_name,
            .duplicate_type_definition,
            .type_name_collision,
            .infinite_loop_container,
            .infinite_loop_field,
            .empty_union,
            .unreachable_type,
            => {},
        }
        return p.errors.append(p.gpa, e);
    }

    fn setDocs(p: *Parser, loc: Loc) void {
        assert(p.docs_offset == 0);
        p.docs_offset = loc.start + 1;
    }

    fn popDocs(p: *Parser) u32 {
        const offset = p.docs_offset;
        p.docs_offset = 0;
        return offset;
    }

    fn rejectDocs(p: *Parser) !void {
        if (p.docs_offset == 0) return;
        try p.err(.{
            .tag = .unbound_docs,
            .main_location = .{
                .start = p.docs_offset - 1,
                .end = p.docs_offset + 2,
            },
        });
    }

    fn finalize(p: *Parser) !Ast {
        while (p.node().tag != .root) {
            if (p.node().loc.end == 0) {
                p.node().loc.end = p.tok.loc.end;
            }
            p.up();
        }
        assert(p.meta.items.len == 1);

        if (p.docs_offset != 0) try p.err(.{
            .tag = .unbound_docs,
            .main_location = .{
                .start = p.docs_offset - 1,
                .end = p.docs_offset + 2,
            },
        });

        if (!p.has_syntax_errors) try p.validateIdentifiers();

        defer p.scopes = .empty;
        return .{
            .has_syntax_errors = p.has_syntax_errors,
            .nodes = try p.nodes.toOwnedSlice(p.gpa),
            .errors = try p.errors.toOwnedSlice(p.gpa),
            .scopes = p.scopes,
        };
    }

    fn validateIdentifiers(p: *Parser) !void {
        assert(!p.has_syntax_errors);
        refs: for (p.refs.items) |r| {
            const name = r.loc.slice(p.src);
            var container_idx = r.container_idx;
            while (true) {
                const scope = p.scopes.get(container_idx).?;
                if (scope.types.contains(name)) continue :refs;
                if (container_idx == 0) break;
                container_idx = p.nodes.items[container_idx].parent_idx;
            }

            try p.err(.{
                .tag = .undeclared_identifier,
                .main_location = r.loc,
            });
        }

        for (p.scopes.keys()[1..]) |cidx| {
            const names = p.scopes.get(cidx).?.types.keys();
            var container_idx = cidx;
            while (true) {
                container_idx = p.nodes.items[container_idx].parent_idx;
                const scope = p.scopes.get(container_idx).?;
                for (names) |name| {
                    if (scope.types.get(name)) |orig| {
                        const start: u32 = @intCast(name.ptr - p.src.ptr);
                        try p.err(.{
                            .tag = .{ .type_name_collision = orig },
                            .main_location = .{
                                .start = start,
                                .end = @intCast(start + name.len),
                            },
                        });
                    }
                }
                if (container_idx == 0) break;
            }
        }

        if (p.errors.items.len > 0) return;

        var unexplored_paths: std.ArrayList(struct {
            field: FieldIterator.DirectContainerField,
            depth: u32,
            last_option: bool = true,
        }) = .empty;
        defer unexplored_paths.deinit(p.gpa);

        // key is container_idx
        var known_good_containers: std.AutoHashMapUnmanaged(u32, void) = .empty;
        defer known_good_containers.deinit(p.gpa);

        // key is a union container idx
        var loopy_unions: std.AutoHashMapUnmanaged(u32, std.ArrayList(struct {
            container_idx: u32,
            container_kind: ContainerKind,
            container_name: Loc,
            field_name: Loc,
        })) = .empty;
        defer {
            var it = loopy_unions.iterator();
            while (it.next()) |entry| entry.value_ptr.deinit(p.gpa);
            loopy_unions.deinit(p.gpa);
        }

        // key is container_idx
        var dfs_path: std.AutoArrayHashMapUnmanaged(u32, struct {
            container_kind: ContainerKind,
            container_name: Loc,
            outbound_field: Loc,
            last_option: bool, // always true for struct fields
        }) = .empty;
        defer dfs_path.deinit(p.gpa);

        const top_lvl_names = p.scopes.get(0).?.types;
        for (top_lvl_names.values()) |top_level_container_idx| {
            log.debug("exploring top level type {}", .{top_level_container_idx});
            assert(unexplored_paths.items.len == 0);
            assert(dfs_path.entries.len == 0);

            if (known_good_containers.contains(top_level_container_idx)) continue;

            var fi: FieldIterator = .init(p.nodes.items, &p.scopes, p.src, top_level_container_idx);
            while (fi.nextDirectContainer()) |field| try unexplored_paths.append(p.gpa, .{
                .field = field,
                .depth = 0,
            });

            explore: while (unexplored_paths.pop()) |ux| {
                dfs_path.shrinkRetainingCapacity(ux.depth);

                const source_container_idx = p.nodes.items[ux.field.node_idx].parent_idx;
                if (known_good_containers.contains(source_container_idx)) {
                    continue :explore;
                }

                const source_container = containerInfo(p.nodes.items, p.src, source_container_idx);

                log.debug("adding {any} to path\n", .{ux});
                const gop_p = try dfs_path.getOrPut(p.gpa, source_container_idx);
                if (gop_p.found_existing) {
                    const suffix_keys = dfs_path.keys()[gop_p.index..];
                    const suffix = dfs_path.values()[gop_p.index..];
                    for (suffix_keys, suffix) |union_idx, step| {
                        // Don't report a loop if any step is a union that has not
                        // beeen exhausted yet or if it is already known to be good.
                        if (step.container_kind == .@"union" and (!step.last_option or
                            known_good_containers.contains(union_idx)))
                        {
                            log.debug("saving {} union steps for {}", .{ suffix.len, union_idx });
                            const gop_lu = try loopy_unions.getOrPut(p.gpa, union_idx);
                            if (!gop_lu.found_existing) gop_lu.value_ptr.* = .empty;
                            try gop_lu.value_ptr.ensureUnusedCapacity(p.gpa, suffix.len);
                            for (suffix_keys, suffix) |k, s| gop_lu.value_ptr.appendAssumeCapacity(.{
                                .container_idx = k,
                                .container_kind = s.container_kind,
                                .container_name = s.container_name,
                                .field_name = s.outbound_field,
                            });

                            continue :explore;
                        }
                    }

                    var loopy_containers: std.AutoArrayHashMapUnmanaged(u32, void) = .empty;
                    defer loopy_containers.deinit(p.gpa);
                    try loopy_containers.ensureUnusedCapacity(p.gpa, @intCast(suffix.len));
                    for (suffix_keys, suffix) |container_idx, step| {
                        const gop_lc = try loopy_containers.getOrPut(p.gpa, container_idx);
                        if (gop_lc.found_existing) continue;

                        try p.err(.{
                            .tag = .{ .infinite_loop_container = step.container_kind },
                            .main_location = step.container_name,
                        });

                        switch (step.container_kind) {
                            .@"struct" => {
                                try p.err(.{
                                    .tag = .infinite_loop_field,
                                    .main_location = step.outbound_field,
                                });
                            },
                            .@"union" => {
                                var kv = loopy_unions.fetchRemove(container_idx) orelse continue;
                                defer kv.value.deinit(p.gpa);
                                for (kv.value.items) |saved_step| {
                                    const gops = try loopy_containers.getOrPut(p.gpa, saved_step.container_idx);
                                    if (gops.found_existing) continue;
                                    try p.err(.{
                                        .tag = .{ .infinite_loop_container = saved_step.container_kind },
                                        .main_location = saved_step.container_name,
                                    });
                                    if (saved_step.container_kind == .@"struct") {
                                        try p.err(.{
                                            .tag = .infinite_loop_field,
                                            .main_location = saved_step.field_name,
                                        });
                                    }
                                }
                            },
                        }
                    }
                    return;
                }

                gop_p.value_ptr.* = .{
                    .container_kind = source_container.kind,
                    .container_name = source_container.name,
                    .outbound_field = ux.field.name_loc,
                    .last_option = ux.last_option,
                };

                log.debug("field '{s}' ({}) of {t} {s} ({}) resolved to type ({})\n", .{
                    ux.field.name_loc.slice(p.src),
                    ux.field.node_idx,
                    source_container.kind,
                    source_container.name.slice(p.src),
                    source_container_idx,
                    ux.field.target_container_idx,
                });

                var it = p.fieldIterator(ux.field.target_container_idx);
                switch (it.container_kind) {
                    .@"struct" => {
                        var first = true;
                        while (it.nextDirectContainer()) |field| {
                            try unexplored_paths.append(p.gpa, .{
                                .field = field,
                                .depth = @intCast(dfs_path.entries.len),
                                .last_option = first,
                            });
                            first = false;
                        }

                        if (first) {
                            for (dfs_path.keys(), dfs_path.values()) |container_idx, step| {
                                switch (step.container_kind) {
                                    .@"struct" => if (step.last_option) {
                                        try known_good_containers.put(p.gpa, container_idx, {});
                                    },
                                    .@"union" => {
                                        try known_good_containers.put(p.gpa, container_idx, {});
                                        _ = loopy_unions.remove(container_idx);
                                    },
                                }
                            }
                            continue :explore;
                        }
                    },
                    .@"union" => {
                        if (it.unionAnyTerminal()) {
                            try known_good_containers.put(p.gpa, ux.field.target_container_idx, {});
                            continue :explore;
                        }
                        var first = true;
                        while (it.nextDirectContainer()) |f| {
                            try unexplored_paths.append(p.gpa, .{
                                .field = f,
                                .depth = @intCast(dfs_path.entries.len),
                                .last_option = first,
                            });
                            first = false;
                        }

                        // no empty unions
                        if (first) return p.err(.{
                            .tag = .empty_union,
                            .main_location = ux.field.target_container_name,
                        });
                    },
                }
            }
        }

        // no loops detected, check for unreachable nested types
        // for (p.scopes.values()[1..]) |scope| {
        //     for (scope.values()) |container_idx| {
        //         if (!known_good_containers.contains(container_idx)) {
        //             try p.err(.{
        //                 .tag = .unreachable_type,
        //                 .main_location = containerInfo(p.nodes.items, p.src, container_idx).name,
        //             });
        //         }
        //     }
        // }
    }

    fn fieldIterator(p: *Parser, container_idx: u32) FieldIterator {
        return .init(p.nodes.items, &p.scopes, p.src, container_idx);
    }

    const FieldIterator = struct {
        nodes: []const Node,
        scopes: *const Scopes,
        src: [:0]const u8,
        container_kind: ContainerKind,
        container_idx: u32,
        next_field_idx: u32,

        const DirectContainerField = struct {
            name_loc: Loc,
            node_idx: u32,
            target_container_name: Loc,
            target_container_idx: u32,
            // target_container_kind: ContainerKind,
        };

        fn init(
            nodes: []const Node,
            scopes: *const Scopes,
            src: [:0]const u8,
            container_idx: u32,
        ) FieldIterator {
            const container = &nodes[container_idx];
            const field_idx = if (container.childIdx(nodes)) |field_idx| switch (nodes[field_idx].tag) {
                .struct_field, .union_field => field_idx,
                else => 0,
            } else 0;

            return .{
                .nodes = nodes,
                .scopes = scopes,
                .src = src,
                .container_idx = container_idx,
                .next_field_idx = field_idx,
                .container_kind = switch (container.tag) {
                    .@"struct" => .@"struct",
                    .@"union" => .@"union",
                    else => unreachable,
                },
            };
        }

        fn nextDirectContainer(fi: *FieldIterator) ?DirectContainerField {
            while (fi.next_field_idx != 0) {
                const field = &fi.nodes[fi.next_field_idx];
                defer fi.next_field_idx = field.next_idx;

                switch (field.tag) {
                    else => unreachable,
                    .struct_field => assert(fi.container_kind == .@"struct"),
                    .union_field => assert(fi.container_kind == .@"union"),
                    .@"struct", .@"union" => {
                        fi.next_field_idx = 0;
                        return null;
                    },
                }

                const expr_idx = field.childIdx(fi.nodes) orelse continue;
                const expr = fi.nodes[expr_idx];
                var t: Tokenizer = .{ .idx = expr.loc.start };
                const tok = t.next(fi.src);
                switch (tok.tag) {
                    else => continue,
                    .identifier => {
                        const target = resolveContainer(
                            fi.nodes,
                            fi.scopes,
                            fi.src,
                            tok.loc.slice(fi.src),
                            fi.container_idx,
                        ).?;

                        const name_loc = blk: {
                            t.idx = field.loc.start;
                            const name_tok = t.next(fi.src);
                            assert(name_tok.tag == .identifier);
                            break :blk name_tok.loc;
                        };

                        return .{
                            .name_loc = name_loc,
                            .node_idx = fi.next_field_idx,
                            .target_container_idx = target.node_idx,
                            .target_container_name = target.name,
                            // .target_container_kind = target.kind,
                        };
                    },
                }
            } else return null;
        }

        fn unionAnyTerminal(fi: *const FieldIterator) bool {
            assert(fi.container_kind == .@"union");
            var field_idx = fi.next_field_idx;
            while (field_idx != 0) {
                const field = &fi.nodes[field_idx];
                field_idx = field.next_idx;
                switch (field.tag) {
                    else => unreachable,
                    .@"struct", .@"union" => return false,
                    .struct_field => unreachable,
                    .union_field => {
                        const expr_idx = field.childIdx(fi.nodes) orelse return true;
                        const expr = fi.nodes[expr_idx];
                        var t: Tokenizer = .{ .idx = expr.loc.start };
                        switch (t.next(fi.src).tag) {
                            .identifier => continue,
                            else => return true,
                        }
                    },
                }
            } else return false;
        }
    };

    const ResolvedContainer = struct {
        name: Loc,
        node_idx: u32,
        kind: ContainerKind,
    };
    fn resolveContainer(
        nodes: []const Node,
        scopes: *const Scopes,
        src: [:0]const u8,
        name: []const u8,
        source_container_idx: u32,
    ) ?ResolvedContainer {
        var container_idx = source_container_idx;
        while (true) {
            const scope = scopes.get(container_idx).?.types;
            if (scope.getEntry(name)) |entry| {
                const slice = entry.key_ptr.*;
                const start: u32 = @intCast(slice.ptr - src.ptr);
                return .{
                    .node_idx = entry.value_ptr.*,
                    .name = .{
                        .start = start,
                        .end = @intCast(start + slice.len),
                    },
                    .kind = switch (nodes[entry.value_ptr.*].tag) {
                        .@"struct" => .@"struct",
                        .@"union" => .@"union",
                        else => unreachable,
                    },
                };
            }
            if (container_idx == 0) return null;
            container_idx = nodes[container_idx].parent_idx;
        }
    }
};

const ContainerInfo = struct {
    name: Loc,
    kind: ContainerKind,
};

fn containerInfo(nodes: []const Node, src: [:0]const u8, container_idx: u32) ContainerInfo {
    const container = nodes[container_idx];
    const container_kind: ContainerKind = switch (container.tag) {
        .@"struct" => .@"struct",
        .@"union" => .@"union",
        else => unreachable,
    };
    var t: Tokenizer = .{ .idx = container.loc.start };
    _ = t.next(src);
    const tok = t.next(src);
    assert(tok.tag == .identifier);
    const container_name_loc = tok.loc;
    return .{
        .name = container_name_loc,
        .kind = container_kind,
    };
}

/// Asserts that the Ast it's called on has no syntax errors that prevent
/// formatting from happening.
pub fn fmt(ast: Ast, src: [:0]const u8) Fmt {
    assert(!ast.has_syntax_errors);
    return .{ .nodes = ast.nodes, .src = src };
}

const Fmt = struct {
    nodes: []const Node,
    src: [:0]const u8,

    pub fn format(f: Fmt, w: *Writer) !void {
        assert(f.nodes.len > 0);
        assert(f.nodes[0].tag == .root);
        if (f.nodes.len == 1) return;

        var container_idx: u32 = if (f.nodes[1].tag == .root_expr) blk: {
            const expr = &f.nodes[f.nodes[1].childIdx(f.nodes).?];
            assert(expr.tag == .type_expr);
            try f.printDocs(&f.nodes[1], w, 0);
            try w.writeAll("$ = ");
            const expr_src = expr.loc.slice(f.src);
            var it = std.mem.tokenizeAny(u8, expr_src, " \t\r\n");
            while (it.next()) |tok| try w.writeAll(tok);
            const next_idx = f.nodes[1].next_idx;
            if (next_idx == 0) return;
            break :blk next_idx;
        } else 1;

        try w.writeAll("\n\n");
        var indent: u32 = 0;
        var direction: enum { enter, leave } = .enter;
        container: while (container_idx != 0) {
            const c = &f.nodes[container_idx];
            assert(c.tag == .@"struct" or c.tag == .@"union");

            direction: switch (direction) {
                .enter => {
                    const container_src = f.src[c.loc.start..]; // preserves null terminator
                    var t: Tokenizer = .{};
                    const container_kw = t.next(container_src);
                    assert(container_kw.tag == .struct_kw or container_kw.tag == .union_kw);
                    const name = t.next(container_src);
                    assert(name.tag == .identifier);
                    try f.printDocs(c, w, indent);
                    try w.splatByteAll(' ', indent * 4);
                    try w.print("{t} {s} {{", .{ c.tag, name.loc.slice(container_src) });
                    indent += 1;
                    var body_idx = c.childIdx(f.nodes) orelse {
                        direction = .leave;
                        continue :direction .leave;
                    };
                    try w.writeAll("\n");
                    var last_was_field = false;
                    while (body_idx != 0) {
                        const elem = &f.nodes[body_idx];
                        switch (elem.tag) {
                            else => unreachable,
                            .@"struct", .@"union" => {
                                if (last_was_field) try w.writeAll("\n");
                                direction = .enter;
                                container_idx = body_idx;
                                continue :container;
                            },
                            .struct_field, .union_field => {
                                const field_src = f.src[elem.loc.start..];
                                var field_t: Tokenizer = .{};
                                const field_name = field_t.next(field_src);
                                assert(field_name.tag == .identifier);
                                try f.printDocs(elem, w, indent);
                                try w.splatByteAll(' ', indent * 4);
                                if (elem.childIdx(f.nodes)) |expr_idx| {
                                    try w.print("{s}: ", .{field_name.loc.slice(field_src)});
                                    const expr_src = f.nodes[expr_idx].loc.slice(f.src);
                                    var it = std.mem.tokenizeAny(u8, expr_src, " \t\r\n");
                                    while (it.next()) |tok| try w.writeAll(tok);
                                } else {
                                    try w.writeAll(field_name.loc.slice(field_src));
                                }

                                try w.writeAll(",\n");
                                if (elem.next_idx == 0) {
                                    direction = .leave;
                                    continue :direction .leave;
                                } else {
                                    const next_elem = f.nodes[elem.next_idx];
                                    const next_is_field = switch (next_elem.tag) {
                                        .struct_field, .union_field => true,
                                        else => false,
                                    };

                                    const next_start = if (next_elem.docs_offset != 0)
                                        next_elem.docs_offset
                                    else
                                        next_elem.loc.start;

                                    if (next_is_field and std.mem.count(
                                        u8,
                                        f.src[elem.loc.end..next_start],
                                        "\n",
                                    ) > 1) try w.writeAll("\n");
                                }

                                body_idx = elem.next_idx;
                                last_was_field = true;
                            },
                        }
                    }

                    direction = .leave;
                    continue :direction .leave;
                },
                .leave => {
                    indent -= 1;
                    if (c.childIdx(f.nodes) != null) try w.splatByteAll(' ', indent * 4);
                    try w.writeAll("}\n");

                    if (c.next_idx != 0) {
                        const next_elem = f.nodes[c.next_idx];
                        const next_start = if (next_elem.docs_offset != 0)
                            next_elem.docs_offset
                        else
                            next_elem.loc.start;
                        if (std.mem.count(u8, f.src[c.loc.end..next_start], "\n") > 1) {
                            try w.writeAll("\n");
                        }
                        direction = .enter;
                        container_idx = c.next_idx;
                        continue :container;
                    }

                    if (c.parent_idx == 0) return;
                    assert(direction == .leave);
                    container_idx = c.parent_idx;
                    continue :container;
                },
            }
        }
    }

    fn printDocs(f: Fmt, n: *const Node, w: *Writer, indent: u32) !void {
        if (n.docs_offset == 0) return;
        const docs_src = f.src[n.docs_offset - 1 ..];

        var t: Tokenizer = .{};
        while (true) {
            const tok = t.next(docs_src);
            if (tok.tag != .doc_comment_line) return;
            const line = std.mem.trimRight(u8, tok.loc.slice(docs_src), " \t\r");
            try w.splatByteAll(' ', indent * 4);
            try w.print("{s}\n", .{line});
        }
    }
};

pub const ValidationError = struct {
    main_location: ZiggyTokenizer.Token.Loc,
    tag: union(enum) {
        mismatch: struct {
            expected: []const u8,
            found: ZiggyAst.Node.Tag,
        },
        unknown_union_case,
        // union in ziggy document should be enum
        erroneous_union_case_value,
        // enum in ziggy document should be union
        missing_union_value: []const u8, // type expr of the missing value
        // 'field' can be both struct and dict fields
        duplicate_field,
        missing_field: []const u8, // name of the missing field
        unknown_field,

        pub fn format(t: @This(), w: *Writer) !void {
            switch (t) {
                .duplicate_field => {
                    try w.print("duplicate field", .{});
                },
                .unknown_union_case => {
                    try w.print("schema mismatch: unknown union case", .{});
                },
                .erroneous_union_case_value => {
                    try w.print("schema mismatch: union case with unexpected value", .{});
                },
                .missing_union_value => |value| {
                    try w.print("schema mismatch: missing union value of type {s}", .{value});
                },
                .unknown_field => {
                    try w.print("schema mismatch: unknown field", .{});
                },
                .missing_field => |name| {
                    try w.print("schema mismatch: missing field '{s}'", .{name});
                },
                .mismatch => |sm| {
                    try w.print("schema mismatch: expected {s} found {s}", .{
                        sm.expected, switch (sm.found) {
                            .root, .missing_value => unreachable,
                            .braceless_struct => "braceless struct",
                            .struct_h, .struct_v, .struct_v_fixup, .struct_field => "struct",
                            .dict_h, .dict_v, .dict_field => "{:}",
                            .array_h, .array_v, .array_element => "[]",
                            .@"union" => "union",
                            .@"enum" => "enum",
                            .bytes, .bytes_multiline => "bytes",
                            .integer => "int",
                            .float => "float",
                            .bool => "bool",
                            .null => "null",
                        },
                    });
                },
            }
        }
    },
};

/// Validates a Ziggy Document against a Ziggy Schema.
///
/// Asserts that the schema does not contain errors.
/// Asserts that the document does not contain errors.
/// Caller owns returned memory.
pub fn validate(
    schema_ast: Ast,
    gpa: Allocator,
    schema_src: [:0]const u8,
    ziggy_ast: ZiggyAst,
    ziggy_src: [:0]const u8,
) ![]const ValidationError {
    assert(schema_ast.errors.len == 0);
    assert(ziggy_ast.errors.len == 0);

    var type_expr_stack: std.ArrayList(Token) = .empty;
    try type_expr_stack.append(gpa, .{ .tag = .root_sigil, .loc = .{ .start = 0, .end = 0 } });
    defer type_expr_stack.deinit(gpa);
    var type_expr_idx: u32 = 1;

    var any_ziggy_start: ?*const ZiggyAst.Node = null;
    var scopes_stack: std.ArrayList(u32) = .empty;
    try scopes_stack.append(gpa, 0);
    defer scopes_stack.deinit(gpa);

    var seen_fields_stack: std.ArrayList(union(enum) {
        @"struct": std.DynamicBitSetUnmanaged,
        dict: std.StringHashMapUnmanaged(void),
    }) = .empty;
    defer {
        for (seen_fields_stack.items) |*elem| switch (elem.*) {
            .@"struct" => |*s| s.deinit(gpa),
            .dict => |*d| d.deinit(gpa),
        };
        seen_fields_stack.deinit(gpa);
    }

    var errors: std.ArrayList(ValidationError) = .empty;
    defer errors.deinit(gpa);

    // load root type expr
    try schema_ast.loadExpr(gpa, schema_src, &type_expr_stack, 2);
    if (type_expr_stack.items[type_expr_idx].tag == .any_kw) {
        any_ziggy_start = &ziggy_ast.nodes[0];
    }

    var ziggy_it = ziggy_ast.iterator();
    while (true) {
        const ev = ziggy_it.next();

        // std.debug.print("any_ziggy_start = {?*}\n", .{any_ziggy_start});
        // std.debug.print("expr idx = {}\n", .{type_expr_idx});
        // for (type_expr_stack.items, 0..) |expr, idx| {
        //     std.debug.print("expr[{}] = '{s}'\n", .{ idx, expr.loc.slice(schema_src) });
        // }
        // for (seen_fields_stack.items, 0..) |tag, idx| {
        //     std.debug.print("seen[{}] = {t}\n", .{ idx, tag });
        // }
        // std.debug.print("validate ev: {any}\n", .{ev});

        const expr = type_expr_stack.items[type_expr_idx];
        switch (ev) {
            .enter => |node| {
                switch (node.tag) {
                    .root, .missing_value => unreachable,
                    .null => {
                        switch (expr.tag) {
                            .any_kw, .qmark => {},
                            else => {
                                try errors.append(gpa, .{
                                    .tag = .{
                                        .mismatch = .{
                                            .found = node.tag,
                                            .expected = expr.loc.slice(schema_src),
                                        },
                                    },
                                    .main_location = node.loc,
                                });
                                continue;
                            },
                        }
                    },
                    .bool => {
                        switch (expr.tag) {
                            .any_kw, .bool_kw => {},
                            else => {
                                try errors.append(gpa, .{
                                    .tag = .{
                                        .mismatch = .{
                                            .found = node.tag,
                                            .expected = expr.loc.slice(schema_src),
                                        },
                                    },
                                    .main_location = node.loc,
                                });
                                continue;
                            },
                        }
                    },
                    .integer => {
                        switch (expr.tag) {
                            .any_kw, .int_kw, .float_kw => {},
                            else => {
                                try errors.append(gpa, .{
                                    .tag = .{
                                        .mismatch = .{
                                            .found = node.tag,
                                            .expected = expr.loc.slice(schema_src),
                                        },
                                    },
                                    .main_location = node.loc,
                                });
                                continue;
                            },
                        }
                    },
                    .float => {
                        switch (expr.tag) {
                            .any_kw, .float_kw => {},
                            else => {
                                try errors.append(gpa, .{
                                    .tag = .{
                                        .mismatch = .{
                                            .found = node.tag,
                                            .expected = expr.loc.slice(schema_src),
                                        },
                                    },
                                    .main_location = node.loc,
                                });
                                continue;
                            },
                        }
                    },
                    .bytes, .bytes_multiline => {
                        switch (expr.tag) {
                            .any_kw, .bytes_kw => {},
                            else => {
                                try errors.append(gpa, .{
                                    .tag = .{
                                        .mismatch = .{
                                            .found = node.tag,
                                            .expected = expr.loc.slice(schema_src),
                                        },
                                    },
                                    .main_location = node.loc,
                                });
                                continue;
                            },
                        }
                    },
                    .@"enum" => {
                        switch (expr.tag) {
                            .any_kw => {},
                            .identifier => {
                                const scope = scopes_stack.getLast();
                                const container_idx = schema_ast.scopes.get(scope).?.types.get(
                                    expr.loc.slice(schema_src),
                                ).?;
                                const info = containerInfo(schema_ast.nodes, schema_src, container_idx);
                                switch (info.kind) {
                                    .@"struct" => {
                                        try errors.append(gpa, .{
                                            .tag = .{
                                                .mismatch = .{
                                                    .found = node.tag,
                                                    .expected = expr.loc.slice(schema_src),
                                                },
                                            },
                                            .main_location = node.loc,
                                        });
                                    },
                                    .@"union" => {
                                        const name_raw = node.loc.slice(ziggy_src);
                                        const name = name_raw[1..]; //skip '.'
                                        const field = schema_ast.scopes.get(container_idx).?.fields.get(name) orelse {
                                            try errors.append(gpa, .{
                                                .tag = .unknown_union_case,
                                                .main_location = node.loc,
                                            });
                                            continue;
                                        };

                                        const maybe_child_idx = field.idx + 1;
                                        if (maybe_child_idx < schema_ast.nodes.len and
                                            schema_ast.nodes[maybe_child_idx].parent_idx == field.idx)
                                        {
                                            const child_loc = schema_ast.nodes[maybe_child_idx].loc;
                                            try errors.append(gpa, .{
                                                .tag = .{ .missing_union_value = child_loc.slice(schema_src) },
                                                .main_location = node.loc,
                                            });
                                        }
                                    },
                                }
                            },
                            else => {
                                try errors.append(gpa, .{
                                    .tag = .{
                                        .mismatch = .{
                                            .found = node.tag,
                                            .expected = expr.loc.slice(schema_src),
                                        },
                                    },
                                    .main_location = node.loc,
                                });
                            },
                        }
                    },
                    .@"union" => {
                        switch (expr.tag) {
                            .any_kw => if (any_ziggy_start == null) {
                                any_ziggy_start = node;
                            },
                            .identifier => {
                                const scope = scopes_stack.getLast();
                                const container_idx = schema_ast.scopes.get(scope).?.types.get(
                                    expr.loc.slice(schema_src),
                                ).?;
                                const info = containerInfo(schema_ast.nodes, schema_src, container_idx);
                                switch (info.kind) {
                                    .@"struct" => {
                                        try errors.append(gpa, .{
                                            .tag = .{
                                                .mismatch = .{
                                                    .found = .@"union",
                                                    .expected = expr.loc.slice(schema_src),
                                                },
                                            },
                                            .main_location = node.loc,
                                        });
                                        ziggy_it.skip();
                                        assert(ziggy_it.next() == .exit);
                                        continue;
                                    },
                                    .@"union" => {
                                        var t: ZiggyTokenizer = .{ .idx = node.loc.start };
                                        const name_tok = t.next(ziggy_src, true);
                                        assert(name_tok.tag == .union_case);
                                        const name_raw = name_tok.loc.slice(ziggy_src);
                                        const name = name_raw[1 .. name_raw.len - 1]; //skip '.' and '('
                                        const field = schema_ast.scopes.get(container_idx).?.fields.get(name) orelse {
                                            try errors.append(gpa, .{
                                                .tag = .unknown_union_case,
                                                .main_location = node.loc,
                                            });
                                            ziggy_it.skip();
                                            assert(ziggy_it.next() == .exit);
                                            continue;
                                        };

                                        const maybe_child_idx = field.idx + 1;
                                        assert(schema_ast.nodes.len >= maybe_child_idx);
                                        if (maybe_child_idx == schema_ast.nodes.len or
                                            schema_ast.nodes[maybe_child_idx].parent_idx != field.idx)
                                        {
                                            try errors.append(gpa, .{
                                                .tag = .erroneous_union_case_value,
                                                .main_location = node.loc,
                                            });
                                            ziggy_it.skip();
                                            assert(ziggy_it.next() == .exit);
                                            continue;
                                        }

                                        try schema_ast.loadExpr(
                                            gpa,
                                            schema_src,
                                            &type_expr_stack,
                                            maybe_child_idx,
                                        );

                                        type_expr_idx += 1;
                                        if (type_expr_stack.items[type_expr_idx].tag == .any_kw) {
                                            if (any_ziggy_start == null) any_ziggy_start = node;
                                        }
                                    },
                                }
                            },
                            else => {
                                try errors.append(gpa, .{
                                    .tag = .{
                                        .mismatch = .{
                                            .found = node.tag,
                                            .expected = expr.loc.slice(schema_src),
                                        },
                                    },
                                    .main_location = node.loc,
                                });
                            },
                        }
                    },
                    .dict_h, .dict_v => {
                        try seen_fields_stack.append(gpa, .{ .dict = .empty });
                        switch (expr.tag) {
                            .dict_sigil => {},
                            .any_kw => {},
                            else => {
                                try errors.append(gpa, .{
                                    .tag = .{
                                        .mismatch = .{
                                            .found = node.tag,
                                            .expected = expr.loc.slice(schema_src),
                                        },
                                    },
                                    .main_location = node.loc,
                                });
                                ziggy_it.skip();
                                continue;
                            },
                        }
                    },
                    .braceless_struct, .struct_v, .struct_h, .struct_v_fixup => {
                        switch (expr.tag) {
                            .any_kw => {
                                // If we don't have precise schema information for this struct
                                // we just treat is as a dict, see the corresponding handling in
                                // the exit event case.
                                try seen_fields_stack.append(gpa, .{ .dict = .empty });
                            },
                            .identifier => {
                                const scope = scopes_stack.getLast();
                                const container_idx = schema_ast.scopes.get(scope).?.types.get(
                                    expr.loc.slice(schema_src),
                                ).?;
                                const info = containerInfo(schema_ast.nodes, schema_src, container_idx);
                                switch (info.kind) {
                                    .@"union" => {
                                        try errors.append(gpa, .{
                                            .tag = .{
                                                .mismatch = .{
                                                    .found = node.tag,
                                                    .expected = expr.loc.slice(schema_src),
                                                },
                                            },
                                            .main_location = node.loc,
                                        });
                                        ziggy_it.skip();
                                        assert(ziggy_it.next() == .exit);
                                        continue;
                                    },
                                    .@"struct" => {
                                        try scopes_stack.append(gpa, container_idx);
                                        const size = schema_ast.scopes.get(container_idx).?.fields.count();
                                        try seen_fields_stack.append(gpa, .{
                                            .@"struct" = try .initEmpty(gpa, size),
                                        });
                                    },
                                }
                            },
                            else => {
                                try errors.append(gpa, .{
                                    .tag = .{
                                        .mismatch = .{
                                            .found = node.tag,
                                            .expected = expr.loc.slice(schema_src),
                                        },
                                    },
                                    .main_location = node.loc,
                                });
                                ziggy_it.skip();
                                assert(ziggy_it.next() == .exit);
                                continue;
                            },
                        }
                    },
                    .dict_field, .struct_field => {
                        var t: ZiggyTokenizer = .{ .idx = node.loc.start };
                        const name_tok = t.next(ziggy_src, true);
                        const name_raw = name_tok.loc.slice(ziggy_src);
                        const name = switch (name_tok.tag) {
                            .identifier => name_raw[1..], // skip '.'
                            .bytes => name_raw[1 .. name_raw.len - 1], // skip quotes
                            else => unreachable,
                        };
                        const seen = &seen_fields_stack.items[seen_fields_stack.items.len - 1];
                        switch (seen.*) {
                            .@"struct" => |*bits| {
                                assert(expr.tag != .any_kw);
                                const scope = schema_ast.scopes.get(scopes_stack.getLast()).?;
                                const field_slot = scope.fields.getIndex(name) orelse {
                                    try errors.append(gpa, .{
                                        .tag = .unknown_field,
                                        .main_location = node.loc,
                                    });
                                    ziggy_it.skip();
                                    assert(ziggy_it.next() == .exit);
                                    continue;
                                };
                                if (bits.isSet(field_slot)) {
                                    try errors.append(gpa, .{
                                        .tag = .duplicate_field,
                                        .main_location = name_tok.loc,
                                    });
                                    ziggy_it.skip();
                                    assert(ziggy_it.next() == .exit);
                                    continue;
                                }
                                bits.set(field_slot);
                                if (expr.tag != .any_kw) {
                                    const field = scope.fields.values()[field_slot];
                                    try schema_ast.loadExpr(gpa, schema_src, &type_expr_stack, field.idx + 1);
                                    type_expr_idx += 1;
                                    if (type_expr_stack.items[type_expr_idx].tag == .any_kw) {
                                        if (any_ziggy_start == null) any_ziggy_start = node;
                                    }
                                }
                            },
                            .dict => |*map| {
                                if (expr.tag != .any_kw) {
                                    type_expr_idx += 1;
                                    if (type_expr_stack.items[type_expr_idx].tag == .any_kw) {
                                        if (any_ziggy_start == null) any_ziggy_start = node;
                                    }
                                }
                                const gop = try map.getOrPut(gpa, name);
                                if (gop.found_existing) {
                                    try errors.append(gpa, .{
                                        .tag = .duplicate_field,
                                        .main_location = name_tok.loc,
                                    });
                                }
                            },
                        }
                    },
                    .array_h, .array_v => {
                        switch (expr.tag) {
                            .slice_sigil => {},
                            .any_kw => {},
                            else => {
                                try errors.append(gpa, .{
                                    .tag = .{
                                        .mismatch = .{
                                            .found = node.tag,
                                            .expected = expr.loc.slice(schema_src),
                                        },
                                    },
                                    .main_location = node.loc,
                                });
                                ziggy_it.skip();
                                continue;
                            },
                        }
                    },
                    .array_element => {
                        if (expr.tag == .any_kw) {
                            if (any_ziggy_start == null) any_ziggy_start = node;
                        } else {
                            type_expr_idx += 1;
                        }
                    },
                }
            },
            .exit => |node| {
                switch (node.tag) {
                    .root,
                    .missing_value,
                    .null,
                    .integer,
                    .float,
                    .bool,
                    .bytes,
                    .bytes_multiline,
                    .@"enum",
                    => unreachable,
                    .dict_h, .dict_v => {
                        var discarded = seen_fields_stack.pop().?;
                        discarded.dict.deinit(gpa);
                    },
                    .braceless_struct, .struct_h, .struct_v, .struct_v_fixup => {
                        var seen = seen_fields_stack.pop().?;
                        switch (seen) {
                            .@"struct" => |*bits| {
                                const container_idx = scopes_stack.pop().?;
                                const scope = schema_ast.scopes.get(container_idx).?;
                                var it = bits.iterator(.{ .kind = .unset });
                                while (it.next()) |field_idx| {
                                    try errors.append(gpa, .{
                                        .tag = .{
                                            .missing_field = scope.fields.values()[field_idx].loc.slice(
                                                schema_src,
                                            ),
                                        },
                                        .main_location = .{
                                            .start = node.loc.end - 1,
                                            .end = node.loc.end,
                                        },
                                    });
                                }
                                bits.deinit(gpa);
                            },
                            .dict => |*dict| {
                                // This can happen when we are inside of `any`. We don't have precise type
                                // information so we have to treat the struct as a dict.
                                dict.deinit(gpa);
                            },
                        }
                    },
                    .struct_field => {
                        const start = any_ziggy_start orelse {
                            type_expr_stack.items.len = type_expr_idx;
                            type_expr_idx -= 1;
                            continue;
                        };

                        assert(type_expr_stack.items[type_expr_idx].tag == .any_kw);
                        if (node == start) {
                            type_expr_stack.items.len = type_expr_idx;
                            any_ziggy_start = null;
                            type_expr_idx -= 1;
                        }
                    },
                    .@"union", .dict_field, .array_element => {
                        const start = any_ziggy_start orelse {
                            if (node.tag == .@"union") type_expr_stack.items.len = type_expr_idx;
                            type_expr_idx -= 1;
                            continue;
                        };

                        assert(type_expr_stack.items[type_expr_idx].tag == .any_kw);
                        if (node == start) {
                            any_ziggy_start = null;
                            type_expr_idx -= 1;
                        }
                    },
                    .array_h, .array_v => {},
                }
            },
            .done => return errors.toOwnedSlice(gpa),
        }
    }
}

fn loadExpr(
    schema_ast: Ast,
    gpa: Allocator,
    schema_src: [:0]const u8,
    stack: *std.ArrayList(Token),
    node_idx: u32,
) !void {
    var tokenizer: Tokenizer = .{ .idx = schema_ast.nodes[node_idx].loc.start };
    while (true) {
        const t = tokenizer.next(schema_src);
        log.debug("loadexpr: '{s}'", .{t.loc.slice(schema_src)});
        switch (t.tag) {
            .slice_sigil,
            .dict_sigil,
            .identifier,
            .bytes_kw,
            .int_kw,
            .float_kw,
            .bool_kw,
            .any_kw,
            => {
                try stack.append(gpa, t);
            },
            else => break,
        }
    }
}

/// Resolves an offset in a Ziggy document to a corresponding schema node, which
/// can then be used for providing documentation, goto definition, etc.
/// Returns 0 in case of resolution failure, which can happen if the Ziggy
/// document contains errors.
///
/// Asserts that the schema does not contain errors.
pub fn resolveZiggyOffset(
    schema_ast: Ast,
    schema_src: [:0]const u8,
    ziggy_ast: ZiggyAst,
    ziggy_src: [:0]const u8,
    ziggy_offset: u32,
) u32 {
    assert(schema_ast.errors.len == 0);

    var scope_idx: u32 = 0;
    var ziggy_idx: u32 = 1;
    var schema_idx: u32 = 2; // root_expr
    var tokenizer: Tokenizer = .{ .idx = schema_ast.nodes[schema_idx].loc.start };
    var ziggy_node = ziggy_ast.nodes[ziggy_idx];

    outer: while (true) {
        log.debug("resolve: scope_idx: {}, ziggy_idx: {} ({t}), schema_idx: {}\n", .{ scope_idx, ziggy_idx, ziggy_node.tag, schema_idx });
        if (ziggy_node.loc.start > ziggy_offset or ziggy_node.loc.end <= ziggy_offset) {
            return 0;
        }

        const t = tokenizer.next(schema_src);
        switch (t.tag) {
            .slice_sigil => switch (ziggy_node.tag) {
                .array_h, .array_v => {
                    var child_idx = ziggy_idx + 1;
                    if (child_idx == ziggy_ast.nodes.len or
                        ziggy_ast.nodes[child_idx].parent_idx != ziggy_idx) return schema_idx;
                    while (child_idx != 0) {
                        const child = ziggy_ast.nodes[child_idx];
                        defer child_idx = child.next_idx;

                        if (child.loc.start <= ziggy_offset and child.loc.end > ziggy_offset) {
                            ziggy_idx = child_idx;
                            ziggy_node = child;
                        }
                    }

                    return schema_idx;
                },
                else => return 0,
            },
            .identifier => {
                const container_idx = schema_ast.scopes.get(scope_idx).?.types.get(t.loc.slice(schema_src)) orelse return 0;
                const info = containerInfo(schema_ast.nodes, schema_src, container_idx);

                switch (info.kind) {
                    .@"struct" => {
                        log.debug("resolve: struct!\n", .{});
                        switch (ziggy_node.tag) {
                            .braceless_struct, .struct_h, .struct_v => {
                                var field_idx = ziggy_idx + 1;
                                if (field_idx == ziggy_ast.nodes.len or
                                    ziggy_ast.nodes[field_idx].parent_idx != ziggy_idx)
                                {
                                    return schema_idx;
                                }

                                while (field_idx != 0) {
                                    const child = ziggy_ast.nodes[field_idx];
                                    defer field_idx = child.next_idx;

                                    if (child.loc.start <= ziggy_offset and child.loc.end > ziggy_offset) {
                                        const name = blk: {
                                            var name_t: ZiggyTokenizer = .{ .idx = child.loc.start };
                                            const tok = name_t.next(ziggy_src, true);
                                            assert(tok.tag == .identifier);
                                            switch (tok.tag) {
                                                .identifier => break :blk tok.loc.slice(ziggy_src)[1..], // skip the leading dot
                                                .bytes => {
                                                    const raw = tok.loc.slice(ziggy_src);
                                                    break :blk raw[1 .. raw.len - 1]; // skip the quotes
                                                },
                                                else => unreachable,
                                            }
                                        };
                                        log.debug("resolve: field name: {s}\n", .{name});
                                        const schema_field = schema_ast.scopes.get(container_idx).?.fields.get(name) orelse return 0;

                                        // is the offset in the field or in the value?
                                        const value = ziggy_ast.nodes[field_idx + 1];
                                        if (value.loc.start <= ziggy_offset and child.loc.end > ziggy_offset) {
                                            log.debug("resolve: value hit", .{});
                                            ziggy_idx = field_idx + 1;
                                            ziggy_node = value;
                                            scope_idx = container_idx;
                                            schema_idx = schema_field.idx + 1;
                                            tokenizer = .{ .idx = schema_ast.nodes[schema_idx].loc.start };
                                            continue :outer;
                                        }

                                        log.debug("resolve: field hit", .{});
                                        return schema_field.idx;
                                    }
                                }

                                return container_idx;
                            },
                            else => return 0,
                        }
                    },
                    .@"union" => switch (ziggy_node.tag) {
                        .@"union" => {
                            const name = blk: {
                                var name_t: ZiggyTokenizer = .{ .idx = ziggy_node.loc.start };
                                const tok = name_t.next(ziggy_src, true);
                                assert(tok.tag == .union_case);
                                const raw = tok.loc.slice(ziggy_src);
                                break :blk raw[1 .. raw.len - 1]; // skip '.' and '('

                            };
                            const schema_field = schema_ast.scopes.get(container_idx).?.fields.get(name) orelse return 0;

                            // is the offset in the field or in the value?
                            const value = ziggy_ast.nodes[ziggy_idx + 1];
                            if (value.loc.start <= ziggy_offset and ziggy_node.loc.end > ziggy_offset) {
                                ziggy_idx += 1;
                                ziggy_node = value;
                                scope_idx = container_idx;
                                schema_idx = schema_field.idx + 1;
                                tokenizer = .{ .idx = schema_ast.nodes[schema_idx].loc.start };
                                continue :outer;
                            }

                            return schema_field.idx;
                        },
                        else => return 0,
                    },
                }
            },
            .dict_sigil => {
                switch (ziggy_node.tag) {
                    .dict_h, .dict_v => {
                        var field_idx = ziggy_idx + 1;
                        if (field_idx == ziggy_ast.nodes.len or
                            ziggy_ast.nodes[field_idx].parent_idx != ziggy_idx)
                        {
                            return 0;
                        }

                        while (field_idx != 0) {
                            const child = ziggy_ast.nodes[field_idx];
                            defer field_idx = child.next_idx;

                            if (child.loc.start <= ziggy_offset and child.loc.end > ziggy_offset) {
                                // is the offset in the field or in the value?
                                const value = ziggy_ast.nodes[field_idx + 1];
                                if (value.loc.start <= ziggy_offset and child.loc.end > ziggy_offset) {
                                    ziggy_idx = field_idx + 1;
                                    ziggy_node = value;
                                    continue :outer;
                                }

                                return schema_idx;
                            }
                        }
                        return schema_idx;
                    },
                    else => return 0,
                }
            },
            .qmark => switch (ziggy_node.tag) {
                .null => return schema_idx,
                else => continue :outer, // continue to the next type expr token
            },
            .bytes_kw, .bool_kw, .any_kw, .int_kw, .float_kw => return schema_idx,
            else => unreachable,
        }
    }
}

test "basics" {
    const case =
        \\$ = Message
        \\
        \\struct Message {
        \\    id: bytes,
        \\    time: int,
        \\    custom: {:}any,
        \\}
        \\
    ;

    const ast = try Ast.init(std.testing.allocator, case);
    defer ast.deinit(std.testing.allocator);

    errdefer std.debug.print("errors: {any}\n\n nodes: {any}\n\n", .{ ast.errors, ast.nodes });
    try std.testing.expectEqual(0, ast.errors.len);
    try std.testing.expectFmt(case, "{f}", .{ast.fmt(case)});
}
test "duplicate field" {
    const case =
        \\$ = Message
        \\
        \\struct Message {
        \\    custom: {:}any,
        \\    ida: bytes,
        \\    custom: {:}any,
        \\    idb: bytes,
        \\    custom: {:}any,
        \\}
        \\
    ;

    const ast = try Ast.init(std.testing.allocator, case);
    defer ast.deinit(std.testing.allocator);

    errdefer std.debug.print("errors: {any}\n\n nodes: {any}\n\n", .{ ast.errors, ast.nodes });
    try std.testing.expectEqual(2, ast.errors.len);
    try std.testing.expect(ast.errors[0].tag == .duplicate_field_name);
    try std.testing.expect(ast.errors[1].tag == .duplicate_field_name);
    try std.testing.expectFmt(case, "{f}", .{ast.fmt(case)});
}

test "docs" {
    const case =
        \\/// docs above root 1
        \\/// docs above root 2
        \\/// docs above root 3
        \\$ = Message
        \\
        \\/// docs above message 1
        \\/// docs above message 2
        \\/// docs above message 3
        \\struct Message {
        \\    /// docs above first field 1
        \\    /// docs above first field 2
        \\    /// docs above first field 3
        \\    id: bytes,
        \\    time: int,
        \\    /// docs above last field 1
        \\    /// docs above last field 2
        \\    /// docs above last field 3
        \\    custom: {:}any,
        \\}
        \\
    ;

    const ast = try Ast.init(std.testing.allocator, case);
    defer ast.deinit(std.testing.allocator);

    errdefer std.debug.print("errors: {any}\n\n nodes: {any}\n\n", .{ ast.errors, ast.nodes });
    try std.testing.expectEqual(0, ast.errors.len);
    try std.testing.expectFmt(case, "{f}", .{ast.fmt(case)});
}

test "nesting" {
    const case =
        \\$ = Message
        \\
        \\struct Message {
        \\    id: bytes,
        \\    time: int,
        \\    custom: {:}any,
        \\
        \\    struct Foo {}
        \\    struct Bar {}
        \\    struct Baz {}
        \\
        \\    struct Qix {
        \\        qox: int,
        \\        qax: bool,
        \\        qux: any,
        \\    }
        \\}
        \\
    ;

    const ast = try Ast.init(std.testing.allocator, case);
    defer ast.deinit(std.testing.allocator);

    errdefer std.debug.print("errors: {any}\n\n nodes: {any}\n\n", .{ ast.errors, ast.nodes });
    try std.testing.expectEqual(0, ast.errors.len);
    try std.testing.expectFmt(case, "{f}", .{ast.fmt(case)});
}

test "field after decl" {
    const case =
        \\$ = Message
        \\
        \\struct Message {
        \\    id: bytes,
        \\    time: int,
        \\    custom: {:}any,
        \\
        \\    struct Qix {
        \\        qox: int,
        \\        qax: bool,
        \\        qux: any,
        \\    }
        \\
        \\    whops: {:}any,
        \\
        \\    struct Qax {
        \\        qox: int,
        \\        qax: bool,
        \\        qux: any,
        \\    }
        \\}
        \\
    ;

    const ast = try Ast.init(std.testing.allocator, case);
    defer ast.deinit(std.testing.allocator);

    errdefer std.debug.print("errors: {any}\n\n nodes: {any}\n\n", .{ ast.errors, ast.nodes });
    try std.testing.expectEqual(1, ast.errors.len);
    try std.testing.expect(ast.errors[0].tag == .field_after_decl);
}

test "resolve simple struct field" {
    const ziggy_src =
        \\.{
        \\  .foo = "bar",   
        \\}
        \\
    ;

    const schema_src =
        \\$ = FooBar
        \\
        \\struct FooBar {
        \\  foo: bytes,  
        \\}
        \\
    ;

    const gpa = std.testing.allocator;

    const ziggy_ast: ZiggyAst = try .init(gpa, ziggy_src, .{});
    defer ziggy_ast.deinit(gpa);

    const schema_ast: Ast = try .init(gpa, schema_src);
    defer schema_ast.deinit(gpa);

    const schema_idx = schema_ast.resolveZiggyOffset(schema_src, ziggy_ast, ziggy_src, 7);
    try std.testing.expectEqual(4, schema_idx);
}

test "resolve simple struct field - braceless" {
    const ziggy_src =
        \\.foo = "bar",   
        \\
    ;

    const schema_src =
        \\$ = FooBar
        \\
        \\struct FooBar {
        \\  foo: bytes,  
        \\}
        \\
    ;

    const gpa = std.testing.allocator;

    const ziggy_ast: ZiggyAst = try .init(gpa, ziggy_src, .{});
    defer ziggy_ast.deinit(gpa);

    const schema_ast: Ast = try .init(gpa, schema_src);
    defer schema_ast.deinit(gpa);

    const schema_idx = schema_ast.resolveZiggyOffset(schema_src, ziggy_ast, ziggy_src, 2);
    try std.testing.expectEqual(4, schema_idx);
}

test "resolve value in struct" {
    const ziggy_src =
        \\.{
        \\  .foo = "bar",   
        \\}
        \\
    ;

    const schema_src =
        \\$ = FooBar
        \\
        \\struct FooBar {
        \\  foo: bytes,  
        \\}
        \\
    ;

    const gpa = std.testing.allocator;

    const ziggy_ast: ZiggyAst = try .init(gpa, ziggy_src, .{});
    defer ziggy_ast.deinit(gpa);

    const schema_ast: Ast = try .init(gpa, schema_src);
    defer schema_ast.deinit(gpa);

    const schema_idx = schema_ast.resolveZiggyOffset(schema_src, ziggy_ast, ziggy_src, 13);
    try std.testing.expectEqual(5, schema_idx);
}

test "resolve value in nested struct - value" {
    const ziggy_src =
        \\.{
        \\  .foo = .{ .bar = 42 },   
        \\}
        \\
    ;

    const schema_src =
        \\$ = Foo
        \\
        \\struct Foo {
        \\  foo: Bar,
        \\
        \\  struct Bar {
        \\    bar: int,
        \\  }  
        \\}
        \\
    ;

    const gpa = std.testing.allocator;

    const ziggy_ast: ZiggyAst = try .init(gpa, ziggy_src, .{});
    defer ziggy_ast.deinit(gpa);

    const schema_ast: Ast = try .init(gpa, schema_src);
    defer schema_ast.deinit(gpa);

    const schema_idx = schema_ast.resolveZiggyOffset(schema_src, ziggy_ast, ziggy_src, 13);
    try std.testing.expectEqual(6, schema_idx);
}

test "resolve value in nested struct" {
    const ziggy_src =
        \\.{
        \\  .foo = .{ .bar = 42 },   
        \\}
        \\
    ;

    const schema_src =
        \\$ = Foo
        \\
        \\struct Foo {
        \\  foo: Bar,
        \\
        \\  struct Bar {
        \\    bar: int,
        \\  }  
        \\}
        \\
    ;

    const gpa = std.testing.allocator;

    const ziggy_ast: ZiggyAst = try .init(gpa, ziggy_src, .{});
    defer ziggy_ast.deinit(gpa);

    const schema_ast: Ast = try .init(gpa, schema_src);
    defer schema_ast.deinit(gpa);

    const schema_idx = schema_ast.resolveZiggyOffset(schema_src, ziggy_ast, ziggy_src, 16);
    try std.testing.expectEqual(7, schema_idx);
}

test "resolve value in dict" {
    const ziggy_src =
        \\{
        \\  "foo" = "bar",   
        \\}
        \\
    ;

    const schema_src =
        \\$ = {:}bytes
        \\
    ;

    const gpa = std.testing.allocator;

    const ziggy_ast: ZiggyAst = try .init(gpa, ziggy_src, .{});
    defer ziggy_ast.deinit(gpa);

    const schema_ast: Ast = try .init(gpa, schema_src);
    defer schema_ast.deinit(gpa);

    const schema_idx = schema_ast.resolveZiggyOffset(schema_src, ziggy_ast, ziggy_src, 5);
    try std.testing.expectEqual(2, schema_idx);
}

test "resolve value in dict value" {
    const ziggy_src =
        \\{
        \\  "foo" = .{ .bar = 42 },   
        \\}
        \\
    ;

    const schema_src =
        \\$ = {:}Foo
        \\
        \\struct Foo {
        \\  bar: int   
        \\}
    ;

    const gpa = std.testing.allocator;

    const ziggy_ast: ZiggyAst = try .init(gpa, ziggy_src, .{});
    defer ziggy_ast.deinit(gpa);

    const schema_ast: Ast = try .init(gpa, schema_src);
    defer schema_ast.deinit(gpa);

    const schema_idx = schema_ast.resolveZiggyOffset(schema_src, ziggy_ast, ziggy_src, 16);
    try std.testing.expectEqual(4, schema_idx);
}

test "validate structs" {
    const schema_src =
        \\$ = Foo
        \\
        \\struct Foo {
        \\  bar: Bar,
        \\  baz: Baz,
        \\  bax: bool,
        \\
        \\  struct Bar { qux: int }   
        \\  struct Baz { qix: int }   
        \\}
    ;

    const cases: []const [2][:0]const u8 = &.{
        .{
            \\.bar = .{ .qux = 42 },
            \\.baz = .{ .qix = 0 },
            \\.bax = true,
            ,
            "",
        },
        .{
            \\.bar = .{},
            \\.baz = .{ .qix = false },
            \\.bax = true,
            ,
            \\10:11 schema mismatch: missing field 'qux'
            \\29:34 schema mismatch: expected int found bool
            \\
            ,
        },
        .{
            \\.bar = .{ .qux = 42 },
            ,
            \\21:22 schema mismatch: missing field 'baz'
            \\21:22 schema mismatch: missing field 'bax'
            \\
            ,
        },
        .{
            \\.bar = .{},
            \\.baz = .{ .qqx = .{ .bar = 123 } },
            \\.bax = true,
            ,
            \\10:11 schema mismatch: missing field 'qux'
            \\22:44 schema mismatch: unknown field
            \\46:47 schema mismatch: missing field 'qix'
            \\59:60 schema mismatch: missing field 'bax'
            \\
            ,
        },
        .{
            \\.bar = .{},
            \\.bar = .{},
            ,
            \\10:11 schema mismatch: missing field 'qux'
            \\12:16 duplicate field
            \\22:23 schema mismatch: missing field 'baz'
            \\22:23 schema mismatch: missing field 'bax'
            \\
            ,
        },
    };

    const gpa = std.testing.allocator;

    const schema_ast: Ast = try .init(gpa, schema_src);
    defer schema_ast.deinit(gpa);

    for (cases) |case| {
        errdefer std.debug.print("{s}\n", .{case[0]});
        const ziggy_ast: ZiggyAst = try .init(gpa, case[0], .{});
        defer ziggy_ast.deinit(gpa);

        try std.testing.expectEqual(0, ziggy_ast.errors.len);

        const errors = try schema_ast.validate(gpa, schema_src, ziggy_ast, case[0]);
        defer gpa.free(errors);

        var aw: std.Io.Writer.Allocating = .init(gpa);
        defer aw.deinit();

        for (errors) |err| {
            try aw.writer.print("{}:{} {f}\n", .{
                err.main_location.start,
                err.main_location.end,
                err.tag,
            });
        }
        try std.testing.expectEqualStrings(case[1], aw.written());
    }
}

test "validate slices" {
    const schema_src =
        \\$ = Foo
        \\
        \\struct Foo {
        \\  bar: bool,
        \\  baz: []bool,
        \\  bax: [][]bool,
        \\  bor: [][]Bar,
        \\  boz: []Bar,
        \\
        \\  struct Bar { qux: []int }   
        \\}
    ;

    const cases: []const [2][:0]const u8 = &.{
        .{
            \\.bar = false,
            \\.baz = [true, false, false],
            \\.bax = [[true], [false, true], []],
            \\.bor = [[.{.qux = [10, 20]}], [.{.qux = []}], []],
            \\.boz = [.{.qux = [10]}, .{.qux = [10, 20, 30]}, .{.qux = []}],
            ,
            "",
        },
    };

    const gpa = std.testing.allocator;

    const schema_ast: Ast = try .init(gpa, schema_src);
    defer schema_ast.deinit(gpa);

    for (cases) |case| {
        errdefer std.debug.print("{s}\n", .{case[0]});
        const ziggy_ast: ZiggyAst = try .init(gpa, case[0], .{});
        defer ziggy_ast.deinit(gpa);

        try std.testing.expectEqual(0, ziggy_ast.errors.len);

        const errors = try schema_ast.validate(gpa, schema_src, ziggy_ast, case[0]);
        defer gpa.free(errors);

        var aw: std.Io.Writer.Allocating = .init(gpa);
        defer aw.deinit();

        for (errors) |err| {
            try aw.writer.print("{}:{} {f}\n", .{
                err.main_location.start,
                err.main_location.end,
                err.tag,
            });
        }
        try std.testing.expectEqualStrings(case[1], aw.written());
    }
}

test "validate dicts" {
    const schema_src =
        \\$ = Foo
        \\
        \\struct Foo {
        \\  bar: bool,
        \\  baz: {:}bool,
        \\  bax: {:}{:}bool,
        \\  bor: {:}{:}Bar,
        \\  boz: {:}Bar,
        \\
        \\  struct Bar { qux: {:}int }   
        \\}
    ;

    const cases: []const [2][:0]const u8 = &.{
        .{
            \\.bar = false,
            \\.baz = {"foo": true, "bar": false, "baz": false},
            \\.bax = {"a": {"x": true}, "b": {"x": false, "y": true}, "c": {}},
            \\.bor = {"a": {"x": .{.qux = {"q": 10, "p": 20}}}, "b": {"x": .{.qux = {}}}, "c": {}},
            \\.boz = {"a": .{.qux = {"x": 10}}, "b": .{.qux = {"x": 10, "y": 20, "z": 30}}, "c": .{.qux = {}}},
            ,
            "",
        },
    };

    const gpa = std.testing.allocator;

    const schema_ast: Ast = try .init(gpa, schema_src);
    defer schema_ast.deinit(gpa);

    for (cases) |case| {
        errdefer std.debug.print("{s}\n", .{case[0]});
        const ziggy_ast: ZiggyAst = try .init(gpa, case[0], .{});
        defer ziggy_ast.deinit(gpa);

        try std.testing.expectEqual(0, ziggy_ast.errors.len);

        const errors = try schema_ast.validate(gpa, schema_src, ziggy_ast, case[0]);
        defer gpa.free(errors);

        var aw: std.Io.Writer.Allocating = .init(gpa);
        defer aw.deinit();

        for (errors) |err| {
            try aw.writer.print("{}:{} {f}\n", .{
                err.main_location.start,
                err.main_location.end,
                err.tag,
            });
        }
        try std.testing.expectEqualStrings(case[1], aw.written());
    }
}

test "validate unions" {
    const schema_src =
        \\$ = Foo
        \\
        \\struct Foo {
        \\  bar: bool,
        \\  baz: {:}bool,
        \\  bax: {:}{:}bool,
        \\  bor: {:}{:}Bar,
        \\  boz: {:}Bar,
        \\
        \\  union Bar { qux: {:}int }   
        \\}
    ;

    const cases: []const [2][:0]const u8 = &.{
        .{
            \\.bar = false,
            \\.baz = {"foo": true, "bar": false, "baz": false},
            \\.bax = {"a": {"x": true}, "b": {"x": false, "y": true}, "c": {}},
            \\.bor = {"a": {"x": .qux({"q": 10, "p": 20})}, "b": {"x": .qux({})}, "c": {}},
            \\.boz = {"a": .qux({"x": 10}), "b": .qux({"x": 10, "y": 20, "z": 30}), "c": .qux({})},
            ,
            "",
        },
        .{
            \\.bar = false,
            \\.baz = {},
            \\.bax = 30,
            \\.bor = "wrong",
            \\.boz = {"a": .qux({"x": false}), "b": .qux({"x": 10, "y": "wrong", "z": 30}), "c": .qux({})},
            ,
            \\32:34 schema mismatch: expected {:} found int
            \\43:50 schema mismatch: expected {:} found bytes
            \\76:81 schema mismatch: expected int found bool
            \\110:117 schema mismatch: expected int found bytes
            \\
            ,
        },
        .{
            \\.bar = false,
            \\.baz = {},
            \\.bax = {},
            \\.bor = {"a": {"x": .qux(false)}, "b": {"x": .qux}, "c": {"x": "banana"}},
            \\.boz = {},
            ,
            \\60:65 schema mismatch: expected {:} found bool
            \\80:84 schema mismatch: missing union value of type {:}int
            \\98:106 schema mismatch: expected Bar found bytes
            \\
            ,
        },
    };

    const gpa = std.testing.allocator;

    const schema_ast: Ast = try .init(gpa, schema_src);
    defer schema_ast.deinit(gpa);

    for (cases) |case| {
        errdefer std.debug.print("{s}\n", .{case[0]});
        const ziggy_ast: ZiggyAst = try .init(gpa, case[0], .{});
        defer ziggy_ast.deinit(gpa);

        try std.testing.expectEqual(0, ziggy_ast.errors.len);

        const errors = try schema_ast.validate(gpa, schema_src, ziggy_ast, case[0]);
        defer gpa.free(errors);

        var aw: std.Io.Writer.Allocating = .init(gpa);
        defer aw.deinit();

        for (errors) |err| {
            try aw.writer.print("{}:{} {f}\n", .{
                err.main_location.start,
                err.main_location.end,
                err.tag,
            });
        }
        try std.testing.expectEqualStrings(case[1], aw.written());
    }
}

test "validate default schema" {
    const schema_src = default_src;
    const cases: []const [2][:0]const u8 = &.{
        .{
            \\100
            ,
            "",
        },
        .{
            \\3.14
            ,
            "",
        },
        .{
            \\null
            ,
            "",
        },
        .{
            \\false
            ,
            "",
        },
        .{
            \\true
            ,
            "",
        },
        .{
            \\"banana"
            ,
            "",
        },
        .{
            \\.banana
            ,
            "",
        },
        .{
            \\[ 1, false, true, null, .qux, .bar({"a": 10, "b": [.{.true = true}]}),]
            ,
            "",
        },
        .{
            \\.bar = [false, null, 10, "banana", .{.foo = "bar"}, {"any": "field"}],
            \\.baz = {"foo": true, "bar": false, "baz": false},
            \\.bax = {"a": {"x": true}, "b": {"x": false, "y": true}, "c": {}},
            \\.bor = {"a": {"x": .qux({"q": 10, "p": 20})}, "b": {"x": .qux({})}, "c": {}},
            \\.boz = {"a": .qux({"x": 10}), "b": .qux({"x": 10, "y": 20, "z": 30}), "c": .qux({})},
            ,
            "",
        },
        .{
            \\{ "foo": 42, "foo": 42,}
            ,
            \\13:18 duplicate field
            \\
            ,
        },
        .{
            \\.bar = [],
            \\.bar = {},
            ,
            \\11:15 duplicate field
            \\
            ,
        },
        .{
            \\.bar = {"foo": 42, "foo": 42},
            ,
            \\19:24 duplicate field
            \\
            ,
        },
    };

    const gpa = std.testing.allocator;

    const schema_ast: Ast = try .init(gpa, schema_src);
    defer schema_ast.deinit(gpa);

    for (cases) |case| {
        errdefer std.debug.print("{s}\n", .{case[0]});
        const ziggy_ast: ZiggyAst = try .init(gpa, case[0], .{});
        defer ziggy_ast.deinit(gpa);

        try std.testing.expectEqual(0, ziggy_ast.errors.len);

        const errors = try schema_ast.validate(gpa, schema_src, ziggy_ast, case[0]);
        defer gpa.free(errors);

        var aw: std.Io.Writer.Allocating = .init(gpa);
        defer aw.deinit();

        for (errors) |err| {
            try aw.writer.print("{}:{} {f}\n", .{
                err.main_location.start,
                err.main_location.end,
                err.tag,
            });
        }
        try std.testing.expectEqualStrings(case[1], aw.written());
    }
}

test "validate nested any" {
    const schema_src =
        \\$ = Foo
        \\
        \\struct Foo {
        \\  bar: any,
        \\  baz: {:}any,
        \\  bax: {:}{:}any,
        \\  bor: {:}{:}Bar,
        \\  boz: {:}Bar,
        \\
        \\  union Bar { qux: {:}any }   
        \\}
    ;

    const cases: []const [2][:0]const u8 = &.{
        .{
            \\.bar = [false, null, 10, "banana", .{.foo = "bar"}, {"any": "field"}],
            \\.baz = {"foo": true, "bar": false, "baz": false},
            \\.bax = {"a": {"x": true}, "b": {"x": false, "y": true}, "c": {}},
            \\.bor = {"a": {"x": .qux({"q": 10, "p": 20})}, "b": {"x": .qux({})}, "c": {}},
            \\.boz = {"a": .qux({"x": 10}), "b": .qux({"x": 10, "y": 20, "z": 30}), "c": .qux({})},
            ,
            "",
        },
        .{
            \\.bar = {"foo": true, "foo": 10, "foo": "banana"},
            \\.baz = {"foo": true, "foo": 10, "foo": "banana"},
            \\.bax = {"a": {"x": true}, "b": {"x": false, "y": true}, "c": {}},
            \\.bor = {"a": {"x": .qux({"aa": 10, "aa": 20})}, "b": {"x": .qux("banana"), "y": 1, "y": 2}, "c": {}},
            \\.boz = {"a": .qux({"x": 10}), "b": .qux({"x": 10, "y": 20, "z": 30}), "c": .qux({})},
            ,
            \\21:26 duplicate field
            \\32:37 duplicate field
            \\71:76 duplicate field
            \\82:87 duplicate field
            \\201:205 duplicate field
            \\230:238 schema mismatch: expected {:} found bytes
            \\246:247 schema mismatch: expected Bar found int
            \\249:252 duplicate field
            \\254:255 schema mismatch: expected Bar found int
            \\
            ,
        },
    };

    const gpa = std.testing.allocator;

    const schema_ast: Ast = try .init(gpa, schema_src);
    defer schema_ast.deinit(gpa);

    for (cases) |case| {
        errdefer std.debug.print("{s}\n", .{case[0]});
        const ziggy_ast: ZiggyAst = try .init(gpa, case[0], .{});
        defer ziggy_ast.deinit(gpa);

        try std.testing.expectEqual(0, ziggy_ast.errors.len);

        const errors = try schema_ast.validate(gpa, schema_src, ziggy_ast, case[0]);
        defer gpa.free(errors);

        var aw: std.Io.Writer.Allocating = .init(gpa);
        defer aw.deinit();

        for (errors) |err| {
            try aw.writer.print("{}:{} {f}\n", .{
                err.main_location.start,
                err.main_location.end,
                err.tag,
            });
        }
        try std.testing.expectEqualStrings(case[1], aw.written());
    }
}

test "this crashed at some point" {
    const schema_src =
        \\$ = Foo
        \\
        \\struct Foo {
        \\    baz: {:}Bar,
        \\        
        \\    union Bar {
        \\        /// Bar.qux description
        \\        qux: bytes,
        \\        /// Bar.quix description
        \\        qix: int,
        \\        qax,
        \\    }
        \\}
    ;

    const cases: []const [2][:0]const u8 = &.{
        .{
            \\.{
            \\    .baz = .{},
            \\}
            ,
            \\14:18 schema mismatch: expected {:} found struct
            \\
            ,
        },
    };

    const gpa = std.testing.allocator;

    const schema_ast: Ast = try .init(gpa, schema_src);
    defer schema_ast.deinit(gpa);

    for (cases) |case| {
        errdefer std.debug.print("{s}\n", .{case[0]});
        const ziggy_ast: ZiggyAst = try .init(gpa, case[0], .{});
        defer ziggy_ast.deinit(gpa);

        try std.testing.expectEqual(0, ziggy_ast.errors.len);

        const errors = try schema_ast.validate(gpa, schema_src, ziggy_ast, case[0]);
        defer gpa.free(errors);

        var aw: std.Io.Writer.Allocating = .init(gpa);
        defer aw.deinit();

        for (errors) |err| {
            try aw.writer.print("{}:{} {f}\n", .{
                err.main_location.start,
                err.main_location.end,
                err.tag,
            });
        }
        try std.testing.expectEqualStrings(case[1], aw.written());
    }
}
