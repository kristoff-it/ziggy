const Deserializer = @This();

const std = @import("std");
const Io = std.Io;
const assert = std.debug.assert;
const Tokenizer = @import("Tokenizer.zig");
const Token = Tokenizer.Token;
const Ast = @import("Ast.zig");
const schema = @import("schema");
const Allocator = std.mem.Allocator;

gpa: Allocator,
src: [:0]const u8,
meta: *Meta,
opts: Options,
tokenizer: *Tokenizer,

pub const Options = struct {
    /// If set to `to_unescape` you will need to ensure the lifetime of `src`
    /// outlasts the result of calling `deserializeLeaky`.
    copy_strings: CopyStrings = .to_unescape,
    /// Allows you to parse a Ziggy Document embedded in another file, like
    /// SuperMD or HTML.
    ///
    /// When set to anything other than `.none`:
    /// - `src` must start after the initial delimiter (e.g. after the opening
    ///   `---` in a SuperMD file)
    /// - `src` can continue up to the end of the document, including non-Ziggy
    ///   data. While not mandatory, you will generally want to do this since
    ///   `src` must be `[:0]const u8`.
    ///
    /// When expecting a delimiter, on successful deserialization `meta.doc`
    /// will be populated with information about the length of the Ziggy
    /// Document that can help you with subsequent parsing operations.
    delimiter: Tokenizer.Delimiter = .none,
    pub const CopyStrings = enum {
        to_unescape,
        always,
    };
};

/// See the description of `deserializeLeaky` to know how to use this
/// information.
pub const Meta = struct {
    /// Contains the location where the error happened.
    error_loc: Token.Loc,
    /// Set when `deserializeLeaky` returns `error.MissingField`, contains the name
    /// of the first missing field encountered.
    missing_field_name: []const u8,
    /// Populated when `deserializeLeaky` succeeds and `delimiter` is not `.none`.
    doc: struct {
        /// Number of newlines encountered while deserializing the Ziggy
        /// Document. This value is useful to compensate for the missing
        /// lines if you then need to report parsing errors in the outer
        /// document.
        lines: u32,
        /// Byte offset where the Ziggy Document ends. Includes the end
        /// delimiter.
        end: u32,
    },

    pub const init: Meta = undefined;

    /// Implements the correct error reporting procedure for `deserializeLeaky`.
    /// You can use this function directly or copy some of its contents to
    /// make your own error reporting function.
    ///
    /// Asserts that `e` is not error.OutOfMemory
    pub fn reportErrors(
        meta: Meta,
        gpa: Allocator,
        opts: Options,
        /// Path to the Ziggy Document, null will show "<stdin>" instead.
        path: ?[]const u8,
        src: [:0]const u8,
        e: Error,
        w: *Io.Writer,
    ) error{ OutOfMemory, WriteFailed }!void {
        const ast: Ast = try .init(gpa, src, .{ .delimiter = opts.delimiter });
        defer ast.deinit(gpa);

        if (ast.errors.len > 0) {
            for (ast.errors) |err| {
                const sel = err.main_location.getSelection(src);
                try w.print("{s}:{}:{} {f}\n", .{
                    path orelse "<stdin>",
                    sel.start.line,
                    sel.start.col,
                    err.tag,
                });
            }
            return;
        }

        const desc = switch (e) {
            error.OutOfMemory => unreachable, // handle elsewhere
            error.Unexpected => "unexpected token",
            error.Overflow => "integer overflow",
            error.DuplicateField => "duplicate field",
            error.UnknownField => "unknown field",
            error.MissingField => "missing field",
        };

        const sel = meta.error_loc.getSelection(src);
        try w.print("{s}:{}:{} {s}", .{
            path orelse "<stdin>",
            sel.start.line,
            sel.start.col,
            desc,
        });
        if (e == error.MissingField) try w.print(" '{s}'", .{meta.missing_field_name});
        try w.writeAll("\n");
    }

    /// Same as reportErrors but as a formatter.
    pub fn reportErrorsFmt(
        meta: Meta,
        gpa: Allocator,
        opts: Options,
        src: [:0]const u8,
        path: ?[]const u8,
        e: Error,
    ) Fmt {
        return .{
            .gpa = gpa,
            .meta = meta,
            .opts = opts,
            .src = src,
            .path = path,
            .e = e,
        };
    }

    pub const Fmt = struct {
        gpa: Allocator,
        meta: Meta,
        opts: Options,
        src: [:0]const u8,
        path: ?[]const u8,
        e: Error,
        pub fn format(fmt: *const Fmt, w: *Io.Writer) !void {
            fmt.meta.reportErrors(
                fmt.gpa,
                fmt.opts,
                fmt.path,
                fmt.src,
                fmt.e,
                w,
            ) catch return error.WriteFailed;
        }
    };
};
pub const Error = error{
    OutOfMemory,
    Unexpected,

    Overflow,
    DuplicateField,
    UnknownField,
    MissingField,
};

