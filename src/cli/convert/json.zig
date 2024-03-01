const std = @import("std");
const ziggy = @import("ziggy");
const Diagnostic = ziggy.Diagnostic;
const Ast = ziggy.Ast;
const Node = Ast.Node;
const Token = ziggy.Tokenizer.Token;

pub fn ziggyAst(
    gpa: std.mem.Allocator,
    schema: ziggy.schema.Schema,
    diag: ?*ziggy.Diagnostic,
    r: anytype,
) !ziggy.Ast {
    var buf = std.ArrayList(u8).init(gpa);
    defer buf.deinit();

    try r.readAllArrayList(&buf, ziggy.max_size);

    const bytes = try buf.toOwnedSliceSentinel(0);

    var js_diag: std.json.Diagnostics = .{};
    var scanner = std.json.Scanner.initCompleteInput(gpa, bytes);
    scanner.enableDiagnostics(&js_diag);

    var p: Parser = .{
        .gpa = gpa,
        .code = bytes,
        .tokenizer = &scanner,
        .diagnostic = diag,
        .json_diag = &js_diag,
    };

    if (p.diagnostic) |d| {
        d.code = p.code;
    }

    errdefer {
        p.nodes.clearAndFree(gpa);
        p.rules.clearAndFree(gpa);
    }

    const root_node = try p.nodes.addOne(gpa);
    root_node.* = .{ .tag = .root, .parent_id = 0 };

    p.rule = schema.root;
    p.node = root_node;
    try p.next();
    while (true) {
        const rule = p.schema.nodes[p.rule.node];
        switch (p.node) {
            .root => switch (p.token) {
                .object_begin => {
                    switch (rule.tag) {
                        .@"struct" => {
                            try p.addChild(.@"struct", p.rule);
                        },

                        .map => {
                            try p.addChild(.map, p.rule);
                        },
                    }
                    p.loc.start = p.jsonLoc().start;
                },
                .object_end => {
                    p.loc.end = p.jsonLoc().end;
                },
                else => {
                    try p.addChild(.value, p.rule);
                },
            },
            .@"struct" => {},
            .value => switch (p.token) {
                .true => {
                    if (rule.tag != .bool) {
                        try p.addError(.{
                            .type_mismatch = .{
                                .token = .{
                                    .tag = .true,
                                    .loc = p.jsonLoc(),
                                },
                            },
                        });
                    }
                    p.tag = .bool;
                    p.loc = p.jsonLoc();
                    p.parent();
                },
                .false => {
                    if (rule.tag != .bool) {
                        try p.addError(.{
                            .type_mismatch = .{
                                .token = .{
                                    .tag = .false,
                                    .loc = p.jsonLoc(),
                                },
                            },
                        });
                    }
                    p.tag = .bool;
                    p.loc = p.jsonLoc();
                    p.parent();
                },
                .null => {
                    if (rule.tag != .optional) {
                        try p.addError(.{
                            .type_mismatch = .{
                                .token = .{
                                    .tag = .null,
                                    .loc = p.jsonLoc(),
                                },
                            },
                        });
                    }
                    p.tag = .null;
                    p.loc = p.jsonLoc();
                    p.parent();
                },
                .number => {
                    const t: Token.Tag = if (std.mem.indexOfScalar(u8, p.token, '.') != null)
                        .float
                    else
                        .integer;
                    if (rule.tag != .integer and rule.tag != .float) {
                        try p.addError(.{
                            .type_mismatch = .{
                                .token = .{
                                    .tag = t,
                                    .loc = p.jsonLoc(),
                                },
                            },
                        });
                    }
                    p.tag = t;
                    p.loc = p.jsonLoc();
                    p.parent();
                },
                .string => {
                    if (rule.tag != .bytes) {
                        try p.addError(.{
                            .type_mismatch = .{
                                .token = .{
                                    .tag = .bytes,
                                    .loc = p.jsonLoc(),
                                },
                            },
                        });
                    }
                    p.tag = .bytes;
                    p.loc = p.jsonLoc();
                    p.parent();
                },
            },
        }
    }
}

const Parser = struct {
    gpa: std.mem.Allocator,
    code: [:0]const u8,
    tokenizer: *std.json.Scanner,
    diagnostic: ?*Diagnostic,
    json_diag: *std.json.Diagnostics,
    rules: std.ArrayListUnmanaged(?ziggy.schema.Schema.Rule) = .{},
    rule: ?ziggy.schema.Schema.Rule = null,
    nodes: std.ArrayListUnmanaged(Node) = .{},
    node: *Node = undefined,
    token: std.json.Token = undefined,

    pub fn ast(p: *Parser) !ziggy.Ast {
        return .{
            .code = p.code,
            .nodes = try p.nodes.toOwnedSlice(p.gpa),
        };
    }

    fn peek(p: *Parser) ziggy.Token.Tag {
        return p.tokenizer.peek(p.code).tag;
    }

    fn jsonLoc(p: Parser) Token.Loc {
        const offset = p.json_diag.getByteOffset();
        return .{
            .start = offset,
            .end = offset + p.token.len,
        };
    }

    fn next(p: *Parser) !void {
        const token = p.tokenizer.next(p.code) catch {
            const offset = p.js_diag.getByteOffset();
            try p.addError(.{
                .invalid_token = .{
                    .token = .{
                        .tag = if (offset == p.code.len) .eof else .invalid,
                        .loc = .{
                            .start = offset,
                            .end = offset + 1,
                        },
                    },
                },
            });
        };
        p.token = token;
    }

    fn must(p: *Parser, comptime tag: Token.Tag) !void {
        return p.mustAny(&.{tag});
    }

    fn mustAny(p: *Parser, comptime tags: []const Token.Tag) !void {
        for (tags) |t| {
            if (t == p.token.tag) break;
        } else {
            try p.addError(.{
                .unexpected_token = .{
                    .token = p.token,
                    .expected = tags,
                },
            });
        }
    }

    pub fn addError(p: *Parser, err: Diagnostic.Error) !void {
        if (p.diagnostic) |d| {
            try d.errors.append(p.gpa, err);
        }
        return err.zigError();
    }

    pub fn addChild(p: *Parser, tag: Node.Tag, rule: ?ziggy.schema.Schema.Rule) !void {
        const n = p.node;
        const self_id = p.getId();
        const new_child_id: u32 = @intCast(p.nodes.items.len);
        if (n.last_child_id != 0) {
            const child = &p.nodes.items[n.last_child_id];
            std.debug.assert(child.next_id == 0);
            child.next_id = new_child_id;
        }
        if (n.first_child_id == 0) {
            std.debug.assert(n.last_child_id == 0);
            n.first_child_id = new_child_id;
        }

        n.last_child_id = new_child_id;
        const child = try p.nodes.addOne(p.gpa);
        child.* = .{ .tag = tag, .parent_id = self_id };

        p.node = child;

        try p.rules.append(p.rule);
        p.rule = rule;
    }

    pub fn parent(p: *Parser) void {
        const n = p.node;
        p.node = &p.nodes.items[n.parent_id];
        p.rule = p.rules.pop();
    }

    pub fn getId(p: Parser) u32 {
        const n = p.node;
        const idx: u32 = @intCast(
            (@intFromPtr(n) - @intFromPtr(p.nodes.items.ptr)) / @sizeOf(Node),
        );
        std.debug.assert(idx < p.nodes.items.len);
        return idx;
    }
};
