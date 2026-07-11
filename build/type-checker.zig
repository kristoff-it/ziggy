const std = @import("std");
const Io = std.Io;
const Allocator = std.mem.Allocator;
const ziggy = @import("ziggy");
const test_mode = @import("test_mode");
const types = @import("types");

pub fn main(init: std.process.Init) !void {
    const io = init.io;
    const arena = init.arena.allocator();

    var args_it = try init.minimal.args.iterateAllocator(arena);
    _ = args_it.skip();

    const schema_path = args_it.next() orelse @panic("missing schema path arg");
    const schema_src = Io.Dir.cwd().readFileAllocOptions(
        io,
        schema_path,
        arena,
        .limited(ziggy.max_size),
        .@"1",
        0,
    ) catch |e| {
        std.debug.print("{s}: unable to read file: {t}\n", .{
            schema_path, e,
        });
        std.process.exit(1);
    };

    var err: Error = .{};
    const ast: ziggy.schema.Ast = try .init(arena, schema_src);
    if (ast.errors.len > 0) {
        const display_schema_path = if (args_it.next()) |root_path|
            try std.fs.path.relative(
                arena,
                root_path,
                init.environ_map,
                root_path,
                schema_path,
            )
        else
            schema_path;
        for (ast.errors) |e| {
            const sel = e.main_location.getSelection(schema_src);
            std.debug.print("{s}:{}:{}: {f}\n", .{
                display_schema_path,
                sel.start.line,
                sel.start.col,
                e.tag,
            });
        }
        std.process.exit(1);
    }

    inline for (@typeInfo(types).@"struct".decl_names) |decl_name| {
        const T = @field(types, decl_name);

        if (@TypeOf(T) != type) {
            err.report(T, null, "is not a type definition", .{decl_name});
            continue;
        }

        switch (@typeInfo(T)) {
            .@"struct", .@"union", .@"enum" => {},
            else => {
                err.report(T, null, "is not a container type", .{decl_name});
                continue;
            },
        }

        var seen: std.StringHashMapUnmanaged(void) = .empty;
        const global_scope = ast.scopes.values()[0];
        if (test_mode.enabled) {
            if (global_scope.types.count() != 1)
                @panic("in test mode only one top-level definition is allowed");
            const node_idx = global_scope.types.values()[0];
            validateZigContainer(arena, &err, &seen, schema_src, ast, T, node_idx);
        } else {
            if (global_scope.types.get(decl_name)) |node_idx| {
                validateZigContainer(arena, &err, &seen, schema_src, ast, T, node_idx);
            } else {
                err.report(T, null, "missing top-level schema definition for '{s}'", .{
                    decl_name,
                });
            }
        }
    }

    std.process.exit(@intFromBool(err.any));
}

