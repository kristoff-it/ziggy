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
const RecoverAst = @import("RecoverAst.zig");
const Suggestion = RecoverAst.Suggestion;
const Hover = RecoverAst.Hover;

pub const Tree = struct {
    tag: Tree.Tag,
    children: std.ArrayListUnmanaged(Child) = .{},
    suggestions: []const Suggestion = &.{},
    hovers: []const Hover = &.{},

    pub const Tag = enum {
        err,
        document,
        top_level_struct,
        @"struct",
        struct_field,
        array,
        map,
        map_field,
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
        // this method is only used in tests where allocator is a gpa.  it can
        // be removed if tests are updated to use an arena.
        for (t.children.items) |*child| child.deinit(gpa);
        t.children.deinit(gpa);
        for (t.suggestions) |s| gpa.free(s.completions);
        gpa.free(t.suggestions);
        gpa.free(t.hovers);
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
        doc: *Tree,
        gpa: std.mem.Allocator,
        rules: ziggy.schema.Schema,
        diag: ?*ziggy.Diagnostic,
        ziggy_code: [:0]const u8,
    ) !void {
        // TODO: check ziggy file against this ruleset
        var stack = std.ArrayList(CheckItem).init(gpa);
        defer stack.deinit();

        var suggestions = std.ArrayList(Suggestion).init(gpa);
        var hovers = std.ArrayList(Hover).init(gpa);
        defer {
            doc.suggestions = suggestions.toOwnedSlice() catch blk: {
                suggestions.deinit();
                break :blk &.{};
            };
            doc.hovers = hovers.toOwnedSlice() catch blk: {
                hovers.deinit();
                break :blk &.{};
            };
        }

        var doc_root_val: u32 = 0;
        {
            const items = doc.children.items;
            log.debug("check() items len {}", .{items.len});
            if (items.len == 0) return;
            while (doc_root_val < items.len and
                items[doc_root_val] == .token and
                items[doc_root_val].token.tag == .top_comment_line) : (doc_root_val += 1)
            {}

            if (doc_root_val >= items.len) {
                log.debug("check() skipping empty file", .{});
                return;
            }
            assert(doc_root_val < items.len);
            try stack.append(.{
                .rule = rules.root,
                .child = items[doc_root_val],
            });
        }

        while (stack.pop()) |elem| {
            const rule = rules.nodes[elem.rule.node];
            assert(elem.child == .tree);
            const tree = elem.child.tree;

            log.debug(
                "rule {s} {s}, child {}",
                .{ @tagName(rule.tag), rule.loc.src(rules.code), elem.child },
            );
            if (tree.tag == .err) {
                // assume error has already been reported. nothing to do here.
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

                        // start at 1 to skip first token: '['
                        var child_id: usize = 1;
                        while (child_id < items.len) : (child_id += 1) {
                            const arr_child = items[child_id];
                            if (arr_child == .token) {
                                assert(arr_child.token.tag != .comment);
                                switch (arr_child.token.tag) {
                                    .comma, .rsb => continue,
                                    else => {},
                                }
                            }
                            try stack.append(.{
                                .rule = child_rule,
                                .child = arr_child,
                            });
                        }
                    },
                    else => try typeMismatch(gpa, rules, diag, elem, ziggy_code),
                },
                .map => switch (tree.tag) {
                    .map => {
                        //TODO: optimize for simple cases
                        const child_rule: Rule = .{ .node = rule.first_child_id };
                        assert(child_rule.node != 0);
                        // maps look like this:
                        //   '{',
                        //        mapfield
                        //          fieldname, ':', value
                        //        ','?
                        //        mapfield
                        //          fieldname, ':', value
                        //        ','?
                        //   '}'
                        // to add map values, loop over map_field children
                        // adding 3rd child
                        var child_id: usize = 0;
                        while (child_id < tree.children.items.len) : (child_id += 1) {
                            const map_child = tree.children.items[child_id];
                            log.debug("map_child {}", .{map_child});
                            if (map_child == .tree and
                                map_child.tree.tag == .map_field and
                                map_child.tree.children.items.len >= 3)
                            {
                                try stack.append(.{
                                    .rule = child_rule,
                                    .child = map_child.tree.children.items[2],
                                });
                            }
                        }
                    },
                    // the empty literal '{}' is parsed as a struct
                    .@"struct" => {
                        if (tree.children.items.len == 2 and
                            tree.children.items[0] == .token and
                            tree.children.items[0].token.tag == .lb and
                            tree.children.items[1] == .token and
                            tree.children.items[1].token.tag == .rb)
                        {} else try typeMismatch(gpa, rules, diag, elem, ziggy_code);
                    },
                    else => try typeMismatch(gpa, rules, diag, elem, ziggy_code),
                },
                .struct_union => switch (tree.tag) {
                    .@"struct" => {
                        const rule_src = rule.loc.src(rules.code);
                        const struct_name_node = tree.children.items[0];
                        assert(struct_name_node == .token);
                        const name_loc = tree.loc();
                        if (struct_name_node.token.tag != .identifier) {
                            try addErrorCheck(gpa, diag, .{
                                .missing_struct_name = .{
                                    .sel = name_loc.getSelection(ziggy_code),
                                    .expected = rule_src,
                                },
                            });
                        }

                        const struct_name = struct_name_node.token.loc.src(ziggy_code);
                        var ident_id = rule.first_child_id;
                        assert(ident_id != 0);
                        while (ident_id != 0) {
                            const id_rule = rules.nodes[ident_id];
                            defer ident_id = id_rule.next_id;
                            const id_rule_src = id_rule.loc.src(rules.code);
                            if (std.mem.eql(u8, struct_name, id_rule_src)) {
                                try stack.append(.{
                                    .rule = .{ .node = ident_id },
                                    .child = elem.child,
                                });
                                break;
                            }
                        } else {
                            // no match
                            try addErrorCheck(gpa, diag, .{
                                .unknown_struct_name = .{
                                    .name = struct_name,
                                    .sel = struct_name_node.token.loc.getSelection(ziggy_code),
                                    .expected = rule_src,
                                },
                            });
                        }
                    },
                    else => try typeMismatch(gpa, rules, diag, elem, ziggy_code),
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

                        const suggestions_start = suggestions.items.len;
                        log.debug("tree with {} children", .{tree.children.items.len});
                        var struct_end_loc: ?Token.Loc = null;
                        while (child_id < tree.children.items.len) : (child_id += 1) {
                            const field = tree.children.items[child_id];
                            // log.debug("field {}", .{field});
                            switch (field) {
                                .token => |t| {
                                    struct_end_loc = t.loc;
                                    switch (t.tag) {
                                        .comma, .lb, .rb => {},
                                        else => try addErrorCheck(gpa, diag, .{
                                            .unknown_field = .{
                                                .name = field.token.loc.src(ziggy_code),
                                                .sel = field.token.loc.getSelection(ziggy_code),
                                            },
                                        }),
                                    }
                                    continue;
                                },
                                .tree => |field_tree| switch (field_tree.tag) {
                                    .struct_field => {},
                                    else => try addErrorCheck(gpa, diag, .{
                                        .unknown_field = .{
                                            .name = field_tree.loc().src(ziggy_code),
                                            .sel = field_tree.loc().getSelection(ziggy_code),
                                        },
                                    }),
                                },
                            }
                            // log.debug("field tree {}", .{field.tree.fmt(ziggy_code)});
                            if (field.tree.children.items.len < 2) {
                                try suggestions.append(.{
                                    .loc = .{
                                        .start = field.loc().start,
                                        .end = field.loc().end,
                                    },
                                });
                                continue;
                            }

                            assert(field.tree.tag == .struct_field);
                            const field_name_node = field.tree.children.items[1];
                            if (field_name_node != .token) continue;
                            const field_name = field_name_node.token.loc.src(ziggy_code);
                            const field_rule = struct_rule.fields.get(field_name) orelse {
                                log.debug("appending suggestion at {}", .{field_name_node.token.loc});
                                try suggestions.append(.{
                                    .loc = .{
                                        .start = field.loc().start,
                                        .end = field_name_node.loc().end,
                                    },
                                });
                                if (field_name.len != 0)
                                    try addErrorCheck(gpa, diag, .{
                                        .unknown_field = .{
                                            .name = field_name,
                                            .sel = field_name_node.loc().getSelection(ziggy_code),
                                        },
                                    });
                                continue;
                            };

                            // duplicate fields are detected during parsing and
                            // diagnostic errors produced.  but they appear as
                            // normal struct_field trees here.
                            try seen_fields.put(field_name, {});
                            try hovers.append(.{
                                .loc = .{ .start = field.loc().start, .end = field_name_node.token.loc.end },
                                .hover = field_rule.help.doc,
                            });
                            // guard against incomplete fields / errors
                            if (field.tree.children.items.len > 3) {
                                try stack.append(.{
                                    .rule = field_rule.rule,
                                    // skip first 3 tokens of struct field: dot, name, equal
                                    .child = field.tree.children.items[3],
                                });
                            } else {
                                // field likely has errors which have already
                                // been diagnosed
                            }
                        }
                        log.debug("seen_fields.count {} struct_rule.fields.count {}", .{ seen_fields.count(), struct_rule.fields.count() });
                        if (seen_fields.count() != struct_rule.fields.count()) {
                            var completions = std.ArrayList(Suggestion.Completion).init(gpa);
                            const any_suggestion = suggestions_start != suggestions.items.len;
                            log.debug("any_suggestion {} suggestions {}", .{ any_suggestion, suggestions.items.len });

                            for (struct_rule.fields.keys(), struct_rule.fields.values()) |k, v| {
                                if (rules.nodes[v.rule.node].tag == .optional) {
                                    if (any_suggestion and !seen_fields.contains(k)) {
                                        try completions.append(.{
                                            .name = k,
                                            .type = rules.nodes[v.rule.node].loc.src(rules.code),
                                            .desc = v.help.doc,
                                            .snippet = v.help.snippet,
                                        });
                                    }
                                    continue;
                                }

                                if (!seen_fields.contains(k)) {
                                    if (any_suggestion) {
                                        try completions.append(.{
                                            .name = k,
                                            .type = rules.nodes[v.rule.node].loc.src(rules.code),
                                            .desc = v.help.doc,
                                            .snippet = v.help.snippet,
                                        });
                                    }
                                    const dloc = struct_end_loc orelse loc: {
                                        var l = doc.loc();
                                        l.start = l.end -| 1;
                                        break :loc l;
                                    };
                                    assert(dloc.start <= dloc.end);
                                    try addErrorCheck(gpa, diag, .{
                                        .missing_field = .{
                                            .sel = dloc.getSelection(ziggy_code),
                                            .name = k,
                                        },
                                    });
                                }
                            }
                            for (suggestions.items[suggestions_start..]) |*s| {
                                s.completions = completions.items;
                            }
                        }
                    },
                    else => try typeMismatch(gpa, rules, diag, elem, ziggy_code),
                },
                .tag => switch (tree.tag) {
                    .tag_string => {
                        // tag_string tree has children '@', ident, '(', string, ')'
                        if (tree.children.items.len < 2) {
                            try typeMismatch(gpa, rules, diag, elem, ziggy_code);
                            continue;
                        }

                        const tag_src = tree.children.items[1].token.loc.src(ziggy_code);
                        const rule_src = rule.loc.src(rules.code)[1..];
                        if (!std.mem.eql(u8, tag_src, rule_src)) {
                            try typeMismatch(gpa, rules, diag, elem, ziggy_code);
                        } else {
                            const literal_rule = rules.literals.get(rule_src).?;
                            try hovers.append(.{
                                .loc = tree.loc(),
                                .hover = literal_rule.hover,
                            });

                            var cases = std.ArrayList(Suggestion.Completion).init(gpa);
                            errdefer cases.deinit();

                            var enum_idx = rules.nodes[literal_rule.expr].first_child_id;
                            while (enum_idx != 0) {
                                const enum_case = rules.nodes[enum_idx];
                                try cases.append(.{
                                    .name = enum_case.loc.src(rules.code),
                                    .type = "bytes",
                                    .desc = "",
                                    .snippet = null,
                                });
                                enum_idx = enum_case.next_id;
                            }

                            var string_loc = tree.children.items[0].loc();
                            for (tree.children.items[1..]) |child| {
                                string_loc = child.loc();
                                if (child == .token and child.token.tag == .string) break;
                            }
                            try suggestions.append(.{
                                .loc = string_loc,
                                .completions = cases.items,
                            });

                            // validate enum value
                            var string_src = string_loc.src(ziggy_code);
                            if (string_src.len <= 2) {
                                try typeMismatch(gpa, rules, diag, elem, ziggy_code);
                                continue;
                            }
                            string_src = string_src[1 .. string_src.len - 1];
                            const found = for (cases.items) |completion| {
                                if (mem.eql(u8, completion.name, string_src))
                                    break true;
                            } else false;
                            if (!found) try typeMismatch(gpa, rules, diag, elem, ziggy_code);
                        }
                    },
                    else => try typeMismatch(gpa, rules, diag, elem, ziggy_code),
                },
                .bytes => switch (tree.tag) {
                    .string, .line_string => {},
                    else => try typeMismatch(gpa, rules, diag, elem, ziggy_code),
                },
                .int => switch (tree.tag) {
                    .integer => {},
                    else => try typeMismatch(gpa, rules, diag, elem, ziggy_code),
                },
                .float => switch (tree.tag) {
                    .float => {},
                    else => try typeMismatch(gpa, rules, diag, elem, ziggy_code),
                },
                .bool => switch (tree.tag) {
                    .true, .false => {},
                    else => try typeMismatch(gpa, rules, diag, elem, ziggy_code),
                },
                .any => {},
                .unknown => {},
            }
        }
    }

    fn typeMismatch(
        gpa: std.mem.Allocator,
        rules: ziggy.schema.Schema,
        diag: ?*ziggy.Diagnostic,
        check_item: CheckItem,
        ziggy_code: [:0]const u8,
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
                .name = found_child.loc().src(ziggy_code),
                .sel = found_child.loc().getSelection(ziggy_code),
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
        return RecoverAst.findSchemaPathFromLoc(schema_line.loc, bytes);
    }

    pub fn hoverForOffset(ast: Tree, offset: u32) ?[]const u8 {
        for (ast.hovers) |s| {
            if (s.loc.start <= offset and s.loc.end >= offset) {
                return s.hover;
            }
        }
        return null;
    }

    pub fn completionsForOffset(
        ast: Tree,
        offset: u32,
    ) []const RecoverAst.Suggestion.Completion {
        log.debug("completionsForOffset() suggestions len {}", .{ast.suggestions.len});
        for (ast.suggestions) |s| {
            log.debug("completionsForOffset() offset {} loc start/end {}/{}", .{ offset, s.loc.start, s.loc.end });
            if (s.loc.start <= offset and s.loc.end >= offset) {
                return s.completions;
            }
        }
        return &.{};
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
        .identifier,
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
            try p.advanceWithError(.{
                .unexpected = .{
                    .name = token.tag.lexeme(),
                    .sel = token.loc.getSelection(p.code),
                    .expected = &.{"top level struct or value"},
                },
            });
        },
    }

    if (!p.eof()) {
        const m2 = p.open();
        var tok = p.peek(0);
        tok.loc.end = @intCast(p.code.len);
        try p.addError(.{
            .unexpected = .{
                .name = tok.tag.lexeme(),
                .sel = tok.loc.getSelection(p.code),
                .expected = lexemes(&.{.eof}),
            },
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
    log.debug("topLevelStruct()", .{});
    const m = p.open();
    try p.structBody(.top_level);
    _ = p.close(m, .top_level_struct);
}

/// struct_body = (comment* '.' identifier '=' value)+
fn structBody(p: *Parser, mode: enum { top_level, nested }) !void {
    var seen_fields = std.StringHashMap(Token.Loc).init(p.gpa);
    defer seen_fields.deinit();

    while (true) {
        p.comments();
        const t, const t1, const t2, const t3 = p.peekLen(4);
        log.debug(
            "structBody() {s} {s} {s} {s}",
            .{ t.tag.lexeme(), t1.tag.lexeme(), t2.tag.lexeme(), t3.tag.lexeme() },
        );

        switch (t.tag) {
            .dot => {},
            .rb => {
                if (seen_fields.count() == 0) {
                    try p.addError(.{ .unexpected = .{
                        .name = t.tag.lexeme(),
                        .sel = t.loc.getSelection(p.code),
                        .expected = if (mode == .nested)
                            lexemes(&.{ .dot, .rb })
                        else
                            lexemes(&.{.dot}),
                    } });
                }
                break;
            },
            .eof => {
                if (mode == .nested)
                    try p.addError(.{ .unexpected = .{
                        .name = t.tag.lexeme(),
                        .sel = t.loc.getSelection(p.code),
                        .expected = lexemes(&.{ .dot, .rb }),
                    } });
                break;
            },
            else => {
                try p.advanceWithError(.{ .unexpected = .{
                    .name = t.tag.lexeme(),
                    .sel = t.loc.getSelection(p.code),
                    .expected = if (mode == .nested)
                        lexemes(&.{ .dot, .rb })
                    else
                        lexemes(&.{.dot}),
                } });
                continue;
            },
        }
        {
            // this block allows to defer closing the struct_field tree instead
            // of scattering many p.close() calls at exit points.  it also
            // allows a trailing comma token to come after this struct_field
            // tree is closed.
            const m = p.open();
            p.advance();
            defer _ = p.close(m, .struct_field);

            switch (t1.tag) {
                .identifier => {
                    const gop = try seen_fields.getOrPut(t1.loc.src(p.code));
                    if (gop.found_existing) {
                        try p.addError(.{ .duplicate_field = .{
                            .name = t1.tag.lexeme(),
                            .sel = t1.loc.getSelection(p.code),
                            .original = gop.value_ptr.getSelection(p.code),
                        } });
                    } else gop.value_ptr.* = t1.loc;
                },
                .rb, .eof => {
                    try p.addError(.{ .unexpected = .{
                        .name = t1.tag.lexeme(),
                        .sel = t1.loc.getSelection(p.code),
                        .expected = lexemes(&.{.identifier}),
                    } });
                    break;
                },
                .dot => {
                    try p.addError(.{ .unexpected = .{
                        .name = t1.tag.lexeme(),
                        .sel = t1.loc.getSelection(p.code),
                        .expected = lexemes(&.{.identifier}),
                    } });
                    continue;
                },
                else => {
                    try p.advanceWithError(.{ .unexpected = .{
                        .name = t1.tag.lexeme(),
                        .sel = t1.loc.getSelection(p.code),
                        .expected = lexemes(&.{.identifier}),
                    } });
                    continue;
                },
            }
            p.advance();

            switch (t2.tag) {
                .eql => {},
                .rb, .eof => {
                    try p.addError(.{ .unexpected = .{
                        .name = t2.tag.lexeme(),
                        .sel = t2.loc.getSelection(p.code),
                        .expected = lexemes(&.{.eql}),
                    } });
                    break;
                },
                .dot => {
                    try p.addError(.{ .unexpected = .{
                        .name = t2.tag.lexeme(),
                        .sel = t2.loc.getSelection(p.code),
                        .expected = lexemes(&.{.eql}),
                    } });
                    continue;
                },
                else => {
                    try p.advanceWithError(.{ .unexpected = .{
                        .name = t2.tag.lexeme(),
                        .sel = t2.loc.getSelection(p.code),
                        .expected = lexemes(&.{.eql}),
                    } });
                    continue;
                },
            }
            p.advance();

            switch (t3.tag) {
                .identifier,
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
                .rb, .eof => {
                    try p.addError(.{ .unexpected = .{
                        .name = t3.tag.lexeme(),
                        .sel = t3.loc.getSelection(p.code),
                        .expected = lexemes(&.{.value}),
                    } });
                    break;
                },
                .comma => {
                    try p.addError(.{ .unexpected = .{
                        .name = t3.tag.lexeme(),
                        .sel = t3.loc.getSelection(p.code),
                        .expected = lexemes(&.{.value}),
                    } });
                },
                .dot => {
                    try p.addError(.{ .unexpected = .{
                        .name = t3.tag.lexeme(),
                        .sel = t3.loc.getSelection(p.code),
                        .expected = lexemes(&.{.comma}),
                    } });
                    continue;
                },
                else => try p.advanceWithError(.{ .unexpected = .{
                    .name = t3.tag.lexeme(),
                    .sel = t3.loc.getSelection(p.code),
                    .expected = lexemes(&.{.value}),
                } }),
            }
        }

        const t4 = p.peek(0);
        switch (t4.tag) {
            .comma => p.advance(),
            .dot => try p.addError(.{ .unexpected = .{
                .name = t4.tag.lexeme(),
                .sel = t4.loc.getSelection(p.code),
                .expected = lexemes(&.{.comma}),
            } }),
            else => break,
        }
    }

    p.comments();
}

/// value =
///   struct | map | array | tag_string | string | float
/// | integer | true | false | null
fn value(p: *Parser) Diagnostic.Error.ZigError!void {
    const m = p.open();
    const t, const t1 = p.peekLen(2);
    log.debug("value() {s} {s}", .{ @tagName(t.tag), @tagName(t1.tag) });

    switch (t.tag) {
        .identifier => {
            if (t1.tag != .lb) {
                try p.advanceWithErrorNoOpen(m, .{
                    .unexpected = .{
                        .name = t1.tag.lexeme(),
                        .sel = t1.loc.getSelection(p.code),
                        .expected = lexemes(&.{ .lb, .value }),
                    },
                });
                return;
            }
            p.advance();
            try p.struct_();
            _ = p.close(m, .@"struct");
        },
        .lb => switch (t1.tag) {
            .string => {
                try p.map();
                _ = p.close(m, .map);
            },
            .rb => {
                // parse empty literal as a struct even though it could also be
                // a map
                p.advance();
                p.advance();
                _ = p.close(m, .@"struct");
            },
            else => {
                try p.struct_();
                _ = p.close(m, .@"struct");
            },
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
                .unexpected = .{
                    .name = t.tag.lexeme(),
                    .sel = t.loc.getSelection(p.code),
                    .expected = lexemes(&.{.value}),
                },
            });
            _ = p.close(m, .err);
        },
        else => {
            // "expected a value"
            try p.advanceWithErrorNoOpen(m, .{
                .unexpected = .{
                    .name = t.tag.lexeme(),
                    .sel = t.loc.getSelection(p.code),
                    .expected = lexemes(&.{.value}),
                },
            });
        },
    }
}

