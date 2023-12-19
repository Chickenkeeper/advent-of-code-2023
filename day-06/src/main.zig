const std = @import("std");

fn getWins(time: usize, dist: usize) usize {
    var start: usize = 0;
    var end = time / 2;

    if ((time - end) * end <= dist) {
        return 0;
    }

    var len = end;
    while (len > 1) {
        len = end - start;
        const mid = len / 2 + start;

        if ((time - mid) * mid > dist) {
            end = mid;
        } else {
            start = mid;
        }
    }

    return time - end * 2 + 1;
}

fn part1(input: []const u8) usize {
    var lines = std.mem.tokenizeScalar(u8, input, '\n');
    var time_strs = std.mem.tokenizeScalar(u8, lines.next().?, ' ');
    var dist_strs = std.mem.tokenizeScalar(u8, lines.next().?, ' ');
    var total_wins: usize = 1;

    _ = time_strs.next();
    _ = dist_strs.next();
    while (true) {
        const time_str = time_strs.next();
        const dist_str = dist_strs.next();

        if (time_str == null) {
            break;
        }

        const time = std.fmt.parseInt(usize, time_str.?, 10) catch unreachable;
        const dist = std.fmt.parseInt(usize, dist_str.?, 10) catch unreachable;

        total_wins *= getWins(time, dist);
    }

    return total_wins;
}

fn part2(input: []const u8) usize {
    var lines = std.mem.tokenizeScalar(u8, input, '\n');
    var time: usize = 0;
    var dist: usize = 0;

    for (lines.next().?) |char| {
        if (std.ascii.isDigit(char)) {
            time = time * 10 + (char - '0');
        }
    }

    for (lines.next().?) |char| {
        if (std.ascii.isDigit(char)) {
            dist = dist * 10 + (char - '0');
        }
    }

    return getWins(time, dist);
}

pub fn main() !void {
    const input = @embedFile("input.txt");

    std.debug.print("Part 1: {}\n", .{part1(input)});
    std.debug.print("Part 2: {}\n", .{part2(input)});
}
