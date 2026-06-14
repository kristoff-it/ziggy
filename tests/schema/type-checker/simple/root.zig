const ziggy = @import("ziggy");

pub const RootOk = struct {
    a: bool,
    b: i32,

    pub const ziggy_options: ziggy.Options(@This()) = .{
        .schema = @embedFile("root.ziggy-schema"),
    };
};

pub const RootErr1 = struct {
    a: bool,

    pub const ziggy_options: ziggy.Options(@This()) = .{
        .schema = @embedFile("root.ziggy-schema"),
    };
};

pub const RootErr2 = struct {
    a: bool,
    b: i32,
    c: []const u8,

    pub const ziggy_options: ziggy.Options(@This()) = .{
        .schema = @embedFile("root.ziggy-schema"),
    };
};

pub const RootErr3 = struct {
    a: bool,
    b_oops: i32,

    pub const ziggy_options: ziggy.Options(@This()) = .{
        .schema = @embedFile("root.ziggy-schema"),
    };
};
