const std = @import("std");
const assert = std.debug.assert;
const ziggy = @import("ziggy");
const Writer = std.Io.Writer;
const Diagnostic = ziggy.Diagnostic;
const Ast = ziggy.Ast;
const Node = Ast.Node;
const Token = ziggy.Tokenizer.Token;

pub fn toZiggy(
    gpa: std.mem.Allocator,
    schema: ziggy.schema.Schema,
    diag: ?*ziggy.Diagnostic,
    file: std.fs.File,
) ![]const u8 {
    var fr = file.reader(&.{});
    var aw: std.Io.Writer.Allocating = .init(gpa);
    defer aw.deinit();

    _ = try fr.interface.streamRemaining(&aw.writer);
    const in_bytes = try aw.toOwnedSliceSentinel(0);

    var js_diag: std.json.Diagnostics = .{};
    var scanner = std.json.Scanner.initCompleteInput(gpa, in_bytes);
    scanner.enableDiagnostics(&js_diag);

    var out: std.Io.Writer.Allocating = .init(gpa);
    errdefer out.deinit();

    var c: Converter = .{
        .gpa = gpa,
        .code = in_bytes,
        .tokenizer = &scanner,
        .json_diag = &js_diag,
        .diagnostic = diag,
        .schema = schema,
        .out = &out.writer,
    };

    try c.convertJsonValue(try c.next(), schema.root);

    return try out.toOwnedSlice();
}

