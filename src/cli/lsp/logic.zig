const std = @import("std");
const assert = std.debug.assert;
const Allocator = std.mem.Allocator;
const lsp = @import("lsp");
const ziggy = @import("ziggy");
const Handler = @import("../lsp.zig").Handler;
const Document = @import("Document.zig");
const Schema = @import("Schema.zig");
const log = std.log.scoped(.ziggy_lsp);

pub const Language = enum { ziggy, ziggy_schema };

pub fn loadFile(
    self: *Handler,
    arena: std.mem.Allocator,
    new_text: [:0]const u8,
    uri: []const u8,
    language: Language,
) !void {
    switch (language) {
        .ziggy_schema => {
            var schema = Schema.init(self.gpa, new_text, true);
            errdefer schema.deinit(self.gpa);

            const gop = try self.schemas.getOrPut(self.gpa, uri);
            if (gop.found_existing) {
                gop.value_ptr.deinit(self.gpa);
                gop.value_ptr.src = schema.src;
                gop.value_ptr.ast = schema.ast;
            } else {
                gop.key_ptr.* = try self.gpa.dupe(u8, uri);
                gop.value_ptr.* = schema;
            }
            gop.value_ptr.open = true;

            {
                const diags = try arena.alloc(lsp.types.Diagnostic, schema.ast.errors.len);
                for (schema.ast.errors, diags) |err, *d| {
                    const sel = err.main_location.getSelection(schema.src);
                    const msg = try std.fmt.allocPrint(arena, "{f}", .{err.tag});
                    d.* = .{
                        .severity = switch (err.tag) {
                            .infinite_loop_field => .Information,
                            else => .Error,
                        },
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
                        .message = msg,
                    };
                }

                try self.transport.writeNotification(
                    self.gpa,
                    "textDocument/publishDiagnostics",
                    lsp.types.PublishDiagnosticsParams,
                    .{ .uri = uri, .diagnostics = diags },
                    .{ .emit_null_optional_fields = false },
                );
            }
            if (schema.ast.errors.len > 0) return;

            if (gop.value_ptr.refs > 0) {
                assert(schema.ast.errors.len == 0);
                //TODO: add an index
                for (self.docs.keys(), self.docs.values()) |doc_uri, doc| {
                    if (doc.ast.errors.len != 0) continue;
                    const schema_uri = doc.schema_uri orelse continue;
                    if (schema_uri.ptr != gop.key_ptr.*.ptr) continue;

                    const validation_errors = try schema.ast.validate(
                        arena,
                        schema.src,
                        doc.ast,
                        doc.src,
                    );

                    const diags = try arena.alloc(lsp.types.Diagnostic, validation_errors.len);
                    for (validation_errors, diags) |err, *d| {
                        const msg = try std.fmt.allocPrint(arena, "{f}", .{err.tag});
                        const sel = err.main_location.getSelection(doc.src);
                        d.* = .{
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

                    try self.transport.writeNotification(
                        self.gpa,
                        "textDocument/publishDiagnostics",
                        lsp.types.PublishDiagnosticsParams,
                        .{ .uri = doc_uri, .diagnostics = diags },
                        .{ .emit_null_optional_fields = false },
                    );
                }
            }
        },
        .ziggy => {
            var doc = try Document.init(self.gpa, new_text);
            const gop = try self.docs.getOrPut(self.gpa, uri);
            if (gop.found_existing) {
                gop.value_ptr.deinit(self.gpa);
                gop.value_ptr.src = doc.src;
                gop.value_ptr.ast = doc.ast;
            } else {
                gop.key_ptr.* = try self.gpa.dupe(u8, uri);
                gop.value_ptr.* = doc;
            }

            const validation_errors = if (gop.value_ptr.schema_uri) |schema_uri| blk: {
                const schema = self.schemas.get(schema_uri).?;
                if (doc.ast.errors.len != 0 or schema.ast.errors.len != 0) break :blk &.{};
                break :blk try schema.ast.validate(arena, schema.src, doc.ast, doc.src);
            } else if (try schemaForZiggy(self, arena, uri)) |ms| blk: {
                assert(gop.value_ptr.schema_uri == null);
                const schema_uri, const schema = ms;
                gop.value_ptr.schema_uri = schema_uri;
                if (doc.ast.errors.len != 0 or schema.ast.errors.len != 0) break :blk &.{};
                break :blk try schema.ast.validate(arena, schema.src, doc.ast, doc.src);
            } else blk: {
                break :blk try ziggy.schema.Ast.validateDefault(arena, doc.ast, doc.src);
            };

            log.debug("sending {}  errors", .{doc.ast.errors.len + validation_errors.len});
            const diags = try arena.alloc(lsp.types.Diagnostic, doc.ast.errors.len + validation_errors.len);
            for (doc.ast.errors, diags[0..doc.ast.errors.len]) |err, *d| {
                const msg = try std.fmt.allocPrint(arena, "{f}", .{err.tag});
                const sel = err.main_location.getSelection(doc.src);
                d.* = .{
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
                    .severity = switch (err.tag) {
                        .wrong_field_style, .wrong_field_separator => .Information,
                        else => .Error,
                    },
                    .message = msg,
                };
            }

            for (validation_errors, diags[doc.ast.errors.len..]) |err, *d| {
                const msg = try std.fmt.allocPrint(arena, "{f}", .{err.tag});
                const sel = err.main_location.getSelection(doc.src);
                d.* = .{
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

            try self.transport.writeNotification(
                self.gpa,
                "textDocument/publishDiagnostics",
                lsp.types.PublishDiagnosticsParams,
                .{ .uri = uri, .diagnostics = diags },
                .{ .emit_null_optional_fields = false },
            );
            return;
        },
    }
}

pub fn schemaForZiggy(
    self: *Handler,
    arena: std.mem.Allocator,
    uri_doc: []const u8,
) error{OutOfMemory}!?struct { []const u8, Schema } {
    const uri_schema = try std.fmt.allocPrint(arena, "{s}-schema", .{uri_doc});
    log.debug("trying to find schema at '{s}'", .{uri_schema});

    if (self.schemas.getEntry(uri_schema)) |kv| {
        kv.value_ptr.refs += 1;
        return .{ kv.key_ptr.*, kv.value_ptr.* };
    } else blk: {
        const src = std.fs.cwd().readFileAllocOptions(
            uri_schema["file://".len..],
            self.gpa,
            .limited(ziggy.max_size),
            .of(u8),
            0,
        ) catch |err| {
            switch (err) {
                error.FileNotFound => {},
                else => log.err(
                    "unable to open '{s}' as a ziggy schema for '{s}': {t}",
                    .{ uri_schema, uri_doc, err },
                ),
            }
            break :blk;
        };

        var schema = Schema.init(self.gpa, src, false);
        schema.refs = 1;
        errdefer schema.deinit(self.gpa);
        const gpa_schema_uri = try self.gpa.dupe(u8, uri_schema);
        errdefer self.gpa.free(gpa_schema_uri);
        try self.schemas.putNoClobber(
            self.gpa,
            gpa_schema_uri,
            schema,
        );
        return .{ gpa_schema_uri, schema };
    }

    // .ziggy-schema search
    var path_dir: []const u8 = uri_schema["file://".len..];
    while (true) {
        path_dir = std.fs.path.dirname(path_dir) orelse return null;
        const dot_schema_uri = try std.fmt.allocPrint(
            arena,
            "file://{f}",
            .{std.fs.path.fmtJoin(&.{ path_dir, ".ziggy-schema" })},
        );
        const dot_schema_path = dot_schema_uri["file://".len..];
        if (self.schemas.getEntry(dot_schema_uri)) |kv| {
            kv.value_ptr.refs += 1;
            return .{ kv.key_ptr.*, kv.value_ptr.* };
        }
        defer arena.free(dot_schema_path);

        const schema_src = std.fs.cwd().readFileAllocOptions(
            dot_schema_path,
            self.gpa,
            .limited(ziggy.max_size),
            .of(u8),
            0,
        ) catch |err| {
            switch (err) {
                error.FileNotFound => {},
                else => log.err("unable to access schema '{s}': {t}", .{ dot_schema_path, err }),
            }
            continue;
        };

        var schema = Schema.init(self.gpa, schema_src, false);
        schema.refs = 1;
        errdefer schema.deinit(self.gpa);
        const gpa_dot_schema_uri = try self.gpa.dupe(u8, dot_schema_uri);
        try self.schemas.putNoClobber(
            self.gpa,
            gpa_dot_schema_uri,
            schema,
        );
        return .{ gpa_dot_schema_uri, schema };
    }
}
