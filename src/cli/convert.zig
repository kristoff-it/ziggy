const std = @import("std");
const assert = std.debug.assert;
const yaml = @import("yaml");
const ziggy = @import("ziggy");
const json = @import("convert/json.zig");
const loadSchema = @import("load_schema.zig").loadSchema;
const Diagnostic = ziggy.Diagnostic;
const Ast = ziggy.Ast;

pub fn run(gpa: std.mem.Allocator, args: []const []const u8) !void {
    const cmd = try Command.parse(gpa, args);
    switch (cmd.from) {
        .ziggy => @panic("TODO: implement convertFromZiggy()"),
        .others => try convertToZiggy(gpa, cmd),
    }
}

fn convertToZiggy(gpa: std.mem.Allocator, cmd: Command) !void {
    if (cmd.mode != .stdin) @panic("TODO: convertToZiggy implement paths mode");

    const schema = loadSchema(gpa, cmd.schema);

    // in stdin mode only one language will be on
    if (cmd.from.others.json) {
        var diag: ziggy.Diagnostic = .{ .path = null };
        const r = std.io.getStdIn().reader();
        const bytes = json.toZiggy(gpa, schema, &diag, r) catch {
            std.debug.print("{}\n", .{diag});
            std.process.exit(1);
        };
        try std.io.getStdOut().writeAll(bytes);
    } else {
        @panic("TODO: support more file formats");
    }
}

fn fatalDiag(diag: anytype) noreturn {
    std.debug.print("{}\n", .{diag});
    std.process.exit(1);
}

fn oom() noreturn {
    std.debug.print("Out of memory\n", .{});
    std.process.exit(1);
}

