pub const Tokenizer = @import("ziggy/Tokenizer.zig");
pub const Parser = @import("ziggy/Parser.zig");
pub const dynamic = @import("ziggy/dynamic.zig");
pub const Ast = @import("ziggy/Ast.zig");
pub const Diagnostic = @import("ziggy/Diagnostic.zig");
pub const parseLeaky = Parser.parseLeaky;
pub const serializer = @import("ziggy/serializer.zig");
pub const stringify = serializer.stringify;

pub const frontmatter = @import("ziggy/frontmatter.zig");

pub const lsp_parser: enum { recover, resilient } = .resilient;
pub const LanguageServerAst = switch (lsp_parser) {
    .recover => @import("ziggy/RecoverAst.zig"),
    .resilient => @import("ziggy/ResilientParser.zig"),
};

// Ziggy documents and schemas can have a maximum size of 4GB
pub const max_size = 4 * 1024 * 1024 * 1024;

test {
    _ = Tokenizer;
    _ = Parser;
    _ = Diagnostic;
    _ = Ast;

    _ = dynamic;
    _ = serializer;
    _ = @import("ziggy/RecoverAst.zig");
    _ = @import("ziggy/ResilientParser.zig");
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
