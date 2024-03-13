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
    const schema = loadSchema(gpa, cmd.schema);
    switch (cmd.mode) {
        .stdin => |lang| {
            const r = std.io.getStdIn().reader();
            const w = std.io.getStdOut().writer();
            switch (lang) {
                .json => {
                    const bytes = try convertToZiggy(gpa, .json, null, schema, r);
                    try w.writeAll(bytes);
                },
                else => @panic("TODO https://github.com/kristoff-it/ziggy/issues/17"),
            }
        },
        .paths => |paths| {
            // checkFile will reset the arena at the end of each call
            var arena_impl = std.heap.ArenaAllocator.init(gpa);

            for (paths.json) |path| {
                convertFile(
                    &arena_impl,
                    .json,
                    cmd.to,
                    cmd.force,
                    std.fs.cwd(),
                    path,
                    path,
                    schema,
                ) catch |err| switch (err) {
                    error.IsDir, error.AccessDenied => {
                        convertDir(
                            gpa,
                            &arena_impl,
                            .json,
                            cmd.to,
                            cmd.force,
                            path,
                            schema,
                        ) catch |dir_err| {
                            std.debug.print("Error walking dir '{s}': {s}\n", .{
                                path,
                                @errorName(dir_err),
                            });
                            std.process.exit(1);
                        };
                    },
                    else => {
                        std.debug.print("Error while accessing '{s}': {s}\n", .{
                            path, @errorName(err),
                        });
                        std.process.exit(1);
                    },
                };
            }

            if (paths.yaml.len > 0) {
                @panic("YAML support not yet implemented, see https://github.com/kristoff-it/ziggy/issues/17");
            }
            if (paths.toml.len > 0) {
                @panic("TOML support not yet implemented, see https://github.com/kristoff-it/ziggy/issues/17");
            }
            if (paths.ziggy.len > 0) {
                @panic("Conversion from Ziggy not yet implemented, see https://github.com/kristoff-it/ziggy/issues/17");
            }
        },
    }
}

fn convertDir(
    gpa: std.mem.Allocator,
    arena_impl: *std.heap.ArenaAllocator,
    format: Command.Lang,
    to: Command.Lang,
    force: bool,
    path: []const u8,
    schema: ziggy.schema.Schema,
) !void {
    var dir = try std.fs.cwd().openDir(path, .{ .iterate = true });
    defer dir.close();
    var walker = dir.walk(gpa) catch oom();
    defer walker.deinit();
    while (try walker.next()) |item| {
        switch (item.kind) {
            .file => {
                const ext = std.fs.path.extension(item.basename);
                if (ext.len == 0) continue;

                if (std.mem.eql(u8, ext[1..], @tagName(format))) {
                    try convertFile(
                        arena_impl,
                        format,
                        to,
                        force,
                        item.dir,
                        item.basename,
                        item.path,
                        schema,
                    );
                }
            },
            else => {},
        }
    }
}

fn convertFile(
    arena_impl: *std.heap.ArenaAllocator,
    format: Command.Lang,
    to: Command.Lang,
    force: bool,
    base_dir: std.fs.Dir,
    sub_path: []const u8,
    full_path: []const u8,
    schema: ziggy.schema.Schema,
) !void {
    defer _ = arena_impl.reset(.retain_capacity);
    const arena = arena_impl.allocator();

    const in = try base_dir.openFile(sub_path, .{});
    defer in.close();

    const stat = try in.stat();
    if (stat.kind == .directory)
        return error.IsDir;

    const bytes = switch (to) {
        .ziggy => try convertToZiggy(
            arena,
            format,
            full_path,
            schema,
            in.reader(),
        ),
        else => @panic("TODO"),
    };

    // if the file has an expected file extension, we remove it before appending
    // the new extension
    const extensionless = blk: {
        const ext = std.fs.path.extension(sub_path);
        if (std.mem.eql(u8, ext, ".json") or
            std.mem.eql(u8, ext, ".yaml") or
            std.mem.eql(u8, ext, ".toml") or
            std.mem.eql(u8, ext, ".ziggy"))
        {
            break :blk sub_path[0 .. sub_path.len - ext.len];
        }
        break :blk sub_path;
    };

    const out_path = try std.fmt.allocPrint(arena, "{s}.{s}", .{
        extensionless,
        @tagName(to),
    });

    const out = base_dir.createFile(out_path, .{ .exclusive = !force }) catch |err| {
        std.debug.print("Error while creating '{s}': {s}\n", .{
            out_path, @errorName(err),
        });
        std.process.exit(1);
    };
    defer out.close();

    try out.writeAll(bytes);
}

