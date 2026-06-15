const ziggy = @import("ziggy");

pub const RootOk = struct {
    a: MyStruct,
};

const MyStruct = struct {
    b: MyUnion,
};

const MyUnion = union(enum) {
    x: bool,
    y: []RootOk,
};

// ------

pub const RootErr = struct {
    a: MyStructErr,
};

const MyStructErr = struct {
    b: MyUnionErr,
};

// wrongly untagged
const MyUnionErr = union {
    x: bool,
    y: []RootOk,
};
