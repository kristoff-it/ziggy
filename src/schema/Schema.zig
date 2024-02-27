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
code: [:0]const u8,
nodes: []const Ast.Node,
literals: std.StringHashMapUnmanaged(LiteralRule) = .{},
structs: std.StringArrayHashMapUnmanaged(StructRule) = .{},

pub const LiteralRule = struct {
    comment: u32,
    name: u32,
    expr: u32,
};

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
        .code = code,
        .nodes = nodes,
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
        var name_id = literal.first_child_id;
        if (nodes[comment_id].tag == .doc_comment) {
            name_id = nodes[comment_id].next_id;
        } else {
            comment_id = 0;
        }

        const expr_id = literal.last_child_id;
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
        gop.value_ptr.* = .{
            .comment = comment_id,
            .name = name_id,
            .expr = expr_id,
        };
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
    try schema.analyzeRule(gpa, schema.root, diagnostic);
    log.debug("root_rule analized", .{});
    for (schema.structs.keys(), schema.structs.values()) |s_name, s| {
        for (s.fields.keys(), s.fields.values()) |f_name, f| {
            log.debug("analyzeRule '{s}.{s}'", .{ s_name, f_name });
            try schema.analyzeRule(gpa, f.rule, diagnostic);
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
    diagnostic: ?*Diagnostic,
) !void {
    var node = schema.nodes[rule.node];
    while (true) {
        const sel = node.loc.getSelection(schema.code);
        log.debug("analyzing rule '{s}', line: {}, col: {}", .{
            node.loc.src(schema.code),
            sel.start.line,
            sel.start.col,
        });
        switch (node.tag) {
            .bytes, .int, .float, .bool, .any => break,
            .map, .array, .optional => node = schema.nodes[node.first_child_id],
            .tag => {
                const src = node.loc.src(schema.code);
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
                const src = node.loc.src(schema.code);
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
                    const ident = schema.nodes[idx];
                    const src = ident.loc.src(schema.code);
                    const gop = try seen_names.getOrPut(src);
                    if (gop.found_existing) {
                        if (diagnostic) |d| {
                            d.tok = .{
                                .tag = .identifier,
                                .loc = ident.loc,
                            };
                            d.err = .{
                                .duplicate_field = .{
                                    .first_loc = schema.nodes[gop.value_ptr.*].loc,
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
    optional: bool = false,
    rule: Rule,
    doc_node: u32,
};

fn addError(gpa: std.mem.Allocator, diag: ?*ziggy.Diagnostic, err: ziggy.Diagnostic.Error) !void {
    if (diag) |d| {
        try d.errors.append(gpa, err);
    } else {
        return err.zigError();
    }
}

pub fn check(
    self: Schema,
    gpa: std.mem.Allocator,
    doc: ziggy.Ast,
    diag: ?*ziggy.Diagnostic,
) !void {
    // TODO: check ziggy file against this ruleset
    var stack = std.ArrayList(CheckItem).init(gpa);
    defer stack.deinit();

    var doc_root_val: u32 = 1;
    if (doc.nodes[1].tag == .top_comment) {
        doc_root_val = doc.nodes[1].next_id;
    }

    try stack.append(.{
        .rule = self.root,
        .doc_node = doc_root_val,
    });

    while (stack.popOrNull()) |elem| {
        const rule = self.nodes[elem.rule.node];
        const doc_node = doc.nodes[elem.doc_node];
        {
            log.debug("rule '{s}', node '{s}'", .{
                rule.loc.src(self.code),
                @tagName(doc_node.tag),
            });
            const sel = doc_node.loc.getSelection(doc.code);
            log.debug("line: {}, col: {}", .{
                sel.start.line,
                sel.start.col,
            });
        }

        if (doc_node.tag == .value and doc_node.missing) {
            const rule_src = rule.loc.src(self.code);
            try addError(gpa, diag, .{
                .missing = .{
                    .token = .{
                        .tag = .identifier,
                        .loc = doc_node.loc,
                    },
                    .expected = rule_src,
                },
            });
            continue;
        }

        switch (rule.tag) {
            .optional => switch (doc_node.tag) {
                .null => {},
                else => {
                    const child_rule: Rule = .{ .node = rule.first_child_id };
                    assert(child_rule.node != 0);

                    try stack.append(.{
                        .optional = true,
                        .rule = child_rule,
                        .doc_node = elem.doc_node,
                    });
                },
            },
            .array => switch (doc_node.tag) {
                .array => {
                    //TODO: optimize for simple cases
                    const child_rule: Rule = .{ .node = rule.first_child_id };
                    assert(child_rule.node != 0);

                    var doc_child_id = doc_node.first_child_id;
                    while (doc_child_id != 0) {
                        assert(doc.nodes[doc_child_id].tag != .comment);
                        try stack.append(.{
                            .rule = child_rule,
                            .doc_node = doc_child_id,
                        });

                        doc_child_id = doc.nodes[doc_child_id].next_id;
                    }
                },
                else => try self.typeMismatch(gpa, diag, doc, elem),
            },
            .map => switch (doc_node.tag) {
                .struct_or_map => {},
                .map => {
                    //TODO: optimize for simple cases
                    const child_rule: Rule = .{ .node = rule.first_child_id };
                    assert(child_rule.node != 0);

                    var doc_child_id = doc_node.first_child_id;
                    while (doc_child_id != 0) {
                        assert(doc.nodes[doc_child_id].tag == .map_field);
                        try stack.append(.{
                            .rule = child_rule,
                            .doc_node = doc.nodes[doc_child_id].last_child_id,
                        });

                        doc_child_id = doc.nodes[doc_child_id].next_id;
                    }
                },

                else => try self.typeMismatch(gpa, diag, doc, elem),
            },
            .struct_union => switch (doc_node.tag) {
                .@"struct" => {
                    const rule_src = rule.loc.src(self.code);

                    const struct_name_node = doc.nodes[doc_node.first_child_id];
                    if (struct_name_node.tag != .identifier) {
                        try addError(gpa, diag, .{
                            .missing = .{
                                .token = .{
                                    .tag = .identifier,
                                    .loc = .{
                                        // a struct always has curlies
                                        .start = doc_node.loc.start -| 1,
                                        .end = doc_node.loc.start + 1,
                                    },
                                },
                                .expected = rule_src,
                            },
                        });
                    }

                    const struct_name = struct_name_node.loc.src(doc.code);

                    var ident_id = rule.first_child_id;
                    assert(ident_id != 0);
                    while (ident_id != 0) {
                        const id_rule = self.nodes[ident_id];
                        const id_rule_src = id_rule.loc.src(self.code);
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
                    try addError(gpa, diag, .{
                        .unknown = .{
                            .token = .{
                                .tag = .identifier,
                                .loc = struct_name_node.loc,
                            },
                            .expected = rule_src,
                        },
                    });
                },
                else => try self.typeMismatch(gpa, diag, doc, elem),
            },
            .identifier => switch (doc_node.tag) {
                .@"struct", .braceless_struct => {
                    //TODO: optimize for simple cases
                    const name = rule.loc.src(self.code);
                    const struct_rule = self.structs.get(name).?;

                    var seen_fields = std.StringHashMap(void).init(gpa);
                    defer seen_fields.deinit();

                    var doc_child_id = doc_node.first_child_id;
                    if (doc.nodes[doc_child_id].tag == .identifier) {
                        doc_child_id = doc.nodes[doc_child_id].next_id;
                    }

                    while (doc_child_id != 0) {
                        const field = doc.nodes[doc_child_id];
                        doc_child_id = field.next_id;

                        assert(field.tag == .struct_field);

                        const field_name_node = doc.nodes[field.first_child_id];
                        assert(field_name_node.tag == .identifier);

                        const field_name = field_name_node.loc.src(doc.code);

                        const field_rule = struct_rule.fields.get(field_name) orelse {
                            try addError(gpa, diag, .{
                                .unknown = .{
                                    .token = .{
                                        .tag = .identifier,
                                        .loc = field_name_node.loc,
                                    },
                                    .expected = &.{},
                                },
                            });
                            continue;
                        };

                        // duplicate fields should be detected in the doc
                        // via AST contruction.
                        try seen_fields.putNoClobber(field_name, {});

                        try stack.append(.{
                            .rule = field_rule.rule,
                            .doc_node = field.last_child_id,
                        });
                    }

                    if (seen_fields.count() != struct_rule.fields.count()) {
                        var it = struct_rule.fields.iterator();
                        while (it.next()) |kv| {
                            if (self.nodes[kv.value_ptr.rule.node].tag == .optional) {
                                continue;
                            }
                            const k = kv.key_ptr.*;
                            if (!seen_fields.contains(k)) {
                                try addError(gpa, diag, .{
                                    .missing = .{
                                        .token = .{
                                            .tag = .value, // doesn't matter
                                            .loc = .{
                                                .start = doc_node.loc.end - 1,
                                                .end = doc_node.loc.end,
                                            },
                                        },
                                        .expected = k,
                                    },
                                });
                            }
                        }
                    }
                },
                else => try self.typeMismatch(gpa, diag, doc, elem),
            },
            .tag => switch (doc_node.tag) {
                .tag => {},
                else => try self.typeMismatch(gpa, diag, doc, elem),
            },
            .bytes => switch (doc_node.tag) {
                .string, .line_string => {},
                else => try self.typeMismatch(gpa, diag, doc, elem),
            },
            .int => switch (doc_node.tag) {
                .integer => {},
                else => try self.typeMismatch(gpa, diag, doc, elem),
            },
            .float => switch (doc_node.tag) {
                .float => {},
                else => try self.typeMismatch(gpa, diag, doc, elem),
            },
            .bool => switch (doc_node.tag) {
                .bool => {},
                else => try self.typeMismatch(gpa, diag, doc, elem),
            },
            .any => {},
            else => unreachable,
        }
    }
}

fn typeMismatch(
    self: Schema,
    gpa: std.mem.Allocator,
    diag: ?*ziggy.Diagnostic,
    doc: ziggy.Ast,
    check_item: CheckItem,
) !void {
    var rule_node = self.nodes[check_item.rule.node];
    if (check_item.optional) {
        rule_node = self.nodes[rule_node.parent_id];
    }

    const found = doc.nodes[check_item.doc_node];

    assert(found.tag != .comment);
    assert(found.tag != .top_comment);

    try addError(gpa, diag, .{
        .type_mismatch = .{
            .token = .{
                .tag = .value,
                .loc = found.loc,
            },
            .expected = rule_node.loc.src(self.code),
        },
    });
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
