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
    testDeserializer(gpa, src);

    // testSchemaAst(gpa, src);

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
        if (true) return;

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
