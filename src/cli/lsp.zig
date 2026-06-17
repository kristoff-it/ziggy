const std = @import("std");
const Io = std.Io;
const assert = std.debug.assert;
const ziggy = @import("ziggy");
const Document = @import("lsp/Document.zig");
const Schema = @import("lsp/Schema.zig");
const lsp = @import("lsp");
const types = lsp.types;
const offsets = lsp.offsets;
const logic = @import("lsp/logic.zig");

const log = std.log.scoped(.ziggy_lsp);

pub fn run(io: Io, gpa: std.mem.Allocator, dir: Io.Dir, args: []const []const u8) !void {
    _ = args;
    log.debug("Ziggy LSP started!", .{});

    var buf: [4096]u8 = undefined;
    var stdio: lsp.Transport.Stdio = .init(
        &buf,
        Io.File.stdin(),
        Io.File.stdout(),
    );

    var handler: Handler = .{
        .io = io,
        .gpa = gpa,
        .transport = &stdio.transport,
        .dir = dir,
    };
    defer handler.deinit();

    try lsp.basic_server.run(
        io,
        gpa,
        &stdio.transport,
        &handler,
        log.err,
    );
}

pub const Handler = @This();

io: Io,
gpa: std.mem.Allocator,
transport: *lsp.Transport,
dir: Io.Dir,
docs: std.StringArrayHashMapUnmanaged(Document) = .{},
schemas: std.StringHashMapUnmanaged(Schema) = .{},

offset_encoding: offsets.Encoding = .@"utf-16",

fn deinit(self: *Handler) void {
    _ = self;
    // {
    //     var docs_it = self.docs.valueIterator();
    //     while (docs_it.next()) |file| file.deinit(self.gpa);
    //     self.files.deinit(self.gpa);
    //     self.* = undefined;
    // }
    // {
    //     var schemas_it = self.schemas.valueIterator();
    //     while (schemas_it.next()) |file| file.deinit(self.gpa);
    //     self.schemas.deinit(self.gpa);
    //     self.* = undefined;
    // }
}

pub fn initialize(
    self: *Handler,
    _: std.mem.Allocator,
    request: types.InitializeParams,
) types.InitializeResult {
    if (request.clientInfo) |clientInfo| {
        log.info("client is '{s}-{s}'", .{
            clientInfo.name,
            clientInfo.version orelse "<no version>",
        });
    }

    if (request.capabilities.general) |general| {
        for (general.positionEncodings orelse &.{}) |encoding| {
            self.offset_encoding = switch (encoding) {
                .@"utf-8" => .@"utf-8",
                .@"utf-16" => .@"utf-16",
                .@"utf-32" => .@"utf-32",
                .custom_value => break,
            };
            break;
        }
    }

    const capabilities: types.ServerCapabilities = .{
        .positionEncoding = switch (self.offset_encoding) {
            .@"utf-8" => .@"utf-8",
            .@"utf-16" => .@"utf-16",
            .@"utf-32" => .@"utf-32",
        },
        .textDocumentSync = .{
            .text_document_sync_options = .{
                .openClose = true,
                .change = .Full,
            },
        },
        .completionProvider = .{
            .triggerCharacters = &[_][]const u8{ ".", ":", "=" },
        },
        .hoverProvider = .{ .bool = true },
        .definitionProvider = .{ .bool = true },
        .documentFormattingProvider = .{ .bool = true },
    };

    if (@import("builtin").mode == .Debug) {
        lsp.basic_server.validateServerCapabilities(Handler, capabilities);
    }

    return .{
        .serverInfo = .{
            .name = "Ziggy",
            .version = @import("options").version,
        },
        .capabilities = capabilities,
    };
}

pub fn @"textDocument/didOpen"(
    self: *Handler,
    arena: std.mem.Allocator,
    notification: types.TextDocument.DidOpenParams,
) !void {
    const new_text = try self.gpa.dupeSentinel(u8, notification.textDocument.text, 0); // We informed the client that we only do full document syncs
    errdefer self.gpa.free(new_text);

    std.log.debug("didopen! {any} [{s}]", .{
        notification.textDocument.languageId,
        notification.textDocument.uri,
    });

    const language_id = switch (notification.textDocument.languageId) {
        .custom_value => |bytes| bytes,
        else => |tag| {
            log.debug(
                "unrecognized language id: '{t}' (must be one of {{supermd, ziggy, ziggy_schema}}",
                .{tag},
            );
            return;
        },
    };

    const language = std.meta.stringToEnum(logic.Language, language_id) orelse blk: {
        if (std.mem.eql(u8, language_id, "ziggy-schema")) break :blk .ziggy_schema;
        log.debug(
            "unrecognized language id: '{s}' (must be one of {{supermd, ziggy, ziggy_schema}}",
            .{language_id},
        );
        return;
    };

    try logic.loadFile(
        self,
        arena,
        new_text,
        notification.textDocument.uri,
        language,
    );
}

