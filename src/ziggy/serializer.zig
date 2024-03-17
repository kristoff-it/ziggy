const std = @import("std");
const log = std.log.scoped(.serizalizer);

pub const StringifyOptions = struct {
    whitespace: Whitespace = .minified,
    emit_null_fields: bool = true,
    omit_top_level_curly: bool = true,

    pub const Whitespace = enum {
        minified,
        space_1,
        space_2,
        space_4,
        space_8,
        tab,
    };
};

pub fn stringify(value: anytype, opts: StringifyOptions, writer: anytype) !void {
    try stringifyInner(value, opts, 0, 0, writer);
}

pub fn indent(kind: StringifyOptions.Whitespace, level: usize, writer: anytype) !void {
    var char: u8 = ' ';
    const n_chars = level * switch (kind) {
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
    try writer.writeAll("\n");
    try writer.writeByteNTimes(char, n_chars);
}

pub fn stringifyInner(
    value: anytype,
    opts: StringifyOptions,
    indent_level: usize,
    depth: usize,
    writer: anytype,
) @TypeOf(writer).Error!void {
    const T = @TypeOf(value);
    switch (@typeInfo(T)) {
        .Bool,
        .Float,
        .Int,
        .ComptimeFloat,
        .ComptimeInt,
        => try writer.print("{}", .{value}),

        .Pointer => |ptr| {
            switch (ptr.size) {
                .Slice => {
                    switch (ptr.child) {
                        u8 => try escapeString(
                            writer,
                            value,
                            indent_level,
                            opts.whitespace,
                        ),
                        else => try stringifyArray(
                            writer,
                            value,
                            indent_level,
                            depth,
                            opts,
                        ),
                    }
                },
                .One => try stringifyInner(value.*, opts, indent_level, depth, writer),

                else => @compileError("Expected a slice or single pointer. Got a many/C pointer '" ++ @typeName(T) ++ "'"),
            }
        },
        .Array => |arr| switch (arr.child) {
            u8 => try escapeString(writer, &value, indent_level, opts.whitespace),
            else => try stringifyArray(writer, value, indent_level, depth, opts),
        },

        .Null => try writer.writeAll("null"),

        .EnumLiteral => try writer.print("\"{s}\"", .{@tagName(value)}),

        .Enum => {
            if (@hasDecl(T, "ziggy_options") and @hasDecl(T.ziggy_options, "stringify")) {
                try T.ziggy_options.stringify(value, opts, indent_level, depth, writer);
            } else {
                try writer.print("\"{s}\"", .{@tagName(value)});
            }
        },

        .Struct => {
            if (@hasDecl(T, "ziggy_options") and @hasDecl(T.ziggy_options, "stringify")) {
                try T.ziggy_options.stringify(value, opts, indent_level, depth, writer);
            } else {
                try stringifyStruct(writer, value, indent_level, depth, opts);
            }
        },
        .Union => {
            if (@hasDecl(T, "ziggy_options") and @hasDecl(T.ziggy_options, "stringify")) {
                try T.ziggy_options.stringify(value, opts, indent_level, depth, writer);
            } else {
                try stringifyUnion(writer, value, indent_level, depth, opts);
            }
        },

        .Optional => {
            if (value) |v| {
                try stringifyInner(v, opts, indent_level, depth, writer);
            } else {
                try writer.writeAll("null");
            }
        },

        else => @panic("TODO: implement support for " ++ @typeName(T)),
    }
}

fn escapeString(writer: anytype, str: []const u8, indent_level: usize, indent_kind: StringifyOptions.Whitespace) !void {
    if (indent_kind != .minified) {
        if (std.mem.indexOfScalar(u8, str, '\n')) |_| {
            var lines = std.mem.splitScalar(u8, str, '\n');
            while (lines.next()) |line| {
                try writer.writeAll("\\\\");
                try writer.writeAll(line);
                try indent(indent_kind, indent_level, writer);
            }
        } else {
            try writer.print("\"{}\"", .{std.zig.fmtEscapes(str)});
        }
    } else {
        try writer.print("\"{}\"", .{std.zig.fmtEscapes(str)});
    }
}

fn stringifyArray(writer: anytype, array: anytype, indent_level: usize, depth: usize, opts: StringifyOptions) !void {
    try writer.writeAll("[");
    switch (opts.whitespace) {
        // no final comma + spaces
        .minified => {
            if (array.len > 0) {
                try stringifyInner(array[0], opts, 0, depth + 1, writer);
                for (array[1..]) |value| {
                    try writer.writeAll(",");
                    try stringifyInner(value, opts, 0, depth + 1, writer);
                }
            }
        },
        // final comma + newlines
        else => {
            for (array) |value| {
                try indent(opts.whitespace, indent_level + 1, writer);
                try stringifyInner(value, opts, indent_level + 1, depth + 1, writer);
                try writer.writeAll(",");
            }
            try indent(opts.whitespace, indent_level, writer);
        },
    }
    try writer.writeAll("]");
}

fn stringifyStruct(writer: anytype, strct: anytype, indent_level: usize, depth: usize, opts: StringifyOptions) !void {
    const omit_curly = opts.omit_top_level_curly and depth == 0;
    if (omit_curly) {
        _ = try stringifyStructInner(writer, strct, indent_level, depth, opts);
    } else {
        try writer.writeAll("{");
        const any_fields = try stringifyStructInner(writer, strct, indent_level + 1, depth, opts);
        if (any_fields) try indent(opts.whitespace, indent_level, writer);
        try writer.writeAll("}");
    }
}

fn stringifyStructInner(writer: anytype, strct: anytype, indent_level: usize, depth: usize, opts: StringifyOptions) !bool {
    const T = @typeInfo(@TypeOf(strct)).Struct;
    const field_count = blk: {
        var c: usize = 0;
        if (opts.emit_null_fields) break :blk T.fields.len;
        inline for (T.fields) |field| {
            switch (@typeInfo(field.type)) {
                .Optional => if (@field(strct, field.name) != null) {
                    c += 1;
                },
                else => c += 1,
            }
        }
        break :blk c;
    };
    if (T.fields.len > 0) {
        blk: {
            switch (@typeInfo(T.fields[0].type)) {
                .Optional => if (!opts.emit_null_fields and @field(strct, T.fields[0].name) == null) break :blk,
                else => {},
            }

            if (indent_level != 0) try indent(opts.whitespace, indent_level, writer);

            try writer.print(".{s}", .{T.fields[0].name});
            if (opts.whitespace == .minified) {
                try writer.writeAll("=");
            } else {
                try writer.writeAll(" = ");
            }
            try stringifyInner(@field(strct, T.fields[0].name), opts, indent_level, depth + 1, writer);
            if (opts.whitespace != .minified or 1 != field_count) {
                try writer.writeAll(",");
            }
        }
        inline for (T.fields[1..], 2..) |field, idx| {
            const name = field.name;
            const skip = switch (@typeInfo(field.type)) {
                .Optional => if (@field(strct, field.name) == null) !opts.emit_null_fields else false,
                else => false,
            };
            if (!skip) {
                try indent(opts.whitespace, indent_level, writer);
                try writer.print(".{s}", .{name});
                if (opts.whitespace == .minified) {
                    try writer.writeAll("=");
                } else {
                    try writer.writeAll(" = ");
                }
                try stringifyInner(@field(strct, name), opts, indent_level, depth + 1, writer);
                if (opts.whitespace != .minified or idx != field_count) {
                    try writer.writeAll(",");
                }
            }
        }
    }
    return field_count > 0;
}

fn stringifyUnion(writer: anytype, un: anytype, indent_level: usize, depth: usize, opts: StringifyOptions) !void {
    const T = @typeInfo(@TypeOf(un)).Union;
    if (T.tag_type == null) @compileError("Union '" ++ @typeName(@TypeOf(un)) ++ "' must be tagged!");
    var opts_ = opts;
    opts_.omit_top_level_curly = false;
    const at = std.meta.activeTag(un);
    try writer.print("{s}", .{@tagName(at)});
    if (opts.whitespace != .minified) try writer.writeAll(" ");
    inline for (T.fields) |field| {
        if (std.mem.eql(u8, field.name, @tagName(at))) {
            switch (@typeInfo(field.type)) {
                .Struct => try stringifyInner(@field(un, field.name), opts_, indent_level, depth, writer),
                else => {
                    const value_field: std.builtin.Type.StructField = .{
                        .name = "value",
                        .type = field.type,
                        .default_value = null,
                        .is_comptime = false,
                        .alignment = @alignOf(field.type),
                    };
                    const St = @Type(.{ .Struct = .{
                        .layout = .auto,
                        .fields = &.{value_field},
                        .decls = &.{},
                        .is_tuple = false,
                    } });
                    const v: St = .{ .value = @field(un, field.name) };
                    try stringifyInner(v, opts_, indent_level, depth, writer);
                },
            }
        }
    }
}

fn testStringify(value: anytype, opts: StringifyOptions, expected_output: []const u8) !void {
    var output_buffer = std.ArrayList(u8).init(std.testing.allocator);
    defer output_buffer.deinit();

    try stringify(value, opts, output_buffer.writer());

    try std.testing.expectEqualStrings(expected_output, output_buffer.items);
}

test "basic data types" {
    try testStringify(@as(u32, 100), .{}, "100");
    try testStringify(true, .{}, "true");
}

test "strings" {
    const x: []const u8 = "Hello";
    try testStringify(x, .{}, "\"Hello\"");
    try testStringify("World!".*, .{}, "\"World!\"");

    const y: []const u8 = "A string with a \"quote\"";
    try testStringify(y, .{}, "\"A string with a \\\"quote\\\"\"");

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
    try testStringify(z, .{}, mzesc);
}

test "arrays, slices" {
    const arr = [3]u32{ 1, 2, 3 };

    try testStringify(arr, .{}, "[1,2,3]");
    try testStringify(arr, .{ .whitespace = .space_1 },
        \\[
        \\ 1,
        \\ 2,
        \\ 3,
        \\]
    );
    try testStringify(arr, .{ .whitespace = .tab }, "[\n\t1,\n\t2,\n\t3,\n]");

    const slice: []const u32 = &arr;
    try testStringify(slice, .{}, "[1,2,3]");
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
    try testStringify(arr, .{}, "[[1,2],[3,4],[5,6]]");
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
    try testStringify(arr, .{}, "[\"Ala\",\"ma\",\"kota\"]");
    try testStringify(arr, .{ .whitespace = .space_1 },
        \\[
        \\ "Ala",
        \\ "ma",
        \\ "kota",
        \\]
    );

    const lfarr = [2][]const u8{ "Hello\nWorld", "The\nspace" };
    try testStringify(lfarr, .{}, "[\"Hello\\nWorld\",\"The\\nspace\"]");
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
    try testStringify(v, .{}, ".a=10,.b=false,.c=null");
    try testStringify(v, .{ .emit_null_fields = false }, ".a=10,.b=false");
    try testStringify(v, .{ .whitespace = .space_1 },
        \\.a = 10,
        \\.b = false,
        \\.c = null,
    );
    try testStringify(v, .{ .whitespace = .space_1, .omit_top_level_curly = false },
        \\{
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

    try testStringify(v, .{}, ".a=[1,2],.b=true");
    try testStringify(v, .{ .whitespace = .space_2, .omit_top_level_curly = false },
        \\{
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

    try testStringify(v, .{}, ".a={.b=false},.c=0");
    try testStringify(v, .{ .omit_top_level_curly = false }, "{.a={.b=false},.c=0}");
    try testStringify(v, .{ .whitespace = .space_4 },
        \\.a = {
        \\    .b = false,
        \\},
        \\.c = 0,
    );
}

test "union" {
    const U = union(enum) {
        Local: struct {
            path: []const u8,
        },
        Remote: struct {
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
                .Local = .{ .path = "../zine" },
            },
            .{
                .Remote = .{
                    .url = "github.com",
                    .hash = "0xAA",
                },
            },
        },
    };

    try testStringify(
        v,
        .{},
        ".deps=[Local{.path=\"../zine\"},Remote{.url=\"github.com\",.hash=\"0xAA\"}]",
    );
    try testStringify(v, .{ .whitespace = .space_1 },
        \\.deps = [
        \\ Local {
        \\  .path = "../zine",
        \\ },
        \\ Remote {
        \\  .url = "github.com",
        \\  .hash = "0xAA",
        \\ },
        \\],
    );
    try testStringify(v, .{ .whitespace = .space_1, .omit_top_level_curly = false },
        \\{
        \\ .deps = [
        \\  Local {
        \\   .path = "../zine",
        \\  },
        \\  Remote {
        \\   .url = "github.com",
        \\   .hash = "0xAA",
        \\  },
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
        \\  foo {
        \\    .value = "hello",
        \\  },
        \\  bar {
        \\    .value = 123,
        \\  },
        \\]
    );
}
