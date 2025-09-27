/// Parses a Ziggy Schema into an AST, can be used to validate Ziggy
/// Documents, see `ast.validate` for more info.
pub const Ast = @import("schema/Ast.zig");
pub const Tokenizer = @import("schema/Tokenizer.zig");

/// Validating a Ziggy Document AST is necessary to detect duplicate fields.
/// A Ziggy Document that doesn't have a specific schema can always be matched
/// with the default `$ = any` schema, which is what `validateDefault` makes
/// convenient to do.
///
/// Asserts that the schema does not contain errors.
/// Asserts that the document does not contain errors.
/// Caller owns returned memory.
pub const validateDefault = Ast.validateDefault;

test {
    _ = Ast;
    _ = Tokenizer;
}
// pub const checkType = @import("schema/check_type.zig").checkType;