/// Returns the next token, consuming it
pub fn next(d: *const Deserializer) Token {
    return d.tokenizer.next(d.src, true);
}

/// Returns the next token tag, without consuming it
pub fn peek(d: *const Deserializer) Token.Tag {
    var copy = d.tokenizer.*;
    return copy.next(d.src, true).tag;
}

/// Sets the right meta field and returns error.Unexpected, to be used when
/// encountering an unexpected token in a custom deserialization function.
pub fn unexpected(d: *const Deserializer, tok: Token) Error {
    d.meta.error_loc = tok.loc;
    return error.Unexpected;
}

/// Sets the right meta field and returns error.Overflow, to be used when
/// encountering an integer overflow in a custom deserialization function.
pub fn overflow(d: *const Deserializer, tok: Token) Error {
    d.meta.error_loc = tok.loc;
    return error.Overflow;
}

/// Sets the right meta field and returns error.LengthMismatch, to be used when
/// deserializing a Zig array and encountering a Ziggy array of different length.
pub fn lengthMismatch(d: *const Deserializer, tok: Token) Error {
    d.meta.error_loc = tok.loc;
    return error.LengthMismatch;
}

/// Sets the right meta field and returns error.DuplicateField, to be used when
/// encountering a duplicate field in a custom deserialization function.
pub fn duplicateField(d: *const Deserializer, tok: Token) Error {
    d.meta.error_loc = tok.loc;
    return error.DuplicateField;
}

/// Sets the right meta field and returns error.UnknownField, to be used when
/// encountering an unkown field in a custom deserialization function.
pub fn unknownField(d: *const Deserializer, tok: Token) Error {
    d.meta.error_loc = tok.loc;
    return error.UnknownField;
}

/// Sets the right meta field and returns error.MissingField, to be used when
/// encountering a missing field in a custom deserialization function.
/// It's expected for `tok` to be the final token of the container:
///  - .rb for a struct or a dict
///  - .eod, .eof for a braceless struct
pub fn missingField(d: *const Deserializer, tok: Token, name: []const u8) Error {
    d.meta.error_loc = tok.loc;
    d.meta.missing_field_name = name;
    return error.MissingField;
}

/// Turns a Ziggy Document string into Zig types without having to go through an
/// AST first. This function can also be used to parse Ziggy Documents embedded
/// in other files, like SuperMD or HTML, see `Options.delimiter` for more info.
///
/// Since we don't build an AST when deserializing the Ziggy Document, any error
/// reported by this function (other than OutOfMemory) should not be immediately
/// shown to the user, instead:
///
/// 1. Build an AST and report any parsing error found.
/// 2. If the AST does not contain any parsing error, then show the error
///    returned by this function.
///
/// This will guarantee the highest level of quality of error reporting.
/// See `Meta.reportErrors` for a convenient way of showing errors.
///
/// Given that the type passed in might have default values, it might be not
/// immediately obvious how to free an allocated value correctly, hence the
/// 'Leaky' suffix. For long running programs you will want to pass in an arena
/// allocator.
///
/// See `deserialize` for a convenient way of attaching an arena allocator to a
/// deserialized value.
pub fn deserializeLeaky(
    T: type,
    gpa: Allocator,
    src: [:0]const u8,
    meta: *Meta,
    opts: Options,
) Deserializer.Error!T {
    var t: Tokenizer = .{ .delimiter = opts.delimiter };
    var d: Deserializer = .{
        .gpa = gpa,
        .src = src,
        .meta = meta,
        .opts = opts,
        .tokenizer = &t,
    };

    const result = try d.deserializeOne(T, t.next(src, true), true);
    const end = t.next(src, true);
    switch (end.tag) {
        .eof => {},
        .eod => meta.doc = .{ .lines = t.lines, .end = end.loc.end },
        else => {
            meta.error_loc = end.loc;
            return error.Unexpected;
        },
    }

    return result;
}

