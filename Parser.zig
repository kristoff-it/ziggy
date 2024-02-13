const Parser = @This();
const Tokenizer = @import("Tokenizer.zig");

const std = @import("std");
const assert = std.debug.assert;

gpa: std.mem.Allocator,
code: [:0]const u8,
opts: ParseOptions,
tokenizer: Tokenizer = .{},
parents: std.ArrayListUnmanaged(Container) = .{},
container: Container = .start,
state: State = .start,

pub const ParseOptions = struct {
    diagnostics: ?*Diagnostics = null,
    copy_strings: CopyStrings = .always,

    pub const CopyStrings = enum {
        to_unescape,
        always,
    };
};

pub const Diagnostics = struct {
    loc: Tokenizer.Token.Loc = undefined,
    expected: []const Tokenizer.Tag = &.{},
    type_name: []const u8 = undefined,
    container_type: Container = .start,
    first_loc: Tokenizer.Token.Loc = undefined,
    missing_field_name: []const u8 = undefined,

    fn debug(self: Diagnostics, err: ParseError, code: [:0]const u8) void {
        switch (err) {
            error.OutOfMemory => {
                std.debug.print("OutOfMemory", .{});
            },
            error.EOF => {
                std.debug.print(
                    \\Ziggy source contains a syntax error,
                    \\found unexpected end of file.
                    \\
                    \\Expected:
                , .{});

                for (self.expected) |tag| {
                    std.debug.print("'{s}' ", .{tag.lexeme()});
                }

                std.debug.print("\n\n", .{});
            },
            error.Unexpected => {
                const sel = self.loc.getSelection(code);
                std.debug.print(
                    \\Ziggy source contains a syntax error,
                    \\found unexpected token: '{s}'.
                    \\
                    \\Expected:
                , .{self.loc.src(code)});

                for (self.expected) |tag| {
                    std.debug.print("'{s}' ", .{tag.lexeme()});
                }

                std.debug.print(
                    \\
                    \\
                    \\Line: {} Column: {}
                    \\
                , .{ sel.start.line, sel.start.col });
            },
            error.TypeMismatch => {
                const sel = self.loc.getSelection(code);
                std.debug.print(
                    \\Ziggy source did not match expected type.
                    \\Expected {s} ({s}), found '{s}' instead.
                    \\
                    \\Line: {} Column: {}
                    \\
                , .{
                    self.type_name,
                    @tagName(self.container_type),
                    self.loc.src(code),
                    sel.start.line,
                    sel.start.col,
                });
            },
            error.DuplicateField => {
                const sel = self.loc.getSelection(code);
                const first_sel = self.first_loc.getSelection(code);
                std.debug.print(
                    \\Ziggy source contains a duplicate field.
                    \\
                    \\Duplicate Line: {} Column: {}
                    \\Original Line: {} Column: {}
                    \\
                , .{
                    sel.start.line,
                    sel.start.col,
                    first_sel.start.line,
                    first_sel.start.col,
                });
            },
            error.MissingField => {
                const sel = self.loc.getSelection(code);
                std.debug.print(
                    \\Ziggy source contains a struct with a missing field.
                    \\
                    \\Missing field name: '{s}'.
                    \\
                    \\Line: {} Column: {}
                    \\
                , .{
                    self.missing_field_name,
                    sel.start.line,
                    sel.start.col,
                });
            },
        }
    }
};

pub const ParseError = error{
    TypeMismatch,
    OutOfMemory,
    Unexpected,
    MissingField,
    DuplicateField,
    EOF,
};

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

