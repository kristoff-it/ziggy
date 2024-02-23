pub const Tokenizer = @import("ziggy/Tokenizer.zig");
pub const Parser = @import("ziggy/Parser.zig");
pub const Value = @import("ziggy/Value.zig");
pub const Ast = @import("ziggy/Ast.zig");
pub const Diagnostic = @import("ziggy/Diagnostic.zig");
pub const parseLeaky = Parser.parseLeaky;

test {
    _ = Tokenizer;
    _ = Parser;
    _ = Diagnostic;
    _ = Ast;
    _ = Value;
}

pub const schema = struct {
    pub const Diagnostic = @import("schema/Diagnostic.zig");
    pub const Tokenizer = @import("schema/Tokenizer.zig");
    pub const Schema = @import("schema/Schema.zig");
    pub const Ast = @import("schema/Ast.zig");
};

test {
    _ = schema.Diagnostic;
    _ = schema.Tokenizer;
    _ = schema.Schema;
    _ = schema.Ast;
}
