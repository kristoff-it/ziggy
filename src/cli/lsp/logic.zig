const std = @import("std");
const lsp = @import("lsp");
const ziggy = @import("ziggy");
const Handler = @import("../lsp.zig").Handler;
const Document = @import("Document.zig");
const Schema = @import("Schema.zig");

pub const Language = enum { ziggy, ziggy_schema, supermd };
pub const File = union(Language) {
    ziggy: Document,
    ziggy_schema: Schema,
    supermd: Document,

    pub fn deinit(f: *File) void {
        switch (f.*) {
            inline else => |*x| x.deinit(),
        }
    }
};

const log = std.log.scoped(.ziggy_lsp);

pub fn loadFile(
    self: *Handler,
    arena: std.mem.Allocator,
    new_text: [:0]const u8,
    uri: []const u8,
    language: Language,
) !void {
    var res: lsp.types.PublishDiagnosticsParams = .{
        .uri = uri,
        .diagnostics = &.{},
    };

    switch (language) {
        .ziggy_schema => {
            var sk = Schema.init(self.gpa, new_text);
            errdefer sk.deinit();

            const gop = try self.files.getOrPut(self.gpa, uri);
            errdefer _ = self.files.remove(uri);

            if (gop.found_existing) {
                gop.value_ptr.deinit();
            } else {
                gop.key_ptr.* = try self.gpa.dupe(u8, uri);
            }

            gop.value_ptr.* = .{ .ziggy_schema = sk };

            switch (sk.diagnostic.err) {
                .none => {},
                else => {
                    const msg = try std.fmt.allocPrint(arena, "{f}", .{
                        sk.diagnostic,
                    });
                    const sel = sk.diagnostic.tok.loc.getSelection(sk.bytes);
                    res.diagnostics = &.{
                        .{
                            .range = .{
                                .start = .{
                                    .line = sel.start.line - 1,
                                    .character = sel.start.col - 1,
                                },
                                .end = .{
                                    .line = sel.end.line - 1,
                                    .character = sel.end.col - 1,
                                },
                            },
                            .severity = .Error,
                            .message = msg,
                        },
                    };
                },
            }
        },
        .supermd, .ziggy => {
            const schema = try schemaForZiggy(self, arena, uri);

            var doc = try Document.init(
                self.gpa,
                new_text,
                language == .supermd,
                schema,
            );
            errdefer doc.deinit();

            log.debug("document init", .{});

            const gop = try self.files.getOrPut(self.gpa, uri);
            errdefer _ = self.files.remove(uri);

            if (gop.found_existing) {
                gop.value_ptr.deinit();
            } else {
                gop.key_ptr.* = try self.gpa.dupe(u8, uri);
            }

            gop.value_ptr.* = switch (language) {
                else => unreachable,
                .supermd => .{ .supermd = doc },
                .ziggy => .{ .ziggy = doc },
            };

            log.debug("sending {} diagnostic errors", .{doc.diagnostic.errors.items.len});

            const diags = try arena.alloc(lsp.types.Diagnostic, doc.diagnostic.errors.items.len);
            for (doc.diagnostic.errors.items, 0..) |e, idx| {
                const msg = try std.fmt.allocPrint(arena, "{f}", .{
                    e.fmt(.lsp, doc.bytes, null),
                });

                const sel = e.getErrorSelection();
                diags[idx] = .{
                    .range = .{
                        .start = .{
                            .line = sel.start.line - 1,
                            .character = sel.start.col - 1,
                        },
                        .end = .{
                            .line = sel.end.line - 1,
                            .character = sel.end.col - 1,
                        },
                    },
                    .severity = .Error,
                    .message = msg,
                };
            }

            res.diagnostics = diags;
        },
    }
    log.debug("sending diags!", .{});
    try self.transport.writeNotification(
        self.gpa,
        "textDocument/publishDiagnostics",
        lsp.types.PublishDiagnosticsParams,
        res,
        .{ .emit_null_optional_fields = false },
    );
}

pub fn schemaForZiggy(self: *Handler, arena: std.mem.Allocator, uri: []const u8) !?Schema {
    const path = try std.fmt.allocPrint(arena, "{s}-schema", .{uri["file://".len..]});
    log.debug("trying to find schema at '{s}'", .{path});
    const result = self.files.get(path) orelse {
        const bytes = std.fs.cwd().readFileAllocOptions(
            self.gpa,
            path,
            ziggy.max_size,
            null,
            .of(u8),
            0,
        ) catch return null;
        log.debug("schema loaded", .{});
        var schema = Schema.init(self.gpa, bytes);
        errdefer schema.deinit();

        const gpa_path = try self.gpa.dupe(u8, path);
        errdefer self.gpa.free(gpa_path);

        try self.files.putNoClobber(
            self.gpa,
            gpa_path,
            .{ .ziggy_schema = schema },
        );
        return schema;
    };

    if (result == .ziggy_schema) return result.ziggy_schema;
    return null;
}