pub const Command = struct {
    from: FromLangs,
    to: Lang,
    schema: ?[]const u8,
    replace: bool,
    dry_run: bool,
    force: bool,
    ignore_schema_errors: bool,
    mode: Mode,

    pub const Mode = union(enum) {
        stdin,
        paths: []const []const u8,
    };

    pub const Lang = enum { json, yaml, toml, ziggy };
    pub const FromLangs = union(enum) {
        ziggy,
        others: struct {
            json: bool = true,
            yaml: bool = true,
            toml: bool = true,
        },
    };

    fn parse(gpa: std.mem.Allocator, args: []const []const u8) !Command {
        var from = std.AutoArrayHashMap(Lang, void).init(gpa);
        defer from.deinit();

        var to: ?Lang = null;
        var schema: ?[]const u8 = null;
        var replace: ?bool = null;
        var dry_run: ?bool = null;
        var force: ?bool = null;
        var ignore_schema_errors: ?bool = null;
        var mode: ?Mode = null;

        var idx: usize = 0;
        while (idx < args.len) : (idx += 1) {
            const arg = args[idx];
            if (std.mem.eql(u8, arg, "--help") or
                std.mem.eql(u8, arg, "-h"))
            {
                fatalHelp();
            }

            if (std.mem.eql(u8, arg, "--from")) {
                idx += 1;
                if (idx == args.len) {
                    std.debug.print("error: missing '--from' option value\n\n", .{});
                    std.process.exit(1);
                }

                try from.put(std.meta.stringToEnum(Lang, args[idx]) orelse {
                    std.debug.print(
                        "error: invalid '--from' option value: '{s}'\n\n",
                        .{args[idx]},
                    );
                    std.process.exit(1);
                }, {});

                continue;
            }

            if (std.mem.eql(u8, arg, "--to")) {
                if (to != null) {
                    std.debug.print("error: duplicate '--to' flag\n\n", .{});
                    std.process.exit(1);
                }

                idx += 1;
                if (idx == args.len) {
                    std.debug.print("error: missing '--to' option value\n\n", .{});
                    std.process.exit(1);
                }

                to = std.meta.stringToEnum(Lang, args[idx]) orelse {
                    std.debug.print(
                        "error: invalid '--to' option value: '{s}'\n\n",
                        .{args[idx]},
                    );
                    std.process.exit(1);
                };

                continue;
            }

            if (std.mem.eql(u8, arg, "--schema")) {
                if (schema != null) {
                    std.debug.print("error: duplicate '--schema' flag\n\n", .{});
                    std.process.exit(1);
                }

                idx += 1;
                if (idx == args.len) {
                    std.debug.print("error: missing '--to' option value\n\n", .{});
                    std.process.exit(1);
                }

                schema = args[idx];
                continue;
            }

            if (std.mem.eql(u8, arg, "--replace")) {
                if (replace != null) {
                    std.debug.print("error: duplicate '--replace' flag\n\n", .{});
                    std.process.exit(1);
                }

                replace = true;
                continue;
            }

            if (std.mem.eql(u8, arg, "--dry-run")) {
                if (dry_run != null) {
                    std.debug.print("error: duplicate '--dry-run' flag\n\n", .{});
                    std.process.exit(1);
                }

                dry_run = true;
                continue;
            }

            if (std.mem.eql(u8, arg, "--ignore-schema-errors")) {
                if (ignore_schema_errors != null) {
                    std.debug.print("error: duplicate '--ignore-schema-errors' flag\n\n", .{});
                    std.process.exit(1);
                }

                ignore_schema_errors = true;
                continue;
            }

            if (std.mem.eql(u8, arg, "--force") or
                std.mem.eql(u8, arg, "-f"))
            {
                if (force != null) {
                    std.debug.print("error: duplicate '--force' flag\n\n", .{});
                    std.process.exit(1);
                }

                force = true;
                continue;
            }

            if (std.mem.startsWith(u8, arg, "-")) {
                if (std.mem.eql(u8, arg, "--stdin") or
                    std.mem.eql(u8, arg, "-"))
                {
                    if (mode != null) {
                        std.debug.print("unexpected flag: '{s}'\n", .{arg});
                        std.process.exit(1);
                    }

                    mode = .stdin;
                } else {
                    std.debug.print("unexpected flag: '{s}'\n", .{arg});
                    std.process.exit(1);
                }
            } else {
                const paths_start = idx;
                while (idx < args.len) : (idx += 1) {
                    if (std.mem.startsWith(u8, args[idx], "-")) {
                        break;
                    }
                }
                idx -= 1;

                if (mode != null) {
                    std.debug.print(
                        "unexpected path argument(s): '{s}'...\n",
                        .{args[paths_start]},
                    );
                    std.process.exit(1);
                }

                const paths = args[paths_start .. idx + 1];
                mode = .{ .paths = paths };
            }
        }

        const m = mode orelse {
            std.debug.print("missing argument(s)\n\n", .{});
            fatalHelp();
        };

        if (m == .stdin) {
            // from must specify one lang
            if (from.count() != 1) {
                std.debug.print("error: '--stdin' mode requires '--from' to be specified exactly once\n", .{});
                std.process.exit(1);
            }
        }

        if (from.contains(.ziggy)) {
            if (from.count() != 1) {
                std.debug.print("error: '--from' cannot contain both 'ziggy' and other file formats\n", .{});
                std.process.exit(1);
            }

            const t = to orelse {
                std.debug.print("error: when '--from' is 'ziggy', then '--to' must be specified\n", .{});
                std.process.exit(1);
            };

            if (t == .ziggy) {
                std.debug.print("error: when '--from' is 'ziggy', then '--to' must be a different file format\n", .{});
                std.process.exit(1);
            }

            if (schema != null) {
                std.debug.print("error: '--schema' is only allowed when converting to 'ziggy'\n", .{});
                std.process.exit(1);
            }
        } else {
            if (to) |t| {
                if (t != .ziggy) {
                    std.debug.print("error: when '--from' is NOT 'ziggy', then '--to' must be 'ziggy'\n", .{});
                    std.process.exit(1);
                }
            }
        }

        const from_lang: FromLangs = blk: {
            if (from.count() == 0) {
                break :blk .{ .others = .{} };
            }

            if (from.contains(.ziggy)) {
                break :blk .ziggy;
            }

            var res: FromLangs = .{
                .others = .{
                    .json = false,
                    .yaml = false,
                    .toml = false,
                },
            };

            for (from.keys()) |k| switch (k) {
                .ziggy => unreachable,
                .json => res.others.json = true,
                .yaml => res.others.yaml = true,
                .toml => res.others.toml = true,
            };

            break :blk res;
        };

        return .{
            .from = from_lang,
            .to = to orelse .ziggy,
            .schema = schema,
            .replace = replace orelse false,
            .dry_run = dry_run orelse false,
            .force = force orelse false,
            .ignore_schema_errors = ignore_schema_errors orelse false,
            .mode = m,
        };
    }

    // TODO: consider adding --json=file.foo etc
    fn fatalHelp() noreturn {
        std.debug.print(
            \\Usage: ziggy convert PATH [PATH...] [OPTIONS]
            \\
            \\     Converts files between JSON / TOML / YAML and Ziggy.
            \\     Converted files will be placed next to their original.
            \\
            \\Options:
            \\--stdin, -       Format bytes from stdin, ouptut to stdout, 
            \\                 requires specifying '--from' exactly once. 
            \\                 Mutually exclusive with PATH(s).
            \\
            \\--from LANG      The origin file format. When PATH is a directory, 
            \\                 only converts files of the corresponding type by 
            \\                 file extension. When PATH is a file, its 
            \\                 extension must correspond to one of the specified 
            \\                 LANGs.
            \\
            \\                 LANG can be 'json', 'yaml', 'toml', or 'ziggy'.
            \\                 
            \\                 Can be passed multiple times to specify more than
            \\                 one origin file format. When not specified,
            \\                 defaults to 'json', 'yaml', and 'toml'.
            \\
            \\                 NOTE: Only conversions from and to Ziggy are
            \\                 allowed meaning that 'ziggy' must be present in
            \\                 either '--from' or '--to' (exclusive or).
            \\
            \\--to LANG        The destination file format. Defaults to 'ziggy'.
            \\
            \\--schema PATH    Path to a Ziggy Schema, used when 'ziggy' is the 
            \\                 destination file format to produce a better typed
            \\                 output file. Will cause the process to error out 
            \\                 if no reasonable origin file to schema mapping
            \\                 can be inferred.
            \\
            \\--replace        Deletes the origin file, de facto "replacing" it
            \\                 with the converted version (but with a different
            \\                 file extension).
            \\
            \\--dry-run        Output the converted file(s) to stdout.
            \\
            \\--force, -f      Override existing destination files. 
            \\
            \\--ignore-schema-errors
            \\                 When a Ziggy schema is specified and a file fails
            \\                 to convert because of it, continue processing
            \\                 other files anyway. Errors will still be printed
            \\                 to stderr and the application will still have a 
            \\                 non-zero exit status. Non-schema errors (eg I/O
            \\                 errors) will stll cause the process to exit 
            \\                 immediately.
            \\
            \\--help, -h       Print this help and exit.
        , .{});

        std.process.exit(1);
    }
};

