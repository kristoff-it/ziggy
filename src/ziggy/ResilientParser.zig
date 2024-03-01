const Parser = @This();

gpa: std.mem.Allocator,
code: [:0]const u8,
tokenizer: Tokenizer,
diagnostic: ?*Diagnostic,
fuel: u32,
events: std.ArrayListUnmanaged(Event) = .{},

const std = @import("std");
const mem = std.mem;
const assert = std.debug.assert;
const ziggy = @import("../root.zig");
const Diagnostic = @import("Diagnostic.zig");
const Tokenizer = @import("Tokenizer.zig");
const Token = Tokenizer.Token;
const Rule = ziggy.schema.Schema.Rule;
const log = std.log.scoped(.resilient_parser);

pub const Tree = struct {
    tag: Tree.Tag,
    children: std.ArrayListUnmanaged(Child) = .{},

    pub const Tag = enum {
        err,
        document,
        top_level_struct,
        @"struct",
        struct_field,
        array,
        map,
        string,
        line_string,
        tag_string,
        integer,
        float,
        true,
        false,
        null,
    };

    pub fn loc(t: Tree) Token.Loc {
        const len = t.children.items.len;
        if (len == 0) {
            return .{ .start = 0, .end = 0 };
        }

        const start = t.children.items[0].loc();
        const end = t.children.items[len - 1].loc();
        return .{ .start = start.start, .end = end.end };
    }

    pub fn deinit(t: *Tree, gpa: mem.Allocator) void {
        for (t.children.items) |*child| child.deinit(gpa);
        t.children.deinit(gpa);
    }

    pub fn fmt(t: Tree, code: [:0]const u8) TreeFmt {
        return .{ .code = code, .tree = t };
    }

    const CheckItem = struct {
        optional: bool = false,
        rule: ziggy.schema.Schema.Rule,
        child: Child,
    };

    fn addErrorCheck(gpa: std.mem.Allocator, diag: ?*Diagnostic, err: Diagnostic.Error) !void {
        if (diag) |d| {
            try d.errors.append(gpa, err);
        }
    }

    pub fn check(
        doc: Tree,
        gpa: std.mem.Allocator,
        rules: ziggy.schema.Schema,
        diag: ?*ziggy.Diagnostic,
        ziggy_code: [:0]const u8,
    ) !void {

        // TODO: check ziggy file against this ruleset
        var stack = std.ArrayList(CheckItem).init(gpa);
        defer stack.deinit();

        var doc_root_val: u32 = 0;
        {
            const items = doc.children.items;
            if (items.len == 0) return;
            log.debug("check() first_child={s}", .{items[0].loc().src(ziggy_code)});
            while (doc_root_val < items.len and
                items[doc_root_val] == .token and
                items[doc_root_val].token.tag == .top_comment_line) : (doc_root_val += 1)
            {}
            if (doc_root_val >= items.len) return; // empty file, nothing to do
            try stack.append(.{
                .rule = rules.root,
                .child = items[doc_root_val],
            });
        }

        while (stack.popOrNull()) |elem| {
            const rule = rules.nodes[elem.rule.node];
            assert(elem.child == .tree);
            const tree = elem.child.tree;

            log.debug(
                "rule {s} {s}, child {}",
                .{ @tagName(rule.tag), rule.loc.src(rules.code), elem.child },
            );
            if (tree.tag == .err) {
                // TODO more descriptive reporting
                try addErrorCheck(gpa, diag, .{
                    .unexpected_token = .{
                        .token = .{
                            .tag = .invalid,
                            .loc = tree.loc(),
                        },
                        .expected = switch (rule.tag) {
                            .struct_field => &.{.dot},
                            else => &.{},
                        },
                    },
                });
                continue;
            }

            switch (rule.tag) {
                else => std.debug.panic("TODO {s}", .{@tagName(rule.tag)}),
                .optional => switch (tree.tag) {
                    .null => {},
                    else => {
                        const child_rule: Rule = .{ .node = rule.first_child_id };
                        assert(child_rule.node != 0);

                        try stack.append(.{
                            .optional = true,
                            .rule = child_rule,
                            .child = elem.child,
                        });
                    },
                },
                .array => switch (tree.tag) {
                    .array => {
                        //TODO: optimize for simple cases
                        const child_rule: Rule = .{ .node = rule.first_child_id };
                        assert(child_rule.node != 0);

                        const items = tree.children.items;
                        if (items[items.len - 1] != .token) continue;
                        assert(items[items.len - 1].token.tag == .rsb);
                        // start at 1 to skip first token: '['
                        var child_id: usize = 1;
                        while (child_id < items.len - 1) : (child_id += 2) {
                            const arr_child = items[child_id];
                            if (arr_child == .token) {
                                assert(arr_child.token.tag != .comment);
                            }
                            try stack.append(.{
                                .rule = child_rule,
                                .child = arr_child,
                            });
                        }
                    },
                    else => try typeMismatch(gpa, rules, diag, elem),
                },
                .map => switch (tree.tag) {
                    .map => {
                        //TODO: optimize for simple cases
                        const child_rule: Rule = .{ .node = rule.first_child_id };
                        assert(child_rule.node != 0);
                        // maps look like this:
                        //   '{',
                        //        fieldname, ':', value, ','
                        //        fieldname, ':', value, ','?
                        //   '}'
                        // in order to iterate values, we start at 3 to skip
                        // leading curly, fieldname and colon and increment by 4
                        var child_id: usize = 3;
                        while (child_id < tree.children.items.len) : (child_id += 4) {
                            const map_child = tree.children.items[child_id];
                            log.debug("map_child {}", .{map_child});
                            try stack.append(.{
                                .rule = child_rule,
                                .child = map_child,
                            });
                        }
                    },
                    else => try typeMismatch(gpa, rules, diag, elem),
                },
                .struct_union => switch (tree.tag) {
                    .@"struct" => {
                        const rule_src = rule.loc.src(rules.code);
                        const struct_name_node = tree.children.items[0];
                        assert(struct_name_node == .token);
                        const name_loc = tree.loc();
                        if (struct_name_node.token.tag != .identifier) {
                            try addErrorCheck(gpa, diag, .{
                                .missing = .{
                                    .token = .{
                                        .tag = .identifier,
                                        .loc = .{
                                            // a struct always has curlies
                                            .start = name_loc.start -| 1,
                                            .end = name_loc.start + 1,
                                        },
                                    },
                                    .expected = rule_src,
                                },
                            });
                        }

                        const struct_name = struct_name_node.token.loc.src(ziggy_code);

                        var ident_id = rule.first_child_id;
                        assert(ident_id != 0);
                        while (ident_id != 0) {
                            const id_rule = rules.nodes[ident_id];
                            const id_rule_src = id_rule.loc.src(ziggy_code);
                            if (std.mem.eql(u8, struct_name, id_rule_src)) {
                                try stack.append(.{
                                    .rule = .{ .node = ident_id },
                                    .child = elem.child,
                                });
                                continue;
                            }
                            ident_id = id_rule.next_id;
                        }
                        // no match
                        try addErrorCheck(gpa, diag, .{
                            .unknown = .{
                                .token = .{
                                    .tag = .identifier,
                                    .loc = struct_name_node.token.loc,
                                },
                                .expected = rule_src,
                            },
                        });
                    },
                    else => try typeMismatch(gpa, rules, diag, elem),
                },
                .identifier => switch (tree.tag) {
                    .@"struct", .top_level_struct => {
                        //TODO: optimize for simple cases
                        const name = rule.loc.src(rules.code);
                        log.debug("struct name={s}", .{name});
                        const struct_rule = rules.structs.get(name).?;

                        var seen_fields = std.StringHashMap(void).init(gpa);
                        defer seen_fields.deinit();

                        var child_id: usize = 0;
                        if (tree.children.items[0] == .token and
                            tree.children.items[0].token.tag == .identifier)
                            child_id += 1;

                        while (child_id < tree.children.items.len) : (child_id += 2) {
                            const field = tree.children.items[child_id];
                            switch (field) {
                                .token => {
                                    // TODO more descriptive reporting
                                    try addErrorCheck(gpa, diag, .{
                                        .unknown = .{
                                            .token = .{
                                                .tag = .identifier,
                                                .loc = field.token.loc,
                                            },
                                            .expected = &.{},
                                        },
                                    });
                                    continue;
                                },
                                .tree => |field_tree| switch (field_tree.tag) {
                                    .struct_field => {},
                                    else => {
                                        // TODO more descriptive reporting
                                        try addErrorCheck(gpa, diag, .{
                                            .unknown = .{
                                                .token = .{
                                                    .tag = .identifier,
                                                    .loc = field_tree.loc(),
                                                },
                                                .expected = &.{},
                                            },
                                        });
                                        continue;
                                    },
                                },
                            }
                            assert(field.tree.tag == .struct_field);
                            if (field.tree.children.items.len < 2) continue;
                            const field_name_node = field.tree.children.items[1];
                            if (field_name_node != .token) continue;
                            const field_name = field_name_node.token.loc.src(ziggy_code);
                            const field_rule = struct_rule.fields.get(field_name) orelse {
                                // TODO more descriptive reporting
                                try addErrorCheck(gpa, diag, .{
                                    .unknown = .{
                                        .token = .{
                                            .tag = .identifier,
                                            .loc = field_name_node.token.loc,
                                        },
                                        .expected = &.{},
                                    },
                                });
                                continue;
                            };

                            // duplicate fields should be detected in the doc
                            // via AST contruction.
                            try seen_fields.putNoClobber(field_name, {});
                            // guard against incomplete fields / errors
                            if (field.tree.children.items.len > 3) {
                                try stack.append(.{
                                    .rule = field_rule.rule,
                                    // skip first 3 tokens of struct field: dot, name, equal
                                    .child = field.tree.children.items[3],
                                });
                            } else {
                                // TODO maybe check for errors
                            }
                        }

                        if (seen_fields.count() != struct_rule.fields.count()) {
                            var it = struct_rule.fields.iterator();
                            while (it.next()) |kv| {
                                if (rules.nodes[kv.value_ptr.rule.node].tag == .optional) {
                                    continue;
                                }
                                const k = kv.key_ptr.*;
                                if (!seen_fields.contains(k)) {
                                    const field_loc = tree.loc();
                                    try addErrorCheck(gpa, diag, .{
                                        .missing = .{
                                            .token = .{
                                                .tag = .value, // doesn't matter
                                                .loc = .{
                                                    .start = field_loc.start - 1,
                                                    // FIXME this hack was added because sometimes field_loc.end is set to 0
                                                    // and start is > 0
                                                    // TODO find out why is field_loc.end sometimes == 0 and fix it.
                                                    // make sure to add add a test with a reproduction.
                                                    .end = if (field_loc.end < field_loc.start)
                                                        field_loc.start
                                                    else
                                                        field_loc.end,
                                                },
                                            },
                                            .expected = k,
                                        },
                                    });
                                }
                            }
                        }
                    },
                    else => try typeMismatch(gpa, rules, diag, elem),
                },
                .tag => switch (tree.tag) {
                    .tag_string => {},
                    else => try typeMismatch(gpa, rules, diag, elem),
                },
                .bytes => switch (tree.tag) {
                    .string, .line_string => {},
                    else => try typeMismatch(gpa, rules, diag, elem),
                },
                .int => switch (tree.tag) {
                    .integer => {},
                    else => try typeMismatch(gpa, rules, diag, elem),
                },
                .float => switch (tree.tag) {
                    .float => {},
                    else => try typeMismatch(gpa, rules, diag, elem),
                },
                .bool => switch (tree.tag) {
                    .true, .false => {},
                    else => try typeMismatch(gpa, rules, diag, elem),
                },
                .any => {},
            }
        }
    }

    fn typeMismatch(
        gpa: std.mem.Allocator,
        rules: ziggy.schema.Schema,
        diag: ?*ziggy.Diagnostic,
        check_item: CheckItem,
    ) !void {
        var rule_node = rules.nodes[check_item.rule.node];
        if (check_item.optional) {
            rule_node = rules.nodes[rule_node.parent_id];
        }

        const found_child = check_item.child;

        if (found_child == .token) {
            assert(found_child.token.tag != .comment);
            assert(found_child.token.tag != .top_comment_line);
        }

        try addErrorCheck(gpa, diag, .{
            .type_mismatch = .{
                .token = .{
                    .tag = .value,
                    .loc = found_child.loc(),
                },
                .expected = rule_node.loc.src(rules.code),
            },
        });
    }

    pub fn findSchemaToken(tree: Tree) ?Token {
        if (tree.children.items.len == 0) return null;
        const top_comments = tree.children.items[0];
        return if (top_comments == .token and
            top_comments.token.tag == .top_comment_line)
            top_comments.token
        else
            null;
    }

    pub fn findSchemaPath(tree: Tree, bytes: [:0]const u8) ?[]const u8 {
        const schema_line = tree.findSchemaToken() orelse return null;
        return @import("RecoverAst.zig").findSchemaPathFromLoc(schema_line.loc, bytes);
    }
};

