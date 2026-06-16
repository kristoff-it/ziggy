const std = @import("std");
const Io = std.Io;
const ziggy = @import("ziggy");
const builtin = @import("builtin");

pub const std_options: std.Options = .{ .log_level = .err };

pub export fn zig_fuzz_init() void {}

pub export fn zig_fuzz_test(buf: [*:0]const u8, len: isize) void {
    // var gpa_impl: std.heap.DebugAllocator(.{}) = .{};
    // defer std.debug.assert(gpa_impl.deinit() == .ok);
    // const gpa = gpa_impl.allocator();

    var arena_state: std.heap.ArenaAllocator = .init(std.heap.page_allocator);
    defer arena_state.deinit();
    const gpa = arena_state.allocator();

    // @constCast(&buf[@intCast(len - 1)]).* = 0;
    // const src = buf[0..@intCast(len - 1) :0];

    const end = std.mem.indexOfScalar(u8, buf[0..@intCast(len)], 0) orelse return;
    const src = buf[0..end :0];

    // testAst(gpa, src);
    testAstSmith(gpa, src);
    // testDeserializer(gpa, src);

    // testSchemaAst(gpa, src);
}

fn eqlIgnoreWhitespace(a: [:0]const u8, b: [:0]const u8) void {
    var i: u32 = 0;
    var j: u32 = 0;

    outer: while (i < a.len) : (i += 1) {
        const a_byte = a[i];
        if (std.ascii.isWhitespace(a_byte)) continue;
        while (j < b.len) : (j += 1) {
            const b_byte = b[j];
            if (std.ascii.isWhitespace(b_byte)) continue;

            if (a_byte != b_byte) {
                // std.debug.print("---- orig ---\n{f}\n---- round1 ----\n{f}\n", .{
                //     std.zig.fmtString(a),
                //     std.zig.fmtString(b),
                // });
                std.debug.print("---- orig ---\n{s}\n---- round1 ----\n{s}\n", .{
                    a, b,
                });
                const a_span: ziggy.Tokenizer.Token.Loc = .{ .start = i, .end = i + 1 };
                const b_span: ziggy.Tokenizer.Token.Loc = .{ .start = j, .end = j + 1 };
                std.debug.panic("mismatch! [{c}] != [{c}] \na = {any}\nb={any}\n", .{
                    a_byte,
                    b_byte,
                    a_span.slice(a),
                    b_span.slice(b),
                });
            }

            j += 1;
            continue :outer;
        }
    }
}

fn testSchemaAst(gpa: std.mem.Allocator, src: [:0]const u8) void {
    const schema_ast = ziggy.schema.Ast.init(gpa, src) catch unreachable;
    defer schema_ast.deinit(gpa);

    if (!schema_ast.has_syntax_errors) {
        var r1_buf: Io.Writer.Allocating = .init(gpa);
        defer r1_buf.deinit();

        r1_buf.writer.print("{f}", .{schema_ast.fmt(src)}) catch unreachable;
        const round1 = r1_buf.toOwnedSliceSentinel(0) catch unreachable;

        eqlIgnoreWhitespace(src, round1);

        var r2_buf: Io.Writer.Allocating = .init(gpa);
        defer r2_buf.deinit();

        const schema_ast2 = ziggy.schema.Ast.init(gpa, round1) catch unreachable;
        defer schema_ast2.deinit(gpa);
        r2_buf.writer.print("{f}", .{schema_ast2.fmt(round1)}) catch unreachable;
        const round2 = r2_buf.toOwnedSliceSentinel(0) catch unreachable;

        std.testing.expectEqualStrings(round1, round2) catch {
            std.debug.panic("---- orig ----\n{s}[end]\n", .{src});
        };
    }
}

fn testAst(gpa: std.mem.Allocator, src: []const u8) void {
    const ast = ziggy.Ast.init(gpa, src, .{}) catch unreachable;
    defer ast.deinit(gpa);

    if (!ast.has_syntax_errors) {
        var r1_buf: Io.Writer.Allocating = .init(gpa);
        defer r1_buf.deinit();

        ast.render(src, &r1_buf.writer) catch unreachable;
        const round1 = r1_buf.toOwnedSliceSentinel(0) catch unreachable;

        const no_fixup = for (ast.errors) |err| {
            if (err.tag == .wrong_field_style) break false;
        } else true;

        if (no_fixup) eqlIgnoreWhitespace(src, round1);

        var r2_buf: Io.Writer.Allocating = .init(gpa);
        defer r2_buf.deinit();

        const ast2 = ziggy.Ast.init(gpa, round1, .{}) catch unreachable;
        defer ast2.deinit(gpa);
        ast2.render(round1, &r2_buf.writer) catch unreachable;
        const round2 = r2_buf.toOwnedSliceSentinel(0) catch unreachable;

        const ok = std.mem.eql(u8, round1, round2);
        if (!ok) {
            std.debug.panic("---- orig ----\n{s}[end]\n\n---- round1 ---\n{s}[end]\n---- round2 ----\n{s}[end]\n", .{
                src,
                round1,
                round2,
            });
        }
    }
}