const Converter = struct {
    gpa: std.mem.Allocator,
    code: [:0]const u8,
    tokenizer: *std.json.Scanner,
    json_diag: *std.json.Diagnostics,
    diagnostic: ?*Diagnostic,
    schema: ziggy.schema.Schema,
    out: *Writer,

    fn jsonSel(p: Converter) Token.Loc.Selection {
        const start: Token.Loc.Selection.Position = .{
            .line = @intCast(p.json_diag.getLine()),
            .col = @intCast(p.json_diag.getColumn()),
        };

        const end: Token.Loc.Selection.Position = .{
            .line = start.line,
            .col = start.col + 1,
        };
        return .{ .start = start, .end = end };
    }

    fn next(p: *Converter) !std.json.Token {
        return p.tokenizer.next() catch |err| {
            return p.addError(.{
                .syntax = .{ .name = @errorName(err), .sel = p.jsonSel() },
            });
        };
    }

    pub fn addError(p: *Converter, err: Diagnostic.Error) Diagnostic.Error.ZigError {
        if (p.diagnostic) |d| {
            try d.errors.append(p.gpa, err);
        }
        return err.zigError();
    }

    fn convertJsonValue(
        c: *Converter,
        token: std.json.Token,
        rule: ziggy.schema.Schema.Rule,
    ) anyerror!void {
        var sub_rule = rule;
        const r = c.schema.nodes[rule.node];
        if (r.tag == .optional) {
            if (token == .null) {
                try c.out.writeAll("null");
                return;
            }
            sub_rule = .{ .node = r.first_child_id };
        }
        switch (token) {
            else => @panic("TODO"),
            .object_end, .array_end => unreachable,
            .object_begin => try c.convertJsonObject(sub_rule),
            .array_begin => try c.convertJsonArray(sub_rule),
            .string => |s| try c.convertJsonString(s, sub_rule),
            .number => |n| try c.convertJsonNumber(n, sub_rule),
            .true, .false => try c.convertJsonBool(token, sub_rule),
            .null => {
                const rule_src = c.schema.nodes[r.first_child_id].loc.src(c.schema.code);
                return c.addError(.{
                    .type_mismatch = .{
                        .name = "json_null",
                        .sel = c.jsonSel(),
                        .expected = rule_src,
                    },
                });
            },
        }
    }

    fn convertJsonObject(c: *Converter, rule: ziggy.schema.Schema.Rule) !void {
        const r = c.schema.nodes[rule.node];
        const rule_src = r.loc.src(c.schema.code);
        const child_rule_id = if (r.tag == .any) rule.node else r.first_child_id;
        switch (r.tag) {
            .optional => unreachable,
            .map, .any, .unknown => {
                try c.out.writeAll("{");
                var token = try c.next();
                while (token != .object_end) : (token = try c.next()) {
                    try c.out.print("\"{f}\":", .{
                        std.zig.fmtString(token.string),
                    });
                    try c.convertJsonValue(
                        try c.next(),
                        .{ .node = child_rule_id },
                    );
                    try c.out.writeAll(",");
                }
                try c.out.writeAll("}");
            },
            .identifier => {
                const struct_rule = c.schema.structs.get(rule_src).?; // must be present

                // Duplicates are checked by the JSON parser, so only
                // missing non-optional fields remain to check.
                var seen_fields = std.StringHashMap(void).init(c.gpa);
                defer seen_fields.deinit();

                try c.out.writeAll("{");
                var token = try c.next();
                while (token != .object_end) : (token = try c.next()) {
                    // TODO: would be nice to output the unescaped string
                    //       directly into our output buffer.
                    // const k = try std.json.parseFromSliceLeaky([]const u8, c.gpa, token.string, .{});
                    const k = token.string;

                    // TODO: we actually want to frist re-escape the string
                    //       using our syntax before checking for it.
                    const field = struct_rule.fields.get(k) orelse {
                        return c.addError(.{
                            .unknown_field = .{
                                .name = k,
                                .sel = c.jsonSel(),
                            },
                        });
                    };

                    try seen_fields.putNoClobber(k, {});

                    try c.out.print(".{f}=", .{std.zig.fmtId(k)});
                    try c.convertJsonValue(try c.next(), field.rule);
                    try c.out.writeAll(",");
                }

                // ensure all missing keys are optional
                for (struct_rule.fields.keys(), struct_rule.fields.values()) |k, v| {
                    if (seen_fields.contains(k)) continue;
                    if (c.schema.nodes[v.rule.node].tag != .optional) {
                        return c.addError(.{
                            .missing_field = .{
                                .name = k,
                                .sel = c.jsonSel(),
                            },
                        });
                    }
                }
                try c.out.writeAll("}");
            },
            .struct_union => {
                // TODO: implement more strategies

                //Tag-is-only-field strategy.
                //Example layout (remote and local are tag names):
                //{
                //   "foo": { "remote": {"url": "...", hash: "..."}},
                //   "bar": { "local":  {"path": "..."}},
                //}
                const key = (try c.next()).string;
                const key_sel = c.jsonSel();
                var ident_rule_id = r.first_child_id;

                while (ident_rule_id != 0) {
                    const ident = c.schema.nodes[ident_rule_id];
                    const ident_src = ident.loc.src(c.schema.code);

                    if (std.mem.eql(u8, ident_src, key)) {
                        const token = try c.next();
                        if (token != .object_begin) {
                            return c.addError(.{
                                .type_mismatch = .{
                                    .name = @tagName(token),
                                    .sel = c.jsonSel(),
                                    .expected = rule_src,
                                },
                            });
                        }

                        try c.out.writeAll(key);
                        try c.convertJsonObject(.{ .node = ident_rule_id });
                        const end = try c.next();
                        if (end != .object_end) {
                            return c.addError(.{
                                .type_mismatch = .{
                                    .name = "json_multikey_object",
                                    .sel = c.jsonSel(),
                                    .expected = rule_src,
                                },
                            });
                        }
                        break;
                    }

                    ident_rule_id = ident.next_id;
                } else {
                    return c.addError(.{
                        .unknown_struct_name = .{
                            .name = key,
                            .sel = key_sel,
                            .expected = rule_src,
                        },
                    });
                }
            },
            else => {
                return c.addError(.{
                    .type_mismatch = .{
                        .name = "json_object",
                        .sel = c.jsonSel(),
                        .expected = rule_src,
                    },
                });
            },
        }
    }

    fn convertJsonArray(
        c: *Converter,
        rule: ziggy.schema.Schema.Rule,
    ) !void {
        const r = c.schema.nodes[rule.node];
        const rule_src = r.loc.src(c.schema.code);
        const child_rule_id = if (r.tag == .any) rule.node else r.first_child_id;
        switch (r.tag) {
            .optional => unreachable,
            .array, .any => {
                try c.out.writeAll("[");
                var token = try c.next();
                while (token != .array_end) : (token = try c.next()) {
                    try c.convertJsonValue(token, .{ .node = child_rule_id });
                    try c.out.writeAll(",");
                }
                try c.out.writeAll("]");
            },
            else => {
                return c.addError(.{
                    .type_mismatch = .{
                        .name = "json_array",
                        .sel = c.jsonSel(),
                        .expected = rule_src,
                    },
                });
            },
        }
    }

    fn convertJsonString(
        c: *Converter,
        str: []const u8,
        rule: ziggy.schema.Schema.Rule,
    ) !void {
        const r = c.schema.nodes[rule.node];
        const rule_src = r.loc.src(c.schema.code);
        switch (r.tag) {
            .optional => unreachable,
            .bytes, .any, .unknown => {
                try c.out.print("\"{f}\"", .{std.zig.fmtString(str)});
            },
            .tag => {
                try c.out.print("{s}(\"{f}\")", .{
                    rule_src,
                    std.zig.fmtString(str),
                });
            },
            else => {
                return c.addError(.{
                    .type_mismatch = .{
                        .name = "json_string",
                        .sel = c.jsonSel(),
                        .expected = rule_src,
                    },
                });
            },
        }
    }

    fn convertJsonNumberString(
        c: *Converter,
        ns: []const u8,
        rule: ziggy.schema.Schema.Rule,
    ) !void {
        const r = c.schema.nodes[rule.node];
        const rule_src = r.loc.src(c.schema.code);
        switch (r.tag) {
            .optional => unreachable,
            .int, .float, .any, .unknown => {
                try c.out.print("{s}", .{ns});
            },
            else => {
                return c.addError(.{
                    .type_mismatch = .{
                        .name = "json_number_string",
                        .loc = c.jsonSel(),
                        .expected = rule_src,
                    },
                });
            },
        }
    }

    fn convertJsonNumber(
        c: *Converter,
        num: []const u8,
        rule: ziggy.schema.Schema.Rule,
    ) !void {
        const r = c.schema.nodes[rule.node];
        const rule_src = r.loc.src(c.schema.code);
        switch (r.tag) {
            .optional => unreachable,
            .int, .float, .any, .unknown => {
                try c.out.print("{s}", .{num});
            },
            else => {
                return c.addError(.{
                    .type_mismatch = .{
                        .name = "json_number",
                        .sel = c.jsonSel(),
                        .expected = rule_src,
                    },
                });
            },
        }
    }

    fn convertJsonBool(
        c: *Converter,
        token: std.json.Token,
        rule: ziggy.schema.Schema.Rule,
    ) !void {
        assert(token == .true or token == .false);
        const r = c.schema.nodes[rule.node];
        const rule_src = r.loc.src(c.schema.code);
        switch (r.tag) {
            .optional => unreachable,
            .bool, .any, .unknown => {
                try c.out.print("{t}", .{token});
            },
            else => {
                return c.addError(.{
                    .type_mismatch = .{
                        .name = "json_bool",
                        .sel = c.jsonSel(),
                        .expected = rule_src,
                    },
                });
            },
        }
    }
};
