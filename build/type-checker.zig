const std = @import("std");
const ziggy = @import("ziggy");
const types = @import("types");

pub fn main(init: std.process.Init) !void {
    const arena = init.arena.allocator();

    const i = @typeInfo(types).@"struct";
    var err: Error = .{};
    inline for (i.decl_names) |name| {
        const T = @field(types, name);
        if (!@hasDecl(T, "ziggy_options")) {
            err.report(T, null, "missing or private `ziggy_options` decl", .{});
            continue;
        }

        if (@TypeOf(T.ziggy_options) != ziggy.Options(T)) {
            err.report(T, null, "`ziggy_options` must be an instance of `ziggy.Options(T)`", .{});
            continue;
        }

        if (T.ziggy_options.schema == null) {
            err.report(T, null, "missing schema definition in `ziggy_options`", .{});
            continue;
        }

        validateZig(T, arena, &err) catch @panic("oom");
    }

    std.process.exit(@intFromBool(err.any));
}

fn validateZig(
    T: type,
    arena: std.mem.Allocator,
    err: *Error,
) error{OutOfMemory}!void {
    const schema_src = T.ziggy_options.schema.?;

    const ast: ziggy.schema.Ast = try .init(arena, schema_src);
    if (ast.errors.len > 0) {
        err.reportSchema(T, ast.errors);
        return;
    }

    // TODO: handle schemas that don't start from a container type
    const scope = ast.scopes.values()[1];
    const i = @typeInfo(T);
    switch (i) {
        .@"struct" => |s| {
            // TODO: validate that this schema definition is a struct

            // - All struct fields are in schema
            // - All types are compatible
            inline for (s.field_names, s.field_types) |f_name, f_type| {
                if (scope.fields.get(f_name)) |f| {
                    validateTypeExpr(T, f_name, f_type, err, ast, f.idx + 1);
                } else {
                    err.report(T, f_name, "does not exist in schema", .{});
                }
            }

            // - All schema fields are in the struct
            const struct_fields: std.StaticStringMap(std.meta.FieldEnum(T)) = .initEnum();
            for (scope.fields.keys()) |schema_f_name| {
                if (!struct_fields.has(schema_f_name)) {
                    err.report(T, null, "schema field '{s}' missing from struct definition", .{
                        schema_f_name,
                    });
                }
            }
        },
        .@"union" => |u| {
            // TODO: validate that this schema definition is a union
            _ = u;
            @compileError("TODO");
        },

        else => @compileError("TODO"),
    }
}

fn validateTypeExpr(
    T: type,
    f_name: []const u8,
    starting_f_type: type,
    err: *Error,
    ast: ziggy.schema.Ast,
    idx: u32,
) void {
    const schema_src = T.ziggy_options.schema.?;

    const node = ast.nodes[idx];
    const expr_src = node.loc.slice(schema_src);

    var expr_it = node.typeExpr();
    const expr = expr_it.next(schema_src);
    const f_type = starting_f_type;

    while (true) {

        // fallthrough means mismatch
        switch (f_type) {
            []u8, []const u8, [:0]u8, [:0]const u8 => switch (expr.tag) {
                .bytes_kw => return,
                .slice_sigil => {
                    //arst
                    // continue
                },
                else => {},
            },

            else => switch (@typeInfo(f_type)) {
                // .optional => |opt| switch (expr.tag) {
                //     .opt_bytes_kw => {
                //         expr.tag = .bytes_kw;
                //         f_type = opt.child;
                //         continue;
                //     },
                //     .opt_bool_kw => {
                //         expr.tag = .bool_kw;
                //         f_type = opt.child;
                //         continue;
                //     },
                //     .opt_int_kw => {
                //         expr.tag = .int_kw;
                //         f_type = opt.child;
                //         continue;
                //     },
                //     else => {},
                // },

                .bool => switch (expr.tag) {
                    .bool_kw => return,
                    else => {},
                },

                .int => switch (expr.tag) {
                    .int_kw => return,
                    else => {},
                },

                .@"struct" => {
                    if (@hasDecl(f_type, "ziggy_options")) {
                        if (@TypeOf(T.ziggy_options) != ziggy.Options(T)) {
                            err.report(T, null, "`ziggy_options` must be an instance of `ziggy.Options(T)`", .{});
                            return;
                        }

                        switch (T.ziggy_options.roles) {
                            .any => return,
                            .none => {},
                            else => @panic("TODO"),
                        }
                    }
                },
                else => {},
            },
        }

        err.reportType(T, f_name, f_type, expr_src);
        return;
    }
}

