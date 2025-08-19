const Parser = @This();

const std = @import("std");
const assert = std.debug.assert;
const Diagnostic = @import("Diagnostic.zig");
const Tokenizer = @import("Tokenizer.zig");
const Token = Tokenizer.Token;
const dynamic = @import("dynamic.zig");
const Value = dynamic.Value;

gpa: std.mem.Allocator,
code: [:0]const u8,
opts: ParseOptions,
tokenizer: Tokenizer,
state: State = .start,
closed_frontmatter: ?Token = null,

pub const ParseOptions = struct {
    diagnostic: ?*Diagnostic = null,
    copy_strings: CopyStrings = .always,
    /// Leave it set to null when parsing a pure Ziggy file.
    /// Providing a value means that you are parsing a frontmatter embedded in
    /// a document (e.g. SuperMD): in this case the parser will expect the
    /// document to start with a Ziggy document embedded between two `---`
    /// lines.
    frontmatter_meta: ?*FrontmatterMeta = null,
    /// Passed as an out parameter to obtain information about the frontmatter.
    pub const FrontmatterMeta = struct {
        /// Number of lines that the frontmatter occupies, including the lines
        /// occupied by '---'.
        lines: u32 = 0,
        /// Byte offset of where the frontmatter ends.
        offset: u32 = 0,
    };

    pub const CopyStrings = enum {
        to_unescape,
        always,
    };
};
pub const FrontmatterError = error{
    /// The document does not start with a frontmatter framing delimiter (---)
    MissingFrontmatter,
    /// Could not find a closing frontmatter framing delimiter.
    OpenFrontmatter,
};
pub const Error = Diagnostic.Error.ZigError || FrontmatterError;
const Container = enum {
    start,
    @"struct",
    dyn,
    array,
};

const State = enum {
    start,
    struct_lb_or_comma,
    field_dot,
};

pub fn addError(p: *Parser, err: Diagnostic.Error) Diagnostic.Error.ZigError {
    if (p.opts.diagnostic) |d| {
        try d.errors.append(p.gpa, err);
    }
    return err.zigError();
}

fn lexemes(comptime tags: []const Token.Tag) []const []const u8 {
    comptime var out: []const []const u8 = &.{};
    inline for (tags) |t| {
        const next_tag: []const []const u8 = &.{comptime t.lexeme()};
        out = out ++ next_tag;
    }
    return out;
}

/// Use an arena allocator to avoid leaking allocations when complex types
/// are involved.
pub fn parseLeaky(
    comptime T: type,
    gpa: std.mem.Allocator,
    code: [:0]const u8,
    opts: ParseOptions,
) Error!T {
    var parser: Parser = .{
        .gpa = gpa,
        .code = code,
        .opts = opts,
        .tokenizer = .{ .want_comments = false },
    };

    if (opts.frontmatter_meta != null) {
        const tok = parser.next();
        if (tok.tag != .frontmatter) {
            return error.MissingFrontmatter;
        }
    }

    const result = try parser.parseValue(T, parser.next());
    const extra = parser.next();

    if (opts.frontmatter_meta) |fm| {
        const tok = parser.closed_frontmatter orelse extra;
        if (tok.tag != .frontmatter) {
            return error.OpenFrontmatter;
        }

        fm.lines = parser.tokenizer.lines;
        fm.offset = tok.loc.end;
    } else {
        if (extra.tag != .eof) {
            return parser.addError(.{
                .unexpected = .{
                    .name = "EOF",
                    .sel = extra.loc.getSelection(code),
                    .expected = lexemes(&.{.eof}),
                },
            });
        }
    }

    return result;
}

