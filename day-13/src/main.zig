const std = @import("std");

fn getReflectionSum(input: []const u8, max_diffs: usize) usize {
    var sum: usize = 0;
    var patterns = std.mem.tokenizeSequence(u8, input, "\n\n");

    outer: while (patterns.next()) |pattern| {
        const width = std.mem.indexOfScalar(u8, pattern, '\n').?;
        const height = (pattern.len + 1) / (width + 1);

        horizontal: for (1..height) |y| {
            var diffs = max_diffs;
            const range = @min(y, height - y);

            for (0..range) |i| {
                for (0..width) |x| {
                    const top_char = pattern[x + (y - 1 - i) * (width + 1)];
                    const bottom_char = pattern[x + (y + i) * (width + 1)];

                    if (top_char != bottom_char) {
                        if (diffs > 0) {
                            diffs -= 1;
                        } else {
                            continue :horizontal;
                        }
                    }
                }
            }

            if (diffs == 0) {
                sum += y * 100;
                continue :outer;
            }
        }

        vertical: for (1..width) |x| {
            var diffs = max_diffs;
            const range = @min(x, width - x);

            for (0..range) |i| {
                for (0..height) |y| {
                    const left_char = pattern[(x - 1 - i) + y * (width + 1)];
                    const right_char = pattern[(x + i) + y * (width + 1)];

                    if (left_char != right_char) {
                        if (diffs > 0) {
                            diffs -= 1;
                        } else {
                            continue :vertical;
                        }
                    }
                }
            }

            if (diffs == 0) {
                sum += x;
            }
        }
    }

    return sum;
}

fn part1(input: []const u8) usize {
    return getReflectionSum(input, 0);
}

fn part2(input: []const u8) usize {
    return getReflectionSum(input, 1);
}

pub fn main() void {
    const input = @embedFile("input.txt");

    std.debug.print("Part 1: {}\n", .{part1(input)});
    std.debug.print("Part 2: {}\n", .{part2(input)});
}