fn renderJsonValue(
    value: json.Value,
    rule: ziggy.schema.Schema.Rule,
    schema: ziggy.schema.Schema,
    w: anytype,
) anyerror!void {
    switch (value) {
        .object => |o| try renderJsonObject(o, rule, schema, w),
        .array => |a| try renderJsonArray(a, rule, schema, w),
        .string => |s| try renderJsonString(s, rule, schema, w),
        .number_string => |ns| try renderJsonNumberString(ns, rule, schema, w),
        .float => |f| try renderJsonFloat(f, rule, schema, w),
        .integer => |i| try renderJsonInteger(i, rule, schema, w),
        .bool => |b| try renderJsonBool(b, rule, schema, w),
        .null => try renderJsonNull(rule, schema, w),
    }
}

fn renderJsonObject(
    obj: json.ObjectMap,
    rule: ziggy.schema.Schema.Rule,
    schema: ziggy.schema.Schema,
    w: anytype,
) !void {
    const r = schema.nodes[rule.node];
    const rule_src = r.loc.src(schema.code);
    const child_rule_id = if (r.tag == .any) rule.node else r.first_child_id;
    switch (r.tag) {
        .map, .any => {
            try w.writeAll("{");
            for (obj.keys(), obj.values()) |k, v| {
                try w.print("\"{}\":", .{std.zig.fmtEscapes(k)});
                try renderJsonValue(v, .{ .node = child_rule_id }, schema, w);
                try w.writeAll(",");
            }
            try w.writeAll("}");
        },
        .identifier => {
            const struct_rule = schema.structs.get(rule_src).?; // must be present

            try w.writeAll("{");
            for (obj.keys(), obj.values()) |k, v| {
                const field = struct_rule.fields.get(k) orelse {
                    std.debug.print("error: unknown field '{s}'\n", .{k});
                    std.process.exit(1);
                };
                try w.print(".{} = ", .{std.zig.fmtId(k)});
                try renderJsonValue(v, field.rule, schema, w);
                try w.writeAll(",");
            }

            // ensure all missing keys are optional
            for (struct_rule.fields.keys(), struct_rule.fields.values()) |k, v| {
                if (obj.contains(k)) continue;
                if (schema.nodes[v.rule.node].tag != .optional) {
                    std.debug.print("error: missing field '{s}'\n", .{k});
                    std.process.exit(1);
                }
            }
            try w.writeAll("}");
        },
        .struct_union => @panic("TODO: struct union for json objects"),
        else => {
            std.debug.print("error: type mismatch, expected '{s}', found 'object'\n", .{
                rule_src,
            });
            std.process.exit(1);
        },
    }
}

