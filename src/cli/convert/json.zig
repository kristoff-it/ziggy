const std = @import("std");
const assert = std.debug.assert;
const json = std.json;
const Allocator = std.mem.Allocator;
const Io = std.Io;
const Writer = std.Io.Writer;
const Schema = @import("../convert.zig").Command.Schema;
const ziggy = @import("ziggy");
const Token = ziggy.Tokenizer.Token;
const Ast = ziggy.Ast;
const Node = Ast.Node;

pub const Error = struct {
    loc: ziggy.Tokenizer.Token.Loc, // loc into the json document
    kind: Kind,

    pub const Kind = union(enum) {
        syntax,
        unexpected_end,
        type_mismatch: []const u8, // expected type from schema
        unknown_field,
        missing_field: struct {
            name: []const u8,
            type: []const u8,
        },
    };
};

pub fn toZiggy(
    gpa: Allocator,
    schema: Schema,
    errors: *std.ArrayListUnmanaged(Error),
    in_bytes: [:0]const u8,
) error{OutOfMemory}![]const u8 {
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
        .errors = errors,
        .schema = schema,
        .out = &out.writer,
    };

    const first_token = c.next() catch |err| switch (err) {
        error.OutOfMemory, error.WriteFailed => return error.OutOfMemory,
        error.Json => {
            assert(errors.items.len > 0);
            return;
        },
    };

    c.convertJsonValue(first_token, schema.root) catch |err| switch (err) {
        error.OutOfMemory, error.WriteFailed => return error.OutOfMemory,
        error.Json => {
            assert(errors.items.len > 0);
            return;
        },
    };

    return try out.toOwnedSlice();
}

const Converter = struct {
    gpa: std.mem.Allocator,
    code: [:0]const u8,
    tokenizer: *std.json.Scanner,
    json_diag: *std.json.Diagnostics,
    errors: *std.ArrayListUnmanaged(Error),
    schema: Schema,
    out: *Writer,

    fn convertJsonValue(c: *Converter, token: json.Token, rule: Schema.Rule) !void {
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
                try c.err(.{ .type_mismatch = rule_src });
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
                    try c.out.writeAll(token.string);
                    try c.convertJsonValue(try c.next(), .{ .node = child_rule_id });
                    try c.out.writeAll(",");
                }
                try c.out.writeAll("}");
            },
            .identifier => {
                const struct_rule = c.schema.structs.get(rule_src).?; // must be present

                // Duplicates are checked by the JSON parser, so only
                // missing mandatory fields remain to check.
                var seen_fields = std.StringHashMap(void).init(c.gpa);
                defer seen_fields.deinit();

                try c.out.writeAll(".{");
                var token = try c.next();
                while (token != .object_end) : (token = try c.next()) {
                    const k = token.string;
                    const field = struct_rule.fields.get(k) orelse {
                        try c.addError(.unknown_field);
                        try c.discardOne();
                        continue;
                    };

                    try seen_fields.putNoClobber(k, {});

                    try c.out.print(".{f}=", .{std.zig.fmtId(k)});
                    try c.convertJsonValue(try c.next(), field.rule);
                    try c.out.writeAll(",");
                }

                // ensure all missing keys are omissible
                for (struct_rule.fields.keys(), struct_rule.fields.values()) |k, v| {
                    if (seen_fields.contains(k)) continue;
                    switch (c.schema.nodes[v.rule.node].tag) {
                        .optional, .map, .array => {},
                        else => {
                            return c.addError(.{ .missing_field = k });
                        },
                    }
                }

                try c.out.writeAll("}");
            },
            .struct_union => {
                // TODO: implement more strategies
                if (true) @panic("TODO");

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
                return c.addError(.{ .type_mismatch = rule_src });
            },
        }
    }

    fn convertJsonArray(c: *Converter, rule: Schema.Rule) !void {
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
                return c.addError(.{ .type_mismatch = rule_src });
            },
        }
    }

    fn convertJsonString(c: *Converter, str: []const u8, rule: Schema.Rule) !void {
        const r = c.schema.nodes[rule.node];
        const rule_src = r.loc.src(c.schema.code);
        switch (r.tag) {
            .optional => unreachable,
            .bytes, .any, .unknown => {
                try c.out.writeAll(str);
            },
            else => {
                return c.addError(.{ .type_mismatch = rule_src });
            },
        }
    }

    fn convertJsonNumber(c: *Converter, num: []const u8, rule: Schema.Rule) !void {
        const r = c.schema.nodes[rule.node];
        const rule_src = r.loc.src(c.schema.code);
        switch (r.tag) {
            .optional => unreachable,
            .int, .float, .any, .unknown => {
                try c.out.writeAll(num);
            },
            else => {
                return c.err(.{ .type_mismatch = rule_src });
            },
        }
    }

    fn convertJsonBool(c: *Converter, token: json.Token, rule: Schema.Rule) !void {
        assert(token == .true or token == .false);

        const r = c.schema.nodes[rule.node];
        const rule_src = r.loc.src(c.schema.code);
        switch (r.tag) {
            .optional => unreachable,
            .bool, .any, .unknown => {
                try c.out.writeAll(if (token == .true) "true" else "false");
            },
            else => {
                return c.err(.{ .type_mismatch = rule_src });
            },
        }
    }

    fn next(c: *Converter) error{ OutOfMemory, Json }!std.json.Token {
        return c.tokenizer.next() catch |_err| switch (_err) {
            error.BufferUnderrun => unreachable, // we use initCompleteInput
            error.OutOfMemory => return error.OutOfMemory,
            error.Syntax => {
                try c.errors.append(c.gpa, .{
                    .loc = c.json_diag.getByteOffset(),
                    .kind = .syntax,
                });
                return error.Json;
            },
            error.UnexpectedEndOfInput => {
                try c.errors.append(c.gpa, .{
                    .loc = c.json_diag.getByteOffset(),
                    .kind = .unexpected_end,
                });
                return error.Json;
            },
        };
    }

    fn err(c: *Converter, kind: Error.Kind) error{OutOfMemory}!void {
        try c.errors.append(c.gpa, .{
            .loc = c.json_diag.getByteOffset(),
            .kind = kind,
        });
    }
};