/// Used when implementng `ziggy.parse()` for a type
pub fn parseValue(
    self: *Parser,
    comptime T: type,
    first_tok: Token,
) Error!T {
    const info = @typeInfo(T);

    switch (info) {
        .pointer => |ptr| switch (ptr.size) {
            .slice => switch (ptr.child) {
                u8 => return self.parseBytes(T, first_tok),
                else => return self.parseArray(T, first_tok),
            },
            .one => {
                const v: T = try self.gpa.create(ptr.child);
                errdefer self.gpa.destroy(v);

                v.* = try self.parseValue(ptr.child, first_tok);
                return v;
            },
            else => @compileError("Unable to parse pointer to many / C: " ++ @typeName(T)),
        },
        .bool => return self.parseBool(first_tok),
        .int => return self.parseInt(T, first_tok),
        .float => return self.parseFloat(T, first_tok),
        .@"struct" => {
            if (@hasDecl(T, "ziggy_options") and @hasDecl(T.ziggy_options, "parse")) {
                return T.ziggy_options.parse(self, first_tok);
            }
            return self.parseStruct(T, first_tok);
        },
        .@"union" => {
            if (@hasDecl(T, "ziggy_options") and @hasDecl(T.ziggy_options, "parse")) {
                return T.ziggy_options.parse(self, first_tok);
            }
            return self.parseUnion(T, first_tok);
        },
        .@"enum" => {
            if (@hasDecl(T, "ziggy_options") and @hasDecl(T.ziggy_options, "parse")) {
                return T.ziggy_options.parse(self, first_tok);
            }
            return self.parseEnum(T, first_tok);
        },
        .optional => |opt| {
            if (first_tok.tag == .null) {
                return null;
            } else {
                // this *has* to be a return try
                return try self.parseValue(opt.child, first_tok);
            }
        },
        else => @compileError("TODO"),
    }
}

fn parseEnum(
    self: *Parser,
    comptime T: type,
    first_tok: Token,
) Error!T {
    const token = switch (first_tok.tag) {
        .at => blk: {
            // Skip over "@<enumtype>("
            _ = try self.nextMust(.identifier);
            _ = try self.nextMust(.lp);
            break :blk try self.nextMust(.string);
        },

        .string => first_tok,
        else => {
            return self.addError(.{
                .syntax = .{
                    .name = first_tok.loc.src(self.code),
                    .sel = first_tok.loc.getSelection(self.code),
                },
            });
        },
    };

    const enum_str = std.mem.trim(u8, token.loc.src(self.code), "\"");

    if (first_tok.tag == .at) {
        // Skip over ")"
        _ = try self.nextMust(.rp);
    }

    return std.meta.stringToEnum(T, enum_str) orelse {
        return self.addError(.{
            .unknown_field = .{
                .name = first_tok.loc.src(self.code),
                .sel = first_tok.loc.getSelection(self.code),
            },
        });
    };
}