pub fn @"textDocument/didChange"(
    self: *Handler,
    arena: std.mem.Allocator,
    notification: types.TextDocument.DidChangeParams,
) !void {
    if (notification.contentChanges.len == 0) return;

    const orig_txt: [:0]u8, const lang = if (self.docs.getPtr(notification.textDocument.uri)) |doc| .{
        doc.src,
        doc.language,
    } else if (self.schemas.getPtr(notification.textDocument.uri)) |schema| .{
        schema.src,
        .ziggy_schema,
    } else {
        log.err("changeDocument failed: unknown doc: [{s}]", .{notification.textDocument.uri});
        return error.InvalidParams;
    };

    var buffer: std.ArrayList(u8) = .fromOwnedSliceSentinel(0, orig_txt);
    errdefer buffer.deinit(self.gpa);

    for (notification.contentChanges) |content_change| {
        switch (content_change) {
            .text_document_content_change_whole_document => |change| {
                buffer.clearRetainingCapacity();
                try buffer.appendSlice(self.gpa, change.text);
            },
            .text_document_content_change_partial => |change| {
                const loc = offsets.rangeToLoc(buffer.items, change.range, self.offset_encoding);
                try buffer.replaceRange(self.gpa, loc.start, loc.end - loc.start, change.text);
            },
        }
    }
    const new_text = try buffer.toOwnedSliceSentinel(self.gpa, 0);
    errdefer self.gpa.free(new_text);

    try logic.loadFile(
        self,
        arena,
        new_text,
        notification.textDocument.uri,
        lang,
    );
}

pub fn @"textDocument/didClose"(
    self: *Handler,
    _: std.mem.Allocator,
    notification: types.TextDocument.DidCloseParams,
) void {
    if (self.docs.fetchSwapRemove(notification.textDocument.uri)) |kv| {
        if (kv.value.schema_uri) |schema_path| {
            const schema = self.schemas.getPtr(schema_path).?;
            schema.refs -= 1;
            if (schema.refs == 0 and !schema.open) {
                const schema_kv = self.schemas.fetchRemove(schema_path).?;
                self.gpa.free(schema_kv.key);
                schema_kv.value.deinit(self.gpa, false);
                return;
            }
        }

        self.gpa.free(kv.key);
        kv.value.deinit(self.gpa, false);
        return;
    }

    if (self.schemas.getPtr(notification.textDocument.uri)) |schema| {
        if (schema.refs > 0) {
            schema.open = false;
            return;
        }

        const kv = self.schemas.fetchRemove(notification.textDocument.uri).?;
        self.gpa.free(kv.key);
        kv.value.deinit(self.gpa, false);
        return;
    }
}

pub fn @"textDocument/completion"(
    self: *Handler,
    arena: std.mem.Allocator,
    request: types.completion.Params,
) error{OutOfMemory}!lsp.ResultType("textDocument/completion") {
    log.debug("completion request", .{});
    const doc = self.docs.get(request.textDocument.uri) orelse return null;

    const offset = lsp.offsets.positionToIndex(
        doc.src,
        request.position,
        self.offset_encoding,
    );

    log.debug("completion at offset {}", .{offset});

    const schema_path = doc.schema_uri orelse return null;
    const schema = self.schemas.get(schema_path).?;
    if (schema.ast.errors.len > 0) return null;

    const resolved = schema.ast.resolveZiggyOffset(
        schema.src,
        doc.ast,
        doc.src,
        @intCast(offset),
    ) orelse return null;

    var node = schema.ast.nodes[resolved.schema_idx];

    c: switch (node.tag) {
        .root, .root_expr, .type_expr => unreachable,
        .struct_field, .union_field => {
            std.debug.print("field\n", .{});
            node = schema.ast.nodes[node.parent_idx];
            continue :c node.tag;
        },
        .@"struct", .@"union" => {
            const scope = schema.ast.scopes.getPtr(resolved.schema_idx) orelse return null;

            var existing_fields: std.StringHashMapUnmanaged(void) = .empty;
            defer existing_fields.deinit(arena);
            {
                var ziggy_idx = resolved.ziggy_idx;
                var ziggy_node = doc.ast.nodes[ziggy_idx];
                z: switch (ziggy_node.tag) {
                    .struct_field, .dict_field => {
                        ziggy_idx = ziggy_node.parent_idx;
                        if (ziggy_idx == 0) return null;
                        ziggy_node = doc.ast.nodes[ziggy_idx];
                        continue :z ziggy_node.tag;
                    },
                    .struct_v, .struct_h => {
                        var field_idx = ziggy_idx + 1;
                        while (field_idx < doc.ast.nodes.len) {
                            const child_node = doc.ast.nodes[field_idx];
                            if (child_node.parent_idx != ziggy_idx) break;

                            const tok_src = doc.src[child_node.loc.start..];
                            var t: ziggy.Tokenizer = .init(.none);
                            const tok = t.next(tok_src, true);
                            switch (tok.tag) {
                                .identifier => {
                                    try existing_fields.put(arena, tok.loc.slice(tok_src)[1..], {});
                                },
                                .bytes => {
                                    const key = tok.loc.slice(tok_src);
                                    try existing_fields.put(arena, key[1 .. key.len - 1], {});
                                },
                                else => {},
                            }

                            if (child_node.next_idx == 0) break;
                            field_idx = child_node.next_idx;
                        }
                    },
                    else => return null,
                }
            }

            const completions = try arena.alloc(
                types.completion.Item,
                scope.fields.count(),
            );

            var c_idx: u32 = 0;
            for (scope.fields.keys()) |field| {
                if (existing_fields.contains(field)) continue;
                defer c_idx += 1;

                completions[c_idx] = .{
                    .label = field,
                    .kind = .Field,
                    .documentation = .{
                        .markup_content = .{
                            .kind = .markdown,
                            .value = "banana",
                        },
                    },
                };
            }

            return .{ .completion_items = completions[0..c_idx] };
        },
    }

    return null;
}