fn testDeserializer(gpa: std.mem.Allocator, src: [:0]const u8) void {
    const types = .{
        f32,                    i32,    bool,
        []f32,                  []bool, ?f32,
        ?bool,                  []?f32, []?i32,
        []?bool,                bool,   []const u8,
        struct { a: i32 },
        struct {
            a: i32,
            b: bool,
        },
        struct {
            a: i32,
            b: bool,
            c: []const u8,
        },
        struct {
            a: i32 = 0,
            b: bool = true,
            c: []const u8 = "banana",
        },
        union(enum) { a: i32 },
        union(enum) {
            a: i32,
            b: bool,
        },
        union(enum) {
            a: i32,
            b: bool,
            c: []const u8,
        },
        union(enum) {
            a: i32,
            b: bool,
            c: []const u8,
        },
    };

    inline for (types) |T| testDeserializeType(T, gpa, src);
}

fn testDeserializeType(T: type, gpa: std.mem.Allocator, src: [:0]const u8) void {
    var meta: ziggy.Deserializer.Meta = .init;
    const res = ziggy.deserializeLeaky(T, gpa, src, &meta, .{}) catch |err| {
        std.debug.assert(err != error.OutOfMemory);
        std.debug.print("{f}", .{
            meta.reportErrorsFmt(gpa, .{}, null, src, err),
        });
        return;
    };

    var aw: Io.Writer.Allocating = .init(gpa);
    const w = &aw.writer;

    ziggy.serialize(res, .{}, w) catch unreachable;

    const round1 = aw.toOwnedSliceSentinel(0) catch unreachable;

    meta = .init;
    const res1 = ziggy.deserializeLeaky(T, gpa, round1, &meta, .{}) catch |err| {
        std.debug.print("---- orig ----\n{s}\n---- round1 ----\n{s}[end]\n", .{
            src,
            round1,
        });

        std.debug.assert(err != error.OutOfMemory);
        std.debug.print("{f}", .{
            meta.reportErrorsFmt(gpa, .{}, null, src, err),
        });

        unreachable;
    };

    // switch (@typeInfo(T)) {
    //     .@"union" => res1.a += 1,
    //     else => {},
    // }

    std.testing.expectEqualDeep(res, res1) catch {
        std.debug.print("---- orig ----\n{s}\n---- round1 ----\n{s}[end]\n", .{
            src,
            round1,
        });
        unreachable;
    };
}

fn testAstSmith(gpa: std.mem.Allocator, raw: []const u8) void {
    const src = doc_smith.build(gpa, raw) catch unreachable;
    const ast = ziggy.Ast.init(gpa, src, .{}) catch unreachable;
    defer ast.deinit(gpa);

    std.debug.assert(!ast.has_syntax_errors);

    // var r1_buf: Io.Writer.Allocating = .init(gpa);
    // defer r1_buf.deinit();

    // ast.render(src, &r1_buf.writer) catch unreachable;
    // const round1 = r1_buf.toOwnedSliceSentinel(0) catch unreachable;

    // const no_fixup = for (ast.errors) |err| {
    //     if (err.tag == .wrong_field_style) break false;
    // } else true;

    // if (no_fixup) eqlIgnoreWhitespace(src, round1);

    // var r2_buf: Io.Writer.Allocating = .init(gpa);
    // defer r2_buf.deinit();

    // const ast2 = ziggy.Ast.init(gpa, round1, .{}) catch unreachable;
    // defer ast2.deinit(gpa);
    // ast2.render(round1, &r2_buf.writer) catch unreachable;
    // const round2 = r2_buf.toOwnedSliceSentinel(0) catch unreachable;

    // const ok = std.mem.eql(u8, round1, round2);
    // if (!ok) {
    //     std.debug.panic("---- orig ----\n{s}[end]\n\n---- round1 ---\n{s}[end]\n---- round2 ----\n{s}[end]\n", .{
    //         src,
    //         round1,
    //         round2,
    //     });
    // }
}

