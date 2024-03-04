const TreeSitterAst = @This();

const std = @import("std");
const treez = @import("treez");
const Diagnostic = @import("Diagnostic.zig");

const log = std.log.scoped(.treesitter);

tree: *treez.Tree,

pub fn init(
    gpa: std.mem.Allocator,
    code: [:0]const u8,
    _: bool,
    diagnostic: ?*Diagnostic,
) !TreeSitterAst {
    _ = diagnostic;
    const ziggy_lang = try treez.Language.get("ziggy");

    var parser = try treez.Parser.create();
    defer parser.destroy();

    try parser.setLanguage(ziggy_lang);

    const tree = try parser.parseString(null, code);

    const query = try treez.Query.create(ziggy_lang,
        \\(ERROR) @id
    );
    defer query.destroy();

    var pv = try treez.CursorWithValidation.init(gpa, query);

    const cursor = try treez.Query.Cursor.create();
    defer cursor.destroy();

    cursor.execute(query, tree.getRootNode());

    while (pv.nextCapture(code, cursor)) |capture| {
        const node = capture.node;
        const look = try treez.LookaheadIterator.create(ziggy_lang, node.parseState());
        while (look.next()) {
            log.debug("expected: '{s}'", .{try look.currentSymbolName()});
        }
        // log.info("{s}", .{code[node.getStartByte()..node.getEndByte()]});
    }

    log.info("\n\n{s}\n\n", .{tree.getRootNode()});

    return .{ .tree = tree };
}
