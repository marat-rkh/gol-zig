const std = @import("std");
const stdout = std.io.getStdOut().writer();

pub fn main() !void {
    const sz = 10;
    var board1 = std.mem.zeroes([sz][sz]bool);
    var board2 = std.mem.zeroes([sz][sz]bool);

    var curBoard = &board1;
    var nextBoard = &board2;
    init(sz, curBoard);
    while (true) {
        try print(sz, curBoard);
        std.time.sleep(500 * std.time.ns_per_ms);

        tick(sz, curBoard, nextBoard);
        swap(*[sz][sz]bool, &curBoard, &nextBoard);
    }
}

fn init(n: comptime_int, board: *[n][n]bool) void {
    var prng = std.rand.DefaultPrng.init(0);
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
            const symbol = if (cell) "*" else "・";
            try stdout.print("{s}", .{symbol});
        }
        try stdout.print("\n", .{});
    }
    try stdout.print("\n", .{});
}

fn tick(n: comptime_int, curBoard: *[n][n]bool, nextBoard: *[n][n]bool) void {
    if (n < 2) {
        @panic("Unsupported board size, must be at least 2 by 2");
    }
    const lastIndex = n - 1;
    for (0..lastIndex) |i| {
        for (0..lastIndex) |j| {
            var neighbours: []const bool = undefined;
            if (i == 0) {
                // Top edge
                neighbours = switch (j) {
                    0 => &[_]bool{ curBoard[0][1], curBoard[1][1], curBoard[1][0] },
                    lastIndex => &[_]bool{ curBoard[0][lastIndex - 1], curBoard[1][lastIndex - 1], curBoard[1][lastIndex] },
                    else => &[_]bool{ curBoard[0][j - 1], curBoard[1][j - 1], curBoard[1][j], curBoard[1][j + 1], curBoard[0][j + 1] },
                };
            } else if (i == lastIndex) {
                // Bottom edge
            } else if (j == 0) {
                // Left edge
            } else if (j == lastIndex) {
                // Right edge
            } else {
                neighbours = &[_]bool{
                    curBoard[i - 1][j - 1], curBoard[i - 1][j], curBoard[i - 1][j + 1],
                    curBoard[i + 1][j - 1], curBoard[i + 1][j], curBoard[i + 1][j + 1],
                    curBoard[i][j - 1],     curBoard[i][j + 1],
                };
            }
            const livesCount = countTrues(neighbours);
            nextBoard[i][j] = curBoard[i][j] and (livesCount == 2 or livesCount == 3) or livesCount == 3;
        }
    }
}

fn swap(T: anytype, p1: *T, p2: *T) void {
    const tmp = p1;
    p1.* = p2.*;
    p2.* = tmp.*;
}

fn countTrues(bs: []const bool) u8 {
    var count: u8 = 0;
    for (bs) |b| {
        if (b) {
            count += 1;
        }
    }
    return count;
}
