const std = @import("std");
const assert = std.debug.assert;
const Diagnostic = @import("Diagnostic.zig");
const Parser = @import("Parser.zig");
const Tokenizer = @import("Tokenizer.zig");
const Token = Tokenizer.Token;
const serializer = @import("serializer.zig");

pub const Value = union(enum) {
    kv: Map(Value),
    array: []const Value,
    tag: Tag,
    bytes: []const u8,
    integer: i64,
    float: f64,
    bool: bool,
    null,

    pub const Tag = struct { name: []const u8, bytes: []const u8 };

    pub const ziggy_options = struct {
        pub fn stringify(
            value: Value,
            opts: serializer.StringifyOptions,
            indent_level: usize,
            depth: usize,
            writer: anytype,
        ) !void {
            switch (value) {
                .bytes => |b| try writer.print("\"{}\"", .{std.zig.fmtEscapes(b)}),
                .tag => |tag| try writer.print("@{s}(\"{}\")", .{ tag.name, std.zig.fmtEscapes(tag.bytes) }),
                .kv => |kv| try Map(Value).ziggy_options.stringify(kv, opts, indent_level, depth, writer),
                inline .bool, .integer, .float => |b| try writer.print("{}", .{b}),
                .null => try writer.writeAll("null"),
                .array => |array| {
                    try writer.writeAll("[");
                    for (array, 0..) |e, idx| {
                        try e.ziggy_options.stringify(e, opts, indent_level, depth, writer);
                        if (idx < array.len - 1) {
                            try writer.writeAll(", ");
                        }
                    }
                    try writer.writeAll("]");
                },
            }
        }

        pub fn parse(p: *Parser, first: Token) Parser.Error!Value {
            switch (first.tag) {
                .null => return .null,
                .true, .false => return .{ .bool = try p.parseBool(first) },
                .integer => return .{ .integer = try p.parseInt(i64, first) },
                .float => return .{ .float = try p.parseFloat(f64, first) },
                .string, .line_string => return .{ .bytes = try p.parseBytes([]const u8, first) },
                .at => {
                    const name = try p.nextMust(.identifier);
                    _ = try p.nextMust(.lp);
                    const str = try p.nextMust(.string);
                    _ = try p.nextMust(.rp);
                    return .{
                        .tag = .{
                            .name = name.loc.src(p.code),
                            .bytes = try str.loc.unescape(p.gpa, p.code),
                        },
                    };
                },

                .identifier, .dot, .lb => {
                    return .{ .kv = try Map(Value).ziggy_options.parse(p, first) };
                },

                .lsb => {
                    var array = std.ArrayList(Value).init(p.gpa);
                    errdefer array.deinit();
                    var elem_tok = try p.nextNoEof();
                    while (elem_tok.tag != .rsb) {
                        const new = try array.addOne();
                        new.* = try Value.ziggy_options.parse(p, elem_tok);

                        elem_tok = try p.nextMustAny(&.{ .comma, .rsb });
                        if (elem_tok.tag == .comma) {
                            elem_tok = p.next();
                        }
                    }
                    return .{ .array = try array.toOwnedSlice() };
                },
                else => {
                    return p.addError(.{
                        .syntax = .{
                            .name = first.loc.src(p.code),
                            .sel = first.loc.getSelection(p.code),
                        },
                    });
                },
            }
        }
    };
};

pub const ContainerKind = union(enum) {
    /// Contains the struct name, if present
    ziggy_struct: ?[]const u8,
    map,
};