/// Same as `deserializeLeaky` (make sure to read its description!) but it
/// bundles the return value with an arena allocator. You can then call `deinit`
/// on the returned value to free all allocated data.
pub fn deserialize(
    T: type,
    gpa: Allocator,
    src: [:0]const u8,
    meta: *Meta,
    opts: Options,
) Deserializer.Error!Value(T) {
    var result: Value(T) = undefined;
    result.arena = .init(gpa);
    result.value = try deserializeLeaky(T, result.arena.allocator(), src, meta, opts);
    return result;
}

pub fn Value(T: type) T {
    return struct {
        value: T,
        arena_state: std.heap.ArenaAllocator,

        pub fn deinit(v: @This()) void {
            v.arena_state.deinit();
        }
    };
}

/// Deserializes one full value of type `T`.
/// Does not check that the tokenizer has reached EOD/EOF.
///
/// If you're looking to deserialize an entire Ziggy Document, you probably
/// don't want to use this function. Use `root.deserializeLeaky` instead.
///
/// If you're implementing a custom deserialization function in `ziggy_options`,
/// you will probably want to call this function from the provided
/// `Deserializer` parameter to deserialize basic types.
pub fn deserializeOne(d: *const Deserializer, T: type, first: Token, top_lvl: bool) Error!T {
    switch (@typeInfo(T)) {
        .type,
        .void,
        .null,
        .noreturn,
        .undefined,
        .error_union,
        .error_set,
        .@"fn",
        .@"opaque",
        .frame,
        .@"anyframe",
        .enum_literal,
        => @compileError("cannot deserialize " ++ @tagName(@typeInfo(T))),

        .bool => switch (first.tag) {
            .true => return true,
            .false => return false,
            else => return d.unexpected(first),
        },
        .comptime_float, .float => switch (first.tag) {
            .integer, .float => {
                return std.fmt.parseFloat(T, first.loc.slice(d.src)) catch {
                    // The token was already validated and parsing floats cannot overflow.
                    unreachable;
                };
            },
            else => return d.unexpected(first),
        },
        .comptime_int, .int => switch (first.tag) {
            .integer => {
                return std.fmt.parseInt(T, first.loc.slice(d.src), 10) catch |err| {
                    switch (err) {
                        error.InvalidCharacter => unreachable,
                        error.Overflow => return d.overflow(first),
                    }
                };
            },
            else => return d.unexpected(first),
        },
        .optional => |info| switch (first.tag) {
            .null => return null,
            else => return try d.deserializeOne(info.child, first, false),
        },
        .@"enum" => switch (first.tag) {
            .identifier => return std.meta.stringToEnum(T, first.loc.slice(d.src)),
            else => return d.unexpected(first),
        },
        .@"union" => |info| {
            if (@hasDecl(T, "ziggy_options") and
                @hasDecl(T.ziggy_options, "deserialize"))
            {
                return T.ziggy_options.deserialize(d, first, false);
            }
            if (info.tag_type == null) @compileError("cannot deserialize untagged unions");
            switch (first.tag) {
                .identifier => {
                    const tag = first.loc.slice(d.src)[1..]; // skip '.'
                    inline for (info.fields) |f| {
                        if (std.mem.eql(u8, f.name, tag)) {
                            if (f.type != void) return d.unexpected(first);
                            return @unionInit(T, f.name, {});
                        }
                    } else return d.unknownField(first);
                },
                .union_case => {
                    if (@hasDecl(T, "ziggy_options") and
                        @hasDecl(T.ziggy_options, "deserialize"))
                    {
                        return T.ziggy_options.deserialize(d, first, false);
                    }
                    const tag = blk: {
                        const raw = first.loc.slice(d.src)[1..]; // skip '.'
                        break :blk raw[0 .. raw.len - 1]; // skip '('
                    };

                    inline for (info.fields) |f| {
                        if (std.mem.eql(u8, f.name, tag)) {
                            if (f.type == void) return d.unexpected(first);
                            const value = @unionInit(
                                T,
                                f.name,
                                try d.deserializeOne(
                                    f.type,
                                    d.next(),
                                    top_lvl,
                                ),
                            );

                            const tok = d.next();
                            if (tok.tag != .rp) return d.unexpected(tok);
                            return value;
                        }
                    } else return d.unknownField(first);
                },
                else => return d.unexpected(first),
            }
        },
        .array, .vector => |info| {
            var arr: T = undefined;

            if (first.tag != .lsb) return d.unexpected(first);
            if (arr.len == 0) {
                const maybe_rsb = d.next();
                return if (maybe_rsb.tag == .rsb) arr else d.lengthMismatch(maybe_rsb);
            }

            for (&arr, 0..) |*elem, idx| {
                const tok = d.next();
                if (tok.tag == .rsb) {
                    return if (idx == arr.len - 1) arr else d.lengthMismatch(tok);
                }

                elem.* = try d.deserializeOne(
                    info.child,
                    d.next(),
                    false,
                );

                switch (d.peek()) {
                    .comma => {
                        _ = d.next();
                        continue;
                    },
                    .rsb => return if (idx == arr.len - 1) arr else d.lengthMismatch(next),
                    else => return d.unexpected(d.next()),
                }
            }
            comptime unreachable;
        },
        .@"struct" => |info| {
            if (@hasDecl(T, "ziggy_options") and
                @hasDecl(T.ziggy_options, "deserialize"))
            {
                return T.ziggy_options.deserialize(d, first, top_lvl);
            }

            var seen: std.StaticBitSet(info.fields.len) = .initEmpty();
            var result: T = undefined;

            var field_token = if (top_lvl and first.tag == .identifier)
                first
            else switch (first.tag) {
                .eod, .eof => {
                    d.meta.doc = .{ .lines = d.tokenizer.lines, .end = first.loc.end };
                    if (top_lvl) {
                        try d.finalizeStruct(&result, info, &seen, first);
                        return result;
                    } else return d.unexpected(first);
                },
                .lb => return d.deserializeDict(T, &result, info, &seen, first),
                .dotlb => blk: {
                    const tok = d.next();
                    if (tok.tag != .identifier) return d.unexpected(tok);
                    break :blk tok;
                },
                else => return d.unexpected(first),
            };
            assert(field_token.tag == .identifier);
            outer: while (true) { // this is safe because we're filling `seen`
                switch (field_token.tag) {
                    .identifier => {},
                    .rb, .eod, .eof => {
                        if (first.tag == .identifier) switch (field_token.tag) {
                            // braceless top lvl struct
                            .eof => {},
                            .eod => d.meta.doc = .{
                                .lines = d.tokenizer.lines,
                                .end = field_token.loc.end,
                            },
                            else => return d.unexpected(field_token),
                        } else switch (field_token.tag) {
                            .rb => {},
                            else => return d.unexpected(field_token),
                        }

                        // done parsing the struct, see if we have any missing field
                        try d.finalizeStruct(&result, info, &seen, field_token);
                        return result;
                    },
                    else => return d.unexpected(field_token),
                }
                const name = field_token.loc.slice(d.src)[1..]; // skip '.'
                inline for (info.fields, 0..) |f, idx| {
                    // We skip seen fields to optimize the happy path
                    if (!seen.isSet(idx) and std.mem.eql(u8, f.name, name)) {
                        const eql = d.next();
                        if (eql.tag != .eql) return d.unexpected(eql);

                        if (@hasDecl(T, "ziggy_options") and
                            @hasDecl(T.ziggy_options, "skip_fields"))
                        blk: {
                            const skip_fields = T.ziggy_options.skip_fields;
                            if (@TypeOf(skip_fields) != []const std.meta.FieldEnum(T)) {
                                @compileError(
                                    "ziggy_options.skip_fields must be a []const std.meta.FieldEnum(T)",
                                );
                            }

                            if (std.mem.indexOfScalar(
                                std.meta.FieldEnum(T),
                                skip_fields,
                                std.meta.stringToEnum(std.meta.FieldEnum(T), name).?,
                            ) != null) return d.unknownField(field_token);

                            // otherwise continue deserializing as normal
                            break :blk;
                        }

                        if (@hasDecl(T, "ziggy_options") and
                            @hasDecl(T.ziggy_options, "deserializeField"))
                        {
                            T.ziggy_options.deserializeField(d, &result, f.name, field_token);
                        } else {
                            @field(result, f.name) = try d.deserializeOne(
                                f.type,
                                d.next(),
                                false,
                            );
                        }
                        seen.set(idx);

                        if (d.peek() == .comma) _ = d.next();
                        field_token = d.next();
                        continue :outer;
                    }
                } else {
                    // unhappy path, either an unknown field or a duplicate field
                    inline for (info.fields, 0..) |f, idx| {
                        if (std.mem.eql(u8, f.name, name)) {
                            // duplicate
                            assert(seen.isSet(idx));
                            return d.duplicateField(field_token);
                        }
                    } else return d.unknownField(field_token);
                    comptime unreachable;
                }
            }
            comptime unreachable;
        },
        .pointer => |info| switch (info.size) {
            .c, .many => @compileError("cannot deserialize many or c-style pointers"),
            .one => {
                const ptr: T = d.gpa.create(info.child);
                errdefer d.gpa.destroy(ptr);

                ptr.* = try d.deserializeOne(info.child, first, top_lvl);
                return ptr;
            },
            .slice => switch (info.child) {
                u8 => return d.parseBytes(T, first),
                else => {
                    if (first.tag != .lsb) return d.unexpected(first);

                    var buf: std.ArrayList(info.child) = .empty;
                    errdefer buf.deinit(d.gpa);

                    while (true) {
                        const tok = d.next();
                        if (tok.tag == .rsb) break;

                        try buf.append(d.gpa, try d.deserializeOne(
                            info.child,
                            tok,
                            false,
                        ));

                        switch (d.peek()) {
                            .comma => {
                                _ = d.next();
                                continue;
                            },
                            .rsb => continue,
                            else => return d.unexpected(first),
                        }

                        comptime unreachable;
                    }

                    if (info.sentinel()) |s| {
                        return buf.toOwnedSliceSentinel(d.gpa, s);
                    } else {
                        return buf.toOwnedSlice(d.gpa);
                    }
                },
            },
        },
    }

    comptime unreachable;
}