fn parseUnion(
    self: *Parser,
    comptime T: type,
    first_tok: Token,
) Error!T {
    // When a top-level struct omits curlies, the first
    // token will be a dot. Is such case we don't want
    // to expect a closing right bracket.
    const info = @typeInfo(T).@"union";
    comptime {
        if (info.tag_type == null) {
            @compileError("union '" ++ @typeName(T) ++ "' must be tagged");
        }

        for (info.fields) |f| {
            switch (@typeInfo(f.type)) {
                .@"struct" => {},
                else => {
                    @compileError("all the cases of union '" ++ @typeName(T) ++ "' must be of struct type");
                },
            }
        }
    }

    // TODO: check identifier for conformance
    try self.must(first_tok, .identifier);
    const case_name = first_tok.loc.src(self.code);

    inline for (info.fields) |f| {
        if (std.mem.eql(u8, f.name, case_name)) {
            return @unionInit(
                T,
                f.name,
                try self.parseStruct(f.type, self.next()),
            );
        }
    }

    return self.addError(.{
        .unknown_field = .{
            .name = first_tok.loc.src(self.code),
            .sel = first_tok.loc.getSelection(self.code),
        },
    });
}
fn parseStruct(
    self: *Parser,
    comptime T: type,
    first_tok: Token,
) Error!T {
    // When a top-level struct omits curlies, the first
    // token will be a dot. Is such case we don't want
    // to expect a closing right bracket.
    const need_closing_rb = first_tok.tag != .dot;
    const info = @typeInfo(T).@"struct";

    var tok = first_tok;
    if (tok.tag == .identifier) {
        // TODO: check identifier for conformance
        tok = self.next();
    }
    if (tok.tag == .lb) {
        tok = self.next();
    }

    // TODO: optimization: turn this into an array of bools when
    //       diagnocstics are disabled
    var fields_seen = [_]?Token.Loc{null} ** info.fields.len;
    var val: T = undefined;
    while (true) {
        if (need_closing_rb) {
            try self.mustAny(tok, &.{ .dot, .rb });
        } else if (self.opts.frontmatter_meta != null) {
            try self.mustAny(tok, &.{ .dot, .frontmatter, .eof });
        } else {
            try self.mustAny(tok, &.{ .dot, .eof });
        }

        if (tok.tag != .dot) {
            try self.finalizeStruct(
                T,
                info,
                &val,
                &fields_seen,
                tok,
            );

            if (tok.tag == .frontmatter) self.closed_frontmatter = tok;
            return val;
        }

        // we found the start of a field
        assert(tok.tag == .dot);

        const ident = try self.nextMust(.identifier);
        _ = try self.nextMust(.eql);
        const field_name = ident.loc.src(self.code);

        if (@hasDecl(T, "ziggy_options") and @hasDecl(T.ziggy_options, "skip_fields")) blk: {
            const skip_fields = T.ziggy_options.skip_fields;
            if (@TypeOf(skip_fields) != []const std.meta.FieldEnum(T)) {
                @compileError("ziggy_options.skip_fields must be a []const std.meta.FieldEnum(T)");
            }

            if (std.meta.stringToEnum(
                std.meta.FieldEnum(T),
                field_name,
            )) |field_enum| {
                if (std.mem.indexOfScalar(std.meta.FieldEnum(T), skip_fields, field_enum) == null) {
                    break :blk;
                }
            }

            return self.addError(.{
                .unknown_field = .{
                    .name = ident.loc.src(self.code),
                    .sel = ident.loc.getSelection(self.code),
                },
            });
        }

        outer: inline for (info.fields, 0..) |f, idx| {
            if (@hasDecl(T, "ziggy_options") and @hasDecl(T.ziggy_options, "skip_fields")) {
                const skip_fields = T.ziggy_options.skip_fields;
                if (@TypeOf(skip_fields) != []const std.meta.FieldEnum(T)) {
                    @compileError("ziggy_options.skip_fields must be a []const std.meta.FieldEnum(T)");
                }

                const sf_idx: std.meta.FieldEnum(T) = @enumFromInt(idx);
                inline for (skip_fields) |sf| {
                    @setEvalBranchQuota(1000000);
                    if (sf == sf_idx) continue :outer;
                }
            }

            if (std.mem.eql(u8, f.name, field_name)) {
                if (fields_seen[idx]) |first_loc| {
                    return self.addError(.{
                        .duplicate_field = .{
                            .name = ident.loc.src(self.code),
                            .sel = ident.loc.getSelection(self.code),
                            .original = first_loc.getSelection(self.code),
                        },
                    });
                }
                fields_seen[idx] = ident.loc;
                @field(val, f.name) = try self.parseValue(f.type, self.next());
                break;
            }
        } else {
            return self.addError(.{
                .unknown_field = .{
                    .name = ident.loc.src(self.code),
                    .sel = ident.loc.getSelection(self.code),
                },
            });
        }

        tok = self.next();
        if (tok.tag == .comma) {
            tok = self.next();
        } else {
            if (need_closing_rb) {
                try self.mustAny(tok, &.{ .comma, .rb });
            } else if (self.opts.frontmatter_meta != null) {
                try self.mustAny(tok, &.{ .comma, .rb, .frontmatter, .eof });
            } else {
                try self.mustAny(tok, &.{ .comma, .rb, .eof });
            }
        }
    }
}

// TODO: allocate memory to copy fields_seen and pass it all to diagnostic
fn finalizeStruct(
    self: *Parser,
    comptime T: type,
    info: std.builtin.Type.Struct,
    val: *T,
    fields_seen: []const ?Token.Loc,
    struct_end: Token,
) Error!void {
    inline for (info.fields, 0..) |field, idx| {
        if (fields_seen[idx] == null) {
            if (field.default_value_ptr) |ptr| {
                const dv_ptr: *const field.type = @ptrCast(@alignCast(ptr));
                @field(val, field.name) = dv_ptr.*;
            } else {
                return self.addError(.{
                    .missing_field = .{
                        .name = field.name,
                        .sel = struct_end.loc.getSelection(self.code),
                    },
                });
            }
        }
    }
}

