const std = @import("std");

pub const Result = union(enum) {
    integer: Base,
    float: FloatBase,
    failure: Error,
};

pub const Base = enum(u8) { decimal = 10, hex = 16, binary = 2, octal = 8 };
pub const FloatBase = enum(u8) { decimal = 10, hex = 16 };
pub const Error = union(enum) {
    empty_string,
    lonely_hyphen,
    leading_zero,
    missing_digits_after_decimal,
    missing_digits_after_exponent,
    invalid_byte: usize,
};

test validateJSONNumber {
    const cases: []const struct { []const u8, Result } = &.{
        .{ "", .{ .failure = .empty_string } },
        .{ "-", .{ .failure = .lonely_hyphen } },
        .{ "0", .{ .integer = .decimal } },
        .{ "-0", .{ .integer = .decimal } },
        .{ "01", .{ .failure = .leading_zero } },
        .{ "-05", .{ .failure = .leading_zero } },
        .{ "50", .{ .integer = .decimal } },
        .{ "50.", .{ .failure = .missing_digits_after_decimal } },
        .{ "0.", .{ .failure = .missing_digits_after_decimal } },
        .{ "-7.", .{ .failure = .missing_digits_after_decimal } },
        .{ "50.01", .{ .float = .decimal } },
        .{ "0.5", .{ .float = .decimal } },
        .{ "-7.6", .{ .float = .decimal } },
        .{ "50e", .{ .failure = .missing_digits_after_exponent } },
        .{ "0e15", .{ .float = .decimal } },
        .{ "0E+5", .{ .float = .decimal } },
        .{ "0e-5", .{ .float = .decimal } },
        .{ "0E-6.7", .{ .failure = .{ .invalid_byte = 4 } } },
        .{ "-0.57e+89", .{ .float = .decimal } },
    };
    for (cases) |tuple| {
        const input, const result = tuple;
        try std.testing.expectEqualDeep(result, validateJSONNumber(input));
    }
}

/// an EBNF grammar for JSON numbers is as follows:
/// number = ["-"], integer, [fractional], [exponent]
/// integer = "0" | ( nonzero, { digit } )
/// nonzero = "1" | "2" | "3" | "4" | "5" | "6" | "7" | "8" | "9"
/// digit = "0" | nonzero
/// fractional = ".", digit, { digit }
/// exponent = ( "e" | "E" ), ["+", "-"], digit, { digit }
pub fn validateJSONNumber(bytes: []const u8) Result {
    var index: usize = 0;
    state: switch (State.number) {
        .number => {
            if (index >= bytes.len or index > 1) {
                @branchHint(.unlikely);
                return .{ .failure = if (index > 0) .lonely_hyphen else .empty_string };
            }
            if (index == 0 and bytes[index] == '-') {
                index += 1;
                continue :state .number;
            }
            index += 1;
            switch (bytes[index - 1]) {
                '0'...'9' => continue :state .integer,
                else => return .{ .failure = .{ .invalid_byte = index - 1 } },
            }
        },
        .integer => {
            if (index >= bytes.len) return .{ .integer = .decimal };
            if (bytes[index - 1] != '0') continue :state .digits;
            index += 1;
            switch (bytes[index - 1]) {
                '.' => continue :state .fractional,
                'e', 'E' => continue :state .exponent,
                '0'...'9' => return .{ .failure = .leading_zero },
                else => return .{ .failure = .{ .invalid_byte = index - 1 } },
            }
        },
        .digits => while (index < bytes.len) : (index += 1)
            switch (bytes[index]) {
                '0'...'9' => {},
                '.' => {
                    index += 1;
                    continue :state .fractional;
                },
                'e', 'E' => {
                    index += 1;
                    continue :state .exponent;
                },
                else => return .{ .failure = .{ .invalid_byte = index } },
            }
        else
            return .{ .integer = .decimal },
        .fractional => {
            var at_least_one = false;
            while (index < bytes.len) : (index += 1)
                switch (bytes[index]) {
                    '0'...'9' => at_least_one = true,
                    'e', 'E' => {
                        index += 1;
                        if (at_least_one) continue :state .exponent;
                        return .{ .failure = .{ .invalid_byte = index - 1 } };
                    },
                    else => return .{ .failure = .{ .invalid_byte = index } },
                }
            else
                return if (at_least_one)
                    .{ .float = .decimal }
                else
                    .{ .failure = .missing_digits_after_decimal };
        },
        .exponent => {
            if (index >= bytes.len) return .{ .failure = .missing_digits_after_exponent };
            switch (bytes[index]) {
                '0'...'9' => continue :state .exponent_continues,
                '-', '+' => {
                    index += 1;
                    continue :state .exponent_continues;
                },
                else => return .{ .failure = .{ .invalid_byte = index } },
            }
        },
        .exponent_continues => {
            var at_least_one = false;
            while (index < bytes.len) : (index += 1)
                switch (bytes[index]) {
                    '0'...'9' => at_least_one = true,
                    else => return .{ .failure = .{ .invalid_byte = index } },
                }
            else
                return if (at_least_one)
                    .{ .float = .decimal }
                else
                    .{ .failure = .missing_digits_after_exponent };
        },
    }
    comptime unreachable;
}

const State = enum { number, integer, digits, fractional, exponent, exponent_continues };