fn validateZigContainer(
    arena: Allocator,
    err: *Error,
    seen: *std.StringHashMapUnmanaged(void),
    schema_src: [:0]const u8,
    ast: ziggy.schema.Ast,
    T: type,
    node_idx: u32,
) void {
    if (ziggy.getOptions(T)) |opts| {
        if (opts.roles == .any) return;
    }

    {
        const match_name = std.fmt.allocPrint(
            arena,
            "{s}:{}",
            .{ @typeName(T), node_idx },
        ) catch @panic("oom");
        const gop = seen.getOrPut(arena, match_name) catch @panic("oom");
        if (gop.found_existing) return;
    }

    const schema_kind = ast.nodes[node_idx].tag;
    const type_scope = ast.scopes.get(node_idx).?;
    switch (@typeInfo(T)) {
        else => unreachable,
        .pointer => |ptr_info| {
            std.debug.assert(ptr_info.size == .one);

            return validateZigContainer(
                arena,
                err,
                seen,
                schema_src,
                ast,
                ptr_info.child,
                node_idx,
            );
        },
        inline .@"struct", .@"union", .@"enum" => |container_info, zig_kind| {
            switch (zig_kind) {
                else => unreachable,
                .@"struct" => {
                    if (schema_kind == .@"union") {
                        if (ziggy.getOptions(T)) |opts| {
                            switch (opts.roles) {
                                .container => |c| {
                                    if (c.@"union") |U| {
                                        return validateZigContainer(
                                            arena,
                                            err,
                                            seen,
                                            schema_src,
                                            ast,
                                            U,
                                            node_idx,
                                        );
                                    }
                                },
                                else => {},
                            }
                        }

                        err.report(T, null,
                            \\is of kind 'struct', while schema expects 'union' or 'enum'
                        , .{});
                        return;
                    }
                },
                .@"union", .@"enum" => {
                    if (zig_kind == .@"union") {
                        if (container_info.tag_type == null) {
                            err.report(T, null,
                                \\must be a tagged union to be (de)serialized
                            , .{});
                            return;
                        }
                    }

                    switch (schema_kind) {
                        else => unreachable,
                        .@"struct" => {
                            err.report(T, null,
                                \\is of kind '{t}' but schema expects 'struct'
                            , .{zig_kind});
                            return;
                        },
                        .@"union" => if (zig_kind == .@"enum") {
                            // If schema container is a union and Zig type is an enum,
                            // check that all schema fields are payloadless.
                            for (type_scope.fields.values()) |field| {
                                if (ast.fieldTypeExpr(field.idx) != null) {
                                    err.report(T, null,
                                        \\is of kind 'enum' but the schema union has at least one payload
                                    , .{});
                                    return;
                                }
                            }
                        },
                    }
                },
            }

            const skip_fields = if (ziggy.getOptions(T)) |opts| opts.skip_fields else &.{};
            inline for (container_info.field_names, 0..) |f_name, f_idx| blk: {
                @setEvalBranchQuota(100000);
                if (zig_kind == .@"struct" and comptime std.mem.indexOfScalar(
                    std.meta.FieldEnum(T),
                    skip_fields,
                    std.meta.stringToEnum(std.meta.FieldEnum(T), f_name).?,
                ) != null) break :blk;

                if (type_scope.fields.getPtr(f_name)) |field| {
                    if (zig_kind != .@"enum") {
                        if (ast.fieldTypeExpr(field.idx)) |field_expr| {
                            const f_type = container_info.field_types[f_idx];

                            var expr = field_expr;
                            const expr_src = expr.loc.slice(schema_src);

                            if (zig_kind == .@"struct") {
                                // A Schema field of outer type '?', '{:}', '[]'
                                // must have a corresponding Zig type with a
                                // default value.
                                const f_attrs = container_info.field_attrs[f_idx];
                                switch (expr_src[0]) {
                                    '?' => if (f_attrs.default_value_ptr == null) {
                                        err.report(T, f_name,
                                            \\schema type '{s}' (optional) requires this Zig struct field to have a default value
                                        , .{expr_src});
                                    } else if (@typeInfo(f_type) != .optional) {
                                        // Optional Schema fields are
                                        // compatible with non-optional Zig
                                        // fields that have a default
                                        // value.
                                        expr.it.idx += "?".len;
                                    },
                                    '[' => if (f_attrs.default_value_ptr == null) {
                                        err.report(T, f_name,
                                            \\schema type '{s}' (slice) requires this Zig struct field to have a default value
                                        , .{expr_src});
                                    },
                                    '{' => if (f_attrs.default_value_ptr == null) {
                                        err.report(T, f_name,
                                            \\schema type '{s}' (dictionary) requires this Zig struct field to have a default value
                                        , .{expr_src});
                                    },
                                    else => {},
                                }
                            }

                            validateFieldExpr(
                                arena,
                                err,
                                seen,
                                schema_src,
                                ast,
                                T,
                                node_idx,
                                f_type,
                                f_name,
                                expr_src,
                                &expr.it,
                                expr.it.next(schema_src),
                            );
                        }
                    }
                } else {
                    err.report(T, f_name, "field not in schema", .{});
                }
            }

            const field_map: std.StaticStringMap(std.meta.FieldEnum(T)) = .initEnum();
            for (type_scope.fields.values()) |schema_field| {
                const schema_field_name = schema_field.loc.slice(schema_src);
                if (!field_map.has(schema_field_name)) {
                    if (ast.fieldTypeExpr(schema_field.idx)) |expr| {
                        const expr_src = expr.loc.slice(schema_src);
                        err.report(T, null, "missing field '{s}' ({s})", .{
                            schema_field_name, expr_src,
                        });
                    } else {
                        err.report(T, null, "missing field '{s}' (payloadless)", .{
                            schema_field_name,
                        });
                    }
                }
            }
        },
    }
}