fn convertToZiggy(
    gpa: std.mem.Allocator,
    format: Command.Lang,
    file_path: ?[]const u8,
    schema: ziggy.schema.Schema,
    r: std.fs.File.Reader,
) ![]const u8 {
    var diag: ziggy.Diagnostic = .{ .path = file_path };

    switch (format) {
        else => {
            @panic("TODO: support more file formats");
        },
        .json => {
            const bytes = json.toZiggy(gpa, schema, &diag, r) catch {
                std.debug.print("{} arstasr\n", .{diag});
                std.process.exit(1);
            };

            return bytes;
        },
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
    to: Lang,
    schema: ?[]const u8,
    replace: bool,
    dry_run: bool,
    force: bool,
    ignore_schema_errors: bool,
    mode: Mode,

    pub const Mode = union(enum) {
        stdin: Lang,
        paths: Paths,
    };

    pub const Lang = enum { json, yaml, toml, ziggy };
    pub const Paths = struct {
        json: []const []const u8,
        yaml: []const []const u8,
        toml: []const []const u8,
        ziggy: []const []const u8,
    };

    fn parse(gpa: std.mem.Allocator, args: []const []const u8) !Command {
        var stdin: ?Lang = null;
        var json_paths = std.ArrayList([]const u8).init(gpa);
        var yaml_paths = std.ArrayList([]const u8).init(gpa);
        var toml_paths = std.ArrayList([]const u8).init(gpa);
        var ziggy_paths = std.ArrayList([]const u8).init(gpa);

        var to: ?Lang = null;
        var schema: ?[]const u8 = null;
        var replace: ?bool = null;
        var dry_run: ?bool = null;
        var force: ?bool = null;
        var ignore_schema_errors: ?bool = null;

        var idx: usize = 0;
        while (idx < args.len) : (idx += 1) {
            const arg = args[idx];
            if (std.mem.eql(u8, arg, "--help") or
                std.mem.eql(u8, arg, "-h"))
            {
                fatalHelp();
            }

            if (std.mem.eql(u8, arg, "--json") or
                std.mem.eql(u8, arg, "--yaml") or
                std.mem.eql(u8, arg, "--toml") or
                std.mem.eql(u8, arg, "--ziggy"))
            {
                if (stdin != null) {
                    std.debug.print("error: --stdin and path-based flags are mutually exclusive\n\n", .{});
                    std.process.exit(1);
                }

                idx += 1;
                if (idx == args.len) {
                    std.debug.print("error: missing '{s}' option value\n\n", .{arg});
                    std.process.exit(1);
                }

                switch (arg[2]) {
                    else => unreachable,
                    'j' => try json_paths.append(args[idx]),
                    'y' => try yaml_paths.append(args[idx]),
                    't' => try toml_paths.append(args[idx]),
                    'z' => try ziggy_paths.append(args[idx]),
                }
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

            if (std.mem.eql(u8, arg, "--stdin") or
                std.mem.eql(u8, arg, "-"))
            {
                if (json_paths.items.len > 0 or
                    yaml_paths.items.len > 0 or
                    toml_paths.items.len > 0 or
                    ziggy_paths.items.len > 0)
                {
                    std.debug.print("error: --stdin and path-based flags are mutually exclusive\n\n", .{});
                    std.process.exit(1);
                }

                idx += 1;
                if (idx == args.len) {
                    std.debug.print("error: missing '--to' option value\n\n", .{});
                    std.process.exit(1);
                }

                if (stdin != null) {
                    std.debug.print("error: duplicate --stdin flag\n\n", .{});
                    std.process.exit(1);
                }

                stdin = std.meta.stringToEnum(Lang, args[idx]) orelse {
                    std.debug.print(
                        "error: invalid '--stdin' option value: '{s}'\n\n",
                        .{args[idx]},
                    );
                    std.process.exit(1);
                };

                continue;
            }

            std.debug.print("unexpected argument: '{s}'\n", .{arg});
            std.process.exit(1);
        }

        if (ziggy_paths.items.len > 0 or stdin == .ziggy) {
            if (json_paths.items.len > 0 or
                yaml_paths.items.len > 0 or
                toml_paths.items.len > 0)
            {
                std.debug.print("error: if converting from ziggy, then no other input file formats can be used\n", .{});
                std.process.exit(1);
            }

            const t = to orelse {
                std.debug.print("error: when converting from 'ziggy', then '--to' must be specified\n", .{});
                std.process.exit(1);
            };

            if (t == .ziggy) {
                std.debug.print("error: when converting from 'ziggy', then '--to' must be a defined and set to a different file format\n", .{});
                std.process.exit(1);
            }

            if (schema != null) {
                std.debug.print("error: '--schema' is only allowed when converting to 'ziggy'\n", .{});
                std.process.exit(1);
            }
        } else {
            if (to) |t| {
                if (t != .ziggy) {
                    std.debug.print("error: when converting from other file formats, then the destination format must be 'ziggy'\n", .{});
                    std.process.exit(1);
                }
            }
        }

        if (json_paths.items.len == 0 and
            yaml_paths.items.len == 0 and
            toml_paths.items.len == 0 and
            ziggy_paths.items.len == 0 and
            stdin == null)
        {
            std.debug.print("error: either --stdin or one of the path-based flags must be present\n\n", .{});
            std.process.exit(1);
        }

        const mode: Mode = if (stdin) |s| .{
            .stdin = s,
        } else .{
            .paths = .{
                .json = try json_paths.toOwnedSlice(),
                .yaml = try yaml_paths.toOwnedSlice(),
                .toml = try toml_paths.toOwnedSlice(),
                .ziggy = try ziggy_paths.toOwnedSlice(),
            },
        };

        return .{
            .to = to orelse .ziggy,
            .schema = schema,
            .replace = replace orelse false,
            .dry_run = dry_run orelse false,
            .force = force orelse false,
            .ignore_schema_errors = ignore_schema_errors orelse false,
            .mode = mode,
        };
    }

    // TODO: consider adding --json=file.foo etc
    fn fatalHelp() noreturn {
        std.debug.print(
            \\Usage: ziggy convert [OPTIONS]
            \\
            \\     Converts files between JSON / TOML / YAML and Ziggy.
            \\     Converted files will be placed next to their original.
            \\
            \\     LANG can be one of 'json', 'yaml', 'toml', 'ziggy'.
            \\     Ziggy must be either the origin xor the desination format.
            \\
            \\Options:
            \\--stdin LANG     Format bytes from stdin, ouptut to stdout, 
            \\                 LANG defines the input file format. Mutually
            \\                 exclusive with other path-based arguments.
            \\
            \\--json PATH      Convert --LANG files from PATH to the desination
            \\--yaml PATH      file format. If PATH is a directory, it will be 
            \\--toml PATH      scanned recursively for --LANG files. When PATH
            \\--ziggy PATH     is a file, the flag will override file extension
            \\                 format detection. Each flag can be passed 
            \\                 multiple times and can also be mixed with the
            \\                 main restriction that conversion must happen
            \\                 exclusively either *from* or *to* Ziggy.  
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
            \\                 with the converted version (but with the new file
            \\                 extension).
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
    var sub_rule = rule;
    const r = schema.nodes[rule.node];
    if (r.tag == .optional) {
        if (value == null) {
            try w.writeAll("null");
            return;
        }
        sub_rule = .{ .node = r.first_child_id };
    }
    switch (value) {
        .object => |o| try renderJsonObject(o, sub_rule, schema, w),
        .array => |a| try renderJsonArray(a, sub_rule, schema, w),
        .string => |s| try renderJsonString(s, sub_rule, schema, w),
        .number_string => |ns| try renderJsonNumberString(ns, sub_rule, schema, w),
        .float => |f| try renderJsonFloat(f, sub_rule, schema, w),
        .integer => |i| try renderJsonInteger(i, sub_rule, schema, w),
        .bool => |b| try renderJsonBool(b, sub_rule, schema, w),
        .null => {
            const rule_src = schema.nodes[r.first_child_id].loc.src(schema.code);
            std.debug.print("error: type mismatch, expected '{s}', found 'null'\n", .{
                rule_src,
            });
            std.process.exit(1);
        },
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
        .optional => unreachable,
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
        .optional => unreachable,
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
        .optional => unreachable,
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
        .optional => unreachable,
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
        .optional => unreachable,
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
        .optional => unreachable,
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
        .optional => unreachable,
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