pub fn parse(comptime T: type, gpa: std.mem.Allocator, code: [:0]const u8, opts: ParseOptions) ParseError!T {
    var parser: Parser = .{
        .gpa = gpa,
        .code = code,
        .opts = opts,
    };

    var result: T = undefined;

    const info = @typeInfo(T);

    switch (info) {
        else => @compileError("TODO"),
        .Struct => {
            const tok = parser.tokenizer.next(code) orelse {
                var fields_seen = [_]?Tokenizer.Token.Loc{null} ** info.Struct.fields.len;
                try parser.finalizeStruct(T, info.Struct, &result, &fields_seen, .{
                    .start = 0,
                    .end = 0,
                });
                return result;
            };
            switch (tok.tag) {
                .dot => {
                    parser.container = .@"struct";
                    parser.state = .field_dot;
                },
                .lb => {
                    parser.container = .@"struct";
                    parser.state = .struct_lb_or_comma;
                },
                else => {
                    if (opts.diagnostics) |d| {
                        d.loc = tok.loc;
                        d.type_name = @typeName(T);
                        d.container_type = .@"struct";
                    }
                    return error.TypeMismatch;
                },
            }
            try parser.parseStruct(T, &result);
        },
    }

    return result;
}

fn parseValue(self: *Parser, comptime T: type, val: *T) ParseError!void {
    const info = @typeInfo(T);

    switch (info) {
        .Pointer => |ptr| switch (ptr.size) {
            .Slice => switch (ptr.child) {
                u8 => try self.parseString(T, val),
                else => @compileError("TODO"),
            },
            else => @compileError("TODO"),
        },
        .Bool => try self.parseBool(val),
        .Struct => {
            const tok = self.tokenizer.next(self.code);
            switch (tok.tag) {
                .lb => {
                    self.container = .@"struct";
                    self.state = .struct_lb_or_comma;
                },
                .dot => {
                    if (self.opts.diagnostics) |d| {
                        d.loc = tok.loc;
                        d.expected = &.{.lb};
                    }
                    return error.Unexpected;
                },
                else => {
                    if (self.opts.diagnostics) |d| {
                        d.loc = tok.loc;
                        d.type_name = @typeName(T);
                        d.container_type = .@"struct";
                    }
                    return error.TypeMismatch;
                },
            }
            try self.parseStruct(T, self.gpa, val);
        },
        else => @compileError("TODO"),
    }
}
fn parseStruct(self: *Parser, comptime T: type, val: *T) ParseError!void {
    assert(self.container == .@"struct");

    const info = @typeInfo(T).Struct;

    // TODO: optimization: turn this into an array of bools when
    //       diagnocstics are disabled
    var fields_seen = [_]?Tokenizer.Token.Loc{null} ** info.fields.len;
    while (true) switch (self.state) {
        .start => unreachable,
        .struct_lb_or_comma => {
            const rb_or_dot = self.tokenizer.next(self.code) orelse {
                return self.finalizeStruct(T, info, val, &fields_seen, .{
                    .start = self.code.len - 1,
                    .end = self.code.len,
                });
            };

            switch (rb_or_dot.tag) {
                .dot => self.state = .field_dot,
                .rb => return self.finalizeStruct(
                    T,
                    info,
                    val,
                    &fields_seen,
                    rb_or_dot.loc,
                ),
                else => {
                    if (self.opts.diagnostics) |d| {
                        d.loc = rb_or_dot.loc;
                        d.expected = &.{ .dot, .rb };
                    }

                    return error.Unexpected;
                },
            }
        },
        .field_dot => {
            const ident = try self.must(.ident);
            _ = try self.must(.eql);
            inline for (info.fields, 0..) |f, idx| {
                if (std.mem.eql(u8, f.name, ident.loc.src(self.code))) {
                    if (fields_seen[idx]) |first_loc| {
                        if (self.opts.diagnostics) |d| {
                            d.loc = ident.loc;
                            d.first_loc = first_loc;
                        }
                        return error.DuplicateField;
                    }
                    fields_seen[idx] = ident.loc;
                    try self.parseValue(f.type, &@field(val, f.name));
                    break;
                }
            }

            const comma_or_rb = self.tokenizer.next(self.code) orelse {
                return self.finalizeStruct(T, info, val, &fields_seen, .{
                    .start = self.code.len - 1,
                    .end = self.code.len,
                });
            };

            switch (comma_or_rb.tag) {
                else => {
                    if (self.opts.diagnostics) |d| {
                        d.loc = comma_or_rb.loc;
                        d.expected = &.{ .comma, .rb };
                    }

                    return error.Unexpected;
                },
                .comma => self.state = .struct_lb_or_comma,
                .rb => return self.finalizeStruct(
                    T,
                    info,
                    val,
                    &fields_seen,
                    comma_or_rb.loc,
                ),
            }
        },
    };
}

