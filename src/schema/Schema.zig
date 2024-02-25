const Schema = @This();

const std = @import("std");
const assert = std.debug.assert;
const ziggy = @import("../root.zig");
const Tokenizer = @import("Tokenizer.zig");
const Diagnostic = @import("Diagnostic.zig");
const Ast = @import("Ast.zig");
const Node = Ast.Node;

const log = std.log.scoped(.schema);

root: Rule,
literals: std.StringHashMapUnmanaged(struct { comment: u32, name: u32 }) = .{},
structs: std.StringArrayHashMapUnmanaged(StructRule) = .{},

pub const StructRule = struct {
    comment: u32,
    name: u32,
    fields: std.StringArrayHashMapUnmanaged(Field) = .{},

    pub const Field = struct {
        comment: u32,
        name: u32,
        rule: Rule,
    };
};

pub const Rule = struct {
    // index into nodes
    node: u32,
};

/// Nodes are usually `ast.nodes.toOwnedSlice()` and `diagnostic` can also be reused
/// from AST parsing.
pub fn init(
    gpa: std.mem.Allocator,
    nodes: []const Node,
    code: [:0]const u8,
    diagnostic: ?*Diagnostic,
) !Schema {
    var names = std.ArrayList(u32).init(gpa);
    defer names.deinit();

    const root_expr = nodes[1];
    assert(root_expr.last_child_id != 0);

    var schema: Schema = .{
        .root = .{ .node = root_expr.last_child_id },
    };
    errdefer schema.deinit(gpa);

    var idx = root_expr.next_id;
    while (idx != 0) {
        const literal = nodes[idx];
        if (literal.tag == .@"struct") {
            break;
        }

        var comment_id = literal.first_child_id;
        if (nodes[comment_id].tag != .doc_comment) {
            comment_id = 0;
        }
        const name_id = literal.last_child_id;
        assert(nodes[name_id].tag == .identifier);
        log.debug("literal '{s}'", .{nodes[name_id].loc.src(code)});

        const gop = try schema.literals.getOrPut(gpa, nodes[name_id].loc.src(code));
        if (gop.found_existing) {
            if (diagnostic) |d| {
                d.tok = .{
                    .tag = .identifier,
                    .loc = nodes[name_id].loc,
                };
                d.err = .{
                    .duplicate_field = .{
                        .first_loc = nodes[gop.value_ptr.name].loc,
                    },
                };
            }
            return error.DuplicateField;
        }
        gop.value_ptr.* = .{ .comment = comment_id, .name = name_id };
        idx = literal.next_id;
    }

    while (idx != 0) {
        const struct_def = nodes[idx];
        assert(struct_def.tag == .@"struct");

        var child_idx = struct_def.first_child_id;
        assert(child_idx != 0);

        var struct_comment_id: u32 = 0;
        if (nodes[child_idx].tag == .doc_comment) {
            struct_comment_id = child_idx;
            child_idx = nodes[child_idx].next_id;
        }

        const struct_name_id = child_idx;
        const struct_name = nodes[child_idx];
        child_idx = struct_name.next_id;

        log.debug("struct '{s}'", .{struct_name.loc.src(code)});

        var fields: std.StringArrayHashMapUnmanaged(StructRule.Field) = .{};
        while (child_idx != 0) {
            const f = nodes[child_idx];
            assert(f.tag == .struct_field);
            var field_child_id = f.first_child_id;
            var comment_id: u32 = 0;
            if (nodes[field_child_id].tag == .doc_comment) {
                comment_id = field_child_id;
                field_child_id = nodes[field_child_id].next_id;
            }

            const name_id = field_child_id;
            assert(nodes[name_id].tag == .identifier);
            const rule_id = nodes[name_id].next_id;
            assert(rule_id != 0);

            const gop = try fields.getOrPut(gpa, nodes[name_id].loc.src(code));
            if (gop.found_existing) {
                if (diagnostic) |d| {
                    d.tok = .{
                        .tag = .identifier,
                        .loc = nodes[name_id].loc,
                    };
                    d.err = .{
                        .duplicate_field = .{
                            .first_loc = nodes[gop.value_ptr.name].loc,
                        },
                    };
                }
                return error.DuplicateField;
            }
            gop.value_ptr.* = .{
                .comment = comment_id,
                .name = name_id,
                .rule = .{ .node = rule_id },
            };
            child_idx = f.next_id;
        }

        const gop = try schema.structs.getOrPut(gpa, struct_name.loc.src(code));
        if (gop.found_existing) {
            if (diagnostic) |d| {
                d.tok = .{
                    .tag = .identifier,
                    .loc = struct_name.loc,
                };
                d.err = .{
                    .duplicate_field = .{
                        .first_loc = nodes[gop.value_ptr.name].loc,
                    },
                };
            }
            return error.DuplicateField;
        }
        gop.value_ptr.* = .{
            .comment = struct_comment_id,
            .name = struct_name_id,
            .fields = fields,
        };

        idx = struct_def.next_id;
    }

    // Analysis
    log.debug("beginning analysis", .{});
    try schema.analyzeRule(gpa, schema.root, nodes, code, diagnostic);
    log.debug("root_rule analized", .{});
    for (schema.structs.keys(), schema.structs.values()) |s_name, s| {
        for (s.fields.keys(), s.fields.values()) |f_name, f| {
            log.debug("analyzeRule '{s}.{s}'", .{ s_name, f_name });
            try schema.analyzeRule(gpa, f.rule, nodes, code, diagnostic);
        }
    }

    return schema;
}