pub fn parseBool(self: *Parser, true_or_false: Token) !bool {
    try self.mustAny(true_or_false, &.{ .true, .false });
    return switch (true_or_false.tag) {
        .true => true,
        .false => false,
        else => unreachable,
    };
}

pub fn parseInt(self: *Parser, comptime T: type, num: Token) !T {
    assert(@typeInfo(T) == .int);

    try self.must(num, .integer);
    return std.fmt.parseInt(T, num.loc.src(self.code), 10) catch {
        return self.addError(.overflow);
    };
}

pub fn parseFloat(self: *Parser, comptime T: type, num: Token) !T {
    assert(@typeInfo(T) == .float);

    try self.must(num, .float);
    return std.fmt.parseFloat(T, num.loc.src(self.code)) catch {
        return self.addError(.overflow);
    };
}

pub fn parseBytes(self: *Parser, comptime T: type, token: Token) !T {
    try self.mustAny(token, &.{ .string, .at, .line_string });

    switch (token.tag) {
        .string => return self.mustUnescape(token),
        .at => {
            _ = try self.nextMust(.identifier);
            _ = try self.nextMust(.lp);
            const str = try self.nextMust(.string);
            _ = try self.nextMust(.rp);

            return self.mustUnescape(str);
        },
        .line_string => {
            var str: std.ArrayList(u8) = .empty;
            errdefer str.deinit(self.gpa);

            var current = token;
            while (current.tag == .line_string) {
                try str.appendSlice(self.gpa, current.loc.src(self.code)[2..]);

                if (self.peek().tag != .line_string) break;

                try str.append(self.gpa, '\n');
                current = self.next();
            }
            return str.toOwnedSlice(self.gpa);
        },
        else => unreachable,
    }
}

fn parseArray(self: *Parser, comptime T: type, lsb: Token) !T {
    const info = @typeInfo(T).pointer;
    assert(info.size == .slice);

    try self.must(lsb, .lsb);

    var tok = self.next();
    var list: std.ArrayListUnmanaged(info.child) = .{};
    errdefer list.deinit(self.gpa);

    while (true) {
        if (tok.tag == .rsb) {
            return list.toOwnedSlice(self.gpa);
        }

        try list.append(
            self.gpa,
            try self.parseValue(info.child, tok),
        );

        tok = self.next();
        if (tok.tag == .comma) {
            tok = self.next();
        } else {
            try self.must(tok, .rsb);
        }
    }
}

pub fn next(self: *Parser) Token {
    return self.tokenizer.next(self.code);
}
pub fn nextNoEof(
    self: *Parser,
) !Token {
    const tok = self.next();
    if (tok.tag == .eof) return self.addError(.{
        .unexpected = .{
            .name = tok.tag.lexeme(),
            .sel = tok.loc.getSelection(self.code),
            .expected = &.{},
        },
    });
    return tok;
}

pub fn peek(self: *Parser) Token {
    var t = self.tokenizer;
    return t.next(self.code);
}

pub fn mustUnescape(self: *Parser, tok: Token) ![]const u8 {
    return tok.loc.unescape(self.gpa, self.code) catch |err| switch (err) {
        error.Syntax => {
            return self.addError(.{
                .syntax = .{
                    .name = "bad escape",
                    .sel = tok.loc.getSelection(self.code),
                },
            });
        },
    };
}
pub fn nextMust(self: *Parser, comptime tag: Token.Tag) !Token {
    return self.nextMustAny(&.{tag});
}

pub fn nextMustAny(
    self: *Parser,
    comptime tags: []const Token.Tag,
) !Token {
    const next_tok = self.next();
    try self.mustAny(next_tok, tags);
    return next_tok;
}

pub fn must(
    self: *Parser,
    tok: Token,
    comptime tag: Token.Tag,
) !void {
    return self.mustAny(tok, &.{tag});
}

pub fn mustAny(
    self: *Parser,
    tok: Token,
    comptime tags: []const Token.Tag,
) !void {
    for (tags) |t| {
        if (t == tok.tag) break;
    } else {
        return self.addError(.{
            .unexpected = .{
                .name = tok.tag.lexeme(),
                .sel = tok.loc.getSelection(self.code),
                .expected = lexemes(tags),
            },
        });
    }
}