// TODO: allocate memory to copy fields_seen and pass it all to diagnostics
inline fn finalizeStruct(
    self: *Parser,
    comptime T: type,
    info: std.builtin.Type.Struct,
    val: *T,
    fields_seen: []const ?Tokenizer.Token.Loc,
    struct_end_loc: Tokenizer.Token.Loc,
) ParseError!void {
    inline for (info.fields, 0..) |field, idx| {
        if (fields_seen[idx] == null) {
            if (field.default_value) |ptr| {
                const dv_ptr: *field.type = @ptrCast(ptr);
                @field(val, field.name) = dv_ptr.*;
            } else {
                if (self.opts.diagnostics) |d| {
                    d.missing_field_name = field.name;
                    d.loc = struct_end_loc;
                }
                return error.MissingField;
            }
        }
    }
}

fn parseBool(self: *Parser, val: *bool) !void {
    const ident = try self.must(.ident);
    const src = ident.loc.src(self.code);
    if (std.mem.eql(u8, src, "true")) {
        val.* = true;
    } else if (std.mem.eql(u8, src, "false")) {
        val.* = false;
    } else {
        if (self.opts.diagnostics) |d| {
            d.loc = ident.loc;
            d.expected = &.{ .true, .false };
        }
        return error.Unexpected;
    }
}

fn parseString(self: *Parser, comptime T: type, val: *T) !void {
    const str = try self.must(.str);
    val.* = str.loc.unquote(self.code) orelse @panic("TODO");
}

pub fn must(self: *Parser, comptime tag: Tokenizer.Tag) !Tokenizer.Token {
    const tok = self.tokenizer.next(self.code) orelse {
        if (self.opts.diagnostics) |d| {
            d.expected = &.{tag};
        }
        return error.EOF;
    };
    if (tok.tag != tag) {
        if (self.opts.diagnostics) |d| {
            d.loc = tok.loc;
            d.expected = &.{tag};
        }
        return error.Unexpected;
    }
    return tok;
}

test "basics" {
    const case =
        \\.foo = "bar",
        \\.bar = false,
    ;

    const Case = struct {
        foo: []const u8,
        bar: bool,
    };

    const c = try parse(Case, std.testing.allocator, case, .{});
    try std.testing.expectEqualStrings("bar", c.foo);
    try std.testing.expectEqual(false, c.bar);
}

test "struct - syntax error" {
    const case =
        \\.foo = "bar",
        \\.bar = .false,
    ;

    const Case = struct {
        foo: []const u8,
        bar: bool,
    };

    var diag: Diagnostics = .{};
    _ = parse(Case, std.testing.allocator, case, .{
        .diagnostics = &diag,
    }) catch |err| {
        diag.debug(err, case);
    };
}

test "struct - missing field" {
    const case =
        \\.foo = "bar",
    ;

    const Case = struct {
        foo: []const u8,
        bar: bool,
    };

    var diag: Diagnostics = .{};
    _ = parse(Case, std.testing.allocator, case, .{
        .diagnostics = &diag,
    }) catch |err| {
        diag.debug(err, case);
    };
}

test "struct - duplicate field" {
    const case =
        \\.foo = "bar",
        \\.bar = false,
        \\.foo = "bar",
    ;

    const Case = struct {
        foo: []const u8,
        bar: bool,
    };

    var diag: Diagnostics = .{};
    _ = parse(Case, std.testing.allocator, case, .{
        .diagnostics = &diag,
    }) catch |err| {
        diag.debug(err, case);
    };
}