pub fn @"textDocument/definition"(
    self: *Handler,
    arena: std.mem.Allocator,
    request: types.Definition.Params,
) error{OutOfMemory}!lsp.ResultType("textDocument/definition") {
    _ = arena;
    const doc = self.docs.get(request.textDocument.uri) orelse return null;
    const schema_path = doc.schema_uri orelse return null;
    const schema = self.schemas.get(schema_path).?;
    const offset = lsp.offsets.positionToIndex(
        doc.src,
        request.position,
        self.offset_encoding,
    );
    log.debug("hover at offset {}", .{offset});

    const resolved = schema.ast.resolveZiggyOffset(
        schema.src,
        doc.ast,
        doc.src,
        @intCast(offset),
    ) orelse return null;

    const node = schema.ast.nodes[resolved.schema_idx];
    return .{
        .definition = types.Definition{
            .location = .{
                .uri = schema_path,
                .range = .{
                    .start = lsp.offsets.indexToPosition(schema.src, node.loc.start, self.offset_encoding),
                    .end = lsp.offsets.indexToPosition(schema.src, node.loc.end, self.offset_encoding),
                },
            },
        },
    };
}

pub fn @"textDocument/hover"(
    self: *Handler,
    arena: std.mem.Allocator,
    request: types.Hover.Params,
) error{OutOfMemory}!lsp.ResultType("textDocument/hover") {
    const doc = self.docs.get(request.textDocument.uri) orelse return null;
    const schema_path = doc.schema_uri orelse return null;
    const schema = self.schemas.get(schema_path).?;
    const offset = lsp.offsets.positionToIndex(
        doc.src,
        request.position,
        self.offset_encoding,
    );
    log.debug("hover at offset {}", .{offset});

    const resolved = schema.ast.resolveZiggyOffset(
        schema.src,
        doc.ast,
        doc.src,
        @intCast(offset),
    ) orelse return null;

    var out: std.ArrayList(u8) = .empty;
    const node = schema.ast.nodes[resolved.schema_idx];
    log.debug("hover node: {any}", .{node});
    switch (node.tag) {
        .@"struct", .@"union", .struct_field, .union_field => {
            if (node.docs_offset == 0) return null;
            var t: ziggy.schema.Tokenizer = .{ .idx = node.docs_offset - 1 };
            while (true) {
                const tok = t.next(schema.src);
                if (tok.tag != .doc_comment_line) break;
                try out.appendSlice(arena, tok.loc.slice(schema.src)[3..]);
                try out.append(arena, '\n');
            }
        },
        .type_expr => return null,
        else => unreachable,
    }

    return .{
        .contents = .{
            .markup_content = .{
                .kind = .markdown,
                .value = out.items,
            },
        },
    };
}

pub fn @"textDocument/formatting"(
    self: *Handler,
    arena: std.mem.Allocator,
    request: types.document_formatting.Params,
) !?[]const types.TextEdit {
    if (self.docs.get(request.textDocument.uri)) |doc| {
        if (doc.ast.has_syntax_errors) return null;
        const range: offsets.Range = .{
            .start = .{ .line = 0, .character = 0 },
            .end = offsets.indexToPosition(doc.src, doc.src.len, self.offset_encoding),
        };

        log.debug("format doc!", .{});

        var aw = std.Io.Writer.Allocating.init(arena);
        try doc.ast.render(doc.src, &aw.writer);

        return try arena.dupe(types.TextEdit, &.{.{
            .range = range,
            .newText = aw.written(),
        }});
    }

    if (self.docs.get(request.textDocument.uri)) |schema| {
        if (schema.ast.has_syntax_errors) return null;
        const range: offsets.Range = .{
            .start = .{ .line = 0, .character = 0 },
            .end = offsets.indexToPosition(
                schema.src,
                schema.src.len,
                self.offset_encoding,
            ),
        };

        log.debug("format schema!", .{});

        var aw = std.Io.Writer.Allocating.init(arena);
        try schema.ast.render(schema.src, &aw.writer);

        return try arena.dupe(types.TextEdit, &.{.{
            .range = range,
            .newText = aw.written(),
        }});
    }

    return null;
}

pub fn onResponse(
    _: *Handler,
    _: std.mem.Allocator,
    response: lsp.JsonRPCMessage.Response,
) void {
    log.warn("received unexpected response from client with id '{?}'!", .{response.id});
}
