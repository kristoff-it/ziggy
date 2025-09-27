const Serializer = @This();

const std = @import("std");
const Io = std.Io;
const log = std.log.scoped(.serizalizer);

opts: Options,
writer: *Io.Writer,

pub const Options = struct {
    whitespace: Whitespace = .space_4,
    emit_null_fields: bool = true,
    omit_top_level_curlies: bool = true,

    pub const Whitespace = enum {
        minified,
        space_1,
        space_2,
        space_4,
        space_8,
        tab,
    };
};

/// Turn a Zig value into a Ziggy Document.
pub fn serialize(value: anytype, opts: Serializer.Options, writer: *Io.Writer) !void {
    var serializer: Serializer = .{ .opts = opts, .writer = writer };
    try serializer.serializeOne(value, 0, 0);
}

/// Should be called only by custom serialization functions in `ziggy_options`.
pub fn serializeOne(
    s: *const Serializer,
    value: anytype,
    indent_level: usize,
    depth: usize,
) Io.Writer.Error!void {
    const w = s.writer;
    const T = @TypeOf(value);
    switch (@typeInfo(T)) {
        .bool,
        .float,
        .int,
        .comptime_float,
        .comptime_int,
        => try w.print("{}", .{value}),
        .null => try w.writeAll("null"),
        .enum_literal => try w.print(".{t}", .{value}),
        .pointer => |ptr| {
            switch (ptr.size) {
                .slice => {
                    switch (ptr.child) {
                        u8 => try s.escapeString(value, indent_level),
                        else => try s.serializeArray(value, indent_level, depth),
                    }
                },
                .one => try s.serializeOne(value.*, indent_level, depth),

                else => @compileError("expected a slice or single pointer, got a many/C pointer '" ++ @typeName(T) ++ "'"),
            }
        },
        .array => |arr| switch (arr.child) {
            u8 => try s.escapeString(&value, indent_level),
            else => try s.serializeArray(value, indent_level, depth),
        },

        .@"enum" => {
            if (@hasDecl(T, "ziggy_options") and @hasDecl(T.ziggy_options, "serialize")) {
                try T.ziggy_options.serialize(s, value, indent_level, depth);
            } else {
                try w.print(".{t}", .{value});
            }
        },

        .@"struct" => {
            if (@hasDecl(T, "ziggy_options") and @hasDecl(T.ziggy_options, "serialize")) {
                try T.ziggy_options.serialize(s, value, indent_level, depth);
            } else {
                try s.serializeStruct(value, indent_level, depth);
            }
        },
        .@"union" => {
            if (@hasDecl(T, "ziggy_options") and @hasDecl(T.ziggy_options, "serialize")) {
                try T.ziggy_options.serialize(s, value, indent_level, depth);
            } else {
                try s.serializeUnion(value, indent_level, depth);
            }
        },

        .optional => {
            if (value) |v| {
                try s.serializeOne(v, indent_level, depth);
            } else {
                try w.writeAll("null");
            }
        },

        else => @panic("TODO: implement support for " ++ @typeName(T)),
    }
}

pub fn indent(s: *const Serializer, level: usize) !void {
    const w = s.writer;

    var char: u8 = ' ';
    const n_chars = level * switch (s.opts.whitespace) {
        .minified => return,
        .space_1 => @as(usize, 1),
        .space_2 => @as(usize, 2),
        .space_4 => @as(usize, 4),
        .space_8 => @as(usize, 8),
        .tab => blk: {
            char = '\t';
            break :blk @as(usize, 1);
        },
    };
    try w.writeAll("\n");
    try w.splatByteAll(char, n_chars);
}

fn escapeString(s: *const Serializer, str: []const u8, indent_level: usize) !void {
    const w = s.writer;
    if (s.opts.whitespace != .minified) {
        if (std.mem.indexOfScalar(u8, str, '\n')) |_| {
            var lines = std.mem.splitScalar(u8, str, '\n');
            while (lines.next()) |line| {
                try w.writeAll("\\\\");
                try w.writeAll(line);
                try s.indent(indent_level);
            }
        } else {
            try w.print("\"{f}\"", .{std.zig.fmtString(str)});
        }
    } else {
        try w.print("\"{f}\"", .{std.zig.fmtString(str)});
    }
}

