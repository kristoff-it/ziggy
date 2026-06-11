const std = @import("std");
const ziggy = @import("ziggy");
const test_type = @import("test_type");
const CaseType = test_type.Case;

pub fn main(init: std.process.Init) !void {
    const io = init.io;
    const arena = init.arena.allocator();

    const args = try init.minimal.args.toSlice(arena);
    const case = try std.Io.Dir.cwd().readFileAllocOptions(
        io,
        args[1],
        arena,
        .limited(ziggy.max_size),
        .of(u8),
        0,
    );

    var meta: ziggy.Deserializer.Meta = .init;
    _ = ziggy.deserializeLeaky(
        CaseType,
        arena,
        case,
        &meta,
        .{},
    ) catch |err| {
        std.debug.print("{f}", .{
            meta.reportErrorsFmt(
                arena,
                .{},
                std.fs.path.basename(args[1]),
                case,
                err,
            ),
        });
        std.process.exit(1);
    };

    @panic("unreachable");
}