fn validateFieldExpr(
    arena: Allocator,
    err: *Error,
    seen: *std.StringHashMapUnmanaged(void),
    schema_src: [:0]const u8,
    ast: ziggy.schema.Ast,
    T: type,
    node_idx: u32,
    F: type,
    comptime field_name: []const u8,
    expr_src: []const u8,
    expr_it: *ziggy.schema.Tokenizer,
    tok: ziggy.schema.Tokenizer.Token,
) void {
    if (ziggy.getOptions(F)) |opts| {
        if (opts.roles == .any) return;
    }

    const field_info = @typeInfo(F);
    switch (tok.tag) {
        // Container tokens
        .opt_slice_sigil => if (field_info == .optional)
            if (ziggy.getOptions(field_info.optional.child)) |opts| {
                switch (opts.roles) {
                    .any => unreachable,
                    .container => |c| if (c.slice) |Child| {
                        return validateFieldExpr(
                            arena,
                            err,
                            schema_src,
                            ast,
                            T,
                            node_idx,
                            Child,
                            field_name,
                            expr_src,
                            expr_it,
                            expr_it.next(schema_src),
                        );
                    },
                    .none => {},
                }
            },
        .slice_sigil => if (ziggy.getOptions(F)) |opts| {
            switch (opts.roles) {
                .any => unreachable,
                .container => |c| if (c.slice) |Child| {
                    return validateFieldExpr(
                        arena,
                        err,
                        seen,
                        schema_src,
                        ast,
                        T,
                        node_idx,
                        Child,
                        field_name,
                        expr_src,
                        expr_it,
                        expr_it.next(schema_src),
                    );
                },
                .none => {},
            }
        } else if (field_info == .pointer and field_info.pointer.size == .slice) {
            return validateFieldExpr(
                arena,
                err,
                seen,
                schema_src,
                ast,
                T,
                node_idx,
                field_info.pointer.child,
                field_name,
                expr_src,
                expr_it,
                expr_it.next(schema_src),
            );
        },

        .opt_dict_sigil => if (field_info == .optional)
            if (ziggy.getOptions(field_info.optional.child)) |opts| {
                switch (opts.roles) {
                    .any => unreachable,
                    .container => |c| if (c.dict) |Child| {
                        return validateFieldExpr(
                            arena,
                            err,
                            seen,
                            schema_src,
                            ast,
                            T,
                            node_idx,
                            Child,
                            field_name,
                            expr_src,
                            expr_it,
                            expr_it.next(schema_src),
                        );
                    },
                    .none => {},
                }
            },

        .dict_sigil => if (ziggy.getOptions(F)) |opts| {
            switch (opts.roles) {
                .any => unreachable,
                .container => |c| if (c.dict) |Child| {
                    return validateFieldExpr(
                        arena,
                        err,
                        seen,
                        schema_src,
                        ast,
                        T,
                        node_idx,
                        Child,
                        field_name,
                        expr_src,
                        expr_it,
                        expr_it.next(schema_src),
                    );
                },
                .none => {},
            }
        },

        // Terminal tokens
        .opt_bytes_kw => switch (F) {
            ?[]u8, ?[]const u8, ?[:0]u8, ?[:0]const u8 => return,
            else => {},
        },
        .bytes_kw => switch (F) {
            []u8, []const u8, [:0]u8, [:0]const u8 => return,
            else => {},
        },

        .opt_bool_kw => switch (F) {
            ?bool => return,
            else => {},
        },
        .bool_kw => switch (F) {
            bool => return,
            else => {},
        },

        .opt_float_kw => switch (F) {
            ?f16, ?f32, ?f64, ?f80 => return,
            else => {},
        },
        .float_kw => switch (F) {
            f16, f32, f64, f80 => return,
            else => {},
        },

        .opt_int_kw => if (field_info == .optional) {
            const child_info = @typeInfo(field_info.optional.child);
            if (child_info == .int) return;
        },
        .int_kw => if (field_info == .int) return,

        .opt_identifier => if (field_info == .optional) {
            const container_name = tok.loc.slice(schema_src)[1..];
            const child_node_idx = ast.findContainerType(node_idx, container_name).?;
            return validateZigContainer(
                arena,
                err,
                seen,
                schema_src,
                ast,
                field_info.optional.child,
                child_node_idx,
            );
        },
        .identifier => {
            const container_name = tok.loc.slice(schema_src);
            const child_node_idx = ast.findContainerType(node_idx, container_name).?;
            return validateZigContainer(
                arena,
                err,
                seen,
                schema_src,
                ast,
                F,
                child_node_idx,
            );
        },

        .any_kw => {
            // only a .container == .any type can (de)serialize this meta-type
            // and we checked above, making this an unconditional mismatch
        },
        else => unreachable,
    }

    err.report(T, field_name, "has type '{s}' which is incompatible with '{s}'", .{
        // We don't use F because it might be a sub-type of the original field type.
        @typeName(@FieldType(T, field_name)), expr_src,
    });

    if (@FieldType(T, field_name) != F) {
        err.info(T, field_name, "zig child type is '{s}', schema has '{s}'", .{
            @typeName(F), tok.loc.slice(schema_src),
        });
    }
}

const Error = struct {
    any: bool = false,
    fn report(err: *Error, T: type, field: ?[]const u8, comptime fmt: []const u8, args: anytype) void {
        err.any = true;

        std.debug.print("{s}", .{@typeName(T)});
        if (field) |f| std.debug.print(".{s}", .{f});
        std.debug.print(": ", .{});
        std.debug.print(fmt, args);
        std.debug.print("\n", .{});
    }

    fn info(err: *Error, T: type, field: ?[]const u8, comptime fmt: []const u8, args: anytype) void {
        err.any = true;

        const line = @typeName(T).len + if (field) |f| f.len + 1 else 0;
        const spaces = line -| "hint".len;

        for (0..spaces) |_| std.debug.print(" ", .{});

        std.debug.print("hint: ", .{});
        std.debug.print(fmt, args);
        std.debug.print("\n", .{});
    }

    fn reportType(
        err: *Error,
        T: type,
        f_name: []const u8,
        f_type: type,
        expr_src: []const u8,
    ) void {
        err.report(T, f_name, "has type '{s}' which is incompatible with '{s}'", .{
            @typeName(f_type), expr_src,
        });
    }
};