/// tag_string = '@' identifier '(' string ')'
fn tagString(p: *Parser) !void {
    // mark open/close is handled in value()
    try p.expect(.at);
    try p.expect(.identifier);
    try p.expect(.lp);
    try p.expect(.string);
    try p.expect(.rp);
}

/// array = '[' (array_elem,  (',' array_elem)*)? ','? comment* ']'
/// array_elem = comment* value
fn array(p: *Parser) !void {
    log.debug("array()", .{});
    // mark open/close is handled in value()
    try p.expect(.lsb);

    while (true) {
        p.comments();
        const t = p.peek(0);
        log.debug("array() {s}", .{@tagName(t.tag)});

        switch (t.tag) {
            .identifier,
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
            .rsb, .dot => break, // allow for recovery on dot
            .eof => {
                try p.addError(.{ .unexpected = .{
                    .name = t.tag.lexeme(),
                    .sel = t.loc.getSelection(p.code),
                    .expected = lexemes(&.{ .value, .rsb }),
                } });
                break;
            },
            else => {
                try p.advanceWithError(.{ .unexpected = .{
                    .name = t.tag.lexeme(),
                    .sel = t.loc.getSelection(p.code),
                    .expected = lexemes(&.{ .value, .rsb }),
                } });
            },
        }

        const t1 = p.peek(0);
        switch (t1.tag) {
            .comma => p.advance(),
            .rsb, .eof => break,
            else => {
                try p.advanceWithError(.{ .unexpected = .{
                    .name = t1.tag.lexeme(),
                    .sel = t1.loc.getSelection(p.code),
                    .expected = lexemes(&.{ .comma, .rsb }),
                } });
            },
        }
    }

    _ = p.consume(.comma);
    p.comments();
    try p.expect(.rsb);
}