inline fn finalizeStruct(
    d: *const Deserializer,
    result: anytype,
    info: std.builtin.Type.Struct,
    seen: anytype,
    last: Token,
) Error!void {
    inline for (info.fields, 0..) |f, idx| {
        if (!seen.isSet(idx)) {
            if (f.default_value_ptr != null) {
                @field(result, f.name) = f.defaultValue().?;
                continue;
            }
            return d.missingField(last, f.name);
        }
    }
}

inline fn deserializeDict(
    d: *const Deserializer,
    T: type,
    result: *T,
    info: std.builtin.Type.Struct,
    seen: anytype,
    first: Token,
) Error!T {
    assert(first.tag == .lb);

    var field_token = d.next();
    outer: while (true) {
        switch (field_token.tag) {
            .bytes => {},
            .rb => {
                try d.finalizeStruct(result, info, seen, field_token);
                return result.*;
            },
            else => return d.unexpected(field_token),
        }

        const name = blk: {
            const raw = field_token.loc.slice(d.src)[1..]; // skip first '"'
            break :blk raw[0 .. raw.len - 1]; // skip second '"'
        };

        inline for (info.fields, 0..) |f, idx| {
            // We skip seen fields to optimize the happy path
            if (!seen.isSet(idx) and std.mem.eql(u8, f.name, name)) {
                const colon = d.next();
                if (colon.tag != .colon) return d.unexpected(colon);
                if (@hasDecl(T, "ziggy_options") and
                    @hasDecl(T.ziggy_options, "deserializeField"))
                {
                    T.ziggy_options.deserializeField(d, result, f.name, field_token);
                } else {
                    @field(result, f.name) = try d.deserializeOne(
                        f.type,
                        d.next(),
                        false,
                    );
                }
                seen.set(idx);

                if (d.peek() == .comma) _ = d.next();
                field_token = d.next();
                continue :outer;
            }
        } else {
            // unhappy path, either an unknown field or a duplicate field
            inline for (info.fields, 0..) |f, idx| {
                if (std.mem.eql(u8, f.name, name)) {
                    // duplicate
                    assert(seen.isSet(idx));
                    return d.duplicateField(field_token);
                }
            } else return d.unknownField(field_token);
            comptime unreachable;
        }
    }
}

