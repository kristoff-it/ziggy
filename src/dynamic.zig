const std = @import("std");
const Allocator = std.mem.Allocator;
const assert = std.debug.assert;
const Writer = std.Io.Writer;
const Tokenizer = @import("Tokenizer.zig");
const Token = Tokenizer.Token;
const Serializer = @import("Serializer.zig");
const Deserializer = @import("Deserializer.zig");
const deserializeLeaky = @import("root.zig").deserializeLeaky;

/// A type capable of deserializing from, and serializing to, any Zig Document.
pub const Dynamic = union(enum) {
    /// Used to deserialize Ziggy dictionaries and structs, see `kv.container_kind`.
    kv: Dictionary(Dynamic),
    @"union": struct {
        tag: []const u8,
        value: *Dynamic,
    },
    @"enum": []const u8,
    array: []const Dynamic,
    bytes: []const u8,
    integer: i64,
    float: f64,
    bool: bool,
    null,

    pub const ziggy_options = struct {
        pub fn serialize(
            s: *const Serializer,
            value: Dynamic,
            indent_level: usize,
            depth: usize,
        ) !void {
            const w = s.writer;
            const opts = s.opts;
            switch (value) {
                inline .bool, .integer, .float => |b| try w.print("{}", .{b}),
                .null => try w.writeAll("null"),
                .bytes => |b| try w.print(
                    "\"{}\"",
                    .{std.zig.fmtEscapes(b)},
                ),
                .@"enum" => |tag| try w.print(
                    ".{s}",
                    .{tag},
                ),
                .@"union" => |un| {
                    try w.print(".{s}(", .{un.tag});
                    try un.value.ziggy_options.serialize(
                        un.value.*,
                        opts,
                        indent_level,
                        depth,
                        w,
                    );
                    try w.writeAll(")");
                },
                .kv => |kv| try Dictionary(Dynamic).ziggy_options.serialize(
                    kv,
                    opts,
                    indent_level,
                    depth,
                    w,
                ),
                .array => |array| {
                    try w.writeAll("[");
                    for (array, 0..) |e, idx| {
                        try e.ziggy_options.serialize(e, opts, indent_level, depth, w);
                        if (idx < array.len - 1) {
                            try w.writeAll(", ");
                        }
                    }
                    try w.writeAll("]");
                },
            }
        }

        pub fn deserialize(
            d: *const Deserializer,
            first: Token,
            top_lvl: bool,
        ) Deserializer.Error!Dynamic {
            switch (first.tag) {
                .null => return .null,
                .true => return .{ .bool = true },
                .false => return .{ .bool = false },
                .integer => return .{
                    .integer = try d.deserializeOne(i64, first, false),
                },
                .float => return .{
                    .float = try d.deserializeOne(f64, first, false),
                },
                .bytes, .bytes_line => return .{
                    .bytes = try d.deserializeOne([]const u8, first, false),
                },
                .identifier, .dotlb, .lb => return .{
                    .kv = try d.deserializeOne(Dictionary(Dynamic), first, top_lvl),
                },
                .@"enum" => return .{ .@"enum" = first.loc.slice(d.src)[1..] },
                .union_case => return .{
                    .tag = blk: {
                        const raw = first.loc.slice(d.src)[1..]; // skip '.'
                        break :blk raw[0 .. raw.len - 1]; // skip '('
                    },
                    .value = try d.deserializeOne(*Dynamic, d.next(), false),
                },
                .lsb => {
                    return .{
                        .array = try d.deserializeOne([]const Dynamic, first, false),
                    };
                },
                else => return d.unexpected(first),
            }
        }
    };
};

