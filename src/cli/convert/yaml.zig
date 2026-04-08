const builtin = @import("builtin");
const std = @import("std");
const Allocator = std.mem.Allocator;
const Io = std.Io;
const yaml = @import("yaml");
const Command = @import("../convert.zig").Command;

pub fn convert(gpa: Allocator, src: [:0]const u8, schema: ?Command.Schema) ![]const u8 {
    const aw: Io.Writer.Allocating = .init(gpa);
    const out = &aw.writer;

    if (true) @panic("TODO");

    var p: yaml.Parser = try .init(gpa, src);
    p.parse(gpa) catch |err| {
        if (err == error.OutOfMemory) oom();
        const errors = try p.errors.toOwnedBundle("");
        errors.renderToStdErr(.{}, .auto);
        return error.Failure;
    };

    std.debug.print("convert no errors!", .{});
    const tree = try p.toOwnedTree(gpa);

    _ = tree;
    _ = out;
    _ = schema;

    return "";
}

const Iterator = struct {
    nodes: []const Node,
    state: union(Direction) {
        enter: struct {
            from_idx: u32,
            next_idx: u32,
        },
        exit: struct {
            next_idx: u32,
            target_parent_idx: u32,
            target_idx: u32,
        },
        done: u32,
    } = .{ .enter = .{ .from_idx = 0, .next_idx = 1 } },

    const Event = union(enum) {
        enter: *yaml.Parser.Node,
        exit: *yaml.Parser.Node,
        done,
    };
    fn next(it: *Iterator) Event {
        next: switch (it.state) {
            .enter => |enter| {
                assert(enter.next_idx != 0);
                const from_node = &it.nodes[enter.from_idx];
                const next_node = &it.nodes[enter.next_idx];
                // child or current node is no_exit and next is sibling
                if (next_node.parent_idx == enter.from_idx or
                    (no_exit and next_node.parent_idx == from_node.parent_idx))
                {
                    it.state.enter = .{
                        .from_idx = enter.next_idx,
                        .next_idx = enter.next_idx + 1,
                    };
                    return .{ .enter = next_node };
                }

                assert(next_node.parent_idx <= from_node.parent_idx);
                it.state = .{
                    .exit = .{
                        .next_idx = if (no_exit) from_node.parent_idx else enter.from_idx,
                        .target_parent_idx = next_node.parent_idx,
                        .target_idx = enter.next_idx,
                    },
                };
                continue :next it.state;
            },
        }
    }
};

fn fatal(comptime fmt: []const u8, args: anytype) noreturn {
    std.debug.print("fatal error: " ++ fmt ++ "\n", args);
    if (builtin.mode == .Debug) @breakpoint();
    std.process.exit(1);
}

fn oom() noreturn {
    fatal("out of memory", .{});
}