fn validateTypeExprOld(
    T: type,
    f_name: []const u8,
    starting_f_type: type,
    err: *Error,
    ast: ziggy.schema.Ast,
    idx: u32,
) void {
    const node = ast.nodes[idx];
    const expr_src = node.loc.slice(T.ziggy_options.schema);

    var info = @typeInfo(starting_f_type);
    var f_type = starting_f_type;
    var expr_it = node.typeExpr();
    outer: while (true) {
        if (f_type == ziggy.Dynamic) return;
        const tok = expr_it.next(T.ziggy.schema);

        inner: switch (tok.tag) {
            // Container tokens
            .opt_slice_sigil => if (info == .optional) {
                info = @typeInfo(info.optional.child);
                f_type = info.optional.child;
                if (f_type == ziggy.Dynamic) return;

                continue :inner .slice_sigil;
            },
            .slice_sigil => if (info == .pointer and info.pointer.size == .slice) {
                info = @typeInfo(info.pointer.child);
                f_type = info.pointer.child;
                continue :outer;
            },

            .opt_dict_sigil => if (info == .optional) {
                info = @typeInfo(info.optional.child);
                f_type = info.optional.child;
                if (f_type == ziggy.Dynamic) return;

                continue :inner .dict_sigil;
            },
            .dict_sigil => if (f_type == ziggy.Dictionary) {
                info = @typeInfo(f_type.Child);
                f_type = f_type.Child;
                continue :outer;
            },

            // Terminal tokens
            .opt_bytes_kw => if (info == .optional) {
                info = @typeInfo(info.optional.child);
                f_type = info.optional.child;
                if (f_type == ziggy.Dynamic) return;

                continue :inner .bytes_kw;
            },
            .bytes_kw => switch (f_type) {
                []u8, []const u8, [:0]u8, [:0]const u8 => return,
                else => {},
            },

            .opt_bool_kw => if (info == .optional) {
                info = @typeInfo(info.optional.child);
                f_type = info.optional.child;
                if (f_type == ziggy.Dynamic) return;

                continue :inner .bool_kw;
            },
            .bool_kw => switch (f_type) {
                bool => return,
                else => {},
            },

            .opt_float_kw => if (info == .optional) {
                info = @typeInfo(info.optional.child);
                f_type = info.optional.child;
                if (f_type == ziggy.Dynamic) return;

                continue :inner .float_kw;
            },
            .float_kw => switch (f_type) {
                f32, f64 => return,
                else => {},
            },

            .opt_int_kw => if (info == .optional) {
                info = @typeInfo(info.optional.child);
                f_type = info.optional.child;
                if (f_type == ziggy.Dynamic) return;

                continue :inner .int_kw;
            },
            .int_kw => if (@typeInfo(f_type) == .int) return,
            else => std.debug.panic("TODO: validateTypeExpr for '{t}'", .{tok.tag}),
        }

        err.report(T, f_name, "has type '{s}' which is incompatible with '{s}'", .{
            @typeName(f_type), expr_src,
        });
        return;
    }
    comptime unreachable;
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

    fn reportSchema(err: *Error, T: type, errors: []const ziggy.schema.Ast.Error) void {
        std.debug.assert(errors.len > 0);
        err.any = true;

        for (errors) |e| {
            const sel = e.main_location.getSelection(T.ziggy_options.schema.?);
            std.debug.print("{s}.ziggy.schema:{}:{}: {f}\n", .{
                @typeName(T),
                sel.start.line,
                sel.start.col,
                e.tag,
            });
        }
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
