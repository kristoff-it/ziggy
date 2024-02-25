const std = @import("std");
const assert = std.debug.assert;
const Diagnostic = @import("Diagnostic.zig");
const Parser = @import("Parser.zig");
const Tokenizer = @import("Tokenizer.zig");
const Token = Tokenizer.Token;
const serializer = @import("serializer.zig");

pub const ContainerKind = enum { ziggy_struct, map };

/// Thin wrapper over std.HashMapUnmanaged
pub fn Map(comptime T: type) type {
    return struct {
        kind: ContainerKind,
        data: std.StringHashMapUnmanaged(T),

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
                if (tok.tag == .identifier) {
                    // TODO: check identifier for conformance
                    tok = parser.next();
                    has_identifier = true;
                }

                if (tok.tag == .lb) {
                    tok = parser.next();
                }

                try parser.mustAny(tok, &.{ .dot, .string });

                switch (tok.tag) {
                    else => unreachable,
                    .dot => {
                        const data = try parseFields(
                            parser,
                            .ziggy_struct,
                            tok,
                            need_closing_rb,
                        );
                        return .{
                            .kind = .ziggy_struct,
                            .data = data,
                        };
                    },
                    .string => {
                        if (has_identifier) {
                            if (parser.opts.diagnostic) |d| {
                                d.tok = tok;
                                d.err = .{
                                    .unexpected_token = .{
                                        .expected = &.{.dot},
                                    },
                                };
                            }
                            return error.Syntax;
                        }

                        const data = try parseFields(parser, .map, tok, true);
                        return .{
                            .kind = .map,
                            .data = data,
                        };
                    },
                }
            }

            fn parseFields(
                parser: *Parser,
                kind: ContainerKind,
                first_tok: Token,
                need_closing_rb: bool,
            ) Parser.Error!std.StringHashMapUnmanaged(T) {
                var result: std.StringHashMapUnmanaged(T) = .{};
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
                const item_count = value.data.count();
                if (!omit_curly) {
                    try writer.writeAll("{");
                    try serializer.indent(opts.whitespace, indent, writer);
                }
                var data_it = value.data.iterator();
                var idx: usize = 1;
                switch (value.kind) {
                    .ziggy_struct => {
                        while (data_it.next()) |entry| : (idx += 1) {
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
                        while (data_it.next()) |entry| : (idx += 1) {
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
    defer result.data.deinit(std.testing.allocator);

    try std.testing.expectEqual(1, result.data.get("foo"));
    try std.testing.expectEqual(2, result.data.get("bar"));
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
    defer result.data.deinit(std.testing.allocator);

    try std.testing.expectEqualStrings("bar", result.data.get("foo").?);
    try std.testing.expectEqualStrings("baz", result.data.get("bar").?);
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
    defer result.dependencies.data.deinit(std.testing.allocator);
    const gfm = result.dependencies.data.get("gfm") orelse return error.Missing;
    try std.testing.expect(gfm == .Remote);
    try std.testing.expectEqualStrings("https://github.com", gfm.Remote.url);
    try std.testing.expectEqualStrings("123...", gfm.Remote.hash);
    const super = result.dependencies.data.get("super") orelse return error.Missing;
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

    var deps: Map(Project.Dependency) = .{ .kind = .map, .data = .{} };
    defer deps.data.deinit(std.testing.allocator);
    try deps.data.put(
        std.testing.allocator,
        "gfm",
        .{
            .Remote = .{
                .url = "https://github.com",
                .hash = "123...",
            },
        },
    );
    try deps.data.put(
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
