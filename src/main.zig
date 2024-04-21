const std = @import("std");
const stdout = std.io.getStdOut().writer();

pub fn main() !void {
    const sz = 10;
    var board1 = std.mem.zeroes([sz][sz]bool);
    var board2 = std.mem.zeroes([sz][sz]bool);

    var curBoard = &board1;
    var nextBoard = &board2;
    init(sz, curBoard, 1);
    try print(sz, curBoard);

    var steps: u16 = 0;
    while (true) {
        std.time.sleep(700 * std.time.ns_per_ms);
        tick(sz, curBoard, nextBoard);
        try print(sz, nextBoard);
        if (!eql(sz, curBoard, nextBoard)) {
            swap(*[sz][sz]bool, &curBoard, &nextBoard);
            steps += 1;
        } else {
            try stdout.print("The game of life has ended after {d} steps!\n", .{steps});
            return;
        }
    }
}

fn init(n: comptime_int, board: *[n][n]bool, seed: u64) void {
    var prng = std.rand.DefaultPrng.init(seed);
    const rand = prng.random();
    for (board) |*row| {
        for (row) |*cell| {
            cell.* = rand.boolean();
        }
    }
}

fn print(n: comptime_int, board: *[n][n]bool) !void {
    for (board) |row| {
        for (row) |cell| {
            const symbol = if (cell) "*" else ".";
            try stdout.print("{s}", .{symbol});
        }
        try stdout.print("\n", .{});
    }
    try stdout.print("\n", .{});
}

fn tick(n: comptime_int, curBoard: *[n][n]bool, nextBoard: *[n][n]bool) void {
    for (0..n) |ii| {
        const i: i128 = @intCast(ii);
        for (0..n) |jj| {
            const j: i32 = @intCast(jj);
            const neighbours = [_]std.meta.Tuple(&.{ i128, i128 }){
                .{ i - 1, j - 1 }, .{ i - 1, j }, .{ i - 1, j + 1 },
                .{ i + 1, j - 1 }, .{ i + 1, j }, .{ i + 1, j + 1 },
                .{ i, j - 1 },     .{ i, j + 1 },
            };
            var liveCount: u128 = 0;
            for (neighbours) |indices| {
                if (indices[0] >= 0 and indices[0] < n and indices[1] >= 0 and indices[1] < n) {
                    const ni: usize = @intCast(indices[0]);
                    const nj: usize = @intCast(indices[1]);
                    if (curBoard[ni][nj]) {
                        liveCount += 1;
                    }
                }
            }
            nextBoard[ii][jj] = curBoard[ii][jj] and (liveCount == 2 or liveCount == 3) or liveCount == 3;
        }
    }
}

fn swap(T: anytype, p1: *T, p2: *T) void {
    const tmp = p1.*;
    p1.* = p2.*;
    p2.* = tmp;
}

fn eql(n: comptime_int, a: *[n][n]bool, b: *[n][n]bool) bool {
    for (a, b) |aa, bb| {
        if (!std.mem.eql(bool, &aa, &bb)) {
            return false;
        }
    }
    return true;
}

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
