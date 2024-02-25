const Diagnostic = @This();

const std = @import("std");
const Tokenizer = @import("Tokenizer.zig");
const Token = Tokenizer.Token;

/// The data being parsed, this field should not be set manually by users.
code: [:0]const u8 = "",

/// A path to the file, used to display diagnostics.
/// If not present, error positions will be printed as "line: XX col: XX".
/// This field should be set as needed by users.
path: ?[]const u8,

tok: Token = .{
    .tag = .eof,
    .loc = .{ .start = 0, .end = 0 },
},
err: Error = .none,

pub const Error = union(enum) {
    none,
    overflow,
    eof: struct {
        expected: []const Token.Tag,
    },
    unexpected_token: struct {
        expected: []const Token.Tag,
    },
    invalid_token,

    duplicate_field: struct {
        name: []const u8,
        first_loc: Token.Loc,
    },
    missing_field: struct {
        name: []const u8,
    },
    unknown_field,

    schema: struct {
        err: anyerror,
    },

    type_mismatch: struct {
        expected: []const u8,
    },

    missing_struct_name: struct {
        expected: []const u8,
    },

    wrong_struct_name: struct {
        expected: []const u8,
    },
};

pub fn debug(self: Diagnostic) void {
    std.debug.print("{}", .{self});
}

pub fn format(
    self: Diagnostic,
    comptime fmt: []const u8,
    options: std.fmt.FormatOptions,
    out_stream: anytype,
) !void {
    _ = options;

    const lsp = std.mem.eql(u8, fmt, "lsp");

    if (!lsp) {
        const start = self.tok.loc.getSelection(self.code).start;
        if (self.path) |p| {
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

    switch (self.err) {
        .none => {},
        .overflow => {
            try out_stream.print("overflow", .{});
            if (!lsp) {
                try out_stream.print(": '{s}'", .{
                    self.tok.loc.src(self.code),
                });
            }
        },
        .invalid_token => {
            try out_stream.print("invalid token", .{});
            if (!lsp) {
                try out_stream.print(": '{s}'", .{
                    self.tok.loc.src(self.code),
                });
            }
        },
        .eof => |eof| {
            if (!lsp) {
                try out_stream.print("unexpected EOF, ", .{});
            }
            try out_stream.print("expected: ", .{});

            for (eof.expected, 0..) |tag, idx| {
                try out_stream.print("'{s}'", .{tag.lexeme()});
                if (idx != eof.expected.len - 1) {
                    try out_stream.print(" or ", .{});
                }
            }

            try out_stream.print("\n", .{});
        },
        .unexpected_token => |u| {
            if (self.tok.tag == .eof) {
                if (!lsp) {
                    try out_stream.print("unexpected EOF, ", .{});
                }
                try out_stream.print("expected: ", .{});
            } else {
                if (!lsp) {
                    try out_stream.print("unexpected token: '{s}', ", .{
                        self.tok.loc.src(self.code),
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
            if (lsp) {
                try out_stream.print("duplicate field", .{});
            } else {
                const first_sel = dup.first_loc.getSelection(self.code);
                try out_stream.print("found duplicate field '{s}', first definition here:", .{
                    dup.name,
                });
                if (self.path) |p| {
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
            try out_stream.print(
                "missing field '{s}'",
                .{miss.name},
            );
        },
        .unknown_field => {
            const name = self.tok.loc.src(self.code);
            try out_stream.print(
                "unknown field '{s}'",
                .{name},
            );
        },

        .schema => |s| {
            try out_stream.print("schema file error: {s}", .{
                @errorName(s.err),
            });
        },

        .type_mismatch => |mism| {
            try out_stream.print(
                "type mismatch, expected '{s}'",
                .{mism.expected},
            );
        },

        .missing_struct_name => |msn| {
            if (lsp) {
                try out_stream.print(
                    "missing struct name, expected one of ({s})",
                    .{msn.expected},
                );
            } else {
                const struct_start = self.tok.loc.getSelection(self.code);
                try out_stream.print(
                    "missing struct name, expected '{s}'",
                    .{msn.expected},
                );
                if (self.path) |p| {
                    try out_stream.print("\n{s}:{}:{}\n", .{
                        p,
                        struct_start.start.line,
                        struct_start.start.col,
                    });
                } else {
                    try out_stream.print(" line: {} col: {}\n", .{
                        struct_start.start.line,
                        struct_start.start.col,
                    });
                }
            }
        },

        .wrong_struct_name => |wsn| {
            if (lsp) {
                try out_stream.print(
                    "wrong struct name, expected one of ({s})",
                    .{wsn.expected},
                );
            } else {
                const struct_name = self.tok.loc.getSelection(self.code);
                try out_stream.print(
                    "wrong struct name '{s}' expected '{s}'",
                    .{ self.tok.loc.src(self.code), wsn.expected },
                );
                if (self.path) |p| {
                    try out_stream.print("\n{s}:{}:{}\n", .{
                        p,
                        struct_name.start.line,
                        struct_name.start.col,
                    });
                } else {
                    try out_stream.print(" line: {} col: {}\n", .{
                        struct_name.start.line,
                        struct_name.start.col,
                    });
                }
            }
        },
    }
}