fn parseBytes(
    d: *const Deserializer,
    T: type,
    first_token: Token,
) !T {
    // TODO: unescape support!
    const info = @typeInfo(T).pointer;
    assert(info.child == u8);
    assert(info.size == .slice);
    switch (first_token.tag) {
        .bytes => {
            // TODO: avoid unnecessary copies
            const bytes = std.zig.string_literal.parseAlloc(
                d.gpa,
                first_token.loc.slice(d.src),
            ) catch |err| switch (err) {
                error.OutOfMemory => return error.OutOfMemory,
                error.InvalidLiteral => unreachable,
            };
            if (info.sentinel()) |s| {
                defer d.gpa.free(bytes);
                const new_buf = try d.gpa.allocSentinel(info.child, bytes.len, s);
                @memcpy(new_buf, bytes);
                return new_buf;
            } else switch (d.opts.copy_strings) {
                .always => return bytes,
                .to_unescape => return bytes,
            }
        },
        .bytes_line => {
            var result: std.ArrayList(u8) = .empty;
            errdefer result.deinit(d.gpa);

            var current = first_token;
            while (current.tag == .bytes_line) {
                try result.appendSlice(d.gpa, current.loc.slice(d.src)[2..]);
                if (d.peek() != .bytes_line) break;
                try result.append(d.gpa, '\n');
                current = d.next();
            }

            if (info.sentinel()) |s| {
                return result.toOwnedSliceSentinel(d.gpa, s);
            } else {
                return result.toOwnedSlice(d.gpa);
            }
        },
        else => {
            d.meta.error_loc = first_token.loc;
            return error.Unexpected;
        },
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

    var meta: Meta = undefined;
    const c = try deserializeLeaky(Case, arena, case, &meta, .{});

    try std.testing.expectEqualStrings("bar", c.foo);
    try std.testing.expectEqual(false, c.bar);
}

test "struct - top level curlies" {
    const case =
        \\.{
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

    var meta: Meta = undefined;
    const c = try deserializeLeaky(Case, arena, case, &meta, .{});

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

    var meta: Meta = undefined;
    const c = try deserializeLeaky(Case, arena, case, &meta, .{});

    try std.testing.expectEqualStrings("bar", c.foo);
    try std.testing.expectEqual(false, c.bar);
}

test "string" {
    const case =
        \\
        \\ "foo"
        \\
    ;

    var arena_state = std.heap.ArenaAllocator.init(std.testing.allocator);
    defer arena_state.deinit();
    const arena = arena_state.allocator();

    var meta: Meta = undefined;
    const result = try deserializeLeaky([]const u8, arena, case, &meta, .{});

    try std.testing.expectEqualStrings("foo", result);
}

test "union" {
    const case =
        \\
        \\ .date("2020-07-06T00:00:00")
        \\
    ;

    const Case = union(enum) {
        date: [:0]const u8,
    };

    var arena_state = std.heap.ArenaAllocator.init(std.testing.allocator);
    defer arena_state.deinit();
    const arena = arena_state.allocator();

    var meta: Meta = undefined;
    const result = try deserializeLeaky(Case, arena, case, &meta, .{});

    try std.testing.expectEqualStrings("2020-07-06T00:00:00", result.date);
}

test "int basics" {
    const case =
        \\
        \\ 1042
        \\
    ;

    var arena_state = std.heap.ArenaAllocator.init(std.testing.allocator);
    defer arena_state.deinit();
    const arena = arena_state.allocator();

    var meta: Meta = undefined;
    const result = try deserializeLeaky(usize, arena, case, &meta, .{});

    try std.testing.expectEqual(1042, result);
}

test "float basics" {
    const case =
        \\
        \\ 10.42
        \\
    ;

    var arena_state = std.heap.ArenaAllocator.init(std.testing.allocator);
    defer arena_state.deinit();
    const arena = arena_state.allocator();

    var meta: Meta = undefined;
    const result = try deserializeLeaky(f64, arena, case, &meta, .{});

    try std.testing.expectEqual(10.42, result);
}

test "array basics" {
    const case =
        \\
        \\ [1, 2, 3]
        \\
    ;

    var arena_state = std.heap.ArenaAllocator.init(std.testing.allocator);
    defer arena_state.deinit();
    const arena = arena_state.allocator();
    var meta: Meta = undefined;
    const result = try deserializeLeaky([]usize, arena, case, &meta, .{});

    try std.testing.expectEqualSlices(usize, &.{ 1, 2, 3 }, result);
}

test "array trailing comma" {
    const case =
        \\
        \\ [1, 2, 3, ]
        \\
    ;

    var arena_state = std.heap.ArenaAllocator.init(std.testing.allocator);
    defer arena_state.deinit();
    const arena = arena_state.allocator();

    var meta: Meta = undefined;
    const result = try deserializeLeaky([]usize, arena, case, &meta, .{});

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

    var meta: Meta = undefined;
    const c = try deserializeLeaky(Case, arena, case, &meta, .{});
    try std.testing.expectEqualStrings("bar", c.foo);
    try std.testing.expectEqual(false, c.bar);
}

test "optional - string" {
    const case =
        \\
        \\ "foo"
        \\
    ;

    var arena_state = std.heap.ArenaAllocator.init(std.testing.allocator);
    defer arena_state.deinit();
    const arena = arena_state.allocator();

    var meta: Meta = undefined;
    const result = try deserializeLeaky(?[]const u8, arena, case, &meta, .{});
    try std.testing.expectEqualStrings("foo", result.?);
}

test "optional - null" {
    const case =
        \\
        \\ null
        \\
    ;

    var arena_state = std.heap.ArenaAllocator.init(std.testing.allocator);
    defer arena_state.deinit();
    const arena = arena_state.allocator();

    var meta: Meta = undefined;
    const result = try deserializeLeaky(?[]const u8, arena, case, &meta, .{});
    try std.testing.expect(result == null);
}

test "unions" {
    const case =
        \\.dep1 = .remote(.{
        \\    .url = "https://github.com",
        \\    .hash = "123...",
        \\}),
        \\.dep2 =  .local(.{
        \\    .path = "../super"
        \\}),
    ;

    const Project = struct {
        dep1: Dependency,
        dep2: Dependency,
        pub const Dependency = union(enum) {
            remote: struct {
                url: []const u8,
                hash: []const u8,
            },
            local: struct {
                path: []const u8,
            },
        };
    };

    var arena_state = std.heap.ArenaAllocator.init(std.testing.allocator);
    defer arena_state.deinit();
    const arena = arena_state.allocator();

    var meta: Meta = undefined;
    const c = try deserializeLeaky(Project, arena, case, &meta, .{});
    try std.testing.expect(c.dep1 == .remote);
    try std.testing.expectEqualStrings("https://github.com", c.dep1.remote.url);
    try std.testing.expectEqualStrings("123...", c.dep1.remote.hash);
    try std.testing.expect(c.dep2 == .local);
    try std.testing.expectEqualStrings("../super", c.dep2.local.path);
}

test "multiline string" {
    const case =
        \\.outer = .{
        \\  .str =
        \\    \\fst
        \\    \\snd
        \\  ,
        \\}
    ;

    const Case = struct {
        outer: struct {
            str: []const u8,
        },
    };

    var arena_state = std.heap.ArenaAllocator.init(std.testing.allocator);
    defer arena_state.deinit();
    const arena = arena_state.allocator();

    var meta: Meta = undefined;
    const c = try deserializeLeaky(Case, arena, case, &meta, .{});
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

    var arena_state = std.heap.ArenaAllocator.init(std.testing.allocator);
    defer arena_state.deinit();
    const arena = arena_state.allocator();

    var meta: Meta = undefined;
    const opts: Options = .{ .delimiter = .dashes };
    _ = try deserializeLeaky(Case, arena, case["---".len..], &meta, opts);

    const lines: u32 = @intCast(std.mem.count(u8, case, "\n"));
    try std.testing.expectEqual(lines, meta.doc.lines);
    try std.testing.expectEqual(case.len - "---".len, meta.doc.end);
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

    var arena_state = std.heap.ArenaAllocator.init(std.testing.allocator);
    defer arena_state.deinit();
    const arena = arena_state.allocator();

    var meta: Meta = undefined;
    const opts: Options = .{ .delimiter = .dashes };
    _ = try deserializeLeaky(Case, arena, case["---".len..], &meta, opts);

    const lines: u32 = @intCast(std.mem.count(u8, case, "\n"));
    try std.testing.expectEqual(lines, meta.doc.lines);
    try std.testing.expectEqual(case.len - "---".len, meta.doc.end);
}

test "struct - frontmatter" {
    const case =
        \\---
        \\.{
        \\    .foo = "Zig's New Relationship with LLVM",
        \\    .bar = false,
        \\}
        \\---
    ;

    const Case = struct {
        foo: []const u8,
        bar: bool,
    };

    var arena_state = std.heap.ArenaAllocator.init(std.testing.allocator);
    defer arena_state.deinit();
    const arena = arena_state.allocator();

    var meta: Meta = undefined;
    const opts: Options = .{ .delimiter = .dashes };
    _ = try deserializeLeaky(Case, arena, case["---".len..], &meta, opts);

    const lines: u32 = @intCast(std.mem.count(u8, case, "\n"));
    try std.testing.expectEqual(lines, meta.doc.lines);
    try std.testing.expectEqual(case.len - "---".len, meta.doc.end);
}

test "struct - frontmatter plus markdown" {
    const case =
        \\---
        \\.{
        \\    .foo = "Zig's New Relationship with LLVM",
        \\    .bar = false,
        \\}
        \\---
        \\
        \\ bla bla bla 
    ;

    const Case = struct {
        foo: []const u8,
        bar: bool,
    };

    var arena_state = std.heap.ArenaAllocator.init(std.testing.allocator);
    defer arena_state.deinit();
    const arena = arena_state.allocator();

    var meta: Meta = undefined;
    const opts: Options = .{ .delimiter = .dashes };
    _ = try deserializeLeaky(Case, arena, case["---".len..], &meta, opts);

    try std.testing.expectEqual(5, meta.doc.lines);
    try std.testing.expectEqual(74, meta.doc.end);
}

test "braceless struct no trailing comma - frontmatter + markdown" {
    const case =
        \\---
        \\.foo = "bar",
        \\.bar = false
        \\---
        \\
        \\aarst arst arst 
        \\
        \\ arstarst
    ;

    const Case = struct {
        foo: []const u8,
        bar: bool,
    };

    var arena_state = std.heap.ArenaAllocator.init(std.testing.allocator);
    defer arena_state.deinit();
    const arena = arena_state.allocator();

    var meta: Meta = undefined;
    const opts: Options = .{ .delimiter = .dashes };
    _ = try deserializeLeaky(Case, arena, case["---".len..], &meta, opts);

    try std.testing.expectEqual(3, meta.doc.lines);
    try std.testing.expectEqual(31, meta.doc.end);
}

test "missing delimiter in markdown" {
    const case =
        \\---
        \\.foo = "bar",
        \\.bar = false
        \\
        \\aarst arst arst 
        \\
        \\ arstarst
    ;

    const Case = struct {
        foo: []const u8,
        bar: bool,
    };

    var arena_state = std.heap.ArenaAllocator.init(std.testing.allocator);
    defer arena_state.deinit();
    const arena = arena_state.allocator();

    var meta: Meta = undefined;
    const opts: Options = .{ .delimiter = .dashes };
    try std.testing.expectError(
        error.Unexpected,
        deserializeLeaky(Case, arena, case["---".len..], &meta, opts),
    );

    try std.testing.expectFmt(
        \\<stdin>:5:1 unexpected token
        \\
    , "{f}", .{meta.reportErrorsFmt(
        arena,
        opts,
        case["---".len..],
        null,
        error.Unexpected,
    )});
}

test "duplicate field + syntax error" {
    const case =
        \\---
        \\.foo = "bar",
        \\.foo = false
        \\
        \\aarst arst arst 
        \\
        \\ arstarst
    ;

    const Case = struct {
        foo: []const u8,
        bar: bool,
    };

    var arena_state = std.heap.ArenaAllocator.init(std.testing.allocator);
    defer arena_state.deinit();
    const arena = arena_state.allocator();

    var meta: Meta = undefined;
    const opts: Options = .{ .delimiter = .dashes };
    try std.testing.expectError(
        error.DuplicateField,
        deserializeLeaky(Case, arena, case["---".len..], &meta, opts),
    );

    try std.testing.expectFmt(
        \\<stdin>:5:1 unexpected token
        \\
    , "{f}", .{meta.reportErrorsFmt(
        arena,
        opts,
        case["---".len..],
        null,
        error.DuplicateField,
    )});
}

test "duplicate field in markdown" {
    const case =
        \\---
        \\.foo = "bar",
        \\.foo = false
        \\---
        \\aarst arst arst
        \\
        \\ arstarst
    ;

    const Case = struct {
        foo: []const u8,
        bar: bool,
    };

    var arena_state = std.heap.ArenaAllocator.init(std.testing.allocator);
    defer arena_state.deinit();
    const arena = arena_state.allocator();

    var meta: Meta = undefined;
    const opts: Options = .{ .delimiter = .dashes };
    try std.testing.expectError(
        error.DuplicateField,
        deserializeLeaky(Case, arena, case["---".len..], &meta, opts),
    );

    try std.testing.expectFmt(
        \\<stdin>:3:1 duplicate field
        \\
    , "{f}", .{meta.reportErrorsFmt(
        arena,
        opts,
        case["---".len..],
        null,
        error.DuplicateField,
    )});
}
