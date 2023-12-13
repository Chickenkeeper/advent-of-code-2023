const std = @import("std");

fn part1(input: []const u8) usize {
    const width: isize = @bitCast(std.mem.indexOfScalar(u8, input, '\n').? + 1);
    const offsets = [_]isize{ -width - 1, -width, -width + 1, -1, 1, width - 1, width, width + 1 };
    var is_part_num = false;
    var reading_num = false;
    var num_start: usize = 0;
    var num_end: usize = 0;
    var sum: usize = 0;

    for (input, 0..) |char, i| {
        if (std.ascii.isDigit(char)) {
            num_end = i;

            if (!reading_num) {
                num_start = i;
                reading_num = true;
            }

            if (!is_part_num) {
                for (offsets) |offset| {
                    const index = @as(isize, @bitCast(i)) + offset;

                    if (index >= 0 and index < input.len) {
                        const symbol = input[@bitCast(index)];

                        if (!std.ascii.isDigit(symbol) and symbol != '\n' and symbol != '.') {
                            is_part_num = true;
                            break;
                        }
                    }
                }
            }
        } else if (reading_num) {
            reading_num = false;

            if (is_part_num) {
                is_part_num = false;
                sum += std.fmt.parseInt(usize, input[num_start..(num_end + 1)], 10) catch unreachable;
            }
        }
    }

    return sum;
}

fn part2(input: []const u8) usize {
    const width = std.mem.indexOfScalar(u8, input, '\n').? + 1;
    const height = input.len / width;
    var sum: usize = 0;

    outer: for (input, 0..) |char, i| {
        if (char != '*') continue;

        const cx = i % width;
        const cy = (i - cx) / width;
        var adjacent_nums = std.BoundedArray(usize, 2).init(0) catch unreachable;

        const y_start: usize = if (cy > 0) 0 else 1;
        const y_end: usize = if (cy < height - 1) 2 else 1;
        const x_start: usize = if (cx > 0) 0 else 1;
        const x_end: usize = if (cx < width - 1) 2 else 1;

        for (y_start..(y_end + 1)) |yi| {
            var prev_was_digit = false;

            for (x_start..(x_end + 1)) |xi| {
                if (yi == 1 and xi == 1) {
                    prev_was_digit = false;
                    continue;
                }

                const y_offset = (cy + yi - 1) * width;
                const x_offset = cx + xi - 1;

                if (std.ascii.isDigit(input[y_offset + x_offset])) {
                    if (prev_was_digit) {
                        continue;
                    } else if (adjacent_nums.len == 2) {
                        continue :outer;
                    }

                    var num_start = x_offset;
                    var num_end = x_offset;

                    while (num_start > 0) : (num_start -= 1) {
                        if (!std.ascii.isDigit(input[y_offset + num_start - 1])) break;
                    }

                    while (num_end < width - 1) : (num_end += 1) {
                        if (!std.ascii.isDigit(input[y_offset + num_end + 1])) break;
                    }

                    const num_slice = input[(y_offset + num_start)..(y_offset + num_end + 1)];
                    const num = std.fmt.parseInt(usize, num_slice, 10) catch unreachable;

                    adjacent_nums.append(num) catch unreachable;
                    prev_was_digit = true;
                } else {
                    prev_was_digit = false;
                }
            }
        }

        if (adjacent_nums.len == 2) {
            sum += adjacent_nums.get(0) * adjacent_nums.get(1);
        }
    }

    return sum;
}

pub fn main() void {
    const input = @embedFile("input.txt");

    std.debug.print("Part 1: {}\n", .{part1(input)});
    std.debug.print("Part 2: {}\n", .{part2(input)});
}