pub fn deinit(self: *Schema, gpa: std.mem.Allocator) void {
    self.literals.deinit(gpa);
    for (self.structs.values()) |*v| v.fields.deinit(gpa);
    self.structs.deinit(gpa);
}

fn analyzeRule(
    schema: Schema,
    gpa: std.mem.Allocator,
    rule: Rule,
    nodes: []const Node,
    code: [:0]const u8,
    diagnostic: ?*Diagnostic,
) !void {
    var node = nodes[rule.node];
    while (true) {
        const sel = node.loc.getSelection(code);
        log.debug("analyzing rule '{s}', line: {}, col: {}", .{
            node.loc.src(code),
            sel.start.line,
            sel.start.col,
        });
        switch (node.tag) {
            .bytes, .int, .float, .bool, .any => break,
            .map, .array => node = nodes[node.first_child_id],
            .tag => {
                const src = node.loc.src(code);
                if (!schema.literals.contains(src[1..])) {
                    if (diagnostic) |d| {
                        d.tok = .{
                            .tag = .identifier,
                            .loc = node.loc,
                        };
                        d.err = .unknown_field;
                    }
                    return error.UnknownField;
                }
                break;
            },
            .identifier => {
                const src = node.loc.src(code);
                if (!schema.structs.contains(src)) {
                    if (diagnostic) |d| {
                        d.tok = .{
                            .tag = .identifier,
                            .loc = node.loc,
                        };
                        d.err = .unknown_field;
                    }
                    return error.UnknownField;
                }
                break;
            },
            .struct_union => {
                var idx = node.first_child_id;
                assert(idx != 0);
                var seen_names = std.StringHashMap(u32).init(gpa);
                defer seen_names.deinit();

                while (idx != 0) {
                    const ident = nodes[idx];
                    const src = ident.loc.src(code);
                    const gop = try seen_names.getOrPut(src);
                    if (gop.found_existing) {
                        if (diagnostic) |d| {
                            d.tok = .{
                                .tag = .identifier,
                                .loc = ident.loc,
                            };
                            d.err = .{
                                .duplicate_field = .{
                                    .first_loc = nodes[gop.value_ptr.*].loc,
                                },
                            };
                        }
                        return error.DuplicateField;
                    }
                    gop.value_ptr.* = idx;

                    if (!schema.structs.contains(src)) {
                        if (diagnostic) |d| {
                            d.tok = .{
                                .tag = .identifier,
                                .loc = ident.loc,
                            };
                            d.err = .unknown_field;
                        }
                        return error.UnknownField;
                    }
                    idx = ident.next_id;
                }
                break;
            },

            else => unreachable,
        }
    }
}

const CheckItem = struct {
    rule: Rule,
    doc_node: u32,
};

