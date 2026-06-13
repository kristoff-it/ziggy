const std = @import("std");
const ziggy = @import("ziggy");
const types = @import("types");

pub fn main(init: std.process.Init) !void {
    const arena = init.arena.allocator();

    const i = @typeInfo(types).@"struct";
    var err: Error = .{};
    inline for (i.decl_names) |name| {
        const T = @field(types, name);
        if (!@hasDecl(T, "ziggy")) {
            err.report(T, null, "missing or private `ziggy` decl", .{});
            continue;
        }
        if (!@hasDecl(T.ziggy, "schema")) {
            err.report(T, null, "missing or private `ziggy.schema` decl", .{});
            continue;
        }

        validateType(T, arena, &err) catch @panic("oom");
    }

    std.process.exit(@intFromBool(err.any));
}

fn validateType(T: type, arena: std.mem.Allocator, err: *Error) error{OutOfMemory}!void {
    const ast: ziggy.schema.Ast = try .init(arena, T.ziggy.schema);
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

            // All struct fields are in schema
            inline for (s.field_names, s.field_types) |f_name, f_type| {
                if (scope.fields.get(f_name)) |f| {
                    validateTypeExpr(T, f_name, f_type, err, ast, f.idx + 1);
                } else {
                    err.report(T, f_name, "does not exist in schema", .{});
                }
            }

            // All schema fields are in the struct
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
    f_type: type,
    err: *Error,
    ast: ziggy.schema.Ast,
    idx: u32,
) void {
    const type_expr = ast.nodes[idx];
    std.debug.assert(type_expr.tag == .type_expr);

    const slice = T.ziggy.schema[type_expr.loc.start..];
    var t: ziggy.schema.Tokenizer = .{};
    const tok = t.next(slice);
    switch (tok.tag) {
        .bytes_kw => switch (f_type) {
            []u8, []const u8, [:0]u8, [:0]const u8 => return,
            else => {},
        },
        .bool_kw => switch (f_type) {
            bool => return,
            else => {},
        },
        .float_kw => switch (f_type) {
            f32, f64 => return,
            else => {},
        },
        .int_kw => if (@typeInfo(f_type) == .int) return,
        else => std.debug.panic("TODO: validateTypeExpr for '{t}'", .{tok.tag}),
    }

    err.report(T, f_name, "has type '{s}' which is incompatible with '{s}'", .{
        @typeName(f_type), tok.tag.lexeme(),
    });
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
            const sel = e.main_location.getSelection(T.ziggy.schema);
            std.debug.print("{s}.ziggy.schema:{}:{}: {f}\n", .{
                @typeName(T),
                sel.start.line,
                sel.start.col,
                e.tag,
            });
        }
    }
};