pub const doc_smith = struct {
    const Op = enum(u8) {
        // add comment
        comment = 'c',
        // add newline
        newline = 'n',
        // add space,
        space = 'w',

        // add null
        null = 'N',
        // add bool
        bool = 'b',
        // add bytes
        bytes = 'B',
        // add int
        int = 'i',
        // add float
        float = 'f',
        // add slice
        slice = 'l',
        // add struct
        @"struct" = 's',
        // add dict
        dict = 'd',
        // add union
        @"union" = 'u',

        // up
        up = 'U',

        // return
        _,
    };

    pub fn build(gpa: std.mem.Allocator, src: []const u8) ![:0]const u8 {
        var out: std.Io.Writer.Allocating = .init(gpa);
        var stack: std.ArrayList(ziggy.Tokenizer.Token.Tag) = .empty;
        const w = &out.writer;

        try buildInternal(w, gpa, src, &stack);

        while (stack.pop()) |last| {
            try w.writeAll(switch (last) {
                .lsb => "]",
                .dotlb, .lb => "}",
                .union_case => ")",
                else => unreachable,
            });
        }

        return out.toOwnedSliceSentinel(0);
    }

    fn buildInternal(
        w: anytype,
        gpa: std.mem.Allocator,
        src: []const u8,
        stack: *std.ArrayList(ziggy.Tokenizer.Token.Tag),
    ) !void {
        const max = 2;
        var newlines: u32 = 0;
        var spaces: u32 = 0;
        var comments: u32 = 0;
        var one = false;

        var idx: u32 = 0;
        while (idx < src.len) : (idx += 1) {
            const c = src[idx];
            const op: Op = @enumFromInt(c);

            switch (op) {
                .newline => newlines = 0,
                .space => spaces = 0,
                .comment => comments = 0,
                else => if (one and stack.items.len == 0) {
                    return;
                } else {
                    one = true;
                },
            }

            switch (op) {

                // add comment
                .comment => {
                    if (comments < max) try w.writeAll("//comment\n") else return;
                    comments += 1;
                },
                // add newline
                .newline => {
                    if (newlines < max) try w.writeAll("\n") else return;
                    newlines += 1;
                },
                // add space,
                .space => {
                    if (spaces < max) try w.writeAll(" ") else return;
                    spaces += 1;
                },

                .null, .bool, .bytes, .int, .float => {
                    const elem: []const u8 = switch (op) {
                        // add null
                        .null => "null",
                        // add bool
                        .bool => "true",
                        // add bytes
                        .bytes => "\"string\"",
                        // add int
                        .int => "1",
                        // add float
                        .float => "1.0",
                        else => unreachable,
                    };

                    if (stack.last()) |last| switch (last.*) {
                        .lsb => try w.print("{s},", .{elem}),
                        .union_case => {
                            try w.print("{s})", .{elem});
                            _ = stack.pop();

                            while (stack.last()) |next| {
                                if (next.* != .union_case) {
                                    try w.writeAll(",");
                                    break;
                                }
                                try w.writeAll(")");
                                _ = stack.pop();
                            }
                        },
                        .dotlb => try w.print(".field{} = {s},", .{
                            idx,
                            elem,
                        }),
                        .lb => try w.print("\"field{}\": {s},", .{ idx, elem }),

                        else => unreachable,
                    } else {
                        try w.writeAll(elem);
                        return;
                    }
                },

                .slice, .@"struct", .dict => {
                    const tag: ziggy.Tokenizer.Token.Tag = switch (op) {
                        // add slice
                        .slice => .lsb,
                        // add struct
                        .@"struct" => .dotlb,
                        // add dict
                        .dict => .lb,
                        else => unreachable,
                    };
                    const lexeme = switch (tag) {
                        .lsb => "[",
                        .dotlb => ".{",
                        .lb => "{",
                        else => unreachable,
                    };

                    if (stack.last()) |last| switch (last.*) {
                        .lsb, .union_case => try w.writeAll(lexeme),
                        .dotlb => try w.print(".field{} = {s}", .{
                            idx,
                            lexeme,
                        }),
                        .lb => try w.print("\"field{}\": {s}", .{ idx, lexeme }),
                        else => unreachable,
                    } else {
                        try w.writeAll(lexeme);
                    }

                    try stack.append(gpa, tag);
                },

                // add union
                .@"union" => {
                    if (stack.last()) |last| switch (last.*) {
                        .lsb, .union_case => try w.print(".case{}(", .{idx}),
                        .dotlb => try w.print(".field{} = .case{}(", .{ idx, idx }),
                        .lb => try w.print("\"field{}\": .case{}(", .{ idx, idx }),
                        else => unreachable,
                    } else {
                        try w.print(".case{}(", .{idx});
                    }

                    try stack.append(gpa, .union_case);

                    var next_idx = idx + 1;
                    const valid = while (next_idx < src.len) {
                        const next_op: Op = @enumFromInt(src[next_idx]);
                        switch (next_op) {
                            .null,
                            .bool,
                            .bytes,
                            .int,
                            .float,
                            .slice,
                            .@"struct",
                            .dict,
                            .@"union",
                            => break true,
                            .up => break false,
                            .comment, .newline, .space => next_idx += 1,
                            else => break false,
                        }
                    } else false;

                    if (!valid) {
                        try w.writeAll("999");
                        return;
                    }
                },

                // up
                .up => {
                    while (true) {
                        const last = stack.pop() orelse return;
                        try w.writeAll(switch (last) {
                            .lsb => "]",
                            .dotlb, .lb => "}",
                            .union_case => ")",
                            else => unreachable,
                        });

                        if (stack.last()) |next| {
                            if (next.* != .union_case) {
                                try w.writeAll(",");
                                break;
                            }
                        }
                    }
                },

                // return
                else => return,
            }
        }
    }
};
