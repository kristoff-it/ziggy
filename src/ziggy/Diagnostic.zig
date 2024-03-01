const Diagnostic = @This();

const std = @import("std");
const Tokenizer = @import("Tokenizer.zig");
const Token = Tokenizer.Token;

/// A path to the file, used to display diagnostics.
/// If not present, error positions will be printed as "line: XX col: XX".
/// This field should be set as needed by users.
path: ?[]const u8,

/// The data being parsed, this field should not be set manually by users.
code: [:0]const u8 = "",
errors: std.ArrayListUnmanaged(Error) = .{},

pub const Error = union(enum) {
    overflow,
    oom,
    eof: struct {
        expected: []const Token.Tag,
    },
    unexpected_token: struct {
        token: Token,
        expected: []const Token.Tag,
    },
    invalid_token: struct {
        token: Token,
    },
    duplicate_field: struct {
        token: Token,
        original: Token.Loc,
    },
    missing: struct {
        token: Token,
        expected: []const u8,
    },
    unknown: struct {
        token: Token,
        expected: []const u8,
    },
    schema: struct {
        loc: Token.Loc,
        err: anyerror,
    },
    type_mismatch: struct {
        token: Token,
        expected: []const u8,
    },

    pub const ZigError = error{ Overflow, OutOfMemory, Syntax };
    pub fn zigError(e: Error) ZigError {
        return switch (e) {
            .overflow => error.Overflow,
            .oom => error.OutOfMemory,
            else => error.Syntax,
        };
    }

    pub fn getErrorSelection(e: Error, code: [:0]const u8) Token.Loc.Selection {
        return switch (e) {
            .overflow, .oom => .{
                .start = .{ .line = 0, .col = 0 },
                .end = .{ .line = 0, .col = 0 },
            },
            .eof => {
                const loc: Token.Loc = .{
                    .start = @intCast(code.len - 1),
                    .end = @intCast(code.len),
                };
                return loc.getSelection(code);
            },
            .schema => |s| return s.loc.getSelection(code),
            inline else => |x| x.token.loc.getSelection(code),
        };
    }

    pub fn fmt(e: Error, code: [:0]const u8, path: ?[]const u8) ErrorFmt {
        return .{
            .err = e,
            .code = code,
            .path = path,
        };
    }
    pub const ErrorFmt = struct {
        code: [:0]const u8,
        path: ?[]const u8,
        err: Error,

        pub fn format(
            err_fmt: ErrorFmt,
            comptime fmt_string: []const u8,
            options: std.fmt.FormatOptions,
            out_stream: anytype,
        ) !void {
            _ = options;

            const lsp = std.mem.eql(u8, fmt_string, "lsp");

            if (!lsp) {
                const start = err_fmt.err.getErrorSelection(err_fmt.code).start;
                if (err_fmt.path) |p| {
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

            switch (err_fmt.err) {
                .oom => try out_stream.print("out of memory\n", .{}),
                .overflow => {
                    try out_stream.print("overflow\n", .{});
                    // if (!lsp) {
                    //     try out_stream.print(": '{s}'", .{
                    //         o.token.loc.src(err_fmt.code),
                    //     });
                    // }
                },
                .invalid_token => |i| {
                    try out_stream.print("invalid token", .{});
                    if (!lsp) {
                        try out_stream.print(": '{s}'", .{
                            i.token.loc.src(err_fmt.code),
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
                    if (u.token.tag == .eof) {
                        if (!lsp) {
                            try out_stream.print("unexpected EOF, ", .{});
                        }
                        try out_stream.print("expected: ", .{});
                    } else {
                        if (!lsp) {
                            try out_stream.print("unexpected token: '{s}', ", .{
                                u.token.loc.src(err_fmt.code),
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
                        const first_sel = dup.original.getSelection(err_fmt.code);
                        try out_stream.print("found duplicate field '{s}', first definition here:", .{
                            dup.original.src(err_fmt.code),
                        });
                        if (err_fmt.path) |p| {
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
                .missing => |miss| {
                    try out_stream.print(
                        "missing '{s}'",
                        .{miss.expected},
                    );
                },
                .unknown => |u| {
                    const name = u.token.loc.src(err_fmt.code);
                    try out_stream.print(
                        "unknown '{s}'",
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

                // .missing_struct_name => |msn| {
                //     if (lsp) {
                //         try out_stream.print(
                //             "missing struct name, expected one of ({s})",
                //             .{msn.expected},
                //         );
                //     } else {
                //         const struct_start = msn.token.loc.getSelection(err_fmt.code);
                //         try out_stream.print(
                //             "missing struct name, expected '{s}'",
                //             .{msn.expected},
                //         );
                //         if (err_fmt.path) |p| {
                //             try out_stream.print("\n{s}:{}:{}\n", .{
                //                 p,
                //                 struct_start.start.line,
                //                 struct_start.start.col,
                //             });
                //         } else {
                //             try out_stream.print(" line: {} col: {}\n", .{
                //                 struct_start.start.line,
                //                 struct_start.start.col,
                //             });
                //         }
                //     }
                // },

                // .wrong_struct_name => |wsn| {
                //     if (lsp) {
                //         try out_stream.print(
                //             "wrong struct name, expected one of ({s})",
                //             .{wsn.expected},
                //         );
                //     } else {
                //         const struct_name = wsn.token.loc.getSelection(err_fmt.code);
                //         try out_stream.print(
                //             "wrong struct name '{s}' expected '{s}'",
                //             .{ wsn.token.loc.src(err_fmt.code), wsn.expected },
                //         );
                //         if (err_fmt.path) |p| {
                //             try out_stream.print("\n{s}:{}:{}\n", .{
                //                 p,
                //                 struct_name.start.line,
                //                 struct_name.start.col,
                //             });
                //         } else {
                //             try out_stream.print(" line: {} col: {}\n", .{
                //                 struct_name.start.line,
                //                 struct_name.start.col,
                //             });
                //         }
                //     }
                // },
            }
        }
    };
};

pub fn deinit(self: *Diagnostic, gpa: std.mem.Allocator) void {
    self.errors.deinit(gpa);
}

pub fn debug(self: Diagnostic) void {
    std.debug.print("{}", .{self});
}

pub fn format(
    self: Diagnostic,
    comptime fmt: []const u8,
    options: std.fmt.FormatOptions,
    out_stream: anytype,
) !void {
    for (self.errors.items) |e| {
        try e.fmt(self.code, self.path).format(fmt, options, out_stream);
    }
}