pub const TreeFmt = struct {
    code: [:0]const u8,
    tree: Tree,

    pub fn format(
        tfmt: TreeFmt,
        comptime fmt_str: []const u8,
        options: std.fmt.FormatOptions,
        writer: anytype,
    ) !void {
        _ = options;
        if (mem.eql(u8, fmt_str, "pretty"))
            try tfmt.prettyPrint(writer, 0, false)
        else
            try tfmt.dump(writer, 0);
    }

    fn prettyPrintToken(
        tfmt: TreeFmt,
        token: Token,
        indent: u8,
        i: usize,
        has_trailing_comma: bool,
        writer: anytype,
    ) !void {
        switch (token.tag) {
            .string, .integer, .float => {
                try writer.writeAll(token.loc.src(tfmt.code));
            },
            .identifier => {
                try writer.writeAll(token.loc.src(tfmt.code));
                // identifiers have a trailing space except between
                // tag_string '@' and identifier
                if (i == 0 or
                    (tfmt.tree.children.items[i - 1] == .token and
                    tfmt.tree.children.items[i - 1].token.tag != .at))
                    try writer.writeByte(' ');
            },
            .comment, .top_comment_line => {
                try writer.writeAll(token.loc.src(tfmt.code));
                try writer.writeByte('\n');
            },
            .line_string => {
                try writer.writeByte('\n');
                try writer.writeByteNTimes(' ', (indent + 1) * 4);
                try writer.writeAll(token.loc.src(tfmt.code));
                // if this is the last line string, indent for a trailing comma
                if (i + 1 == tfmt.tree.children.items.len) {
                    try writer.writeByte('\n');
                    try writer.writeByteNTimes(' ', (indent + 1) * 4);
                }
            },
            else => {
                try writer.writeAll(token.tag.lexeme());
                if (has_trailing_comma and
                    (token.tag == .lsb or token.tag == .lb or token.tag == .comma))
                {
                    try writer.writeByte('\n');
                    const unindent = token.tag == .comma and
                        i + 1 < tfmt.tree.children.items.len and
                        tfmt.tree.children.items[i + 1] == .token and
                        (tfmt.tree.children.items[i + 1].token.tag == .rsb or
                        tfmt.tree.children.items[i + 1].token.tag == .rb);
                    const new_indent = (indent -| @intFromBool(unindent)) * 4;
                    try writer.writeByteNTimes(' ', new_indent);
                } else if (tfmt.tree.tag == .top_level_struct) {
                    try writer.writeByte('\n');
                } else {
                    // print trailing space
                    if (token.tag == .eql or
                        token.tag == .comma or
                        token.tag == .colon)
                        try writer.writeByte(' ');
                }
            },
        }
    }

    fn prettyPrint(
        tfmt: TreeFmt,
        writer: anytype,
        indent: u8,
        has_trailing_comma: bool,
    ) !void {
        var i: usize = 0;
        while (i < tfmt.tree.children.items.len) : (i += 1) {
            const child = tfmt.tree.children.items[i];
            switch (child) {
                .token => |token| try tfmt.prettyPrintToken(
                    token,
                    indent,
                    i,
                    has_trailing_comma,
                    writer,
                ),
                .tree => |tree| {
                    const mlast_child = if (tree.children.items.len < 2)
                        null
                    else
                        tree.children.items[tree.children.items.len - 2];

                    const is_container =
                        tree.tag == .array or
                        tree.tag == .@"struct" or
                        tree.tag == .map;

                    const _has_trailing_comma = is_container and
                        if (mlast_child) |last_child|
                        last_child == .token and last_child.token.tag == .comma
                    else
                        false;

                    const additional_indent = @intFromBool(_has_trailing_comma);
                    const sub_tfmt = TreeFmt{ .tree = tree, .code = tfmt.code };
                    try sub_tfmt.prettyPrint(
                        writer,
                        indent + additional_indent,
                        _has_trailing_comma,
                    );
                },
            }
        }
    }

    fn dump(tfmt: TreeFmt, writer: anytype, indent: usize) !void {
        try writer.writeByteNTimes(' ', indent * 2);
        _ = try writer.write(@tagName(tfmt.tree.tag));
        try writer.writeByte('\n');
        for (tfmt.tree.children.items) |child| {
            switch (child) {
                .token => |token| {
                    try writer.writeByteNTimes(' ', indent * 2);
                    try writer.print(
                        "  '{s}' {}:{}\n",
                        .{ token.loc.src(tfmt.code), token.loc.start, token.loc.end },
                    );
                },
                .tree => |tree| {
                    const sub_tfmt = TreeFmt{ .tree = tree, .code = tfmt.code };
                    try sub_tfmt.dump(writer, indent + 1);
                },
            }
        }
    }
};

