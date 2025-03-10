const std = @import("std");
const ziggy = @import("ziggy");
const test_type = @import("test_type");
const CaseType = test_type.Case;

pub fn main() !void {
    var gpa_state: std.heap.DebugAllocator(.{}) = .init;
    var arena_state = std.heap.ArenaAllocator.init(gpa_state.allocator());
    defer arena_state.deinit();
    const arena = arena_state.allocator();

    const args = try std.process.argsAlloc(arena);
    const case = try std.fs.cwd().readFileAllocOptions(
        arena,
        args[1],
        ziggy.max_size,
        null,
        1,
        0,
    );

    var diag: ziggy.Diagnostic = .{ .path = null };
    _ = ziggy.parseLeaky(CaseType, arena, case, .{
        .diagnostic = &diag,
    }) catch |err| {
        if (err != error.Syntax) @panic("wrong error!");
        std.debug.print("{s}", .{diag.fmt(case)});
        std.process.exit(1);
    };

    @panic("unreachable");
}
