const ziggy = @import("ziggy");

pub const RootOk = struct {
    a: MyStruct,

    const MyStruct = struct {
        b: MyUnion,

        const MyUnion = union(enum) {
            x: bool,
            y: []RootOk,
        };
    };
};

pub const RootErr = struct {
    a: MyStructErr,

    const MyStructErr = struct {
        b: MyUnionErr,

        // wrongly untagged
        const MyUnionErr = union {
            x: bool,
            y: []RootOk,
        };
    };
};

pub const RootErr1 = struct {
    a: MyStructErr1,

    const MyStructErr1 = struct {
        b: MyUnionErr1,

        // wrongly an enum
        const MyUnionErr1 = enum { x, y };
    };
};