pub fn check(
    self: Schema,
    gpa: std.mem.Allocator,
    ast: Ast,
    doc: ziggy.Ast,
    diag: ?*ziggy.Diagnostic,
) !void {
    // TODO: check ziggy file against this ruleset
    var stack = std.ArrayList(CheckItem).init(gpa);
    defer stack.deinit();

    var doc_root_val: u32 = 1;
    if (doc.nodes.items[1].tag == .top_comment) {
        doc_root_val = doc.nodes.items[1].next_id;
    }

    try stack.append(.{
        .rule = self.root,
        .doc_node = doc_root_val,
    });

    while (stack.popOrNull()) |elem| {
        const rule = ast.nodes.items[elem.rule.node];
        const doc_node = doc.nodes.items[elem.doc_node];
        {
            log.debug("rule '{s}', node '{s}'", .{
                rule.loc.src(ast.code),
                @tagName(doc_node.tag),
            });
            const sel = doc_node.loc.getSelection(doc.code);
            log.debug("line: {}, col: {}", .{
                sel.start.line,
                sel.start.col,
            });
        }
        switch (rule.tag) {
            .array => switch (doc_node.tag) {
                .array, .array_comma => {
                    //TODO: optimize for simple cases
                    const child_rule: Rule = .{ .node = rule.first_child_id };
                    assert(child_rule.node != 0);

                    var doc_child_id = doc_node.first_child_id;
                    while (doc_child_id != 0) {
                        assert(doc.nodes.items[doc_child_id].tag != .comment);
                        try stack.append(.{
                            .rule = child_rule,
                            .doc_node = doc_child_id,
                        });

                        doc_child_id = doc.nodes.items[doc_child_id].next_id;
                    }
                },
                else => return typeMismatch(ast, diag, rule, doc_node),
            },
            .map => switch (doc_node.tag) {
                .struct_or_map => {},
                .map => {
                    //TODO: optimize for simple cases
                    const child_rule: Rule = .{ .node = rule.first_child_id };
                    assert(child_rule.node != 0);

                    var doc_child_id = doc_node.first_child_id;
                    while (doc_child_id != 0) {
                        assert(doc.nodes.items[doc_child_id].tag == .map_field);
                        try stack.append(.{
                            .rule = child_rule,
                            .doc_node = doc.nodes.items[doc_child_id].last_child_id,
                        });

                        doc_child_id = doc.nodes.items[doc_child_id].next_id;
                    }
                },

                else => return typeMismatch(ast, diag, rule, doc_node),
            },
            .struct_union => switch (doc_node.tag) {
                .@"struct" => {
                    const rule_src = rule.loc.src(ast.code);

                    const struct_name_node = doc.nodes.items[doc_node.first_child_id];
                    if (struct_name_node.tag != .identifier) {
                        if (diag) |d| {
                            d.tok = .{
                                .tag = .identifier,
                                .loc = .{
                                    // a struct always has curlies
                                    .start = doc_node.loc.start -| 1,
                                    .end = doc_node.loc.start + 1,
                                },
                            };
                            d.err = .{
                                .missing_struct_name = .{
                                    .expected = rule_src,
                                },
                            };
                        }
                        return error.MissingStructName;
                    }

                    const struct_name = struct_name_node.loc.src(doc.code);

                    var ident_id = rule.first_child_id;
                    assert(ident_id != 0);
                    while (ident_id != 0) {
                        const id_rule = ast.nodes.items[ident_id];
                        const id_rule_src = id_rule.loc.src(ast.code);
                        if (std.mem.eql(u8, struct_name, id_rule_src)) {
                            try stack.append(.{
                                .rule = .{ .node = ident_id },
                                .doc_node = elem.doc_node,
                            });
                            continue;
                        }
                        ident_id = id_rule.next_id;
                    }
                    // no match
                    if (diag) |d| {
                        d.tok = .{
                            .tag = .identifier,
                            .loc = struct_name_node.loc,
                        };
                        d.err = .{
                            .wrong_struct_name = .{
                                .expected = rule_src,
                            },
                        };
                    }
                    return error.WrongStructName;
                },
                else => return typeMismatch(ast, diag, rule, doc_node),
            },
            .identifier => switch (doc_node.tag) {
                .@"struct", .braceless_struct => {
                    //TODO: optimize for simple cases
                    const name = rule.loc.src(ast.code);
                    const struct_rule = self.structs.get(name).?;

                    var seen_fields = std.StringHashMap(void).init(gpa);
                    defer seen_fields.deinit();

                    var doc_child_id = doc_node.first_child_id;
                    if (doc.nodes.items[doc_child_id].tag == .identifier) {
                        doc_child_id = doc.nodes.items[doc_child_id].next_id;
                    }

                    while (doc_child_id != 0) {
                        const field = doc.nodes.items[doc_child_id];
                        assert(field.tag == .struct_field);

                        const field_name_node = doc.nodes.items[field.first_child_id];
                        assert(field_name_node.tag == .identifier);

                        const field_name = field_name_node.loc.src(doc.code);

                        const field_rule = struct_rule.fields.get(field_name) orelse {
                            if (diag) |d| {
                                d.tok = .{
                                    .tag = .identifier,
                                    .loc = field_name_node.loc,
                                };
                                d.err = .unknown_field;
                            }
                            return error.UnknownField;
                        };

                        // duplicate fields should be detected in the doc
                        // via AST contruction.
                        try seen_fields.putNoClobber(field_name, {});

                        try stack.append(.{
                            .rule = field_rule.rule,
                            .doc_node = field.last_child_id,
                        });

                        doc_child_id = field.next_id;
                    }

                    if (seen_fields.count() != struct_rule.fields.count()) {
                        for (struct_rule.fields.keys()) |k| {
                            if (!seen_fields.contains(k)) {
                                if (diag) |d| {
                                    // tok must point at where the struct ends
                                    d.tok = .{
                                        .tag = .value, // doesn't matter
                                        .loc = .{
                                            .start = doc_node.loc.end - 1,
                                            .end = doc_node.loc.end,
                                        },
                                    };
                                    d.err = .{
                                        .missing_field = .{
                                            .name = k,
                                        },
                                    };
                                }
                                return error.UnknownField;
                            }
                        }
                    }
                },
                else => return typeMismatch(ast, diag, rule, doc_node),
            },
            .tag => switch (doc_node.tag) {
                .tag => {},
                else => return typeMismatch(ast, diag, rule, doc_node),
            },
            .bytes => switch (doc_node.tag) {
                .string, .line_string => {},
                else => return typeMismatch(ast, diag, rule, doc_node),
            },
            .int => switch (doc_node.tag) {
                .integer => {},
                else => return typeMismatch(ast, diag, rule, doc_node),
            },
            .float => switch (doc_node.tag) {
                .float => {},
                else => return typeMismatch(ast, diag, rule, doc_node),
            },
            .bool => switch (doc_node.tag) {
                .bool => {},
                else => return typeMismatch(ast, diag, rule, doc_node),
            },
            .any => {},
            else => unreachable,
        }
    }
}

