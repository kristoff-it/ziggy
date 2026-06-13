pub const RootOk = struct {
    a: bool,
    b: i32,

    pub const ziggy = struct {
        pub const schema = @embedFile("root.ziggy-schema");
    };
};

pub const RootOk1 = struct {
    a: bool,
    b: i64,

    pub const ziggy = struct {
        pub const schema = @embedFile("root.ziggy-schema");
    };
};

pub const RootErr1 = struct {
    a: []const u8,
    b: u64,

    pub const ziggy = struct {
        pub const schema = @embedFile("root.ziggy-schema");
    };
};

pub const RootErr2 = struct {
    a: bool,
    b: ?[]const u8,

    pub const ziggy = struct {
        pub const schema = @embedFile("root.ziggy-schema");
    };
};

pub const RootErr3 = struct {
    a: struct { a: bool },
    b: []const u8,

    pub const ziggy = struct {
        pub const schema = @embedFile("root.ziggy-schema");
    };
};
