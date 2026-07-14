/// Useful for building Ziggy tooling, parses a Ziggy Document keeping
/// track of source locations, which you can use to generate better error
/// messages for your users.
///
/// An AST can be validated against a Ziggy Schema. If the document you're
/// loading does not have any specific schema, you should still validate it
/// against the default schema ('$ = any') in order to detect duplicate
/// fields. See `schema.Ast.validate` and `schema.Ast.validateDefault`.
///
/// See `deserialize` to load a Ziggy Document directly into a Zig type.
pub const Ast = @import("Ast.zig");
pub const Tokenizer = @import("Tokenizer.zig");

/// Definitions for turning Zig values into Ziggy Documents. For an easier
/// inteface, see first `serialize`.
pub const Serializer = @import("Serializer.zig");
pub const serialize = Serializer.serialize;

/// Definitions for turning Ziggy Documents into Zig values. For an easier
/// inteface, see first `deserialize` and `deserializeLeaky`.
pub const Deserializer = @import("Deserializer.zig");
pub const deserialize = Deserializer.deserialize;
pub const deserializeLeaky = Deserializer.deserializeLeaky;

/// A Zig type capable of (de)serializing any Ziggy Document value.
pub const Dynamic = @import("dynamic.zig").Dynamic;
/// A thin wrapper around `std.StringArrayHashMap` that can match Ziggy
/// dictionaries.
pub const Dictionary = @import("dynamic.zig").Dictionary;
/// A thhin wrapper around `std.ArrayList` that can match Ziggy slices.
pub const ArrayList = @import("dynamic.zig").ArrayList;

/// Ziggy Schemas can be used to validate the structure of Ziggy Documents.
pub const schema = @import("schema.zig");

/// Ziggy Documents and Schemas can have a maximum size of 4GB
pub const max_size = @import("std").math.maxInt(u32);

/// Rendering modes supported by Document and Schema ASTs
pub const RenderMode = enum {
    plain,
    html,
    terminal,
};

/// When a Zig container type has a public decl named `ziggy_options` of
/// type `Options(T)`, it can customize (de)serialization behavior.
pub fn Options(T: type) type {
    const std = @import("std");

    return struct {
        /// Fields listed here will not be (de)serialized. If `deserialize`
        /// is null, skipped fields must have a default value.
        skip_fields: []const std.meta.FieldEnum(T) = &.{},

        /// If set, the source location of where this struct was loaded
        /// from in the Ziggy document will be saved in this field.
        /// The field in question must be:
        ///  - present in `skip_fields`
        ///  - of type `ziggy.Tokenizer.Token.Loc`
        loc_field: ?std.meta.FieldEnum(T) = null,

        /// Used by build-time Zig type <> Ziggy Schema compatibility
        /// validation for types that customize (de)serialization.
        ///
        /// - 'any':  The type can match any Ziggy type and, in the
        ///           case of wrapping types ('?', '{:}', '[]'), it
        ///           will also consume child values. This is the
        ///           value of `ziggy.Dynamic`.
        ///
        /// - 'container': Lets you specify compatibily with container
        ///                types. You will need to provide the child
        ///                type of your custom container in order to
        ///                let the algorithm continue validating the
        ///                type.
        ///
        /// - 'none': The default value.
        roles: union(enum) {
            any,
            container: struct {
                dict: ?type = null,
                slice: ?type = null,
                /// The type corresponding to the union itself which you
                /// are expected to be wrapping (use `.any` otherwise).
                @"union": ?type = null,
            },
            none,
        } = .none,

        /// Override serialization behavior.
        ///
        /// Make sure to see what `s` exposes to you, which includes
        /// access to default serialization behavior.
        serialize: ?fn (
            s: *const Serializer,
            /// The value being serialized.
            value: T,
            /// The current indentation level, should not increase when
            /// rendering data in horizontal orientation.
            indent_level: usize,
            /// The nesting level, unaffected by rendering orientation.
            /// When rendering a struct at depth 0 (top-level), curlies
            /// can be omitted, for example.
            depth: usize,
        ) std.Io.Writer.Error!void = null,

        /// Override deserialization behavior.
        ///
        /// Make sure to see what `d` exposes to you, which includes
        /// access to default deserialization behavior. You will want
        /// to familiarize yourself especially with the tokenizer.
        deserialize: ?fn (
            d: *const Deserializer,
            /// The first token that is expected to belong to your type.
            first: Tokenizer.Token,
            /// Whether we are at the top level or not.
            top_lvl: bool,
        ) Deserializer.Error!T = null,
    };
}

/// Returns `ziggy_options` from T or null if the decl is missing,
/// private, or T is not a container type.
///
/// Will trigger a compile error if `ziggy_options` is not of the
/// right type or any other semantic error is found.
pub inline fn getOptions(T: type) switch (@typeInfo(T)) {
    .@"struct", .@"union", .@"enum" => ?Options(T),
    else => ?void,
} {
    switch (@typeInfo(T)) {
        .@"struct", .@"union", .@"enum" => {},
        else => return null,
    }

    if (!@hasDecl(T, "ziggy_options")) return null;

    if (@TypeOf(T.ziggy_options) != Options(T)) {
        @compileError(@typeName(T) ++
            ".ziggy_options must be of type ziggy.Options(T)");
    }

    switch (@typeInfo(T)) {
        .@"struct" => {
            const std = @import("std");
            if (T.ziggy_options.loc_field) |lf| {
                @setEvalBranchQuota(10000);
                if (comptime std.mem.findScalar(
                    std.meta.FieldEnum(T),
                    T.ziggy_options.skip_fields,
                    lf,
                ) == null) {
                    @compileError("Loc field '" ++ @tagName(lf) ++ "' must be listed in 'skip_fields'");
                }
            }
        },
        .@"union", .@"enum" => {
            if (T.ziggy_options.skip_fields.len > 0) {
                @compileError("'skip_fields' must be empty in union and enum types");
            }
            if (T.ziggy_options.loc_field != null) {
                @compileError("'loc_field' must be null in union and enum types");
            }
        },
        else => return null,
    }

    return T.ziggy_options;
}

test {
    _ = Ast;
    _ = Tokenizer;
    _ = Serializer;
    _ = Deserializer;
    _ = Dynamic;
    _ = Dictionary;
    _ = schema;
}
