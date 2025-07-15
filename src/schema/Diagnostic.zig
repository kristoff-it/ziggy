const Diagnostic = @This();

const std = @import("std");
const Tokenizer = @import("Tokenizer.zig");
const Token = Tokenizer.Token;
const Writer = std.Io.Writer;

/// The data being parsed, this field should not be set manually by users.
code: [:0]const u8 = "",

/// A path to the file, used to display diagnostics.
/// If not present, error positions will be printed as "line: XX col: XX".
/// This field should be set as needed by users.
path: ?[]const u8,

/// Enable for LSP-style formatted printing of errors
lsp: bool,

tok: Token = .{
    .tag = .eof,
    .loc = .{ .start = 0, .end = 0 },
},
err: Error = .none,

pub const Error = union(enum) {
    none,
    unexpected_token: struct {
        expected: []const Token.Tag,
    },
    invalid_token,

    duplicate_field: struct {
        first_loc: Token.Loc,
    },
    missing_field: struct {
        name: []const u8,
    },
    empty_enum,
    unknown_field,
};

pub fn debug(self: Diagnostic) void {
    std.debug.print("{}", .{self});
}

pub fn format(
    d: Diagnostic,
    out_stream: *Writer,
) !void {
    if (!d.lsp) {
        const start = d.tok.loc.getSelection(d.code).start;
        if (d.path) |p| {
            try out_stream.print("{s}:{}:{}\n", .{
                p,
                start.line,
                start.col,
            });
        } else {
            try out_stream.print("line: {} col: {}\n", .{
                start.line,
                start.col,
            });
        }
    }

    switch (d.err) {
        .none => {},
        .empty_enum => {
            try out_stream.print("empty enum", .{});
        },
        .invalid_token => {
            try out_stream.print("invalid token", .{});
            if (!d.lsp) {
                try out_stream.print(": '{s}'", .{
                    d.tok.loc.src(d.code),
                });
            }
        },
        .unexpected_token => |u| {
            if (d.tok.tag == .eof) {
                if (!d.lsp) {
                    try out_stream.print("unexpected EOF, ", .{});
                }
                try out_stream.print("expected: ", .{});
            } else {
                if (!d.lsp) {
                    try out_stream.print("unexpected token: '{s}', ", .{
                        d.tok.loc.src(d.code),
                    });
                }
                try out_stream.print("expected: ", .{});
            }

            for (u.expected, 0..) |tag, idx| {
                try out_stream.print("'{s}'", .{tag.lexeme()});
                if (idx != u.expected.len - 1) {
                    try out_stream.print(" or ", .{});
                }
            }

            try out_stream.print("\n", .{});
        },
        .duplicate_field => |dup| {
            if (d.lsp) {
                try out_stream.print("duplicate field", .{});
            } else {
                const first_sel = dup.first_loc.getSelection(d.code);
                try out_stream.print("found duplicate field '{s}', first definition here:", .{
                    d.tok.loc.src(d.code),
                });
                if (d.path) |p| {
                    try out_stream.print("\n{s}:{}:{}\n", .{
                        p,
                        first_sel.start.line,
                        first_sel.start.col,
                    });
                } else {
                    try out_stream.print(" line: {} col: {}\n", .{
                        first_sel.start.line,
                        first_sel.start.col,
                    });
                }
            }
        },
        .missing_field => |miss| {
            if (d.lsp) {
                try out_stream.print(
                    "missing field '{s}'",
                    .{miss.name},
                );
            } else {
                const struct_end = d.tok.loc.getSelection(d.code);
                try out_stream.print(
                    "missing field '{s}', struct ends here:",
                    .{miss.name},
                );
                if (d.path) |p| {
                    try out_stream.print("\n{s}:{}:{}\n", .{
                        p,
                        struct_end.start.line,
                        struct_end.start.col,
                    });
                } else {
                    try out_stream.print(" line: {} col: {}\n", .{
                        struct_end.start.line,
                        struct_end.start.col,
                    });
                }
            }
        },
        .unknown_field => {
            const name = d.tok.loc.src(d.code);
            if (d.lsp) {
                try out_stream.print(
                    "unknown field '{s}'",
                    .{name},
                );
            } else {
                const selection = d.tok.loc.getSelection(d.code);
                try out_stream.print(
                    "unknown field '{s}' found here:",
                    .{name},
                );
                if (d.path) |p| {
                    try out_stream.print("\n{s}:{}:{}\n", .{
                        p,
                        selection.start.line,
                        selection.start.col,
                    });
                } else {
                    try out_stream.print(" line: {} col: {}\n", .{
                        selection.start.line,
                        selection.start.col,
                    });
                }
            }
        },
    }
}