fn serializeArray(
    s: *const Serializer,
    array: anytype,
    indent_level: usize,
    depth: usize,
) !void {
    const w = s.writer;
    const opts = s.opts;

    try w.writeAll("[");
    switch (opts.whitespace) {
        // no final comma + spaces
        .minified => {
            if (array.len > 0) {
                try s.serializeOne(array[0], 0, depth + 1);
                for (array[1..]) |value| {
                    try w.writeAll(",");
                    try s.serializeOne(value, 0, depth + 1);
                }
            }
        },
        // final comma + newlines
        else => {
            for (array) |value| {
                try s.indent(indent_level + 1);
                try s.serializeOne(value, indent_level + 1, depth + 1);
                try w.writeAll(",");
            }
            try s.indent(indent_level);
        },
    }
    try w.writeAll("]");
}

fn serializeStruct(
    s: *const Serializer,
    strct: anytype,
    indent_level: usize,
    depth: usize,
) !void {
    const w = s.writer;
    const opts = s.opts;
    const omit_curlies = opts.omit_top_level_curlies and depth == 0;
    if (omit_curlies) {
        _ = try s.serializeStructInner(strct, indent_level, depth);
    } else {
        try w.writeAll(".{");
        const any_fields = try s.serializeStructInner(strct, indent_level + 1, depth);
        if (any_fields) try s.indent(indent_level);
        try w.writeAll("}");
    }
}

fn serializeStructInner(
    s: *const Serializer,
    strct: anytype,
    indent_level: usize,
    depth: usize,
) !bool {
    const w = s.writer;
    const opts = s.opts;
    const StructType = @TypeOf(strct);
    const T = @typeInfo(StructType).@"struct";
    const FE = std.meta.FieldEnum(StructType);
    const has_skip_fields: bool = @hasDecl(StructType, "ziggy_options") and @hasDecl(
        StructType.ziggy_options,
        "skip_fields",
    );
    const field_count = blk: {
        var c: usize = 0;
        outer: inline for (T.fields, 0..) |field, idx| {
            if (has_skip_fields) {
                @setEvalBranchQuota(1000);
                const e: FE = @enumFromInt(idx);
                inline for (StructType.ziggy_options.skip_fields) |sf| {
                    if (sf == e) continue :outer;
                }
            }
            switch (@typeInfo(field.type)) {
                .optional => if (opts.emit_null_fields or @field(strct, field.name) != null) {
                    c += 1;
                },
                else => c += 1,
            }
        }
        break :blk c;
    };
    if (T.fields.len > 0) {
        var print_idx: usize = 1;
        blk: {
            if (has_skip_fields) {
                @setEvalBranchQuota(1000);
                const z: FE = @enumFromInt(0);
                inline for (StructType.ziggy_options.skip_fields) |sf| {
                    if (sf == z) break :blk;
                }
            }
            switch (@typeInfo(T.fields[0].type)) {
                .optional => if (!opts.emit_null_fields and @field(strct, T.fields[0].name) == null) break :blk,
                else => {},
            }

            if (indent_level != 0) try s.indent(indent_level);

            try w.print(".{s}", .{T.fields[0].name});
            if (opts.whitespace == .minified) {
                try w.writeAll("=");
            } else {
                try w.writeAll(" = ");
            }
            try s.serializeOne(@field(strct, T.fields[0].name), indent_level, depth + 1);
            if (opts.whitespace != .minified or 1 != field_count) {
                try w.writeAll(",");
            }
            print_idx += 1;
        }

        outer: inline for (T.fields[1..], 2..) |field, idx| {
            // Skip fields mentioned under 'ziggy_options.skip_fields'
            if (has_skip_fields) {
                const skip_fields = StructType.ziggy_options.skip_fields;
                if (@TypeOf(skip_fields) != []const FE) {
                    @compileError("ziggy_options.skip_fields must be a []const std.meta.FieldEnum(T)");
                }

                const sf_idx: FE = @enumFromInt(idx - 1);
                inline for (skip_fields) |sf| { // did you 'pub *var*' skip_fields? (must be 'pub const')
                    if (sf == sf_idx) continue :outer;
                }
            }

            const name = field.name;
            const skip = switch (@typeInfo(field.type)) {
                .optional => if (@field(strct, field.name) == null) !opts.emit_null_fields else false,
                else => false,
            };

            if (!skip) {
                try s.indent(indent_level);
                try w.print(".{s}", .{name});
                if (opts.whitespace == .minified) {
                    try w.writeAll("=");
                } else {
                    try w.writeAll(" = ");
                }
                try s.serializeOne(@field(strct, name), indent_level, depth + 1);
                if (opts.whitespace != .minified or print_idx != field_count) {
                    try w.writeAll(",");
                }
                print_idx += 1;
            }
        }
    }
    return field_count > 0;
}

