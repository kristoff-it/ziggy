const std = @import("std");
const builtin = @import("builtin");
const Ast = @import("Ast.zig");
const Diagnostic = @import("Diagnostic.zig");
const Schema = @import("Schema.zig");
const assert = std.debug.assert;
const Allocator = std.mem.Allocator;

pub fn checkType(T: type, src: [:0]const u8) !void {
    if (!builtin.is_test) @compileError("call checkType in a unit test!");
    var arena_state = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena_state.deinit();

    const arena = arena_state.allocator();
    var diag: Diagnostic = .{ .lsp = false, .path = null };

    const ast = Ast.init(arena, src, &diag) catch |err| {
        std.debug.print("Error while parsing Ziggy Schema:\n{f}\n", .{diag});
        return err;
    };

    const schema = Schema.init(arena, ast.nodes.items, src, &diag) catch |err| {
        std.debug.print("Error while analyzing Ziggy Schema:\n{f}\n", .{diag});
        return err;
    };

    try checkRule(T, arena, &schema, src, schema.root);
}

fn checkRule(
    T: type,
    arena: Allocator,
    schema: *const Schema,
    src: [:0]const u8,
    rule: Schema.Rule,
) error{ Validation, OutOfMemory }!void {
    const node = schema.nodes[rule.node];
    const info = @typeInfo(T);

    switch (info) {
        .@"struct", .@"union", .@"enum" => {
            if (@hasDecl(T, "ziggy_options") and
                (@hasDecl(T.ziggy_options, "parse") or
                    @hasDecl(T.ziggy_options, "stringify")))
            {
                return;
            }
        },
        else => {},
    }

    switch (node.tag) {
        else => std.debug.panic("TODO: '{s}'\n", .{@tagName(node.tag)}),
        .any, .unknown => return,
        .bool => {
            if (T != bool) {
                std.debug.print("Expected 'bool' found '{s}'\n", .{@typeName(T)});
                return error.Validation;
            }
        },
        .bytes => {
            if (T != []const u8 and T != []u8) {
                std.debug.print("Expected 'bytes' found '{s}'\n", .{@typeName(T)});
                return error.Validation;
            }
        },

        .int => {
            if (info != .int) {
                std.debug.print("Expected 'int' found '{s}'\n", .{@typeName(T)});
                return error.Validation;
            }
        },
        .float => {
            if (info != .float) {
                std.debug.print("Expected 'float' found '{s}'\n", .{@typeName(T)});
                return error.Validation;
            }
        },

        .optional => {
            if (info != .optional) {
                std.debug.print("Expected 'optional' found '{s}'\n", .{@typeName(T)});
                return error.Validation;
            }

            try checkRule(info.optional.child, arena, schema, src, .{
                .node = node.first_child_id,
            });
        },

        .array => switch (info) {
            .array => |arr| try checkRule(arr.child, arena, schema, src, .{
                .node = node.first_child_id,
            }),
            .pointer => |ptr| {
                if (ptr.size != .slice) {
                    std.debug.print("Expected 'optional' found '{s}'\n", .{@typeName(T)});
                    return error.Validation;
                }

                try checkRule(ptr.child, arena, schema, src, .{
                    .node = node.first_child_id,
                });
            },
            else => {
                std.debug.print("Expected 'array' found '{s}'\n", .{@typeName(T)});
                return error.Validation;
            },
        },
        .struct_union => {
            if (info != .@"union") {
                std.debug.print("Expected 'union' found '{s}'\n", .{@typeName(T)});
                return error.Validation;
            }
            const u = info.@"union";

            // TODO: this acceleration data structure should probably be part
            //       of the schema itself
            var cases = std.StringArrayHashMap(void).init(arena);
            defer cases.deinit();
            {
                assert(node.first_child_id != 0);
                var idx = node.first_child_id;
                while (idx != 0) : (idx = schema.nodes[idx].next_id) {
                    const case = schema.nodes[idx].loc.src(src);
                    try cases.putNoClobber(case, {});
                }
            }

            inline for (u.fields) |f| {
                if (!cases.swapRemove(f.name)) {
                    std.debug.print("Case '{s}' in union type '{s}' doesn't exist in schema\n", .{
                        f.name,
                        @typeName(T),
                    });
                    return error.Validation;
                }
            }

            if (cases.pop()) |remaining| {
                std.debug.print("Schema union case '{s}' missing in union type '{s}'\n", .{
                    remaining.key,
                    @typeName(T),
                });
                return error.Validation;
            }
        },
        .map => @panic("TODO: map support in checkType"),
        .identifier => {
            switch (info) {
                else => {
                    std.debug.print("Expected 'struct' found '{s}'", .{@typeName(T)});
                    return error.Validation;
                },
                .@"struct" => |s| {
                    const sr = schema.structs.get(node.loc.src(src)).?;
                    const seen_fields = try arena.alloc(bool, sr.fields.entries.len);
                    @memset(seen_fields, false);

                    outer: inline for (s.fields) |f| {
                        // TODO: check for skip_fields

                        if (@hasDecl(T, "ziggy_options") and @hasDecl(T.ziggy_options, "skip_fields")) {
                            const SF = std.meta.FieldEnum(T);
                            const field_enum = @field(SF, f.name);
                            inline for (T.ziggy_options.skip_fields) |sf| {
                                if (field_enum == sf) continue :outer;
                            }
                        }

                        const idx = sr.fields.getIndex(f.name) orelse {
                            std.debug.print("'{s}.{s}' not present in schema\n", .{
                                @typeName(T),
                                f.name,
                            });
                            return error.Validation;
                        };

                        seen_fields[idx] = true;

                        const field = sr.fields.entries.items(.value)[idx];
                        try checkRule(f.type, arena, schema, src, field.rule);
                    }

                    for (seen_fields, 0..) |seen, idx| {
                        if (!seen) {
                            std.debug.print("Struct '{s}' is missing field '{s}' \n", .{
                                @typeName(T),
                                sr.fields.entries.items(.key)[idx],
                            });
                            return error.Validation;
                        }
                    }
                },
            }
        },
    }
}