test "struct - basics" {
    const case =
        \\.foo = "bar",
        \\.bar = false,
    ;

    const Case = struct {
        foo: []const u8,
        bar: bool,
    };

    var arena_state = std.heap.ArenaAllocator.init(std.testing.allocator);
    defer arena_state.deinit();
    const arena = arena_state.allocator();
    const c = try parseLeaky(Case, arena, case, .{});
    try std.testing.expectEqualStrings("bar", c.foo);
    try std.testing.expectEqual(false, c.bar);
}

test "struct - top level curlies" {
    const case =
        \\{
        \\   .foo = "bar",
        \\   .bar = false,
        \\}
    ;

    const Case = struct {
        foo: []const u8,
        bar: bool,
    };

    var arena_state = std.heap.ArenaAllocator.init(std.testing.allocator);
    defer arena_state.deinit();
    const arena = arena_state.allocator();
    const c = try parseLeaky(Case, arena, case, .{});
    try std.testing.expectEqualStrings("bar", c.foo);
    try std.testing.expectEqual(false, c.bar);
}

test "struct - optional comma" {
    const case =
        \\.foo = "bar",
        \\.bar = false
    ;

    const Case = struct {
        foo: []const u8,
        bar: bool,
    };

    var arena_state = std.heap.ArenaAllocator.init(std.testing.allocator);
    defer arena_state.deinit();
    const arena = arena_state.allocator();
    const c = try parseLeaky(Case, arena, case, .{});
    try std.testing.expectEqualStrings("bar", c.foo);
    try std.testing.expectEqual(false, c.bar);
}

test "string" {
    const case =
        \\
        \\ "foo"
        \\
    ;

    var diag: Diagnostic = .{ .path = null };

    const opts: ParseOptions = .{ .diagnostic = &diag };

    var arena_state = std.heap.ArenaAllocator.init(std.testing.allocator);
    defer arena_state.deinit();
    const arena = arena_state.allocator();
    const result = try parseLeaky([]const u8, arena, case, opts);
    try std.testing.expectEqualStrings("foo", result);
}

test "custom string literal" {
    const case =
        \\
        \\ @date("2020-07-06T00:00:00")
        \\
    ;

    var diag: Diagnostic = .{ .path = null };

    const opts: ParseOptions = .{ .diagnostic = &diag };

    var arena_state = std.heap.ArenaAllocator.init(std.testing.allocator);
    defer arena_state.deinit();
    const arena = arena_state.allocator();
    const result = try parseLeaky([]const u8, arena, case, opts);
    try std.testing.expectEqualStrings("2020-07-06T00:00:00", result);
}

test "int basics" {
    const case =
        \\
        \\ 1042
        \\
    ;

    var diag: Diagnostic = .{ .path = null };

    const opts: ParseOptions = .{ .diagnostic = &diag };

    var arena_state = std.heap.ArenaAllocator.init(std.testing.allocator);
    defer arena_state.deinit();
    const arena = arena_state.allocator();
    const result = try parseLeaky(usize, arena, case, opts);
    try std.testing.expectEqual(1042, result);
}

test "float basics" {
    const case =
        \\
        \\ 10.42
        \\
    ;

    var diag: Diagnostic = .{ .path = null };

    const opts: ParseOptions = .{ .diagnostic = &diag };

    var arena_state = std.heap.ArenaAllocator.init(std.testing.allocator);
    defer arena_state.deinit();
    const arena = arena_state.allocator();
    const result = try parseLeaky(f64, arena, case, opts);
    try std.testing.expectEqual(10.42, result);
}

test "array basics" {
    const case =
        \\
        \\ [1, 2, 3]
        \\
    ;

    var diag: Diagnostic = .{ .path = null };

    const opts: ParseOptions = .{ .diagnostic = &diag };

    var arena_state = std.heap.ArenaAllocator.init(std.testing.allocator);
    defer arena_state.deinit();
    const arena = arena_state.allocator();
    const result = try parseLeaky([]usize, arena, case, opts);

    try std.testing.expectEqualSlices(usize, &.{ 1, 2, 3 }, result);
}

