const std = @import("std");
const stdout = std.io.getStdOut().writer();

pub fn main() !void {
    const sz = 10;
    var board1 = std.mem.zeroes([sz][sz]bool);
    var board2 = std.mem.zeroes([sz][sz]bool);

    var currentBoard = &board1;
    var nextBoard = &board2;
    init(sz, currentBoard);
    while (true) {
        try print(sz, currentBoard);
        std.time.sleep(500 * std.time.ns_per_ms);

        tick(sz, currentBoard, nextBoard);
        swap(*[sz][sz]bool, &currentBoard, &nextBoard);
    }
}

fn init(n: comptime_int, board: *[n][n]bool) void {
    var prng = std.rand.DefaultPrng.init(0);
    const rand = prng.random();
    // TODO try to use captures
    for (board) |*row| {
        for (row) |*cell| {
            cell.* = rand.boolean();
        }
    }
}

fn print(n: comptime_int, board: *[n][n]bool) !void {
    for (board) |row| {
        for (row) |cell| {
            const symbol = if (cell) "*" else "・";
            try stdout.print("{s}", .{symbol});
        }
        try stdout.print("\n", .{});
    }
    try stdout.print("\n", .{});
}

fn tick(n: comptime_int, currentBoard: *[n][n]bool, nextBoard: *[n][n]bool) void {
    for (currentBoard, 0..) |_, i| {
        for (currentBoard, 0..) |_, j| {}
    }
}

fn swap(T: anytype, p1: *T, p2: *T) void {
    const tmp = p1;
    p1.* = p2.*;
    p2.* = tmp.*;
}
