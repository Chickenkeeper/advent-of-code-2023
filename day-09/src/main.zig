const std = @import("std");

fn part1(input: []const u8, allocator: std.mem.Allocator) !isize {
    var lines = std.mem.tokenizeScalar(u8, input, '\n');
    var sum: isize = 0;
    var sequence = std.fifo.LinearFifo(isize, .Dynamic).init(allocator);
    defer sequence.deinit();

    while (lines.next()) |line| {
        var num_strs = std.mem.tokenizeScalar(u8, line, ' ');

        while (num_strs.next()) |num_str| {
            const num = std.fmt.parseInt(isize, num_str, 10) catch unreachable;
            try sequence.writeItem(num);
        }

        var sequence_len = sequence.count;
        var si = sequence_len;
        var prev_value = sequence.readItem().?;
        var zeros = true;

        while (true) : (si -= 1) {
            if (si == 1) {
                sum += prev_value;

                if (zeros) break;

                sequence_len -= 1;
                si = sequence_len;
                prev_value = sequence.readItem().?;
                zeros = true;
            }

            const value = sequence.readItem().?;
            const diff = value - prev_value;

            if (diff != 0) {
                zeros = false;
            }

            try sequence.writeItem(diff);
            prev_value = value;
        }

        sequence.discard(sequence.count);
    }

    return sum;
}

fn part2(input: []const u8, allocator: std.mem.Allocator) !isize {
    var lines = std.mem.tokenizeScalar(u8, input, '\n');
    var sum: isize = 0;
    var sequence = std.fifo.LinearFifo(isize, .Dynamic).init(allocator);
    var derivs = std.ArrayList(isize).init(allocator);
    defer sequence.deinit();
    defer derivs.deinit();

    while (lines.next()) |line| {
        var num_strs = std.mem.tokenizeScalar(u8, line, ' ');

        while (num_strs.next()) |num_str| {
            const num = std.fmt.parseInt(isize, num_str, 10) catch unreachable;
            try sequence.writeItem(num);
        }

        var sequence_len = sequence.count;
        var si = sequence_len;
        var prev_value = sequence.readItem().?;
        var zeros = true;
        try derivs.append(prev_value);

        while (true) : (si -= 1) {
            if (si == 1) {
                if (zeros) break;

                sequence_len -= 1;
                si = sequence_len;
                prev_value = sequence.readItem().?;
                zeros = true;

                try derivs.append(prev_value);
            }

            const value = sequence.readItem().?;
            const diff = value - prev_value;

            if (diff != 0) {
                zeros = false;
            }

            try sequence.writeItem(diff);
            prev_value = value;
        }

        var val: isize = 0;
        for (0..derivs.items.len) |i| {
            const ri = derivs.items.len - i - 1;

            val = derivs.items[ri] - val;
        }

        sum += val;
        sequence.discard(sequence.count);
        derivs.clearRetainingCapacity();
    }

    return sum;
}

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();
    const input = @embedFile("input.txt");

    std.debug.print("Part 1: {}\n", .{try part1(input, allocator)});
    std.debug.print("Part 2: {}\n", .{try part2(input, allocator)});
}