fn typeMismatch(
    ast: Ast,
    diag: ?*ziggy.Diagnostic,
    rule_node: Ast.Node,
    found: ziggy.Ast.Node,
) error{TypeMismatch} {
    assert(found.tag != .comment);
    assert(found.tag != .top_comment);

    if (diag) |d| {
        d.tok = .{
            .tag = .value,
            .loc = found.loc,
        };
        d.err = .{
            .type_mismatch = .{
                .expected = rule_node.loc.src(ast.code),
            },
        };
    }
    return error.TypeMismatch;
}

test "basics" {
    const case =
        \\root = Frontmatter
        \\
        \\/// Doc comment 1a
        \\/// Doc comment 1b
        \\@date,
        \\
        \\/// Doc comment 2a
        \\/// Doc comment 2b
        \\struct Frontmatter {
        \\    /// Doc comment 3a
        \\    /// Doc comment 3b
        \\    title: bytes,
        \\    date: @date,
        \\    custom: map[any],
        \\}
        \\
    ;

    var diag: Diagnostic = .{ .path = null };
    errdefer std.debug.print("diag: {}", .{diag});
    const ast = try Ast.init(std.testing.allocator, case, &diag);
    defer ast.deinit();

    try std.testing.expect(diag.err == .none);

    var schema = try Schema.init(std.testing.allocator, ast.nodes.items, case, &diag);
    schema.deinit(std.testing.allocator);
}
