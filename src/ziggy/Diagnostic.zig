const Diagnostic = @This();

const std = @import("std");
const Tokenizer = @import("Tokenizer.zig");
const Token = Tokenizer.Token;
const Writer = std.Io.Writer;

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

    pub const ZigError = error{
        Overflow,
        OutOfMemory,
        Syntax,
    };
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

    pub fn fmt(
        e: Error,
        mode: ErrorFmt.Mode,
        src: []const u8,
        path: ?[]const u8,
    ) ErrorFmt {
        return .{
            .mode = mode,
            .err = e,
            .src = src,
            .path = path,
        };
    }

    pub const ErrorFmt = struct {
        mode: Mode,
        err: Error,
        src: []const u8,
        path: ?[]const u8,

        pub const Mode = enum { lsp, cli };

        pub fn format(
            err_fmt: ErrorFmt,
            out_stream: *Writer,
        ) !void {
            const lsp = err_fmt.mode == .lsp;

            if (!lsp) {
                const sel = err_fmt.err.getErrorSelection();
                const start = sel.start;
                if (err_fmt.path) |p| {
                    try out_stream.print("{s}:{}:{}:\n", .{
                        p,
                        start.line,
                        start.col,
                    });
                } else {
                    try out_stream.print("line: {} col: {}:\n", .{
                        start.line,
                        start.col,
                    });
                }

                var it = std.mem.splitScalar(u8, err_fmt.src, '\n');
                for (1..sel.start.line) |_| _ = it.next().?;

                const line = it.next().?;
                const line_trim_left = std.mem.trimLeft(u8, line, &std.ascii.whitespace);
                // const start_trim_left = line_off.start + line_off.line.len - line_trim_left.len;

                const caret_len = if (sel.start.line == sel.end.line) sel.end.col - sel.start.col else line_trim_left.len;

                const caret_spaces_len = sel.start.col - 1;

                const line_trim = std.mem.trimRight(u8, line_trim_left, &std.ascii.whitespace);

                var hl_buf: [1024]u8 = undefined;

                const highlight = if (caret_len + caret_spaces_len < 1024) blk: {
                    const h = hl_buf[0 .. caret_len + caret_spaces_len];
                    @memset(h[0..caret_spaces_len], ' ');
                    @memset(h[caret_spaces_len..][0..caret_len], '^');
                    break :blk h;
                } else "";

                try out_stream.print(
                    \\    {s}
                    \\    {s}
                    \\
                , .{ line_trim, highlight });
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

pub fn fmt(d: Diagnostic, src: []const u8) Formatter {
    return .{ .diag = d, .src = src };
}

pub const Formatter = struct {
    diag: Diagnostic,
    src: []const u8,

    pub fn format(
        self: Formatter,
        out_stream: *Writer,
    ) !void {
        for (self.diag.errors.items) |e| {
            try e.fmt(.cli, self.src, self.diag.path).format(out_stream);
        }
    }
};
