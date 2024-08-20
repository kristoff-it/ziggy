const Diagnostic = @This();

const std = @import("std");
const Tokenizer = @import("Tokenizer.zig");
const Token = Tokenizer.Token;

/// A path to the file, used to display diagnostics.
/// If not present, error positions will be printed as "line: XX col: XX".
/// This field should be set as needed by users.
path: ?[]const u8,

errors: std.ArrayListUnmanaged(Error) = .{},

pub const Error = union(enum) {
    overflow,
    oom,
    // found an unexpected $name (token, ...)
    unexpected: struct {
        name: []const u8,
        sel: Token.Loc.Selection,
        expected: []const []const u8,
    },
    // Invalid syntax, eg 123ab123, use `unexpected` to also report an expected
    // token / value / etc.
    syntax: struct {
        name: []const u8,
        sel: Token.Loc.Selection,
    },
    duplicate_field: struct {
        name: []const u8,
        sel: Token.Loc.Selection,
        original: Token.Loc.Selection,
    },
    // A struct is missing a field and it has no missing_field_name nodes.
    missing_field: struct {
        name: []const u8,
        sel: Token.Loc.Selection,
    },
    unknown_field: struct {
        name: []const u8,
        sel: Token.Loc.Selection,
    },
    // If the value is a struct union, the struct value must have a name.
    missing_struct_name: struct {
        // the area where the name shuld be put
        sel: Token.Loc.Selection,
        // the expected type expression from schema
        expected: []const u8,
    },
    unknown_struct_name: struct {
        name: []const u8,
        sel: Token.Loc.Selection,
        // the expected type expression from schema
        expected: []const u8,
    },
    missing_value: struct {
        // the area where the name shuld be put
        sel: Token.Loc.Selection,
        // the expected type expression from schema
        expected: []const u8,
    },
    // The schema corresponding to this file could not be loaded
    // (missing file, contains sytnax errors, etc).
    schema: struct {
        sel: Token.Loc.Selection,
        // the error encountered while processing the schema file
        err: []const u8,
    },

    type_mismatch: struct {
        name: []const u8,
        sel: Token.Loc.Selection,
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

    pub fn getErrorSelection(e: Error) Token.Loc.Selection {
        return switch (e) {
            .overflow, .oom => .{
                .start = .{ .line = 0, .col = 0 },
                .end = .{ .line = 0, .col = 0 },
            },
            inline else => |x| x.sel,
        };
    }

    pub fn fmt(e: Error, path: ?[]const u8) ErrorFmt {
        return .{
            .err = e,
            .path = path,
        };
    }
    pub const ErrorFmt = struct {
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
                const start = err_fmt.err.getErrorSelection().start;
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
                .unexpected => |u| {
                    try out_stream.print("unexpected '{s}'", .{u.name});

                    try out_stream.print(", expected: ", .{});

                    for (u.expected, 0..) |elem, idx| {
                        try out_stream.print("'{s}'", .{elem});
                        if (idx != u.expected.len - 1) {
                            try out_stream.print(" or ", .{});
                        }
                    }

                    try out_stream.print("\n", .{});
                },
                .syntax => |syn| {
                    if (lsp) {
                        try out_stream.print("syntax error\n", .{});
                    } else {
                        try out_stream.print("syntax error: '{s}' \n", .{syn.name});
                    }
                },
                .duplicate_field => |dup| {
                    if (lsp) {
                        try out_stream.print("duplicate field", .{});
                    } else {
                        const first_sel = dup.original;
                        try out_stream.print(
                            "duplicate field '{s}', first definition here:",
                            .{dup.name},
                        );
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
                .missing_field => |mf| {
                    try out_stream.print("missing field: '{s}'", .{mf.name});
                },
                .unknown_field => |uf| {
                    try out_stream.print("unknown field '{s}'", .{uf.name});
                },
                .missing_struct_name => |msn| {
                    try out_stream.print(
                        "struct union requires name, expected: '{s}'\n",
                        .{msn.expected},
                    );
                },
                .unknown_struct_name => |usn| {
                    try out_stream.print(
                        "unknown struct name, expected: '{s}'\n",
                        .{usn.expected},
                    );
                },

                .missing_value => |mv| {
                    try out_stream.print(
                        "missing value, expected: {s}\n",
                        .{mv.expected},
                    );
                },
                .schema => |s| {
                    try out_stream.print("schema file error: {s}", .{
                        s.err,
                    });
                },

                .type_mismatch => |mism| {
                    try out_stream.print(
                        "wrong value type, expected {s}",
                        .{mism.expected},
                    );
                },
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
        try e.fmt(self.path).format(fmt, options, out_stream);
    }
}
