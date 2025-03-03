const Ast = @This();

const std = @import("std");
const assert = std.debug.assert;
const ziggy = @import("../root.zig");
const Diagnostic = @import("Diagnostic.zig");
const Tokenizer = @import("Tokenizer.zig");
const Token = Tokenizer.Token;
const Rule = ziggy.schema.Schema.Rule;

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
            return p.addError(.{
                .syntax = .{
                    .name = token.loc.src(p.code),
                    .sel = token.loc.getSelection(p.code),
                },
            });
        }
        p.token = token;
    }

    fn must(p: *Parser, comptime tag: Token.Tag) !void {
        return p.mustAny(&.{tag});
    }

    fn mustAny(p: *Parser, comptime tags: []const Token.Tag) !void {
        for (tags) |t| {
            if (t == p.token.tag) break;
        } else {
            return p.addError(.{
                .unexpected = .{
                    .name = p.token.loc.src(p.code),
                    .sel = p.token.loc.getSelection(p.code),
                    .expected = lexemes(tags),
                },
            });
        }
    }

    pub fn addError(p: *Parser, err: Diagnostic.Error) Diagnostic.Error.ZigError {
        if (p.diagnostic) |d| {
            try d.errors.append(p.gpa, err);
        }
        return err.zigError();
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
                else => try p.addChild(.value),
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
                .dot => {
                    try p.addChild(.struct_field);
                },
                else => {
                    return p.addError(.{
                        .unexpected = .{
                            .name = p.token.loc.src(p.code),
                            .sel = p.token.loc.getSelection(code),
                            .expected = lexemes(&.{ .dot, .eof }),
                        },
                    });
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
                    return p.addError(.{
                        .unexpected = .{
                            .name = p.token.loc.src(p.code),
                            .sel = p.token.loc.getSelection(code),
                            .expected = lexemes(&.{ .dot, .string, .rb }),
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
                .dot => try p.addChild(.struct_field),
                else => {
                    return p.addError(.{
                        .unexpected = .{
                            .name = p.token.loc.src(p.code),
                            .sel = p.token.loc.getSelection(p.code),
                            .expected = lexemes(&.{ .dot, .rb }),
                        },
                    });
                },
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
                        try p.must(.dot);
                        try p.next();
                        try p.must(.identifier);
                        try p.addChild(.identifier);
                        p.node.loc = p.token.loc;
                        p.parent();
                        try p.next();
                        try p.must(.eql);
                        try p.next();
                        try p.addChild(.value);
                    },
                    else => {
                        if (p.token.tag == .comma) {
                            p.node.loc.end = p.token.loc.end;
                            try p.next();
                        } else {
                            p.node.loc.end = p.token.loc.start;
                            try p.mustAny(&.{ .rb, .eof });
                        }
                        p.parent();
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
                .rb => {
                    p.node.loc.end = p.token.loc.end;
                    try p.next();
                    p.parent();
                },
                .string => {
                    try p.addChild(.map_field);
                },
                else => {
                    return p.addError(.{
                        .unexpected = .{
                            .name = p.token.loc.src(p.code),
                            .sel = p.token.loc.getSelection(p.code),
                            .expected = lexemes(&.{ .string, .rb }),
                        },
                    });
                },
            },

            .map_field => {
                const last_child = p.nodes.items[p.node.last_child_id];
                log.debug(" last: '{s}'", .{@tagName(last_child.tag)});
                switch (last_child.tag) {
                    .root => {
                        p.node.loc.start = p.token.loc.start;
                        try p.addChild(.map_field_key);
                        try p.must(.string);
                        p.node.loc = p.token.loc;
                        p.parent();
                        try p.next();
                        try p.must(.colon);
                        try p.next();
                        try p.addChild(.value);
                    },
                    else => {
                        if (p.token.tag == .comma) {
                            p.node.loc.end = p.token.loc.end;
                            try p.next();
                        } else {
                            p.node.loc.end = p.token.loc.start;
                            try p.mustAny(&.{.rb});
                        }
                        p.parent();
                    },
                }
            },
            .array => {
                const last_child = p.nodes.items[p.node.last_child_id];
                log.debug(" last: '{s}'", .{@tagName(last_child.tag)});

                switch (last_child.tag) {
                    .root => {
                        p.node.loc.start = p.token.loc.start;
                    },
                    .comment => unreachable,
                    else => {
                        if (p.token.tag == .comma) {
                            try p.next();
                        } else {
                            if (p.token.tag != .rsb) {
                                return p.addError(.{
                                    .unexpected = .{
                                        .name = p.token.loc.src(p.code),
                                        .sel = p.token.loc.getSelection(p.code),
                                        .expected = lexemes(&.{.comma}),
                                    },
                                });
                            }
                        }
                    },
                }

                while (p.token.tag == .comment) : (try p.next()) {
                    try p.addChild(.comment);
                    p.node.loc = p.token.loc;
                    p.parent();
                }

                if (p.token.tag == .rsb) {
                    p.node.loc.end = p.token.loc.end;
                    try p.next();
                    p.parent();
                    continue;
                }

                try p.addChild(.value);
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
                    try p.next();
                    try p.must(.lb);
                    try p.next();
                    p.parent();
                },
                .lsb => {
                    p.node.tag = .array;
                    p.node.loc.start = p.token.loc.start;
                    try p.next();
                },
                .at => {
                    p.node.tag = .tag;
                    p.node.loc.start = p.token.loc.start;
                    try p.next();
                    try p.must(.identifier);
                    try p.addChild(.identifier);
                    p.node.loc = p.token.loc;
                    p.parent();
                    try p.next();
                    try p.must(.lp);
                    try p.next();
                    try p.must(.string);
                    try p.addChild(.string);
                    p.node.loc = p.token.loc;
                    p.parent();
                    try p.next();
                    try p.must(.rp);
                    p.node.loc.end = p.token.loc.end;
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
                    return p.addError(.{
                        .unexpected = .{
                            .name = p.token.loc.src(p.code),
                            .sel = p.token.loc.getSelection(p.code),
                            .expected = lexemes(&.{.value}),
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

fn lexemes(comptime tags: []const Token.Tag) []const []const u8 {
    comptime var out: []const []const u8 = &.{};
    inline for (tags) |t| {
        const next: []const []const u8 = &.{comptime t.lexeme()};
        out = out ++ next;
    }
    return out;
}

const CheckItem = struct {
    optional: bool = false,
    rule: Rule,
    doc_node: u32,
};

fn addError(
    gpa: std.mem.Allocator,
    diag: ?*ziggy.Diagnostic,
    err: ziggy.Diagnostic.Error,
) ziggy.Diagnostic.Error.ZigError {
    if (diag) |d| {
        try d.errors.append(gpa, err);
    }
    return err.zigError();
}

pub fn check(
    doc: ziggy.Ast,
    gpa: std.mem.Allocator,
    rules: ziggy.schema.Schema,
    diag: ?*ziggy.Diagnostic,
) !void {
    // TODO: check ziggy file against this ruleset
    var stack = std.ArrayList(CheckItem).init(gpa);
    defer stack.deinit();

    var doc_root_val: u32 = 1;
    if (doc.nodes.len < 2) return; // skip empty files
    if (doc.nodes[1].tag == .top_comment) {
        doc_root_val = doc.nodes[1].next_id;
    }

    try stack.append(.{
        .rule = rules.root,
        .doc_node = doc_root_val,
    });

    while (stack.pop()) |elem| {
        const rule = rules.nodes[elem.rule.node];
        const doc_node = doc.nodes[elem.doc_node];
        {
            log.debug("rule '{s}', node '{s}'", .{
                rule.loc.src(rules.code),
                @tagName(doc_node.tag),
            });
            const sel = doc_node.loc.getSelection(doc.code);
            log.debug("line: {}, col: {}", .{
                sel.start.line,
                sel.start.col,
            });
        }

        if (doc_node.tag == .value and doc_node.missing) {
            const rule_src = rule.loc.src(rules.code);
            return addError(gpa, diag, .{
                .missing_value = .{
                    .sel = doc_node.loc.getSelection(doc.code),
                    .expected = rule_src,
                },
            });
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
                else => try doc.typeMismatch(gpa, diag, rules, elem),
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

                else => try doc.typeMismatch(gpa, diag, rules, elem),
            },
            .struct_union => switch (doc_node.tag) {
                .@"struct" => {
                    const rule_src = rule.loc.src(rules.code);

                    const struct_name_node = doc.nodes[doc_node.first_child_id];
                    if (struct_name_node.tag != .identifier) {
                        return addError(gpa, diag, .{
                            .missing_struct_name = .{
                                // a struct always has curlies
                                .sel = doc_node.loc.getSelection(doc.code),
                                .expected = rule_src,
                            },
                        });
                    }

                    const struct_name = struct_name_node.loc.src(doc.code);

                    var ident_id = rule.first_child_id;
                    assert(ident_id != 0);
                    while (ident_id != 0) {
                        const id_rule = rules.nodes[ident_id];
                        const id_rule_src = id_rule.loc.src(rules.code);
                        log.debug("struct_union testing '{s}'", .{id_rule_src});
                        if (std.mem.eql(u8, struct_name, id_rule_src)) {
                            try stack.append(.{
                                .rule = .{ .node = ident_id },
                                .doc_node = elem.doc_node,
                            });
                            break;
                        }
                        ident_id = id_rule.next_id;
                    } else {
                        // no match
                        return addError(gpa, diag, .{
                            .unknown_struct_name = .{
                                .name = struct_name,
                                .sel = struct_name_node.loc.getSelection(doc.code),
                                .expected = rule_src,
                            },
                        });
                    }
                },
                else => try doc.typeMismatch(gpa, diag, rules, elem),
            },
            .identifier => switch (doc_node.tag) {
                .@"struct", .braceless_struct => {
                    //TODO: optimize for simple cases
                    const name = rule.loc.src(rules.code);
                    const struct_rule = rules.structs.get(name).?;

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
                            return addError(gpa, diag, .{
                                .unknown_field = .{
                                    .name = field_name,
                                    .sel = field_name_node.loc.getSelection(doc.code),
                                },
                            });
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
                            if (rules.nodes[kv.value_ptr.rule.node].tag == .optional) {
                                continue;
                            }
                            const k = kv.key_ptr.*;
                            if (!seen_fields.contains(k)) {
                                return addError(gpa, diag, .{
                                    .missing_field = .{
                                        .sel = doc_node.loc.getSelection(doc.code),
                                        .name = k,
                                    },
                                });
                            }
                        }
                    }
                },
                else => try doc.typeMismatch(gpa, diag, rules, elem),
            },
            .tag => switch (doc_node.tag) {
                .tag => {},
                else => try doc.typeMismatch(gpa, diag, rules, elem),
            },
            .bytes => switch (doc_node.tag) {
                .string, .line_string, .multiline_string => {},
                else => try doc.typeMismatch(gpa, diag, rules, elem),
            },
            .int => switch (doc_node.tag) {
                .integer => {},
                else => try doc.typeMismatch(gpa, diag, rules, elem),
            },
            .float => switch (doc_node.tag) {
                .float => {},
                else => try doc.typeMismatch(gpa, diag, rules, elem),
            },
            .bool => switch (doc_node.tag) {
                .bool => {},
                else => try doc.typeMismatch(gpa, diag, rules, elem),
            },
            .any => {},
            .unknown => {},
            else => unreachable,
        }
    }
}

fn typeMismatch(
    doc: ziggy.Ast,
    gpa: std.mem.Allocator,
    diag: ?*ziggy.Diagnostic,
    rules: ziggy.schema.Schema,
    check_item: CheckItem,
) !void {
    var rule_node = rules.nodes[check_item.rule.node];
    if (check_item.optional) {
        rule_node = rules.nodes[rule_node.parent_id];
    }

    const found = doc.nodes[check_item.doc_node];

    assert(found.tag != .comment);
    assert(found.tag != .top_comment);

    return addError(gpa, diag, .{
        .type_mismatch = .{
            .name = "(value)",
            .sel = found.loc.getSelection(doc.code),
            .expected = rule_node.loc.src(rules.code),
        },
    });
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
    if (value_idx >= nodes.len) return; // skip empty files
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
            if (mode == .vertical) {
                try printIndent(indent, w);
            }
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
        \\    [
        \\        123456789,
        \\    ],
        \\],
        \\
    ;

    var diag: Diagnostic = .{ .path = null };
    errdefer std.debug.print("diag: {}", .{diag});
    const ast = try Ast.init(std.testing.allocator, case, true, true, &diag);
    defer ast.deinit(std.testing.allocator);
    try std.testing.expectFmt(case, "{}", .{ast});
}