pub const Child = union(enum) {
    token: Token,
    tree: Tree,

    pub fn loc(c: Child) Token.Loc {
        return switch (c) {
            .token => |t| t.loc,
            .tree => |t| t.loc(),
        };
    }

    pub fn deinit(c: *Child, gpa: mem.Allocator) void {
        if (c.* == .tree) c.tree.deinit(gpa);
    }
    pub fn format(c: Child, comptime fmt: []const u8, options: std.fmt.FormatOptions, writer: anytype) !void {
        _ = fmt;
        _ = options;
        switch (c) {
            .token => try writer.print("token={s}", .{@tagName(c.token.tag)}),
            .tree => try writer.print("tree={s}", .{@tagName(c.tree.tag)}),
        }
    }
};

const Event = union(enum) {
    open: Tree.Tag,
    close,
    advance,
};

pub const MarkOpened = enum(usize) {
    _,
    pub fn toClosed(m: MarkOpened) MarkClosed {
        return @enumFromInt(m.toInt());
    }
    pub fn toInt(m: MarkOpened) usize {
        return @intFromEnum(m);
    }
};

pub const MarkClosed = enum(usize) {
    _,
    pub fn toOpened(m: MarkClosed) MarkOpened {
        return @enumFromInt(m.toInt());
    }
    pub fn toInt(m: MarkClosed) usize {
        return @intFromEnum(m);
    }
};

