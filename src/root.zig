const ziggy = @import("ziggy.zig");

pub const schema = @import("schema.zig");
pub usingnamespace ziggy;

test {
    _ = schema;
    _ = ziggy;
}
