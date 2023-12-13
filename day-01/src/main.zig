const std = @import("std");

fn part1(input: []const u8) usize {
    var first_num: ?usize = null;
    var last_num: usize = 0;
    var sum: usize = 0;

    for (input) |char| {
        if (char == '\n') {
            sum += (first_num.? * 10) + last_num;
            first_num = null;
        } else if (std.ascii.isDigit(char)) {
            last_num = char - '0';
            if (first_num == null) {
                first_num = last_num;
            }
        }
    }

    return sum;
}

fn part2(input: []const u8) usize {
    const words = [_][]const u8{ "zero", "one", "two", "three", "four", "five", "six", "seven", "eight", "nine" };
    var first_num: ?usize = null;
    var last_num: usize = 0;
    var sum: usize = 0;

    for (input, 0..) |char, ci| {
        if (char == '\n') {
            sum += (first_num.? * 10) + last_num;
            first_num = null;
        } else if (std.ascii.isDigit(char)) {
            last_num = char - '0';
            if (first_num == null) {
                first_num = last_num;
            }
        } else for (words, 0..) |word, wi| {
            if (std.mem.startsWith(u8, input[ci..], word)) {
                last_num = wi;
                if (first_num == null) {
                    first_num = last_num;
                }
            }
        }
    }

    return sum;
}

pub fn main() void {
    const input = @embedFile("input.txt");

    std.debug.print("Part 1: {}\n", .{part1(input)});
    std.debug.print("Part 2: {}\n", .{part2(input)});
}
