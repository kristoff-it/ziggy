const Parser = @import("Parser.zig");

pub const parse = Parser.parse;

test {
    _ = @import("Tokenizer.zig");
    _ = Parser;
}