/// struct = struct_name? '{' (struct_field,  (',' struct_field)* )? comment* '}'
fn struct_(p: *Parser) !void {
    log.debug("struct", .{});
    try p.expect(.lb);
    try p.structBody(.nested);
    try p.expect(.rb);
}

/// map = '{' (map_field,  (',' map_field)* )? comment* '}'
/// map_field = comment* string ':' value
fn map(p: *Parser) !void {
    log.debug("map", .{});
    try p.expect(.lb);
    var seen_any_fields = false;

    while (true) {
        p.comments();
        const t, const t1, const t2 = p.peekLen(3);
        log.debug(
            "map() {s} {s} {s}",
            .{ t.tag.lexeme(), t1.tag.lexeme(), t2.tag.lexeme() },
        );

        switch (t.tag) {
            .string => {},
            .rb => {
                if (!seen_any_fields) {
                    try p.addError(.{ .unexpected = .{
                        .name = t.tag.lexeme(),
                        .sel = t.loc.getSelection(p.code),
                        .expected = lexemes(&.{ .string, .rb }),
                    } });
                }
                break;
            },
            .eof => {
                try p.addError(.{ .unexpected = .{
                    .name = t.tag.lexeme(),
                    .sel = t.loc.getSelection(p.code),
                    .expected = lexemes(&.{ .string, .rb }),
                } });
                break;
            },
            else => {
                try p.advanceWithError(.{ .unexpected = .{
                    .name = t.tag.lexeme(),
                    .sel = t.loc.getSelection(p.code),
                    .expected = lexemes(&.{ .string, .rb }),
                } });
                continue;
            },
        }
        {
            // this block allows to defer closing the map_field tree instead
            // of scattering many p.close() calls at exit points.  it also
            // allows a trailing comma token to come after this map_field
            // tree is closed.
            const m = p.open();
            defer _ = p.close(m, .map_field);
            p.advance();

            switch (t1.tag) {
                .colon => {},
                .rb, .eof => {
                    try p.addError(.{ .unexpected = .{
                        .name = t1.tag.lexeme(),
                        .sel = t1.loc.getSelection(p.code),
                        .expected = lexemes(&.{.colon}),
                    } });
                    break;
                },
                else => {
                    try p.advanceWithError(.{ .unexpected = .{
                        .name = t1.tag.lexeme(),
                        .sel = t1.loc.getSelection(p.code),
                        .expected = lexemes(&.{.colon}),
                    } });
                    continue;
                },
            }
            p.advance();

            switch (t2.tag) {
                .identifier,
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
                .rb, .eof => {
                    try p.addError(.{ .unexpected = .{
                        .name = t2.tag.lexeme(),
                        .sel = t2.loc.getSelection(p.code),
                        .expected = lexemes(&.{.value}),
                    } });
                    break;
                },
                else => try p.advanceWithError(.{ .unexpected = .{
                    .name = t2.tag.lexeme(),
                    .sel = t2.loc.getSelection(p.code),
                    .expected = lexemes(&.{.value}),
                } }),
            }
        }

        seen_any_fields = true;
        const t3 = p.peek(0);
        switch (t3.tag) {
            .comma => p.advance(),
            .rb => break,
            else => {
                try p.addError(.{ .unexpected = .{
                    .name = t3.tag.lexeme(),
                    .sel = t3.loc.getSelection(p.code),
                    .expected = lexemes(&.{ .comma, .rb }),
                } });
            },
        }
    }

    p.comments();
    try p.expect(.rb);
}

