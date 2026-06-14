const ziggy = @import("ziggy");

pub const RootErr = struct {
    a: bool,
    b: i32,

    pub const ziggy_options: ziggy.Options(@This()) = .{
        .schema = @embedFile("root.ziggy-schema"),
    };
};
