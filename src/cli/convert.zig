const builtin = @import("builtin");
const std = @import("std");
const assert = std.debug.assert;
const Allocator = std.mem.Allocator;
const Io = std.Io;
const ziggy = @import("ziggy");
const yaml = @import("convert/yaml.zig");
// const json = @import("convert/json.zig");
const Ast = ziggy.Ast;
const Writer = std.Io.Writer;

pub fn run(io: Io, gpa: Allocator, args: []const []const u8) !void {
    var cmd = try Command.parse(gpa, args);
    if (cmd.schema) |*schema| {
        const src = std.fs.cwd().readFileAllocOptions(
            schema.path,
            gpa,
            .limited(ziggy.max_size),
            .of(u8),
            0,
        ) catch |err| fatal("unable to read '{s}': {t}", .{ schema.path, err });

        const ast = ziggy.schema.Ast.init(gpa, src) catch oom();
        if (ast.errors.len > 0) {
            for (ast.errors) |err| {
                const sel = err.main_location.getSelection(src);
                std.debug.print("{s}:{}:{} {f}\n", .{
                    schema.path,
                    sel.start.line,
                    sel.start.col,
                    err.tag,
                });
            }
            fatal("provided schema file contains parsing errors", .{});
        }
        schema.src = src;
        schema.ast = ast;
    }

    switch (cmd.mode) {
        .stdin => |lang| {
            var fr = Io.File.stdin().reader(io, &.{});
            var aw: Io.Writer.Allocating = .init(gpa);
            _ = try fr.interface.streamRemaining(&aw.writer);
            const in_bytes = try aw.toOwnedSliceSentinel(0);
            switch (lang) {
                .yaml => {
                    const out_bytes = try yaml.convert(gpa, in_bytes, cmd.schema);
                    try std.fs.File.stdout().writeAll(out_bytes);
                },
                else => @panic("TODO https://github.com/kristoff-it/ziggy/issues/17"),
            }
        },
        .paths => |paths| {
            _ = paths;
        },
    }

    std.process.cleanExit();
}

pub const Command = struct {
    mode: Mode,
    schema: ?Schema,
    replace: bool,
    stdout: bool,
    force: bool,
    lenient: bool,

    pub const Lang = enum { json, yaml, toml, ziggy, zon };
    pub const Mode = union(enum) {
        stdin: Lang,
        paths: []const []const u8,
    };
    pub const Schema = struct {
        path: []const u8,
        ast: ziggy.schema.Ast = undefined,
        src: [:0]const u8 = undefined,
    };

    fn parse(gpa: std.mem.Allocator, args: []const []const u8) !Command {
        var stdin: ?Lang = null;
        var paths: std.ArrayList([]const u8) = .empty;

        var schema: ?[]const u8 = null;
        var replace: ?bool = null;
        var stdout: ?bool = null;
        var force: ?bool = null;
        var lenient: ?bool = null;

        var idx: usize = 0;
        while (idx < args.len) : (idx += 1) {
            const arg = args[idx];
            if (std.mem.eql(u8, arg, "--help") or
                std.mem.eql(u8, arg, "-h"))
            {
                fatalHelp();
            }

            if (std.mem.eql(u8, arg, "--schema")) {
                if (schema != null) fatal("duplicate '--schema' flag", .{});
                idx += 1;
                if (idx == args.len) fatal("missing '--schema' option value", .{});
                schema = args[idx];
                continue;
            }

            if (std.mem.eql(u8, arg, "--replace")) {
                if (replace != null) fatal("duplicate '--replace' flag", .{});
                replace = true;
                continue;
            }

            if (std.mem.eql(u8, arg, "--stdout")) {
                if (stdout != null) fatal("duplicate '--dry-run' flag", .{});
                stdout = true;
                continue;
            }

            if (std.mem.eql(u8, arg, "--lenient")) {
                if (lenient != null) fatal("duplicate '--lenient' flag", .{});
                lenient = true;
                continue;
            }

            if (std.mem.eql(u8, arg, "--force") or
                std.mem.eql(u8, arg, "-f"))
            {
                if (force != null) fatal("duplicate '--force' flag", .{});
                force = true;
                continue;
            }

            if (std.mem.eql(u8, arg, "--stdin") or
                std.mem.eql(u8, arg, "-"))
            {
                if (stdin != null) fatal("duplicate --stdin flag", .{});
                idx += 1;
                if (idx == args.len) fatal("missing '--to' option value", .{});
                stdin = std.meta.stringToEnum(Lang, args[idx]) orelse {
                    fatal("invalid '--stdin' option value: '{s}'", .{args[idx]});
                };
                continue;
            }

            try paths.append(gpa, arg);
        }

        if (stdin != null and paths.items.len > 0) {
            fatal("'--stdin' and DOC_PATH arguments are mutually exclusive", .{});
        }

        const mode: Mode = if (stdin) |s| .{
            .stdin = s,
        } else .{
            .paths = try paths.toOwnedSlice(gpa),
        };

        return .{
            .mode = mode,
            .schema = if (schema) |path| .{ .path = path } else null,
            .replace = replace orelse false,
            .stdout = stdout orelse false,
            .force = force orelse false,
            .lenient = lenient orelse false,
        };
    }

    // TODO: consider adding --json=file.foo etc
    fn fatalHelp() noreturn {
        std.debug.print(
            \\Usage: ziggy convert DOC_PATH [DOC_PATH...] [OPTIONS] 
            \\
            \\     Converts files from JSON / TOML / YAML / ZON to Ziggy.
            \\     Converted files will be placed next to their original.
            \\
            \\     Detected file extensions:     
            \\          JSON       .json   
            \\          YAML       .yaml, .yml
            \\          TOML       .toml,
            \\          Ziggy      .ziggy  
            \\          ZON        .zon  
            \\
            \\     Only paths to documents are supported, if you need to
            \\     convert an entire directory, use glob pattern expasion
            \\     features from your shell.
            \\     
            \\Options:
            \\--stdin LANG     Format bytes from stdin, ouptut to stdout, 
            \\                 LANG defines the input file format. Mutually
            \\                 exclusive with DOC_PATH arguments. LANG can be
            \\                 one of 'json', 'yaml', 'toml', 'zon'.
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
            \\--stdout         Output the converted file(s) to stdout. In case
            \\                 that more than one DOC_PATH was specified, dashes
            \\                 (---) will be used as a document separator. 
            \\
            \\--force, -f      Override existing destination files. 
            \\
            \\--lenient        When a Ziggy schema is specified and a file fails
            \\                 to convert because of it, continue processing
            \\                 other files anyway. Errors will still be printed
            \\                 to stderr and the application will still have a 
            \\                 non-zero exit status. Non-schema errors (eg I/O
            \\                 errors) will stll cause the process to exit 
            \\                 immediately.
            \\
            \\--help, -h       Print this help and exit.
            \\
            \\
        , .{});

        std.process.exit(1);
    }
};

fn fatal(comptime fmt: []const u8, args: anytype) noreturn {
    std.debug.print("fatal error: " ++ fmt ++ "\n", args);
    if (builtin.mode == .Debug) @breakpoint();
    std.process.exit(1);
}

fn oom() noreturn {
    fatal("out of memory", .{});
}