fn renderJsonArray(
    array: json.Array,
    rule: ziggy.schema.Schema.Rule,
    schema: ziggy.schema.Schema,
    w: anytype,
) !void {
    const r = schema.nodes[rule.node];
    const rule_src = r.loc.src(schema.code);
    const child_rule_id = if (r.tag == .any) rule.node else r.first_child_id;
    switch (r.tag) {
        .array, .any => {
            try w.writeAll("[");
            for (array.items) |v| {
                try renderJsonValue(v, .{ .node = child_rule_id }, schema, w);
            }
            try w.writeAll("]");
        },
        else => {
            std.debug.print("error: type mismatch, expected '{s}', found 'array'\n", .{
                rule_src,
            });
            std.process.exit(1);
        },
    }
}

fn renderJsonString(
    str: []const u8,
    rule: ziggy.schema.Schema.Rule,
    schema: ziggy.schema.Schema,
    w: anytype,
) !void {
    const r = schema.nodes[rule.node];
    const rule_src = r.loc.src(schema.code);
    switch (r.tag) {
        .bytes, .any => {
            try w.print("\"{}\"", .{std.zig.fmtEscapes(str)});
        },
        else => {
            std.debug.print("error: type mismatch, expected '{s}', found 'string'\n", .{
                rule_src,
            });
            std.process.exit(1);
        },
    }
}

fn renderJsonNumberString(
    ns: []const u8,
    rule: ziggy.schema.Schema.Rule,
    schema: ziggy.schema.Schema,
    w: anytype,
) !void {
    const r = schema.nodes[rule.node];
    const rule_src = r.loc.src(schema.code);
    switch (r.tag) {
        .int, .float, .any => {
            try w.print("{s}", .{ns});
        },
        else => {
            std.debug.print("error: type mismatch, expected '{s}', found 'number_string'\n", .{
                rule_src,
            });
            std.process.exit(1);
        },
    }
}

fn renderJsonFloat(
    num: f64,
    rule: ziggy.schema.Schema.Rule,
    schema: ziggy.schema.Schema,
    w: anytype,
) !void {
    const r = schema.nodes[rule.node];
    const rule_src = r.loc.src(schema.code);
    switch (r.tag) {
        .float, .any => {
            try w.print("{}", .{num});
        },
        else => {
            std.debug.print("error: type mismatch, expected '{s}', found 'float'\n", .{
                rule_src,
            });
            std.process.exit(1);
        },
    }
}

fn renderJsonInteger(
    num: i64,
    rule: ziggy.schema.Schema.Rule,
    schema: ziggy.schema.Schema,
    w: anytype,
) !void {
    const r = schema.nodes[rule.node];
    const rule_src = r.loc.src(schema.code);
    switch (r.tag) {
        .int, .float, .any => {
            try w.print("{}", .{num});
        },
        else => {
            std.debug.print("error: type mismatch, expected '{s}', found 'integer'\n", .{
                rule_src,
            });
            std.process.exit(1);
        },
    }
}

fn renderJsonBool(
    b: bool,
    rule: ziggy.schema.Schema.Rule,
    schema: ziggy.schema.Schema,
    w: anytype,
) !void {
    const r = schema.nodes[rule.node];
    const rule_src = r.loc.src(schema.code);
    switch (r.tag) {
        .bool, .any => {
            try w.print("{}", .{b});
        },
        else => {
            std.debug.print("error: type mismatch, expected '{s}', found 'bool'\n", .{
                rule_src,
            });
            std.process.exit(1);
        },
    }
}

fn renderJsonNull(
    rule: ziggy.schema.Schema.Rule,
    schema: ziggy.schema.Schema,
    w: anytype,
) !void {
    const r = schema.nodes[rule.node];
    const rule_src = r.loc.src(schema.code);
    switch (r.tag) {
        .optional, .any => {
            try w.writeAll("null");
        },
        else => {
            std.debug.print("error: type mismatch, expected '{s}', found 'null'\n", .{
                rule_src,
            });
            std.process.exit(1);
        },
    }
}