pub fn init(
    gpa: std.mem.Allocator,
    code: [:0]const u8,
    want_comments: bool,
    diagnostic: ?*Diagnostic,
) !Tree {
    var p = Parser{
        .gpa = gpa,
        .code = code,
        .diagnostic = diagnostic,
        .fuel = 256,
        .tokenizer = .{ .want_comments = want_comments },
    };
    if (diagnostic) |d| d.code = code;
    defer p.deinit();
    p.document() catch {};
    return p.buildTree();
}

pub fn deinit(p: *Parser) void {
    p.events.deinit(p.gpa);
}

/// document = top_comment* (top_level_struct | value)?
fn document(p: *Parser) !void {
    const m = p.open();
    while (p.consume(.top_comment_line)) {}

    const token = p.peek(0);
    switch (token.tag) {
        .eof => {},
        .dot, .comment => try p.topLevelStruct(),
        .lb,
        .lsb,
        .at,
        .string,
        .line_string,
        .float,
        .integer,
        .true,
        .false,
        .null,
        => try p.value(),
        else => {
            // "expected a top level struct or value"
            try p.advanceWithError(.{ .unexpected_token = .{
                .token = token,
                .expected = &.{.value},
            } });
        },
    }

    if (!p.eof()) {
        const m2 = p.open();
        var tok = p.peek(0);
        tok.loc.end = @intCast(p.code.len);
        try p.addError(.{
            .unexpected_token = .{ .token = tok, .expected = &.{.eof} },
        });
        while (!p.eof()) p.advance();
        _ = p.close(m2, .err);
    }
    _ = p.close(m, .document);
}