test "array trailing comma" {
    const case =
        \\
        \\ [1, 2, 3, ]
        \\
    ;

    var diag: Diagnostic = .{ .path = null };
    const opts: ParseOptions = .{ .diagnostic = &diag };

    var arena_state = std.heap.ArenaAllocator.init(std.testing.allocator);
    defer arena_state.deinit();
    const arena = arena_state.allocator();

    const result = try parseLeaky([]usize, arena, case, opts);

    try std.testing.expectEqualSlices(usize, &.{ 1, 2, 3 }, result);
}

test "comments are ignored" {
    const case =
        \\.foo = "bar",
        \\// This is false because I say so
        \\.bar = false,
    ;

    const Case = struct {
        foo: []const u8,
        bar: bool,
    };
    var arena_state = std.heap.ArenaAllocator.init(std.testing.allocator);
    defer arena_state.deinit();
    const arena = arena_state.allocator();

    const c = try parseLeaky(Case, arena, case, .{});
    try std.testing.expectEqualStrings("bar", c.foo);
    try std.testing.expectEqual(false, c.bar);
}

test "optional - string" {
    const case =
        \\
        \\ "foo"
        \\
    ;

    var diag: Diagnostic = .{ .path = null };

    const opts: ParseOptions = .{ .diagnostic = &diag };

    var arena_state = std.heap.ArenaAllocator.init(std.testing.allocator);
    defer arena_state.deinit();
    const arena = arena_state.allocator();

    const result = try parseLeaky(?[]const u8, arena, case, opts);
    try std.testing.expectEqualStrings("foo", result.?);
}

test "optional - null" {
    const case =
        \\
        \\ null
        \\
    ;

    var diag: Diagnostic = .{ .path = null };

    const opts: ParseOptions = .{ .diagnostic = &diag };

    var arena_state = std.heap.ArenaAllocator.init(std.testing.allocator);
    defer arena_state.deinit();
    const arena = arena_state.allocator();

    const result = try parseLeaky(?[]const u8, arena, case, opts);
    try std.testing.expect(result == null);
}

test "tagged string" {
    const case =
        \\
        \\ @tagname("foo")
        \\
    ;

    var diag: Diagnostic = .{ .path = null };

    const opts: ParseOptions = .{ .diagnostic = &diag };

    var arena_state = std.heap.ArenaAllocator.init(std.testing.allocator);
    defer arena_state.deinit();
    const arena = arena_state.allocator();

    const result = try parseLeaky([]const u8, arena, case, opts);
    try std.testing.expectEqualStrings("foo", result);
}

test "unions" {
    const case =
        \\.dep1 = Remote {
        \\    .url = "https://github.com",
        \\    .hash = @sha512("123..."),
        \\},
        \\.dep2 =  Local {
        \\    .path = "../super"
        \\},
    ;

    const Project = struct {
        dep1: Dependency,
        dep2: Dependency,
        pub const Dependency = union(enum) {
            Remote: struct {
                url: []const u8,
                hash: []const u8,
            },
            Local: struct {
                path: []const u8,
            },
        };
    };

    var arena_state = std.heap.ArenaAllocator.init(std.testing.allocator);
    defer arena_state.deinit();
    const arena = arena_state.allocator();

    const c = try parseLeaky(Project, arena, case, .{});
    try std.testing.expect(c.dep1 == .Remote);
    try std.testing.expectEqualStrings("https://github.com", c.dep1.Remote.url);
    try std.testing.expectEqualStrings("123...", c.dep1.Remote.hash);
    try std.testing.expect(c.dep2 == .Local);
    try std.testing.expectEqualStrings("../super", c.dep2.Local.path);
}

test "multiline string" {
    const just_str =
        \\.outer = Stri {
        \\  .str =
        \\    \\fst
        \\    \\snd
        \\  ,
        \\}
    ;

    const MultiStr = struct { outer: struct {
        str: []const u8,
    } };

    var arena_state = std.heap.ArenaAllocator.init(std.testing.allocator);
    defer arena_state.deinit();
    const arena = arena_state.allocator();

    const c = try parseLeaky(MultiStr, arena, just_str, .{});
    try std.testing.expectEqualStrings("fst\nsnd", c.outer.str);
}