fn serializeUnion(
    s: *const Serializer,
    un: anytype,
    indent_level: usize,
    depth: usize,
) !void {
    const w = s.writer;
    const U = @typeInfo(@TypeOf(un)).@"union";
    if (U.tag_type == null)
        @compileError("union '" ++ @typeName(@TypeOf(un)) ++ "' must be tagged!");
    // var opts_ = opts;
    // opts_.omit_top_level_curlies = false;
    const at = std.meta.activeTag(un);
    try w.print(".{t}", .{at});
    inline for (U.fields) |field| {
        if (std.mem.eql(u8, field.name, @tagName(at))) {
            if (field.type != void) {
                try w.writeAll("(");
                try s.serializeOne(@field(un, field.name), indent_level, depth + 1);
                try w.writeAll(")");
            }
            break;
        }
    }
}

fn testStringify(value: anytype, opts: Options, expected_output: []const u8) !void {
    var output_buffer: std.ArrayList(u8) = .empty;
    defer output_buffer.deinit(std.testing.allocator);

    var out: Io.Writer.Allocating = .init(std.testing.allocator);
    defer out.deinit();

    try serialize(value, opts, &out.writer);

    const src = try out.toOwnedSliceSentinel(0);
    defer std.testing.allocator.free(src);
    try std.testing.expectEqualStrings(expected_output, src);

    const Ast = @import("Ast.zig");
    const ast = try Ast.init(std.testing.allocator, src, .{});
    defer ast.deinit(std.testing.allocator);
    errdefer for (ast.errors) |err| std.debug.print("{f}\n", .{err.tag});
    try std.testing.expectEqual(0, ast.errors.len);
}

test "basic data types" {
    try testStringify(@as(u32, 100), .{}, "100");
    try testStringify(true, .{}, "true");
}

test "strings" {
    const x: []const u8 = "Hello";
    try testStringify(x, .{ .whitespace = .minified }, "\"Hello\"");
    try testStringify("World!".*, .{ .whitespace = .minified }, "\"World!\"");

    const y: []const u8 = "A string with a \"quote\"";
    try testStringify(y, .{ .whitespace = .minified }, "\"A string with a \\\"quote\\\"\"");

    const z: []const u8 =
        \\Multiline string "
        \\Yay
    ;
    const zesc: []const u8 = "\\\\Multiline string \"\n\\\\Yay\n";
    const mzesc: []const u8 = "\"Multiline string \\\"\\nYay\"";
    try testStringify(
        z,
        .{ .emit_null_fields = false, .whitespace = .space_2 },
        zesc,
    );
    try testStringify(z, .{ .whitespace = .minified }, mzesc);
}

test "arrays, slices" {
    const arr = [3]u32{ 1, 2, 3 };

    try testStringify(arr, .{ .whitespace = .minified }, "[1,2,3]");
    try testStringify(arr, .{ .whitespace = .space_1 },
        \\[
        \\ 1,
        \\ 2,
        \\ 3,
        \\]
    );
    try testStringify(arr, .{ .whitespace = .tab }, "[\n\t1,\n\t2,\n\t3,\n]");

    const slice: []const u32 = &arr;
    try testStringify(slice, .{ .whitespace = .minified }, "[1,2,3]");
    try testStringify(slice, .{ .whitespace = .space_1 },
        \\[
        \\ 1,
        \\ 2,
        \\ 3,
        \\]
    );
    try testStringify(slice, .{ .whitespace = .tab }, "[\n\t1,\n\t2,\n\t3,\n]");
}

test "nested arrays" {
    const arr = [3][2]u32{ .{ 1, 2 }, .{ 3, 4 }, .{ 5, 6 } };
    try testStringify(arr, .{ .whitespace = .minified }, "[[1,2],[3,4],[5,6]]");
    try testStringify(arr, .{ .whitespace = .space_4 },
        \\[
        \\    [
        \\        1,
        \\        2,
        \\    ],
        \\    [
        \\        3,
        \\        4,
        \\    ],
        \\    [
        \\        5,
        \\        6,
        \\    ],
        \\]
    );
}

test "arrays of strings" {
    const arr = [3][]const u8{ "Ala", "ma", "kota" };
    try testStringify(arr, .{ .whitespace = .minified }, "[\"Ala\",\"ma\",\"kota\"]");
    try testStringify(arr, .{ .whitespace = .space_1 },
        \\[
        \\ "Ala",
        \\ "ma",
        \\ "kota",
        \\]
    );

    const lfarr = [2][]const u8{ "Hello\nWorld", "The\nspace" };
    try testStringify(lfarr, .{ .whitespace = .minified }, "[\"Hello\\nWorld\",\"The\\nspace\"]");
    try testStringify(lfarr, .{ .whitespace = .space_2 },
        \\[
        \\  \\Hello
        \\  \\World
        \\  ,
        \\  \\The
        \\  \\space
        \\  ,
        \\]
    );
}