fn peek(p: *Parser, offset: u8) Token {
    if (p.fuel == 0) @panic("parser is stuck");
    p.fuel = p.fuel - 1;

    const idx = p.tokenizer.idx;
    defer p.tokenizer.idx = idx;
    var i: u8 = 0;
    var tok = p.tokenizer.next(p.code);
    while (i < offset) {
        i += 1;
        tok = p.tokenizer.next(p.code);
    }
    return tok;
}

fn peekLen(p: *Parser, comptime len: u8) [len]Token {
    if (p.fuel == 0) @panic("parser is stuck");
    p.fuel = p.fuel - 1;

    const idx = p.tokenizer.idx;
    defer p.tokenizer.idx = idx;
    var i: u8 = 0;
    var toks: [len]Token = undefined;
    while (i < len) {
        toks[i] = p.tokenizer.next(p.code);
        i += 1;
    }
    return toks;
}

fn consume(p: *Parser, tag: Token.Tag) bool {
    if (p.at(tag)) {
        p.advance();
        return true;
    }
    return false;
}

fn lexemes(comptime tags: []const Token.Tag) []const []const u8 {
    comptime var out: []const []const u8 = &.{};
    inline for (tags) |t| {
        const next: []const []const u8 = &.{comptime t.lexeme()};
        out = out ++ next;
    }
    return out;
}

