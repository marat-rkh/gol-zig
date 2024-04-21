const std = @import("std");
const main = @import("main.zig");

const eql = main.eql;
const tick = main.tick;

test "eql zeros" {
    const sz = 2;
    var board1 = std.mem.zeroes([sz][sz]bool);
    var board2 = std.mem.zeroes([sz][sz]bool);
    try std.testing.expect(eql(sz, &board1, &board2));
}

test "eql all true" {
    var board1: [2][2]bool = .{ .{ true, true }, .{ true, true } };
    var board2: [2][2]bool = .{ .{ true, true }, .{ true, true } };
    try std.testing.expect(eql(2, &board1, &board2));
}

test "not eql when one cell differs" {
    var board1: [2][2]bool = .{ .{ false, true }, .{ true, true } };
    var board2: [2][2]bool = .{ .{ true, true }, .{ true, true } };
    try std.testing.expect(!eql(2, &board1, &board2));
}

test "tick: all dead cells remain dead" {
    var current: [2][2]bool = .{ .{ false, false }, .{ false, false } };
    var next: [2][2]bool = .{ .{ true, true }, .{ true, true } };
    var expected: [2][2]bool = .{ .{ false, false }, .{ false, false } };
    tick(2, &current, &next);
    try std.testing.expect(eql(2, &next, &expected));
}

test "tick: live cell dies when one live neighbour" {
    var current: [2][2]bool = .{ .{ true, false }, .{ false, true } };
    var next: [2][2]bool = .{ .{ true, true }, .{ true, true } };
    var expected: [2][2]bool = .{ .{ false, false }, .{ false, false } };
    tick(2, &current, &next);
    try std.testing.expect(eql(2, &next, &expected));
}

test "tick: dead cell becomes alive when three live neighbour" {
    var current: [2][2]bool = .{ .{ true, true }, .{ true, false } };
    var next: [2][2]bool = .{ .{ false, false }, .{ false, false } };
    var expected: [2][2]bool = .{ .{ true, true }, .{ true, true } };
    tick(2, &current, &next);
    try std.testing.expect(eql(2, &next, &expected));
}

test "oscilator: blinker" {
    const sz = 5;
    var current: [sz][sz]bool = .{
        .{ false, false, false, false, false },
        .{ false, false, true, false, false },
        .{ false, false, true, false, false },
        .{ false, false, true, false, false },
        .{ false, false, false, false, false },
    };
    var next1: [sz][sz]bool = std.mem.zeroes([sz][sz]bool);
    var next2: [sz][sz]bool = std.mem.zeroes([sz][sz]bool);
    var expected1: [sz][sz]bool = .{
        .{ false, false, false, false, false },
        .{ false, false, false, false, false },
        .{ false, true, true, true, false },
        .{ false, false, false, false, false },
        .{ false, false, false, false, false },
    };
    var expected2: [sz][sz]bool = .{
        .{ false, false, false, false, false },
        .{ false, false, true, false, false },
        .{ false, false, true, false, false },
        .{ false, false, true, false, false },
        .{ false, false, false, false, false },
    };
    tick(sz, &current, &next1);
    try std.testing.expect(eql(sz, &next1, &expected1));
    tick(sz, &next1, &next2);
    try std.testing.expect(eql(sz, &next2, &expected2));
}

test "oscilator: beacon" {
    const sz = 6;
    var current: [sz][sz]bool = .{
        .{ false, false, false, false, false, false },
        .{ false, true, true, false, false, false },
        .{ false, true, true, false, false, false },
        .{ false, false, false, true, true, false },
        .{ false, false, false, true, true, false },
        .{ false, false, false, false, false, false },
    };
    var next1: [sz][sz]bool = std.mem.zeroes([sz][sz]bool);
    var next2: [sz][sz]bool = std.mem.zeroes([sz][sz]bool);
    var expected1: [sz][sz]bool = .{
        .{ false, false, false, false, false, false },
        .{ false, true, true, false, false, false },
        .{ false, true, false, false, false, false },
        .{ false, false, false, false, true, false },
        .{ false, false, false, true, true, false },
        .{ false, false, false, false, false, false },
    };
    var expected2: [sz][sz]bool = .{
        .{ false, false, false, false, false, false },
        .{ false, true, true, false, false, false },
        .{ false, true, true, false, false, false },
        .{ false, false, false, true, true, false },
        .{ false, false, false, true, true, false },
        .{ false, false, false, false, false, false },
    };
    tick(sz, &current, &next1);
    try std.testing.expect(eql(sz, &next1, &expected1));
    tick(sz, &next1, &next2);
    try std.testing.expect(eql(sz, &next2, &expected2));
}
