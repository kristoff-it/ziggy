const ziggy = @import("ziggy");

pub const RootOk = struct {
    a: []bool,
    b: ziggy.Dictionary(bool),
    d: ziggy.Dynamic,
};

pub const RootOk1 = struct {
    a: ziggy.ArrayList(bool),
    b: ziggy.Dictionary(bool),
    d: ziggy.Dynamic,
};

pub const RootOk2 = struct {
    a: ziggy.ArrayList(ziggy.Dynamic),
    b: ziggy.Dictionary(ziggy.Dynamic),
    d: ziggy.Dynamic,
};

pub const RootOk3 = struct {
    a: ziggy.Dynamic,
    b: ziggy.Dynamic,
    d: ziggy.Dynamic,
};

pub const RookOk4 = ziggy.Dynamic;

pub const RootErr = struct {
    a: ziggy.ArrayList(u32),
    b: ziggy.Dictionary(u32),
    d: ziggy.Dynamic,
};
