const std = @import("std");
const assert = std.debug.assert;
const ziggy = @import("ziggy");
const Document = @import("lsp/Document.zig");
const Schema = @import("lsp/Schema.zig");
const lsp = @import("lsp");
const types = lsp.types;
const offsets = lsp.offsets;
const ResultType = lsp.server.ResultType;
const Message = lsp.server.Message;

const log = std.log.scoped(.ziggy_lsp);

const ZiggyLsp = lsp.server.Server(Handler);

pub fn run(gpa: std.mem.Allocator, args: []const []const u8) !void {
    _ = args;

    log.debug("Ziggy LSP started!", .{});

    var transport = lsp.Transport.init(
        std.io.getStdIn().reader(),
        std.io.getStdOut().writer(),
    );
    transport.message_tracing = false;

    var server: ZiggyLsp = undefined;
    var handler: Handler = .{
        .gpa = gpa,
        .server = &server,
    };
    server = try ZiggyLsp.init(gpa, &transport, &handler);

    try server.loop();
}

pub const Handler = struct {
    gpa: std.mem.Allocator,
    server: *ZiggyLsp,
    files: std.StringHashMapUnmanaged(Handler.File) = .{},

    usingnamespace @import("lsp/logic.zig");

    pub fn initialize(
        self: Handler,
        _: std.mem.Allocator,
        request: types.InitializeParams,
        offset_encoding: offsets.Encoding,
    ) !lsp.types.InitializeResult {
        _ = self;

        if (request.clientInfo) |clientInfo| {
            log.info("client is '{s}-{s}'", .{ clientInfo.name, clientInfo.version orelse "<no version>" });
        }

        return .{
            .serverInfo = .{
                .name = "Ziggy LSP",
                .version = "0.0.1",
            },
            .capabilities = .{
                .positionEncoding = switch (offset_encoding) {
                    .@"utf-8" => .@"utf-8",
                    .@"utf-16" => .@"utf-16",
                    .@"utf-32" => .@"utf-32",
                },
                .textDocumentSync = .{
                    .TextDocumentSyncOptions = .{
                        .openClose = true,
                        .change = .Full,
                        .save = .{ .bool = true },
                    },
                },
                .completionProvider = .{
                    .triggerCharacters = &[_][]const u8{ ".", ":", "@", "\"" },
                },
                .hoverProvider = .{ .bool = true },
                .definitionProvider = .{ .bool = true },
                .referencesProvider = .{ .bool = true },
                .documentFormattingProvider = .{ .bool = true },
                .semanticTokensProvider = .{
                    .SemanticTokensOptions = .{
                        .full = .{ .bool = true },
                        .legend = .{
                            .tokenTypes = std.meta.fieldNames(types.SemanticTokenTypes),
                            .tokenModifiers = std.meta.fieldNames(types.SemanticTokenModifiers),
                        },
                    },
                },
                .inlayHintProvider = .{ .bool = true },
            },
        };
    }

    pub fn initialized(
        self: Handler,
        _: std.mem.Allocator,
        notification: types.InitializedParams,
    ) !void {
        _ = self;
        _ = notification;
    }

    pub fn shutdown(
        _: Handler,
        _: std.mem.Allocator,
        notification: void,
    ) !?void {
        _ = notification;
    }

    pub fn exit(
        _: Handler,
        _: std.mem.Allocator,
        notification: void,
    ) !void {
        _ = notification;
    }

    pub fn openDocument(
        self: *Handler,
        arena: std.mem.Allocator,
        notification: types.DidOpenTextDocumentParams,
    ) !void {
        const new_text = try self.gpa.dupeZ(u8, notification.textDocument.text); // We informed the client that we only do full document syncs
        errdefer self.gpa.free(new_text);

        const language_id = notification.textDocument.languageId;
        const language = std.meta.stringToEnum(Handler.Language, language_id) orelse {
            log.debug("unrecognized language id: '{s}'", .{language_id});
            return;
        };
        try self.loadFile(
            arena,
            new_text,
            notification.textDocument.uri,
            language,
        );
    }

    pub fn changeDocument(
        self: *Handler,
        arena: std.mem.Allocator,
        notification: types.DidChangeTextDocumentParams,
    ) !void {
        if (notification.contentChanges.len == 0) return;

        const new_text = try self.gpa.dupeZ(u8, notification.contentChanges[notification.contentChanges.len - 1].literal_1.text); // We informed the client that we only do full document syncs
        errdefer self.gpa.free(new_text);

        // TODO: this is a hack while we wait for actual incremental reloads
        const file = self.files.get(notification.textDocument.uri) orelse return;
        try self.loadFile(
            arena,
            new_text,
            notification.textDocument.uri,
            file,
        );
    }

    pub fn saveDocument(
        _: Handler,
        arena: std.mem.Allocator,
        notification: types.DidSaveTextDocumentParams,
    ) !void {
        _ = arena;
        _ = notification;
    }

    pub fn closeDocument(
        self: *Handler,
        _: std.mem.Allocator,
        notification: types.DidCloseTextDocumentParams,
    ) error{}!void {
        var kv = self.files.fetchRemove(notification.textDocument.uri) orelse return;
        self.gpa.free(kv.key);
        kv.value.deinit();
    }

    pub fn completion(
        self: Handler,
        arena: std.mem.Allocator,
        request: types.CompletionParams,
    ) !ResultType("textDocument/completion") {
        const file = self.files.get(request.textDocument.uri) orelse return .{
            .CompletionList = types.CompletionList{
                .isIncomplete = false,
                .items = &.{},
            },
        };
        const offset = file.offsetFromPosition(
            request.position.line,
            request.position.character,
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

                const ziggy_completion = ast.completionsForOffset(offset);

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

    pub fn gotoDefinition(
        self: Handler,
        arena: std.mem.Allocator,
        request: types.DefinitionParams,
    ) !ResultType("textDocument/definition") {
        const file = self.files.get(request.textDocument.uri) orelse return null;
        if (file == .ziggy_schema) return null;

        return .{
            .Definition = types.Definition{
                .Location = .{
                    .uri = try std.fmt.allocPrint(arena, "{s}-schema", .{request.textDocument.uri}),
                    .range = .{
                        .start = .{ .line = 0, .character = 0 },
                        .end = .{ .line = 0, .character = 0 },
                    },
                },
            },
        };
    }

    pub fn hover(
        self: Handler,
        arena: std.mem.Allocator,
        request: types.HoverParams,
        offset_encoding: offsets.Encoding,
    ) !?types.Hover {
        _ = offset_encoding; // autofix
        _ = arena; // autofix

        const file = self.files.get(request.textDocument.uri) orelse return null;

        const doc = switch (file) {
            .ziggy => |doc| doc,
            .ziggy_schema => return null,
        };

        const offset = file.offsetFromPosition(
            request.position.line,
            request.position.character,
        );
        log.debug("hover at offset {}", .{offset});

        const ast = doc.ast orelse return null;
        const h = ast.hoverForOffset(offset) orelse return null;

        return types.Hover{
            .contents = .{
                .MarkupContent = .{
                    .kind = .markdown,
                    .value = h,
                },
            },
        };
    }

    pub fn references(
        _: Handler,
        arena: std.mem.Allocator,
        request: types.ReferenceParams,
    ) !?[]types.Location {
        _ = arena;
        _ = request;
        return null;
    }

    pub fn formatting(
        _: Handler,
        arena: std.mem.Allocator,
        request: types.DocumentFormattingParams,
    ) !?[]types.TextEdit {
        _ = arena;
        _ = request;
        return null;
    }

    pub fn semanticTokensFull(
        _: Handler,
        arena: std.mem.Allocator,
        request: types.SemanticTokensParams,
    ) !?types.SemanticTokens {
        _ = arena;
        _ = request;
        return null;
    }

    pub fn inlayHint(
        _: Handler,
        arena: std.mem.Allocator,
        request: types.InlayHintParams,
    ) !?[]types.InlayHint {
        _ = arena;
        _ = request;
        return null;
    }

    /// Handle a reponse that we have received from the client.
    /// Doesn't usually happen unless we explicitly send a request to the client.
    pub fn response(self: Handler, _response: Message.Response) !void {
        _ = self;
        const id: []const u8 = switch (_response.id) {
            .string => |id| id,
            .integer => |id| {
                log.warn("received response from client with id '{d}' that has no handler!", .{id});
                return;
            },
        };

        if (_response.data == .@"error") {
            const err = _response.data.@"error";
            log.err("Error response for '{s}': {}, {s}", .{ id, err.code, err.message });
            return;
        }

        log.warn("received response from client with id '{s}' that has no handler!", .{id});
    }
};
