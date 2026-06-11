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

    // if (html_ast.errors.len == 0) {
    //     const super_ast = super.Ast.init(gpa, html_ast, src) catch unreachable;
    //     defer super_ast.deinit(gpa);
    // }

    // if (html_ast.errors.len == 0) {
    //     var out: std.Io.Writer.Allocating = .init(gpa);
    //     defer out.deinit();

    //     html_ast.render(src, &out.writer) catch unreachable;

    //     eqlIgnoreWhitespace(src, out.written());

    //     var full_circle: std.Io.Writer.Allocating = .init(gpa);
    //     defer full_circle.deinit();

    //     const html_ast1 = super.html.Ast.init(gpa, out.written(), .superhtml, false) catch unreachable;
    //     defer html_ast1.deinit(gpa);

    //     if (html_ast1.errors.len > 0) {
    //         std.debug.panic("---- orig ----\n{s}[end]\n\n---- round1 ---\n{s}[end]\n", .{
    //             src,
    //             out.written(),
    //         });
    //     }

    //     html_ast1.render(out.written(), &full_circle.writer) catch unreachable;

    //     const super_ast = super.Ast.init(gpa, html_ast, src) catch unreachable;
    //     defer super_ast.deinit(gpa);
    // }
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

            if (std.ascii.toUpper(a_byte) != std.ascii.toUpper(b_byte)) {
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