/// ('//' .?* '\n')*
fn comments(p: *Parser) void {
    while (p.consume(.comment)) {}
}

/// top_level_struct = struct_field (',' struct_field)* ','? comment*
fn topLevelStruct(p: *Parser) !void {
    const m = p.open();
    try p.structField();

    while (true) {
        const token = p.peek(0);
        log.debug("topLevelStruct {}", .{token.tag});
        switch (token.tag) {
            .comma => {
                p.advance();
                // eof check is necessary so that we don't continue parsing
                // struct fields after a final trailing comma
                if (p.peek(0).tag == .eof) break;

                try p.structField();
            },
            .eof => break,
            .dot => {
                // report error and try to recover on dot
                try p.addError(.{ .missing = .{
                    .token = token,
                    .expected = Token.Tag.comma.lexeme(),
                } });
                try p.structField();
            },
            else => {
                try p.advanceWithError(.{ .missing = .{
                    .token = token,
                    .expected = Token.Tag.comma.lexeme(),
                } });
            },
        }
    }

    _ = p.consume(.comma);
    p.comments();
    _ = p.close(m, .top_level_struct);
}

/// struct_field = comment* '.' identifier '=' value
fn structField(p: *Parser) !void {
    assert(!p.eof());
    if (p.at(.comma)) return; // allow for recovery
    const m = p.open();
    p.comments();
    try p.expect(.dot);
    try p.expect(.identifier);
    try p.expect(.eql);
    try p.value();
    _ = p.close(m, .struct_field);
}

/// value =
///   struct | map | array | tag_string | string | float
/// | integer | true | false | null
fn value(p: *Parser) Diagnostic.Error.ZigError!void {
    const m = p.open();
    const token = p.peek(0);
    switch (token.tag) {
        .identifier => {
            const token1 = p.peek(1);
            if (token1.tag != .lb) {
                // "expected struct"
                try p.advanceWithErrorNoOpen(m, .{
                    .unexpected_token = .{
                        .token = token1,
                        .expected = &.{.lb},
                    },
                });
                return;
            }

            p.advance();
            try p.structOrMap(m);
        },
        .lb => {
            try p.structOrMap(m);
        },
        .lsb => {
            try p.array();
            _ = p.close(m, .array);
        },
        .at => {
            try p.tagString();
            _ = p.close(m, .tag_string);
        },
        .string => {
            p.advance();
            _ = p.close(m, .string);
        },
        .line_string => {
            p.advance();
            while (p.consume(.line_string)) {}
            _ = p.close(m, .line_string);
        },
        .integer => {
            p.advance();
            _ = p.close(m, .integer);
        },
        .float => {
            p.advance();
            _ = p.close(m, .float);
        },
        .true => {
            p.advance();
            _ = p.close(m, .true);
        },
        .false => {
            p.advance();
            _ = p.close(m, .false);
        },
        .null => {
            p.advance();
            _ = p.close(m, .null);
        },
        .eof => {
            _ = p.close(m, .err);
        },
        .comma => { // allow for recovery, don't advance
            try p.addError(.{
                .unexpected_token = .{
                    .token = token,
                    .expected = &.{.value},
                },
            });
            _ = p.close(m, .err);
        },
        else => {
            // "expected a value"
            try p.advanceWithErrorNoOpen(m, .{
                .unexpected_token = .{
                    .token = token,
                    .expected = &.{.value},
                },
            });
        },
    }
}