/// Thin wrapper over std.StringArrayHashMapUnmanaged
pub fn Map(comptime T: type) type {
    return struct {
        kind: ContainerKind = .map,
        fields: std.StringArrayHashMapUnmanaged(T) = .{},

        const Self = @This();
        pub const ziggy_options = struct {
            pub fn parse(
                parser: *Parser,
                first_tok: Token,
            ) Parser.Error!Self {
                // When a top-level struct omits curlies, the first
                // token will be a dot. Is such case we don't want
                // to expect a closing right bracket.
                const need_closing_rb = first_tok.tag != .dot;

                var has_identifier = false;
                var tok = first_tok;
                var struct_name: ?[]const u8 = null;
                if (tok.tag == .identifier) {
                    struct_name = tok.loc.src(parser.code);
                    tok = parser.next();
                    has_identifier = true;
                }

                if (tok.tag == .lb) {
                    tok = parser.next();
                }

                try parser.mustAny(tok, &.{ .dot, .string, .rb });

                switch (tok.tag) {
                    else => unreachable,
                    .rb => return .{},
                    .dot => {
                        const fields = try parseFields(
                            parser,
                            .{ .ziggy_struct = struct_name },
                            tok,
                            need_closing_rb,
                        );
                        return .{
                            .kind = .{ .ziggy_struct = struct_name },
                            .fields = fields,
                        };
                    },
                    .string => {
                        if (has_identifier) {
                            return parser.addError(.{
                                .unexpected = .{
                                    .name = tok.loc.src(parser.code),
                                    .sel = tok.loc.getSelection(parser.code),
                                    .expected = &.{"'.'"},
                                },
                            });
                        }

                        const fields = try parseFields(parser, .map, tok, true);
                        return .{
                            .kind = .map,
                            .fields = fields,
                        };
                    },
                }
            }

            fn parseFields(
                parser: *Parser,
                kind: ContainerKind,
                first_tok: Token,
                need_closing_rb: bool,
            ) Parser.Error!std.StringArrayHashMapUnmanaged(T) {
                var result: std.StringArrayHashMapUnmanaged(T) = .{};
                errdefer result.deinit(parser.gpa);

                var tok = first_tok;
                while (true) {
                    if (need_closing_rb) {
                        try parser.mustAny(tok, &.{ .dot, .string, .rb });
                    } else {
                        try parser.mustAny(tok, &.{ .dot, .string, .eof });
                    }

                    if (tok.tag != .dot and tok.tag != .string) {
                        return result;
                    }

                    const value_ptr = switch (kind) {
                        .ziggy_struct => blk: {
                            try parser.must(tok, .dot);
                            const ident = try parser.nextMust(.identifier);
                            const field_name = ident.loc.src(parser.code);
                            _ = try parser.nextMust(.eql);
                            const gop = try result.getOrPut(parser.gpa, field_name);
                            break :blk gop.value_ptr;
                        },
                        .map => blk: {
                            try parser.must(tok, .string);
                            const field_name = try tok.loc.unescape(parser.gpa, parser.code);
                            _ = try parser.nextMust(.colon);
                            const gop = try result.getOrPut(parser.gpa, field_name);
                            break :blk gop.value_ptr;
                        },
                    };

                    value_ptr.* = try parser.parseValue(T, parser.next());

                    tok = parser.next();
                    if (tok.tag == .comma) {
                        tok = parser.next();
                    } else {
                        if (need_closing_rb) {
                            try parser.mustAny(tok, &.{ .comma, .rb });
                        } else {
                            try parser.mustAny(tok, &.{ .comma, .rb, .eof });
                        }
                    }
                }
            }

            pub fn stringify(
                value: Self,
                opts: serializer.StringifyOptions,
                indent_level: usize,
                depth: usize,
                writer: anytype,
            ) !void {
                const omit_curly = opts.omit_top_level_curly and depth == 0;
                const indent = if (omit_curly) indent_level else indent_level + 1;
                const item_count = value.fields.count();
                if (!omit_curly) {
                    if (value.kind == .ziggy_struct) {
                        if (value.kind.ziggy_struct) |name| {
                            try writer.print("{s} ", .{name});
                        }
                    }
                    try writer.writeAll("{");
                    try serializer.indent(opts.whitespace, indent, writer);
                }
                var fields_it = value.fields.iterator();
                var idx: usize = 1;
                switch (value.kind) {
                    .ziggy_struct => {
                        while (fields_it.next()) |entry| : (idx += 1) {
                            if (opts.whitespace == .minified) {
                                try writer.print(".{s}=", .{entry.key_ptr.*});
                            } else {
                                try writer.print(".{s} = ", .{entry.key_ptr.*});
                            }
                            try serializer.stringifyInner(entry.value_ptr.*, opts, indent, depth + 1, writer);
                            if (idx < item_count) {
                                if (opts.whitespace == .minified) {
                                    try writer.writeAll(",");
                                } else {
                                    try writer.writeAll(",");
                                    try serializer.indent(opts.whitespace, indent, writer);
                                }
                            }
                        }
                    },
                    .map => {
                        while (fields_it.next()) |entry| : (idx += 1) {
                            if (opts.whitespace == .minified) {
                                try writer.print("\"{s}\":", .{entry.key_ptr.*});
                            } else {
                                try writer.print("\"{s}\": ", .{entry.key_ptr.*});
                            }
                            try serializer.stringifyInner(entry.value_ptr.*, opts, indent, depth + 1, writer);
                            if (idx < item_count) {
                                if (opts.whitespace == .minified) {
                                    try writer.writeAll(",");
                                } else {
                                    try writer.writeAll(",");
                                    try serializer.indent(opts.whitespace, indent, writer);
                                }
                            }
                        }
                    },
                }
                if (!omit_curly) {
                    if (item_count > 0 and opts.whitespace != .minified) try writer.writeAll(",");
                    try serializer.indent(opts.whitespace, indent_level, writer);
                    try writer.writeAll("}");
                }
            }
        };
    };
}

test "basics" {
    const case =
        \\.foo = 1,
        \\.bar = 2,
    ;

    var diag: Diagnostic = .{ .path = null };
    const opts: Parser.ParseOptions = .{ .diagnostic = &diag };
    var result = try Parser.parseLeaky(Map(usize), std.testing.allocator, case, opts);
    defer result.fields.deinit(std.testing.allocator);

    try std.testing.expectEqual(1, result.fields.get("foo"));
    try std.testing.expectEqual(2, result.fields.get("bar"));
}