/// Thin wrapper over std.StringArrayHashMapUnmanaged
pub fn Dictionary(comptime T: type) type {
    return struct {
        container_kind: enum { @"struct", dict } = .@"struct",
        fields: std.StringArrayHashMapUnmanaged(T) = .empty,

        const Self = @This();
        const Child = T;
        pub const ziggy_options = struct {
            pub fn deserialize(
                d: *const Deserializer,
                first: Token,
                top_lvl: bool,
            ) Deserializer.Error!Self {
                var result: Self = .{};
                var field_token = if (top_lvl and first.tag == .identifier)
                    first
                else switch (first.tag) {
                    .eod, .eof => {
                        d.meta.doc = .{ .lines = d.tokenizer.lines, .end = first.loc.end };
                        return if (top_lvl) result else d.unexpected(first);
                    },
                    .lb => return deserializeDict(d, first),
                    .dotlb => blk: {
                        const tok = d.next();
                        if (tok.tag != .identifier) return d.unexpected(tok);
                        break :blk tok;
                    },
                    else => return d.unexpected(first),
                };

                assert(field_token.tag == .identifier);
                while (true) {
                    switch (field_token.tag) {
                        .identifier => {},
                        .rb, .eod, .eof => {
                            if (first.tag == .identifier) switch (field_token.tag) {
                                // braceless top lvl struct
                                .eof => {},
                                .eod => d.meta.doc = .{
                                    .lines = d.tokenizer.lines,
                                    .end = field_token.loc.end,
                                },
                                else => return d.unexpected(field_token),
                            } else switch (field_token.tag) {
                                .rb => {},
                                else => return d.unexpected(field_token),
                            }
                            return result;
                        },
                        else => return d.unexpected(field_token),
                    }
                    const name = field_token.loc.slice(d.src)[1..]; // skip '.'

                    const eql = d.next();
                    if (eql.tag != .eql) return d.unexpected(eql);

                    const gop = try result.fields.getOrPut(d.gpa, name);
                    if (gop.found_existing) return d.duplicateField(field_token);
                    gop.value_ptr.* = try d.deserializeOne(T, d.next(), false);
                    if (d.peek() == .comma) _ = d.next();
                    field_token = d.next();
                    continue;
                }
                comptime unreachable;
            }

            fn deserializeDict(
                d: *const Deserializer,
                first: Token,
            ) Deserializer.Error!Self {
                assert(first.tag == .lb);
                var result: Self = .{ .container_kind = .dict };
                var field_token = d.next();
                while (true) {
                    switch (field_token.tag) {
                        .bytes => {},
                        .rb => return result,
                        else => return d.unexpected(field_token),
                    }

                    const name = blk: {
                        const raw = field_token.loc.slice(d.src)[1..]; // skip first '"'
                        break :blk raw[0 .. raw.len - 1]; // skip second '"'
                    };

                    const colon = d.next();
                    if (colon.tag != .colon) return d.unexpected(colon);

                    const gop = try result.fields.getOrPut(d.gpa, name);
                    if (gop.found_existing) return d.duplicateField(field_token);
                    gop.value_ptr.* = try d.deserializeOne(T, d.next(), false);
                    if (d.peek() == .comma) _ = d.next();
                    field_token = d.next();
                    continue;
                }
                comptime unreachable;
            }

            pub fn serialize(
                s: *const Serializer,
                value: Self,
                indent_level: usize,
                depth: usize,
            ) !void {
                const w = s.writer;
                const opts = s.opts;

                const omit_curlies = opts.omit_top_level_curlies and depth == 0;
                const indent = if (omit_curlies) indent_level else indent_level + 1;
                const item_count = value.fields.count();

                switch (value.container_kind) {
                    .@"struct" => if (!omit_curlies) try w.writeAll(".{"),
                    .dict => try w.writeAll("{"),
                }
                if (!omit_curlies) try s.indent(indent);

                var idx: usize = 1;
                var fields_it = value.fields.iterator();
                switch (value.container_kind) {
                    .@"struct" => {
                        while (fields_it.next()) |entry| : (idx += 1) {
                            if (opts.whitespace == .minified) {
                                try w.print(".{s}=", .{entry.key_ptr.*});
                            } else {
                                try w.print(".{s} = ", .{entry.key_ptr.*});
                            }
                            try s.serializeOne(entry.value_ptr.*, indent, depth + 1);

                            if (idx < item_count) {
                                try w.writeAll(",");
                                try s.indent(indent);
                            }
                        }
                    },
                    .dict => {
                        while (fields_it.next()) |entry| : (idx += 1) {
                            if (opts.whitespace == .minified) {
                                try w.print("\"{s}\":", .{entry.key_ptr.*});
                            } else {
                                try w.print("\"{s}\": ", .{entry.key_ptr.*});
                            }
                            try s.serializeOne(entry.value_ptr.*, indent, depth + 1);
                            if (idx < item_count) {
                                try w.writeAll(",");
                                try s.indent(indent);
                            }
                        }
                    },
                }
                if (!omit_curlies) {
                    if (item_count > 0 and opts.whitespace != .minified) try w.writeAll(",");
                    try s.indent(indent_level);
                    try w.writeAll("}");
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

    var arena_state = std.heap.ArenaAllocator.init(std.testing.allocator);
    defer arena_state.deinit();
    const arena = arena_state.allocator();

    var meta: Deserializer.Meta = .init;
    var result = try deserializeLeaky(Dictionary(usize), arena, case, &meta, .{});
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

    var arena_state = std.heap.ArenaAllocator.init(std.testing.allocator);
    defer arena_state.deinit();
    const arena = arena_state.allocator();

    var meta: Deserializer.Meta = .init;
    var result = try deserializeLeaky(Dictionary([]const u8), arena, case, &meta, .{});
    try std.testing.expectEqualStrings("bar", result.fields.get("foo").?);
    try std.testing.expectEqualStrings("baz", result.fields.get("bar").?);
}

test "map + union" {
    const case =
        \\.name = "zine",
        \\.dependencies = {
        \\    "gfm":  .remote(.{
        \\        .url = "https://github.com",
        \\        .hash = "123...",
        \\    }),
        \\    "super":  .local(.{
        \\        .path = "../super"
        \\    }),
        \\},
    ;

    const Project = struct {
        name: []const u8,
        dependencies: Dictionary(Dependency),
        pub const Dependency = union(enum) {
            remote: struct {
                url: []const u8,
                hash: []const u8,
            },
            local: struct {
                path: []const u8,
            },
        };
    };

    var arena_state = std.heap.ArenaAllocator.init(std.testing.allocator);
    defer arena_state.deinit();
    const arena = arena_state.allocator();

    var meta: Deserializer.Meta = .init;
    var result = try deserializeLeaky(Project, arena, case, &meta, .{});

    const gfm = result.dependencies.fields.get("gfm") orelse return error.Missing;
    try std.testing.expect(gfm == .remote);
    try std.testing.expectEqualStrings("https://github.com", gfm.remote.url);
    try std.testing.expectEqualStrings("123...", gfm.remote.hash);
    const super = result.dependencies.fields.get("super") orelse return error.Missing;
    try std.testing.expect(super == .local);
    try std.testing.expectEqualStrings("../super", super.local.path);
}

test "map + union stringify" {
    const case =
        \\.name = "zine",
        \\.dependencies = {
        \\    "gfm": .remote(.{
        \\        .url = "https://github.com",
        \\        .hash = "123...",
        \\    }),
        \\    "super": .local(.{
        \\        .path = "../super",
        \\    }),
        \\},
    ;

    const Project = struct {
        name: []const u8,
        dependencies: Dictionary(Dependency),
        pub const Dependency = union(enum) {
            remote: struct {
                url: []const u8,
                hash: []const u8,

                const Self = @This();
                pub const ziggy_options = struct {
                    pub fn serialize(
                        s: *const Serializer,
                        value: Self,
                        indent_level: usize,
                        depth: usize,
                    ) !void {
                        const w = s.writer;
                        const opts = s.opts;

                        const omit_curlies = opts.omit_top_level_curlies and depth == 0;
                        const indent = if (omit_curlies) indent_level else indent_level + 1;
                        if (!omit_curlies) {
                            try w.writeAll(".{");
                            try s.indent(indent);
                        }
                        if (opts.whitespace == .minified) {
                            try w.writeAll(".url=");
                        } else {
                            try w.writeAll(".url = ");
                        }
                        try s.serializeOne(value.url, indent, depth + 1);
                        if (opts.whitespace == .minified) {
                            try w.writeAll(",");
                        } else {
                            try w.writeAll(",");
                            try s.indent(indent);
                        }
                        if (opts.whitespace == .minified) {
                            try w.writeAll(".hash=");
                        } else {
                            try w.writeAll(".hash = ");
                        }
                        try s.serializeOne(value.hash, indent, depth + 1);
                        if (!omit_curlies) {
                            if (opts.whitespace != .minified) try w.writeAll(",");
                            try s.indent(indent_level);
                            try w.writeAll("}");
                        }
                    }
                };
            },
            local: struct {
                path: []const u8,
            },
        };
    };

    var deps: Dictionary(Project.Dependency) = .{ .container_kind = .dict };
    defer deps.fields.deinit(std.testing.allocator);
    try deps.fields.put(
        std.testing.allocator,
        "gfm",
        .{
            .remote = .{
                .url = "https://github.com",
                .hash = "123...",
            },
        },
    );
    try deps.fields.put(
        std.testing.allocator,
        "super",
        .{
            .local = .{
                .path = "../super",
            },
        },
    );
    const proj: Project = .{
        .name = "zine",
        .dependencies = deps,
    };
    var out: Writer.Allocating = .init(std.testing.allocator);
    defer out.deinit();

    try Serializer.serialize(proj, .{ .whitespace = .space_4 }, &out.writer);
    try std.testing.expectEqualStrings(case, out.written());
}
