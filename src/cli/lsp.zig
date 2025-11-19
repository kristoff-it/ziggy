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

pub fn run(io: Io, gpa: std.mem.Allocator, dir: std.fs.Dir, args: []const []const u8) !void {
    _ = args;
    log.debug("Ziggy LSP started!", .{});

    var buf: [4096]u8 = undefined;
    var stdio: lsp.Transport.Stdio = .init(
        io,
        &buf,
        Io.File.stdin(),
        std.fs.File.stdout(),
    );

    var handler: Handler = .{
        .gpa = gpa,
        .transport = &stdio.transport,
        .dir = dir,
    };
    defer handler.deinit();

    try lsp.basic_server.run(
        gpa,
        &stdio.transport,
        &handler,
        log.err,
    );
}

pub const Handler = @This();

gpa: std.mem.Allocator,
transport: *lsp.Transport,
dir: std.fs.Dir,
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
            .TextDocumentSyncOptions = .{
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
    notification: types.DidOpenTextDocumentParams,
) !void {
    const new_text = try self.gpa.dupeZ(u8, notification.textDocument.text); // We informed the client that we only do full document syncs
    errdefer self.gpa.free(new_text);

    std.log.debug("didopen! {s} {s}", .{
        notification.textDocument.languageId,
        notification.textDocument.uri,
    });

    const language_id = notification.textDocument.languageId;
    const language = std.meta.stringToEnum(logic.Language, language_id) orelse {
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
    notification: types.DidChangeTextDocumentParams,
) !void {
    if (notification.contentChanges.len == 0) return;
    const new_text = try self.gpa.dupeZ(
        u8,
        notification.contentChanges[notification.contentChanges.len - 1].literal_1.text,
    ); // We informed the client that we only do full document syncs
    errdefer self.gpa.free(new_text);

    try logic.loadFile(
        self,
        arena,
        new_text,
        notification.textDocument.uri,
        if (self.docs.get(notification.textDocument.uri)) |doc|
            doc.language
        else if (self.schemas.contains(notification.textDocument.uri))
            .ziggy_schema
        else
            return,
    );
}

pub fn @"textDocument/didClose"(
    self: *Handler,
    _: std.mem.Allocator,
    notification: types.DidCloseTextDocumentParams,
) void {
    if (self.docs.fetchSwapRemove(notification.textDocument.uri)) |kv| {
        if (kv.value.schema_uri) |schema_path| {
            const schema = self.schemas.getPtr(schema_path).?;
            schema.refs -= 1;
            if (schema.refs == 0 and !schema.open) {
                const schema_kv = self.schemas.fetchRemove(schema_path).?;
                self.gpa.free(schema_kv.key);
                schema_kv.value.deinit(self.gpa);
                return;
            }
        }

        self.gpa.free(kv.key);
        kv.value.deinit(self.gpa);
        return;
    }

    if (self.schemas.getPtr(notification.textDocument.uri)) |schema| {
        if (schema.refs > 0) {
            schema.open = false;
            return;
        }

        const kv = self.schemas.fetchRemove(notification.textDocument.uri).?;
        self.gpa.free(kv.key);
        kv.value.deinit(self.gpa);
        return;
    }
}

pub fn @"textDocument/completion"(
    self: *Handler,
    arena: std.mem.Allocator,
    request: types.CompletionParams,
) error{OutOfMemory}!lsp.ResultType("textDocument/completion") {
    if (true) return null;
    const file = self.files.get(request.textDocument.uri) orelse return .{
        .CompletionList = types.CompletionList{
            .isIncomplete = false,
            .items = &.{},
        },
    };

    const doc = switch (file) {
        .ziggy => |doc| doc,
        .ziggy_schema => return null,
    };

    const offset = lsp.offsets.positionToIndex(
        doc.src,
        request.position,
        self.offset_encoding,
    );

    log.debug("completion at offset {}", .{offset});

    switch (file) {
        .ziggy => |z| {
            const ast = z.ast orelse return .{
                .CompletionList = types.CompletionList{
                    .isIncomplete = false,
                    .items = &.{},
                },
            };

            const ziggy_completion = ast.completionsForOffset(@intCast(offset));

            const completions = try arena.alloc(
                types.CompletionItem,
                ziggy_completion.len,
            );

            for (completions, ziggy_completion) |*c, zc| {
                c.* = .{
                    .label = zc.name,
                    .labelDetails = .{ .detail = zc.type },
                    .kind = .Field,
                    .insertText = zc.snippet,
                    .insertTextFormat = .Snippet,
                    .documentation = .{
                        .MarkupContent = .{
                            .kind = .markdown,
                            .value = zc.desc,
                        },
                    },
                };
            }

            return .{
                .CompletionList = types.CompletionList{
                    .isIncomplete = false,
                    .items = completions,
                },
            };
        },
        .ziggy_schema => return .{
            .CompletionList = types.CompletionList{
                .isIncomplete = false,
                .items = &.{},
            },
        },
    }
}

pub fn @"textDocument/definition"(
    self: *Handler,
    arena: std.mem.Allocator,
    request: types.DefinitionParams,
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

    const node_idx = schema.ast.resolveZiggyOffset(
        schema.src,
        doc.ast,
        doc.src,
        @intCast(offset),
    );
    if (node_idx == 0) return null;

    const node = schema.ast.nodes[node_idx];
    return .{
        .Definition = types.Definition{
            .Location = .{
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
    request: types.HoverParams,
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

    const node_idx = schema.ast.resolveZiggyOffset(
        schema.src,
        doc.ast,
        doc.src,
        @intCast(offset),
    );
    if (node_idx == 0) return null;

    var out: std.ArrayList(u8) = .empty;
    const node = schema.ast.nodes[node_idx];
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
            .MarkupContent = .{
                .kind = .markdown,
                .value = out.items,
            },
        },
    };
}

pub fn @"textDocument/formatting"(
    self: *Handler,
    arena: std.mem.Allocator,
    request: types.DocumentFormattingParams,
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