fn structOrMap(p: *Parser, m: MarkOpened) !void {
    const token = p.peek(1);
    switch (token.tag) {
        .dot => {
            try p.struct_();
            _ = p.close(m, .@"struct");
        },
        .string => {
            try p.map();
            _ = p.close(m, .map);
        },
        else => {
            // "expected map or struct"
            try p.advanceWithErrorNoOpen(m, .{
                .unexpected_token = .{
                    .token = token,
                    .expected = &.{ .dot, .string },
                },
            });
        },
    }
}

/// tag_string = '@' identifier '(' string ')'
fn tagString(p: *Parser) !void {
    const m = p.open();
    try p.expect(.at);
    try p.expect(.identifier);
    try p.expect(.lp);
    try p.expect(.string);
    try p.expect(.rp);
    _ = p.close(m, .tag_string);
}

/// array = '[' (array_elem,  (',' array_elem)*)? ','? comment* ']'
/// array_elem = comment* value
fn array(p: *Parser) !void {
    // mark open/close is handled in value()
    try p.expect(.lsb);

    while (!p.atAny(&.{ .rsb, .eof })) {
        p.comments();
        try p.value();
        if (!p.consume(.comma)) break;
    }

    _ = p.consume(.comma);
    p.comments();
    try p.expect(.rsb);
}

/// struct = struct_name? '{' (struct_field,  (',' struct_field)* )? comment* '}'
fn struct_(p: *Parser) !void {
    // mark open/close is handled in value()
    _ = p.consume(.identifier);
    try p.expect(.lb);

    while (true) {
        const token = p.peek(0);
        switch (token.tag) {
            .dot, .comment => try p.structField(),
            else => break,
        }
        if (!p.consume(.comma)) break;
    }

    _ = p.consume(.comma);
    p.comments();
    try p.expect(.rb);
}

/// map = '{' (map_field,  (',' map_field)* )? comment* '}'
/// map_field = comment* string ':' value
fn map(p: *Parser) !void {
    // mark open/close is handled in value()
    try p.expect(.lb);

    while (!p.atAny(&.{ .rb, .eof })) {
        p.comments();
        try p.expect(.string);
        try p.expect(.colon);
        try p.value();
        if (!p.consume(.comma)) break;
    }

    _ = p.consume(.comma);
    p.comments();
    try p.expect(.rb);
}

fn peek(p: *Parser, offset: u32) Token {
    if (p.fuel == 0) @panic("parser is stuck");
    p.fuel = p.fuel - 1;

    const idx = p.tokenizer.idx;
    defer p.tokenizer.idx = idx;
    var i: u32 = 0;
    var tok = p.tokenizer.next(p.code);
    while (i < offset) {
        i += 1;
        tok = p.tokenizer.next(p.code);
    }
    return tok;
}

fn consume(p: *Parser, tag: Token.Tag) bool {
    if (p.at(tag)) {
        p.advance();
        return true;
    }
    return false;
}

// this makes it possible to avoid memory errors without allocating below in
// expect() where we need to return a non-static slice.
const static_token_tags = blk: {
    const fields = @typeInfo(Token.Tag).Enum.fields;
    var result: [fields.len][1]Token.Tag = undefined;
    for (fields, 0..) |f, i| {
        result[i][0] = @enumFromInt(f.value);
    }
    break :blk result;
};

fn expect(p: *Parser, tag: Token.Tag) !void {
    if (p.consume(tag)) return;
    try p.addError(.{
        .unexpected_token = .{
            .token = p.peek(0),
            // prevent memory errors by returning a pointer to static memory.
            // this allows us to avoid the following problems:
            //   UAF:          .expected = &.{tag}
            //   memory leak:  .expected = try p.gpa.dupe(&.{tag})
            // duping the slice would require a way to free it later on after
            // the lsp diagnostics are printed.
            .expected = &static_token_tags[@intFromEnum(tag)],
        },
    });
}

fn at(p: *Parser, tag: Token.Tag) bool {
    const tok = p.peek(0);
    // log.debug("at({s}) {s}:'{s}'", .{ @tagName(tag), @tagName(tok.tag), tok.loc.src(p.code) });
    return tag == tok.tag;
}

fn atAny(p: *Parser, tags: []const Token.Tag) bool {
    return mem.indexOfScalar(Token.Tag, tags, p.peek(0).tag) != null;
}

