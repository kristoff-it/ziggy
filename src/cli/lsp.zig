const std = @import("std");
const assert = std.debug.assert;
const ziggy = @import("ziggy");
const Document = @import("lsp/Document.zig");
const Schema = @import("lsp/Schema.zig");
const lsp = @import("lsp");
const types = lsp.types;
const offsets = lsp.offsets;
const logic = @import("lsp/logic.zig");

const log = std.log.scoped(.ziggy_lsp);

pub fn run(gpa: std.mem.Allocator, args: []const []const u8) !void {
    _ = args;

    log.debug("Ziggy LSP started!", .{});

    var buf: [4096]u8 = undefined;
    var stdio: lsp.Transport.Stdio = .init(
        &buf,
        std.fs.File.stdin(),
        std.fs.File.stdout(),
    );

    var handler: Handler = .{
        .gpa = gpa,
        .transport = &stdio.transport,
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
files: std.StringHashMapUnmanaged(logic.File) = .{},
offset_encoding: offsets.Encoding = .@"utf-16",

fn deinit(self: *Handler) void {
    var file_it = self.files.valueIterator();
    while (file_it.next()) |file| file.deinit();
    self.files.deinit(self.gpa);
    self.* = undefined;
}

pub fn initialize(
    self: *Handler,
    _: std.mem.Allocator,
    request: types.InitializeParams,
) types.InitializeResult {
    if (request.clientInfo) |clientInfo| {
        log.info("client is '{s}-{s}'", .{ clientInfo.name, clientInfo.version orelse "<no version>" });
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
            .triggerCharacters = &[_][]const u8{ ".", ":", "@", "\"" },
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
            .name = "Ziggy LSP",
            .version = "0.0.1",
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

    const language_id = notification.textDocument.languageId;
    const language = std.meta.stringToEnum(logic.Language, language_id) orelse {
        log.debug("unrecognized language id: '{s}'", .{language_id});
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

    const new_text = try self.gpa.dupeZ(u8, notification.contentChanges[notification.contentChanges.len - 1].literal_1.text); // We informed the client that we only do full document syncs
    errdefer self.gpa.free(new_text);

    // TODO: this is a hack while we wait for actual incremental reloads
    const file = self.files.get(notification.textDocument.uri) orelse return;

    log.debug("LOAD FILE URI: {s}, file tag = {s}", .{
        notification.textDocument.uri,
        @tagName(file),
    });
    try logic.loadFile(
        self,
        arena,
        new_text,
        notification.textDocument.uri,
        file,
    );
}

pub fn @"textDocument/didClose"(
    self: *Handler,
    _: std.mem.Allocator,
    notification: types.DidCloseTextDocumentParams,
) void {
    var kv = self.files.fetchRemove(notification.textDocument.uri) orelse return;
    self.gpa.free(kv.key);
    kv.value.deinit();
}

pub fn @"textDocument/completion"(
    self: *Handler,
    arena: std.mem.Allocator,
    request: types.CompletionParams,
) error{OutOfMemory}!lsp.ResultType("textDocument/completion") {
    const file = self.files.get(request.textDocument.uri) orelse return .{
        .CompletionList = types.CompletionList{
            .isIncomplete = false,
            .items = &.{},
        },
    };

    const doc = switch (file) {
        .supermd, .ziggy => |doc| doc,
        .ziggy_schema => return null,
    };

    const offset = lsp.offsets.positionToIndex(
        doc.bytes,
        request.position,
        self.offset_encoding,
    );

    log.debug("completion at offset {}", .{offset});

    switch (file) {
        .supermd, .ziggy => |z| {
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

pub fn @"textDocument/hover"(
    self: *Handler,
    _: std.mem.Allocator,
    request: types.HoverParams,
) ?types.Hover {
    const file = self.files.get(request.textDocument.uri) orelse return null;

    const doc = switch (file) {
        .supermd, .ziggy => |doc| doc,
        .ziggy_schema => return null,
    };

    const offset = lsp.offsets.positionToIndex(
        doc.bytes,
        request.position,
        self.offset_encoding,
    );
    log.debug("hover at offset {}", .{offset});

    const ast = doc.ast orelse return null;
    const h = ast.hoverForOffset(@intCast(offset)) orelse return null;

    return types.Hover{
        .contents = .{
            .MarkupContent = .{
                .kind = .markdown,
                .value = h,
            },
        },
    };
}

pub fn @"textDocument/formatting"(
    self: *Handler,
    arena: std.mem.Allocator,
    request: types.DocumentFormattingParams,
) error{OutOfMemory}!?[]const types.TextEdit {
    const file = self.files.get(request.textDocument.uri) orelse return null;

    const new_text: []const u8 = switch (file) {
        .supermd => return null,
        .ziggy => |doc| blk: {
            const ast = ziggy.Ast.init(arena, doc.bytes, true, false, false, null) catch return null;
            break :blk try std.fmt.allocPrint(arena, "{f}\n", .{ast});
        },
        .ziggy_schema => |doc| try std.fmt.allocPrint(arena, "{f}", .{
            doc.ast orelse return null,
        }),
    };

    const old_text = switch (file) {
        .supermd => unreachable,
        inline .ziggy, .ziggy_schema => |doc| doc.bytes,
    };

    const range: offsets.Range = .{
        .start = .{ .line = 0, .character = 0 },
        .end = offsets.indexToPosition(old_text, old_text.len, self.offset_encoding),
    };

    return try arena.dupe(types.TextEdit, &.{.{
        .range = range,
        .newText = new_text,
    }});
}

pub fn onResponse(
    _: *Handler,
    _: std.mem.Allocator,
    response: lsp.JsonRPCMessage.Response,
) void {
    log.warn("received unexpected response from client with id '{?}'!", .{response.id});
}