test "basics 2" {
    const case =
        \\{
        \\   "foo": "bar",
        \\   "bar": "baz",    
        \\}
    ;

    var diag: Diagnostic = .{ .path = null };
    const opts: Parser.ParseOptions = .{ .diagnostic = &diag };
    var result = try Parser.parseLeaky(Map([]const u8), std.testing.allocator, case, opts);
    defer result.fields.deinit(std.testing.allocator);

    try std.testing.expectEqualStrings("bar", result.fields.get("foo").?);
    try std.testing.expectEqualStrings("baz", result.fields.get("bar").?);
}

test "map + union" {
    const case =
        \\.name = "zine",
        \\.dependencies = {
        \\    "gfm": Remote {
        \\        .url = "https://github.com",
        \\        .hash = @sha512("123..."),
        \\    },
        \\    "super": Local {
        \\        .path = "../super"
        \\    },
        \\},
    ;

    const Project = struct {
        name: []const u8,
        dependencies: Map(Dependency),
        pub const Dependency = union(enum) {
            Remote: struct {
                url: []const u8,
                hash: []const u8,
            },
            Local: struct {
                path: []const u8,
            },
        };
    };

    var result = try Parser.parseLeaky(Project, std.testing.allocator, case, .{});
    defer result.dependencies.fields.deinit(std.testing.allocator);
    const gfm = result.dependencies.fields.get("gfm") orelse return error.Missing;
    try std.testing.expect(gfm == .Remote);
    try std.testing.expectEqualStrings("https://github.com", gfm.Remote.url);
    try std.testing.expectEqualStrings("123...", gfm.Remote.hash);
    const super = result.dependencies.fields.get("super") orelse return error.Missing;
    try std.testing.expect(super == .Local);
    try std.testing.expectEqualStrings("../super", super.Local.path);
}

test "map + union stringify" {
    const case =
        \\.name = "zine",
        \\.dependencies = {
        \\    "gfm": Remote {
        \\        .url = "https://github.com",
        \\        .hash = @sha512("123..."),
        \\    },
        \\    "super": Local {
        \\        .path = "../super",
        \\    },
        \\},
    ;

    const Project = struct {
        name: []const u8,
        dependencies: Map(Dependency),
        pub const Dependency = union(enum) {
            Remote: struct {
                url: []const u8,
                hash: []const u8,

                const Self = @This();
                pub const ziggy_options = struct {
                    pub fn stringify(
                        value: Self,
                        opts: serializer.StringifyOptions,
                        indent_level: usize,
                        depth: usize,
                        writer: anytype,
                    ) !void {
                        const omit_curly = opts.omit_top_level_curly and depth == 0;
                        const indent = if (omit_curly) indent_level else indent_level + 1;
                        if (!omit_curly) {
                            try writer.writeAll("{");
                            try serializer.indent(opts.whitespace, indent, writer);
                        }
                        if (opts.whitespace == .minified) {
                            try writer.writeAll(".url=");
                        } else {
                            try writer.writeAll(".url = ");
                        }
                        try serializer.stringifyInner(value.url, opts, indent, depth + 1, writer);
                        if (opts.whitespace == .minified) {
                            try writer.writeAll(",");
                        } else {
                            try writer.writeAll(",");
                            try serializer.indent(opts.whitespace, indent, writer);
                        }
                        if (opts.whitespace == .minified) {
                            try writer.writeAll(".hash=@sha512(");
                        } else {
                            try writer.writeAll(".hash = @sha512(");
                        }
                        try serializer.stringifyInner(value.hash, opts, indent, depth + 1, writer);
                        try writer.writeAll(")");

                        if (!omit_curly) {
                            if (opts.whitespace != .minified) try writer.writeAll(",");
                            try serializer.indent(opts.whitespace, indent_level, writer);
                            try writer.writeAll("}");
                        }
                    }
                };
            },
            Local: struct {
                path: []const u8,
            },
        };
    };

    var deps: Map(Project.Dependency) = .{ .kind = .map, .fields = .{} };
    defer deps.fields.deinit(std.testing.allocator);
    try deps.fields.put(
        std.testing.allocator,
        "gfm",
        .{
            .Remote = .{
                .url = "https://github.com",
                .hash = "123...",
            },
        },
    );
    try deps.fields.put(
        std.testing.allocator,
        "super",
        .{
            .Local = .{
                .path = "../super",
            },
        },
    );
    const proj: Project = .{
        .name = "zine",
        .dependencies = deps,
    };
    var output = std.ArrayList(u8).init(std.testing.allocator);
    defer output.deinit();

    try serializer.stringify(proj, .{ .whitespace = .space_4 }, output.writer());
    try std.testing.expectEqualStrings(case, output.items);
}
