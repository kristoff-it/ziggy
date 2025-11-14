/// Useful for building Ziggy tooling, parses a Ziggy Document keeping track of
/// source locations, which you can use to generate better error messages for
/// your users.
///
/// An AST can be validated against a Ziggy Schema. If the document you're
/// loading does not have any specific schema, you should still validate it
/// against the default schema ('$ = any') in order to detect duplicate fields.
/// See `schema.Ast.validate` and `schema.Ast.validateDefault`.
///
/// See `deserialize` to deserialize a Ziggy Document directly to a Zig type.
pub const Ast = @import("Ast.zig");
pub const Tokenizer = @import("Tokenizer.zig");

/// Definitions for turning Zig values into Ziggy Documents. For an easier
/// inteface, see first `serialize`.
pub const Serializer = @import("Serializer.zig");
pub const serialize = Serializer.serialize;

/// Definitions for turning Ziggy Documents into Zig Values. For an easier
/// inteface, see first `deserialize` and `deserializeLeaky`.
pub const Deserializer = @import("Deserializer.zig");
pub const deserialize = Deserializer.deserialize;
pub const deserializeLeaky = Deserializer.deserializeLeaky;

/// A Zig type capable of deserializing from, and serializing to, any Zig Document.
pub const Dynamic = @import("dynamic.zig").Dynamic;

/// Ziggy Schemas can be used to validate the structure of Ziggy Documents.
pub const schema = @import("schema.zig");

// Ziggy Documents and Schemas can have a maximum size of 4GB
pub const max_size = 4 * 1024 * 1024 * 1024;

test {
    _ = Ast;
    _ = Tokenizer;
    _ = Serializer;
    _ = Deserializer;
    _ = Dynamic;
    _ = schema;
}
