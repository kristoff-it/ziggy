const Schema = @This();

const std = @import("std");
const Io = std.Io;
const assert = std.debug.assert;
const ziggy = @import("../root.zig");
const Tokenizer = @import("Tokenizer.zig");
const Token = Tokenizer.Token;
const Diagnostic = @import("Diagnostic.zig");
const Ast = @import("Ast.zig");
const Node = Ast.Node;

const log = std.log.scoped(.schema);

root: Rule,
code: [:0]const u8,
nodes: []const Ast.Node,
literals: std.StringArrayHashMapUnmanaged(LiteralRule) = .{},
structs: std.StringArrayHashMapUnmanaged(StructRule) = .{},

pub const LiteralRule = struct {
    comment: u32,
    name: u32,
    expr: u32,
    hover: []const u8,
};

pub const StructRule = struct {
    comment: u32,
    name: u32,
    fields: std.StringArrayHashMapUnmanaged(Field) = .{},

    pub const Field = struct {
        name: u32,
        rule: Rule,
        help: Help,

        pub const Help = struct {
            snippet: []const u8,
            doc: []const u8,
        };
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
    var names: std.ArrayList(u32) = .empty;
    defer names.deinit(gpa);

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
            .hover = try schema.docString(gpa, comment_id),
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

            const field_name = nodes[name_id].loc.src(code);
            const gop = try fields.getOrPut(gpa, field_name);
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
                .name = name_id,
                .rule = .{ .node = rule_id },
                .help = .{
                    .snippet = try schema.snippetString(gpa, field_name, rule_id),
                    .doc = try schema.docString(gpa, comment_id),
                },
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

    for (schema.literals.values()) |v| {
        const rule = schema.nodes[v.expr];
        switch (rule.tag) {
            else => unreachable,
            .bytes => continue,
            .enum_definition => {
                var seen = std.StringHashMap(Token.Loc).init(gpa);
                defer seen.deinit();

                var enum_idx = rule.first_child_id;
                if (enum_idx == 0) {
                    if (diagnostic) |d| {
                        d.tok = .{
                            .tag = .enum_kw,
                            .loc = rule.loc,
                        };
                        d.err = .empty_enum;
                    }
                    return error.EmptyEnum;
                }

                while (enum_idx != 0) {
                    const enum_case = schema.nodes[enum_idx];
                    assert(enum_case.tag == .identifier);
                    const gop = try seen.getOrPut(enum_case.loc.src(code));
                    if (gop.found_existing) {
                        if (diagnostic) |d| {
                            d.tok = .{
                                .tag = .identifier,
                                .loc = enum_case.loc,
                            };
                            d.err = .{
                                .duplicate_field = .{
                                    .first_loc = gop.value_ptr.*,
                                },
                            };
                        }
                        return error.DuplicateField;
                    }

                    gop.value_ptr.* = enum_case.loc;
                    enum_idx = enum_case.next_id;
                }
            },
        }
    }

    for (schema.structs.keys(), schema.structs.values()) |s_name, s| {
        for (s.fields.keys(), s.fields.values()) |f_name, f| {
            log.debug("analyzeRule '{s}.{s}'", .{ s_name, f_name });
            try schema.analyzeRule(gpa, f.rule, diagnostic);
        }
    }

    return schema;
}

fn snippetString(
    schema: Schema,
    gpa: std.mem.Allocator,
    field_name: []const u8,
    rule_id: u32,
) ![]const u8 {
    var out: Io.Writer.Allocating = .init(gpa);
    errdefer out.deinit();

    const w = &out.writer;

    try w.print("{s} = ", .{field_name});

    var rule = schema.nodes[rule_id];
    if (rule.tag == .optional) rule = schema.nodes[rule.first_child_id];

    switch (rule.tag) {
        else => unreachable,
        .bytes => try w.writeAll("\"$0\""),
        .any, .unknown, .int, .float, .bool => try w.writeAll("$0"),
        .array => try w.writeAll("[$0]"),
        .map => try w.writeAll("{$0}"),
        .tag => try w.print("{s}($0)", .{rule.loc.src(schema.code)}),
        .identifier => try w.print("{s} {{$0}}", .{rule.loc.src(schema.code)}),
        .struct_union => try w.writeAll("$1 {$0}"),
    }

    try w.writeAll(",");
    return out.toOwnedSlice();
}

fn docString(schema: Schema, gpa: std.mem.Allocator, node_id: u32) ![]const u8 {
    const node = schema.nodes[node_id];
    if (node.tag != .doc_comment) return "";

    var out: std.ArrayList(u8) = .empty;
    errdefer out.deinit(gpa);

    var line_id = node.first_child_id;
    while (line_id != 0) {
        const line = schema.nodes[line_id];
        assert(line.tag == .doc_comment_line);
        const src = line.loc.src(schema.code)[3..];
        try out.appendSlice(gpa, src);
        line_id = line.next_id;
        if (line_id != 0) {
            try out.append(gpa, '\n');
        }
    }

    return try out.toOwnedSlice(gpa);
}

pub fn deinit(self: *Schema, gpa: std.mem.Allocator) void {
    for (self.literals.values()) |l| gpa.free(l.hover);

    self.literals.deinit(gpa);
    for (self.structs.values()) |*s| {
        for (s.fields.values()) |f| {
            gpa.free(f.help.snippet);
            gpa.free(f.help.doc);
        }
        s.fields.deinit(gpa);
    }
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

    var diag: Diagnostic = .{ .lsp = false, .path = null };
    errdefer std.debug.print("diag: {f}", .{diag});
    const ast = try Ast.init(std.testing.allocator, case, &diag);
    defer ast.deinit(std.testing.allocator);

    try std.testing.expect(diag.err == .none);

    var schema = try Schema.init(std.testing.allocator, ast.nodes.items, case, &diag);
    schema.deinit(std.testing.allocator);
}