test "braceless struct - frontmatter" {
    const case =
        \\---
        \\.foo = "bar",
        \\.bar = false,
        \\---
    ;

    const Case = struct {
        foo: []const u8,
        bar: bool,
    };

    var diag: Diagnostic = .{ .path = null };

    var fm: ParseOptions.FrontmatterMeta = undefined;
    const opts: ParseOptions = .{ .diagnostic = &diag, .frontmatter_meta = &fm };

    var arena_state = std.heap.ArenaAllocator.init(std.testing.allocator);
    defer arena_state.deinit();
    const arena = arena_state.allocator();

    _ = try parseLeaky(Case, arena, case, opts);
    const lines: u32 = @intCast(std.mem.count(u8, case, "\n"));
    try std.testing.expectEqual(lines, fm.lines);
    try std.testing.expectEqual(case.len, fm.offset);
}

test "braceless struct extra newline - frontmatter" {
    const case =
        \\---
        \\.foo = "bar",
        \\.bar = false,
        \\---
        \\
    ;

    const Case = struct {
        foo: []const u8,
        bar: bool,
    };

    var diag: Diagnostic = .{ .path = null };

    var fm: ParseOptions.FrontmatterMeta = undefined;
    const opts: ParseOptions = .{ .diagnostic = &diag, .frontmatter_meta = &fm };

    var arena_state = std.heap.ArenaAllocator.init(std.testing.allocator);
    defer arena_state.deinit();
    const arena = arena_state.allocator();

    _ = try parseLeaky(Case, arena, case, opts);
    const lines: u32 = @intCast(std.mem.count(u8, case, "\n"));
    try std.testing.expectEqual(lines, fm.lines);
    try std.testing.expectEqual(case.len, fm.offset);
}

test "braceless struct no trailing comma - frontmatter" {
    const case =
        \\---
        \\.foo = "bar",
        \\.bar = false
        \\---
    ;

    const Case = struct {
        foo: []const u8,
        bar: bool,
    };

    var diag: Diagnostic = .{ .path = null };

    var fm: ParseOptions.FrontmatterMeta = undefined;
    const opts: ParseOptions = .{ .diagnostic = &diag, .frontmatter_meta = &fm };

    var arena_state = std.heap.ArenaAllocator.init(std.testing.allocator);
    defer arena_state.deinit();
    const arena = arena_state.allocator();

    _ = try parseLeaky(Case, arena, case, opts);
    const lines: u32 = @intCast(std.mem.count(u8, case, "\n"));
    try std.testing.expectEqual(lines, fm.lines);
    try std.testing.expectEqual(case.len, fm.offset);
}

test "braceless struct no trailing comma extra newline - frontmatter" {
    const case =
        \\---
        \\.foo = "bar",
        \\.bar = false
        \\---
        \\
    ;

    const Case = struct {
        foo: []const u8,
        bar: bool,
    };

    var diag: Diagnostic = .{ .path = null };

    var fm: ParseOptions.FrontmatterMeta = undefined;
    const opts: ParseOptions = .{ .diagnostic = &diag, .frontmatter_meta = &fm };

    var arena_state = std.heap.ArenaAllocator.init(std.testing.allocator);
    defer arena_state.deinit();
    const arena = arena_state.allocator();

    _ = try parseLeaky(Case, arena, case, opts);
    const lines: u32 = @intCast(std.mem.count(u8, case, "\n"));
    try std.testing.expectEqual(lines, fm.lines);
    try std.testing.expectEqual(case.len, fm.offset);
}

test "struct - frontmatter" {
    const case =
        \\---
        \\{
        \\    .foo = "Zig's New Relationship with LLVM",
        \\    .bar = false,
        \\}
        \\---
        \\
    ;

    const Case = struct {
        foo: []const u8,
        bar: bool,
    };

    var diag: Diagnostic = .{ .path = null };

    var fm: ParseOptions.FrontmatterMeta = undefined;
    const opts: ParseOptions = .{ .diagnostic = &diag, .frontmatter_meta = &fm };

    var arena_state = std.heap.ArenaAllocator.init(std.testing.allocator);
    defer arena_state.deinit();
    const arena = arena_state.allocator();

    _ = try parseLeaky(Case, arena, case, opts);
    const lines: u32 = @intCast(std.mem.count(u8, case, "\n"));
    try std.testing.expectEqual(lines, fm.lines);
    try std.testing.expectEqual(case.len, fm.offset);
}