test "simple struct" {
    const S = struct {
        a: u32,
        b: bool,
        c: ?i16,
    };

    const v: S = .{ .a = 10, .b = false, .c = null };
    try testStringify(v, .{ .whitespace = .minified }, ".a=10,.b=false,.c=null");
    try testStringify(v, .{ .whitespace = .minified, .emit_null_fields = false }, ".a=10,.b=false");
    try testStringify(v, .{ .whitespace = .space_1 },
        \\.a = 10,
        \\.b = false,
        \\.c = null,
    );
    try testStringify(v, .{ .whitespace = .space_1, .omit_top_level_curlies = false },
        \\.{
        \\ .a = 10,
        \\ .b = false,
        \\ .c = null,
        \\}
    );
}

test "struct with array" {
    const S = struct {
        a: [2]u16,
        b: bool,
    };

    const v: S = .{ .a = .{ 1, 2 }, .b = true };

    try testStringify(v, .{ .whitespace = .minified }, ".a=[1,2],.b=true");
    try testStringify(v, .{ .whitespace = .space_2, .omit_top_level_curlies = false },
        \\.{
        \\  .a = [
        \\    1,
        \\    2,
        \\  ],
        \\  .b = true,
        \\}
    );
}

test "nested struct" {
    const S = struct {
        a: struct {
            b: bool,
        },
        c: u8,
    };
    const v: S = .{ .a = .{ .b = false }, .c = 0 };

    try testStringify(v, .{ .whitespace = .minified }, ".a=.{.b=false},.c=0");
    try testStringify(v, .{ .whitespace = .minified, .omit_top_level_curlies = false }, ".{.a=.{.b=false},.c=0}");
    try testStringify(v, .{ .whitespace = .space_4 },
        \\.a = .{
        \\    .b = false,
        \\},
        \\.c = 0,
    );
}

test "union" {
    const U = union(enum) {
        local: struct {
            path: []const u8,
        },
        remote: struct {
            url: []const u8,
            hash: []const u8,
        },
    };

    const S = struct {
        deps: []const U,
    };

    const v: S = .{
        .deps = &.{
            .{
                .local = .{ .path = "../zine" },
            },
            .{
                .remote = .{
                    .url = "github.com",
                    .hash = "0xAA",
                },
            },
        },
    };

    try testStringify(
        v,
        .{ .whitespace = .minified },
        ".deps=[.local(.{.path=\"../zine\"}),.remote(.{.url=\"github.com\",.hash=\"0xAA\"})]",
    );
    try testStringify(v, .{ .whitespace = .space_1 },
        \\.deps = [
        \\ .local(.{
        \\  .path = "../zine",
        \\ }),
        \\ .remote(.{
        \\  .url = "github.com",
        \\  .hash = "0xAA",
        \\ }),
        \\],
    );
    try testStringify(v, .{ .whitespace = .space_1, .omit_top_level_curlies = false },
        \\.{
        \\ .deps = [
        \\  .local(.{
        \\   .path = "../zine",
        \\  }),
        \\  .remote(.{
        \\   .url = "github.com",
        \\   .hash = "0xAA",
        \\  }),
        \\ ],
        \\}
    );
}

test "non struct union" {
    const U = union(enum) {
        foo: []const u8,
        bar: usize,
    };

    const v: U = .{ .foo = "hello" };
    const z: U = .{ .bar = 123 };
    const q: []const U = &.{ v, z };

    try testStringify(q, .{ .whitespace = .space_2 },
        \\[
        \\  .foo("hello"),
        \\  .bar(123),
        \\]
    );
}

test "simple struct + skip fields" {
    const S = struct {
        a: u32,
        b: bool,
        c: ?i16,

        const S = @This();
        pub const ziggy_options = struct {
            pub const skip_fields: []const std.meta.FieldEnum(S) = &.{.b};
        };
    };

    const v: S = .{ .a = 10, .b = false, .c = null };
    try testStringify(v, .{ .whitespace = .minified }, ".a=10,.c=null");
    try testStringify(v, .{ .whitespace = .minified, .emit_null_fields = false }, ".a=10");
    try testStringify(v, .{ .whitespace = .space_1 },
        \\.a = 10,
        \\.c = null,
    );
    try testStringify(v, .{ .whitespace = .space_1, .omit_top_level_curlies = false },
        \\.{
        \\ .a = 10,
        \\ .c = null,
        \\}
    );
}
