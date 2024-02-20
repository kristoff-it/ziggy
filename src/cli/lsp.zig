const std = @import("std");
const assert = std.debug.assert;
const ziggy = @import("ziggy");
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
    var handler: Handler = .{ .gpa = gpa, .server = &server };
    server = try ZiggyLsp.init(gpa, &transport, &handler);

    try server.loop();
}

const Handler = struct {
    gpa: std.mem.Allocator,
    server: *ZiggyLsp,
    documents: std.StringHashMapUnmanaged([:0]u8) = .{},

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
                .name = "ZiggyLSP",
                .version = "0.0.0",
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
                    .triggerCharacters = &[_][]const u8{ ".", ":", "@", "]", "/" },
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
        _: std.mem.Allocator,
        notification: types.DidOpenTextDocumentParams,
    ) !void {
        const new_text = try self.gpa.dupeZ(u8, notification.textDocument.text); // We informed the client that we only do full document syncs
        errdefer self.gpa.free(new_text);

        const gop = try self.documents.getOrPut(self.gpa, notification.textDocument.uri);
        if (gop.found_existing) {
            self.gpa.free(gop.value_ptr.*); // free old text even though this shoudnt be necessary
        } else {
            errdefer std.debug.assert(self.documents.remove(notification.textDocument.uri));
            gop.key_ptr.* = try self.gpa.dupe(u8, notification.textDocument.uri);
        }
        gop.value_ptr.* = new_text;
    }

    pub fn changeDocument(
        self: *Handler,
        _: std.mem.Allocator,
        notification: types.DidChangeTextDocumentParams,
    ) !void {
        if (notification.contentChanges.len == 0) return;
        const new_text = try self.gpa.dupeZ(u8, notification.contentChanges[notification.contentChanges.len - 1].literal_1.text); // We informed the client that we only do full document syncs
        errdefer self.gpa.free(new_text);

        const gop = try self.documents.getOrPut(self.gpa, notification.textDocument.uri);
        if (gop.found_existing) {
            self.gpa.free(gop.value_ptr.*); // free old text even though this shoudnt be necessary
        } else {
            errdefer std.debug.assert(self.documents.remove(notification.textDocument.uri));
            gop.key_ptr.* = try self.gpa.dupe(u8, notification.textDocument.uri);
        }
        gop.value_ptr.* = new_text;

        var res: types.PublishDiagnosticsParams = .{
            .uri = notification.textDocument.uri,
            .diagnostics = &.{},
        };

        var buf = std.ArrayList(u8).init(self.gpa);
        defer buf.deinit();

        var diag: ziggy.Diagnostic = .{ .path = null };

        const ast = ziggy.Ast.init(self.gpa, new_text, true, &diag) catch undefined;
        defer if (std.meta.activeTag(diag.err) == .none) ast.deinit();

        if (std.meta.activeTag(diag.err) != .none) {
            try buf.writer().print("{lsp}", .{diag});
            const range = diag.tok.loc.getSelection(new_text);
            res.diagnostics = &.{
                .{
                    .range = .{
                        .start = .{
                            .line = @intCast(range.start.line - 1),
                            .character = @intCast(range.start.col - 1),
                        },
                        .end = .{
                            .line = @intCast(range.end.line - 1),
                            .character = @intCast(range.end.col - 1),
                        },
                    },
                    .severity = .Error,
                    .message = buf.items,
                },
            };
        }

        const msg = try self.server.sendToClientNotification(
            "textDocument/publishDiagnostics",
            res,
        );

        defer self.gpa.free(msg);
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
        const kv = self.documents.fetchRemove(notification.textDocument.uri) orelse return;
        self.gpa.free(kv.key);
        self.gpa.free(kv.value);
    }

    pub fn completion(
        _: Handler,
        arena: std.mem.Allocator,
        request: types.CompletionParams,
    ) !ResultType("textDocument/completion") {
        _ = request;
        var completions: std.ArrayListUnmanaged(types.CompletionItem) = .{};

        try completions.append(arena, types.CompletionItem{
            .label = "ziggy",
            .kind = .Text,
            .documentation = .{ .string = "Is a Zig-flavored data format" },
        });

        try completions.append(arena, types.CompletionItem{
            .label = "zls",
            .kind = .Function,
            .documentation = .{ .string = "is a Zig LSP" },
        });

        return .{
            .CompletionList = types.CompletionList{
                .isIncomplete = false,
                .items = completions.items,
            },
        };
    }

    pub fn gotoDefinition(
        _: Handler,
        arena: std.mem.Allocator,
        request: types.DefinitionParams,
    ) !ResultType("textDocument/definition") {
        _ = arena;
        _ = request;
        return null;
    }

    pub fn hover(
        self: Handler,
        arena: std.mem.Allocator,
        request: types.HoverParams,
        offset_encoding: offsets.Encoding,
    ) !?types.Hover {
        _ = arena;

        const text = self.documents.get(request.textDocument.uri) orelse return null;
        const line = offsets.lineSliceAtPosition(text, request.position, offset_encoding);

        return types.Hover{
            .contents = .{
                .MarkupContent = .{
                    .kind = .plaintext,
                    .value = line,
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

// pub fn run(
//     gpa: std.mem.Allocator,
//     docs: *std.StringHashMap([]u8),
// ) !void {
//     const stdin_unbuffered_reader = std.io.getStdIn().reader();
//     var buffered_reader = std.io.bufferedReader(stdin_unbuffered_reader);
//     const r = buffered_reader.reader();
//     const w = std.io.getStdOut().writer();

//     var buf = std.ArrayList(u8).init(gpa);
//     var outbuf = std.ArrayList(u8).init(gpa);

//     while (true) : (buf.clearRetainingCapacity()) {
//         const len = try parseHeader(&buf, r);
//         log.debug("headers done", .{});

//         log.debug("len from run(): {}", .{len});
//         try buf.resize(len);

//         try r.readNoEof(buf.items);

//         log.debug("received: \n\n{s}\n\n", .{buf.items});

//         try reply(gpa, buf.items, &outbuf, w, docs);
//         outbuf.clearRetainingCapacity();
//     }
// }

// fn reply(
//     gpa: std.mem.Allocator,
//     bytes: []const u8,
//     buf: *std.ArrayList(u8),
//     w: anytype,
//     docs: *std.StringHashMap([]u8),
// ) !void {
//     const msg = try std.json.parseFromSlice(Message, gpa, bytes, .{
//         .ignore_unknown_fields = true,
//     });
//     defer msg.deinit();

//     switch (msg.value.tag) {
//         .notification => {
//             const notif = msg.value.notification.?;
//             switch (notif) {
//                 else => return,
//                 .@"textDocument/didChange" => |change| {
//                     // const gop = try docs.getOrPut(change.textDocument.uri);
//                     const text = change.contentChanges[0].literal_1.text;
//                     log.debug("saving '{s}' \n\n{s}\n\n", .{ change.textDocument.uri, text });
//                     // if (gop.found_existing) {
//                     //     gop.value_ptr.* = try gpa.realloc(gop.value_ptr.*, text.len);
//                     // } else {
//                     //     gop.value_ptr.* = try gpa.alloc(u8, text.len);
//                     // }

//                     // @memcpy(gop.value_ptr.*, text);
//                     log.debug("saved '{s}'", .{change.textDocument.uri});
//                 },
//             }
//         },
//         .response => @panic("TODO: message response"),
//         .request => {
//             const req = msg.value.request.?;
//             switch (req.params) {
//                 else => std.debug.panic("TODO: req.params == '{s}'", .{@tagName(req.params)}),
//                 .@"textDocument/willSaveWaitUntil" => |ws| {
//                     const maybe_doc = docs.get(ws.textDocument.uri);
//                     var text_edit_buf: [1]types.TextEdit = undefined;
//                     var text_edits: []types.TextEdit = text_edit_buf[0..0];
//                     if (maybe_doc) |doc| {
//                         _ = doc;
//                         text_edits = &text_edit_buf;
//                         text_edits[0] = .{
//                             .range = .{ .start = .{
//                                 .line = 1,
//                                 .character = 1,
//                             }, .end = .{
//                                 .line = 1,
//                                 .character = "banana".len,
//                             } },
//                             .newText = "banana",
//                         };
//                     }

//                     const frame: Frame([]const types.TextEdit) = .{
//                         .id = req.id,
//                         .result = text_edits,
//                     };

//                     try frame.write(buf, w);
//                 },
//                 .initialize => |_| {
//                     const initialize_result: types.InitializeResult = .{
//                         .serverInfo = .{
//                             .name = "Ziggy LSP",
//                             .version = "0.0.1",
//                         },
//                         .capabilities = .{
//                             .positionEncoding = .@"utf-8",
//                             .textDocumentSync = .{
//                                 .TextDocumentSyncOptions = .{
//                                     .openClose = true,
//                                     .change = .Full,
//                                     // .save = .{ .bool = true },
//                                     .willSaveWaitUntil = true,
//                                 },
//                             },
//                         },
//                     };

//                     const frame: Frame(types.InitializeResult) = .{
//                         .id = req.id,
//                         .result = initialize_result,
//                     };

//                     try frame.write(buf, w);
//                 },
//             }
//         },
//     }
// }

// pub fn Frame(comptime T: type) type {
//     return struct {
//         jsonrpc: []const u8 = "2.0",
//         id: types.RequestId,
//         result: T,

//         pub fn write(self: @This(), buf: *std.ArrayList(u8), w: anytype) !void {
//             try std.json.stringify(self, .{}, buf.writer());
//             try w.print(
//                 "Content-Length: {}\r\n\r\n{s}",
//                 .{ buf.items.len, buf.items },
//             );
//         }
//     };
// }

// fn parseHeader(buf: *std.ArrayList(u8), reader: anytype) !usize {
//     var maybe_len: ?usize = null;
//     while (true) : (buf.clearRetainingCapacity()) {
//         try reader.readUntilDelimiterArrayList(buf, '\n', 1024);
//         log.debug("header: '{s}'", .{buf.items});

//         const prefix = "Content-Length: ";

//         if (buf.items.len == 1) break;
//         if (!std.mem.startsWith(u8, buf.items, prefix)) continue;

//         const len_string = blk: {
//             const rest = buf.items[prefix.len..];
//             break :blk rest[0 .. rest.len - 1];
//         };

//         if (maybe_len != null) @panic("len was already set");
//         maybe_len = try std.fmt.parseInt(usize, len_string, 10);
//         log.debug("len: {?}", .{maybe_len});
//     }

//     return maybe_len orelse error.MissingHeader;
// }
