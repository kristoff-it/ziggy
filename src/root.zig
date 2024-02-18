const Parser = @import("Parser.zig");
const Validator = @import("Validator.zig");

pub const Ast = @import("Ast.zig");
pub const Diagnostic = @import("Diagnostic.zig");
pub const parse = Parser.parse;
pub const validate = Validator.validate;

test {
    _ = @import("Tokenizer.zig");
    _ = Parser;
    _ = Diagnostic;
    _ = Validator;
    _ = Ast;
}
