const std = @import("std");

fn part1(input: []const u8) usize {
    var tokens = std.mem.tokenizeAny(u8, input, ":;,\n");
    var game_possible = false;
    var game_num: usize = 0;
    var sum: usize = 0;

    while (tokens.next()) |token| {
        if (token[0] == 'G' or tokens.peek() == null) {
            if (game_possible) {
                sum += game_num;
            }
            game_num += 1;
            game_possible = true;
        } else if (game_possible) {
            const split_index = std.mem.lastIndexOfScalar(u8, token, ' ').?;
            const number = std.fmt.parseInt(u8, token[1..split_index], 10) catch unreachable;
            const colour = token[split_index + 1];

            if ((number > 12 and colour == 'r') or
                (number > 13 and colour == 'g') or
                (number > 14))
            {
                game_possible = false;
            }
        }
    }

    return sum;
}

fn part2(input: []const u8) usize {
    var tokens = std.mem.tokenizeAny(u8, input, ":;,\n");
    var max_red: usize = 0;
    var max_blue: usize = 0;
    var max_green: usize = 0;
    var sum: usize = 0;

    while (tokens.next()) |token| {
        if (token[0] == 'G' or tokens.peek() == null) {
            sum += max_red * max_blue * max_green;
            max_red = 0;
            max_blue = 0;
            max_green = 0;
        } else {
            const split_index = std.mem.lastIndexOfScalar(u8, token, ' ').?;
            const number = std.fmt.parseInt(u8, token[1..split_index], 10) catch unreachable;
            const colour = token[split_index + 1];

            switch (colour) {
                'r' => max_red = @max(max_red, number),
                'g' => max_green = @max(max_green, number),
                else => max_blue = @max(max_blue, number),
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
