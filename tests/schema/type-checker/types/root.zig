const ziggy = @import("ziggy");

pub const RootOk = struct {
    a: bool,
    b: i32,

    pub const ziggy_options: ziggy.Options(@This()) = .{
        .schema = @embedFile("root.ziggy-schema"),
    };
};

pub const RootOk1 = struct {
    a: bool,
    b: i64,

    pub const ziggy_options: ziggy.Options(@This()) = .{
        .schema = @embedFile("root.ziggy-schema"),
    };
};

pub const RootErr1 = struct {
    a: []const u8,
    b: u64,

    pub const ziggy_options: ziggy.Options(@This()) = .{
        .schema = @embedFile("root.ziggy-schema"),
    };
};

pub const RootErr2 = struct {
    a: bool,
    b: []const u16,

    pub const ziggy_options: ziggy.Options(@This()) = .{
        .schema = @embedFile("root.ziggy-schema"),
    };
};

pub const RootErr3 = struct {
    a: Foo,
    b: []const u8,

    pub const Foo = struct { a: bool };

    pub const ziggy_options: ziggy.Options(@This()) = .{
        .schema = @embedFile("root.ziggy-schema"),
    };
};