test "bool" {
    const T = bool;
    const case =
        \\root = bool
        \\
    ;

    try checkType(T, case);
}

test "ints" {
    const Ts = &.{ usize, i16, u22, u0, u1, i0, i1, u64, i64 };
    const case =
        \\root = int
        \\
    ;

    inline for (Ts) |T| try checkType(T, case);
}

test "simple struct" {
    const Foo = struct {
        bar: usize,
        baz: bool,
    };

    const case =
        \\root = Foo
        \\
        \\struct Foo {
        \\    bar: int,
        \\    baz: bool,
        \\}
    ;

    try checkType(Foo, case);
}

test "simple struct - missing field in schema" {
    const Foo = struct {
        bar: usize,
        baz: bool,
    };

    const case =
        \\root = Foo
        \\
        \\struct Foo {
        \\    bar: int,
        \\    baz: bool,
        \\    box: bool,
        \\}
    ;

    try std.testing.expectError(error.Validation, checkType(Foo, case));
}

test "simple struct - missing field in type" {
    const Foo = struct {
        bar: usize,
        baz: bool,
        box: bool,
    };

    const case =
        \\root = Foo
        \\
        \\struct Foo {
        \\    bar: int,
        \\    baz: bool,
        \\}
    ;

    try std.testing.expectError(error.Validation, checkType(Foo, case));
}

test "simple struct - skip fields" {
    const Foo = struct {
        bar: usize,
        baz: bool,
        box: bool,

        const Foo = @This();
        pub const ziggy_options = struct {
            pub const skip_fields: []const std.meta.FieldEnum(Foo) = &.{
                .box,
            };
        };
    };

    const case =
        \\root = Foo
        \\
        \\struct Foo {
        \\    bar: int,
        \\    baz: bool,
        \\}
    ;

    try checkType(Foo, case);
}

test "optional at root" {
    const T = ?bool;
    const case =
        \\root = ?bool
    ;

    try checkType(T, case);
}

test "optional in struct" {
    const Foo = struct {
        bar: ?usize,
    };

    const case =
        \\root = Foo
        \\
        \\struct Foo {
        \\    bar: ?int,
        \\}
    ;

    try checkType(Foo, case);
}

test "optional in struct - error" {
    const Foo = struct {
        bar: ?usize,
    };

    const case =
        \\root = Foo
        \\
        \\struct Foo {
        \\    bar: ?bool,
        \\}
    ;

    try std.testing.expectError(error.Validation, checkType(Foo, case));
}

test "array" {
    const Ts = .{ [10]usize, []i64 };
    const case =
        \\root = [int]
    ;

    inline for (Ts) |T| try checkType(T, case);
}

test "array with error" {
    const T = []const bool;
    const case =
        \\root = [?bool]
    ;

    try std.testing.expectError(error.Validation, checkType(T, case));
}