fn addError(p: Parser, err: Diagnostic.Error) !void {
    log.debug("addError {}", .{err.fmt(p.code, null)});
    if (p.diagnostic) |d| {
        try d.errors.append(p.gpa, err);
    }
}

fn advanceWithError(p: *Parser, err: Diagnostic.Error) !void {
    const m = p.open();
    try p.advanceWithErrorNoOpen(m, err);
}

fn advanceWithErrorNoOpen(p: *Parser, m: MarkOpened, err: Diagnostic.Error) !void {
    try p.addError(err);
    p.advance();
    _ = p.close(m, .err);
}

fn advance(p: *Parser) void {
    assert(!p.eof());
    p.fuel = 256;
    p.events.append(p.gpa, .advance) catch @panic("OOM");
    _ = p.tokenizer.next(p.code);
}

fn eof(p: *Parser) bool {
    return p.peek(0).tag == .eof;
}

fn open(p: *Parser) MarkOpened {
    const mark: MarkOpened = @enumFromInt(p.events.items.len);
    p.events.append(p.gpa, .{ .open = .err }) catch @panic("OOM");
    return mark;
}

// fn openBefore(p: *Parser, m: MarkClosed) MarkOpened {
//     const mark = m.toOpened();
//     p.events.insert(p.gpa, m.toInt(), .{ .open = .err }) catch @panic("OOM");
//     return mark;
// }

fn close(p: *Parser, m: MarkOpened, tag: Tree.Tag) MarkClosed {
    p.events.items[m.toInt()] = .{ .open = tag };
    p.events.append(p.gpa, .close) catch @panic("OOM");
    return m.toClosed();
}

fn buildTree(p: *Parser) !Tree {
    assert(p.events.pop() == .close);
    p.tokenizer.idx = 0;
    var stack = std.ArrayList(Tree).init(p.gpa);
    defer stack.deinit();
    for (p.events.items) |event| {
        // log.debug("build_tree() event={}", .{event});
        switch (event) {
            .open => |tag| try stack.append(.{ .tag = tag }),
            .close => {
                const tree = stack.pop();
                try stack.items[stack.items.len - 1].children.append(
                    p.gpa,
                    .{ .tree = tree },
                );
            },
            .advance => {
                try stack.items[stack.items.len - 1].children.append(
                    p.gpa,
                    .{ .token = p.tokenizer.next(p.code) },
                );
            },
        }
    }

    const tree = stack.pop();
    assert(p.tokenizer.next(p.code).tag == .eof);
    if (stack.items.len != 0) {
        log.debug("unhandled stack item tree {}", .{tree.fmt(p.code)});
        for (stack.items) |x| log.debug("unhandled stack item tag {s}", .{@tagName(x.tag)});
        assert(false);
    }
    // log.debug("tree\n{}\n", .{tree.fmt(p.code)});
    return tree;
}

pub fn expectFmtEql(case: [:0]const u8) !void {
    try expectFmt(case, case);
}

pub fn expectFmt(case: [:0]const u8, expected: []const u8) !void {
    var diag = Diagnostic{ .path = null };
    defer diag.errors.deinit(std.testing.allocator);
    errdefer std.debug.print("{}\n", .{diag});
    var tree = try init(std.testing.allocator, case, true, &diag);
    // std.debug.print("{}\n", .{tree.fmt(case)});
    defer tree.deinit(std.testing.allocator);
    try std.testing.expectFmt(expected, "{pretty}", .{tree.fmt(case)});
}

test "basics" {
    try expectFmtEql(
        \\.foo = "bar",
        \\.bar = [1, 2, 3],
        \\
    );
}

test "vertical" {
    try expectFmtEql(
        \\.foo = "bar",
        \\.bar = [
        \\    1,
        \\    2,
        \\    3,
        \\],
        \\
    );
}

test "complex" {
    try expectFmtEql(
        \\.foo = "bar",
        \\.bar = [
        \\    1,
        \\    23.45,
        \\    {
        \\        "abc": "foo",
        \\        "baz": ["foo", "bar"],
        \\    },
        \\],
        \\.t = true,
        \\.f = false,
        \\.n = null,
        \\.date = @date("2020-10-01T00:00:00"),
        \\
    );
}

test "comments" {
    try expectFmtEql(
        \\//! top comment
        \\//! top comment2
        \\// foo field comment
        \\// foo field comment2
        \\.foo = "bar",
        \\// bar field comment
        \\// bar field comment2
        \\.bar = null
    );
}

test "top level non-struct values" {
    try expectFmtEql("true");
    try expectFmtEql("false");
    try expectFmtEql("null");
    try expectFmtEql(
        \\"top str"
    );
    try expectFmtEql("123");
    try expectFmtEql("123.45");
    try expectFmtEql("{.a = 1, .b = 2}");
    try expectFmtEql(
        \\{"a": 1, "b": 2}
    );
    try expectFmtEql(
        \\[true, false, null, "str", 123, {.a = 1, .b = 2}, {"a": 1, "b": 2}]
    );
}

