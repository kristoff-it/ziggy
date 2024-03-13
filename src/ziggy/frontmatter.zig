const std = @import("std");
const ziggy = @import("../root.zig");

const log = std.log.scoped(.frontmatter);

/// Creates a parser that tries to parse a Header out of the frontmatter.
pub fn Parser(comptime Header: type) type {
    return struct {
        const Result = union(enum) {
            success: struct {
                code: [:0]const u8,
                header: Header,
            },

            /// The frontmatter is framed correctly but the Ziggy data is
            /// malformed
            ziggy_error: ziggy.Diagnostic,

            /// Missing closing '---'.
            framing_error: struct {
                line: usize,
            },
            /// The document is empty
            empty,
        };

        /// The stream will be read up until the closing '---' line of the
        /// frontmatter in both the success and the ziggy_error case.
        pub fn parse(gpa: std.mem.Allocator, reader: anytype, path: ?[]const u8) !Result {
            var error_line: usize = 0;
            const code = findZiggy(gpa, reader, &error_line) catch |err| switch (err) {
                error.Framing => {
                    return .{
                        .framing_error = .{ .line = error_line },
                    };
                },
                error.Empty => return .empty,
                else => return err,
            };

            var diag: ziggy.Diagnostic = .{ .path = path };
            const header = ziggy.parseLeaky(Header, gpa, code, .{ .diagnostic = &diag }) catch {
                return .{ .ziggy_error = diag };
            };

            return .{
                .success = .{
                    .header = header,
                    .code = code,
                },
            };
        }

        fn findZiggy(gpa: std.mem.Allocator, reader: anytype, line_ptr: *usize) ![:0]const u8 {
            line_ptr.* = 1;

            var buf = std.ArrayList(u8).init(gpa);
            errdefer buf.deinit();

            const first_line = while (true) {
                reader.readUntilDelimiterArrayList(&buf, '\n', ziggy.max_size) catch |err| switch (err) {
                    error.EndOfStream => {
                        if (std.mem.trim(u8, buf.items, "\r ").len == 0) {
                            return error.Empty;
                        } else {
                            return error.Framing;
                        }
                    },
                    else => return err,
                };

                const first_line = std.mem.trimRight(u8, buf.items, "\r ");
                if (first_line.len != 0) break first_line;
            };

            if (!std.mem.eql(u8, first_line, "---")) {
                return error.Framing;
            }

            // Reset the buffer to remove the framing line
            buf.clearRetainingCapacity();
            var last_len: usize = 0;
            var done = false;
            while (!done) {
                reader.streamUntilDelimiter(buf.writer(), '\n', ziggy.max_size) catch |err| switch (err) {
                    error.EndOfStream => done = true,
                    else => return err,
                };

                const line = buf.items[last_len..];
                const tl = std.mem.trimRight(u8, line, "\r ");

                if (std.mem.eql(u8, tl, "---")) {
                    buf.resize(last_len) catch unreachable;
                    return buf.toOwnedSliceSentinel(0);
                }

                try buf.append('\n');
                line_ptr.* += 1;
                last_len = buf.items.len;
            }

            return error.Framing;
        }
    };
}