fn expect(p: *Parser, comptime tag: Token.Tag) !void {
    if (p.consume(tag)) return;
    const token = p.peek(0);
    try p.addError(.{
        .unexpected = .{
            .name = token.tag.lexeme(),
            .sel = token.loc.getSelection(p.code),
            .expected = lexemes(&.{tag}),
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
    log.debug("addError {}", .{err.fmt(null)});
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
    assert(p.events.pop().? == .close);
    p.tokenizer.idx = 0;
    var stack = std.ArrayList(Tree).init(p.gpa);
    defer stack.deinit();
    for (p.events.items) |event| {
        // log.debug("build_tree() event={}", .{event});
        switch (event) {
            .open => |tag| try stack.append(.{ .tag = tag }),
            .close => {
                const tree = stack.pop().?;
                if (stack.items.len == 0) {
                    log.debug("tree\n{}\n", .{tree.fmt(p.code)});
                }
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

    const tree = stack.pop().?;
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
    try expectFmtEql(
        \\Foo {.x = 1}
    );
}

test "misc" {
    try expectFmtEql("[]");
    // FIXME completions empty file
    // try expectFmtEql("");
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
    try expectFmtEql(".a = 1,\n, ");
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

    try expectFmtEql(
        \\.custom = {
        \\    "asdf": {.foo = 1, xxx },
        \\},
        \\
    );
    try expectFmtEql(
        \\{"asdfa": }, 
    );
}

test "tree.check" {
    // i'm leaving this here for now as a way to debug Tree.check()
    // TODO either remove this or turn it into a test helper
    if (true) return error.SkipZigTest;
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