test "misc" {
    try expectFmtEql("[]");
    try expectFmtEql("");
    try expectFmtEql("{}");
}

test "line string" {
    try expectFmtEql(
        \\{
        \\    "extended_description": 
        \\        \\Lorem ipsum dolor something something,
        \\        \\this is a multiline string literal.
        \\        ,
        \\}
    );
}

test "invalid" {
    try expectFmtEql(".a = ,\n");
    try expectFmtEql(".a = 1,\n,\n");
    try expectFmtEql(
        \\.a = t ,
        \\.b = 1
    );
    try expectFmtEql(
        \\.x = [],
        \\.
    );
    // FIXME everything after '.a = 1' is an error tree. not sure what to do
    // about the lost whitespace. what should be rendered there?
    try expectFmt(".a = 1 .b = 2", ".a = 1.b = 2");
    try expectFmt(".a = ; ", ".a = (invalid)");
    try expectFmt(
        \\["a "b"] 
    ,
        \\["a "b (invalid)
    );
    try expectFmt(
        \\.title = "My Post #1
    ,
        \\.title = (invalid)
        ,
    );
    try expectFmtEql(
        \\.layout = .title = "asdf",
        \\
    );
}

test "nested named structs" {
    try expectFmtEql(
        \\{
        \\    "asrt1": Remote {
        \\        .url = "arst",
        \\        .hash = "wfp",
        \\    },
        \\}, 
    );

    try expectFmtEql(
        \\//! ziggy-schema:  frontmatter.zs
        \\.title = "My Post #1",
        \\.date = @date("2024-02-18T10:00:00"),
        \\.author = "",
        \\.tags = ["tag1", "tag2"],
        \\.draft = true,
        \\.aliases = [],
        \\.layout = "arst",
        \\.custom = {
        \\    "arst": "foo",
        \\    "bar": true,
        \\    "foo": "https://google.com",
        \\    "bar1": @date("2020-01-01T00:00:00"),
        \\    "bar1": @date("2020-01-01T00:00:00"),
        \\    "asrt1": Remote {
        \\        .url = "arst",
        \\        .hash = "wfp",
        \\    },
        \\    "baz": 
        \\        \\Lorem Ipsum is simply dummy text of 
        \\        \\the printing and typesetting industry. 
        \\        \\
        \\        \\Lorem Ipsum has been the industry's standard 
        \\        \\dummy text ever since the 1500s, when an 
        \\        \\unknown printer took a galley of type and 
        \\        \\scrambled it to make a type specimen book. 
        \\        ,
        \\},
        \\
    );
}

test "maps" {
    try expectFmtEql(
        \\{"asdf": 1}
    );
    try expectFmtEql(
        \\.foo = {"asdf": 1}
    );
    try expectFmtEql(
        \\.foo = Foo {"asdf": 1}
    );
}

test "tree.check" {
    // i'm leaving this here for now as a way to debug Tree.check()
    // TODO either remove this or turn it into a test helper
    if (true) return error.SkipZigTest;
    std.testing.log_level = .debug;
    const code =
        \\//! ziggy-schema:  fm.zs
        \\
        \\.title = "My Post #1
    ;
    const alloc = std.testing.allocator;
    var diag = Diagnostic{ .path = null };
    std.debug.print("{}\n", .{diag});
    var tree = try init(alloc, code, false, &diag);

    defer tree.deinit(alloc);
    const schema_file =
        \\root = Frontmatter
        \\struct Frontmatter {
        \\  title: ?bytes,
        \\}
    ;
    var schema_ast = try ziggy.schema.Ast.init(
        alloc,
        schema_file,
        null,
    );
    defer schema_ast.deinit();
    var rules = try ziggy.schema.Schema.init(
        alloc,
        schema_ast.nodes.items,
        schema_file,
        null,
    );
    defer rules.deinit(alloc);
    diag.deinit(alloc);
    diag = .{ .path = null };
    try Tree.check(tree, alloc, rules, &diag, code);

    for (diag.errors.items) |e| {
        switch (e) {
            inline else => |payload, tag| {
                const P = @TypeOf(payload);
                std.debug.print("diag tag {s}\n", .{@tagName(tag)});
                if (P != void and @hasField(P, "token")) {
                    std.debug.print("{s} {}\n", .{ @tagName(tag), payload.token.loc });
                }
            },
        }
    }
    std.debug.print("errors len {}\n", .{diag.errors.items.len});
    diag.code = code;
    std.debug.print("{}\n", .{diag});
    diag.deinit(alloc);
}
