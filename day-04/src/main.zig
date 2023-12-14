const std = @import("std");

fn part1(input: []const u8, allocator: std.mem.Allocator) !usize {
    const winning_nums_start = std.mem.indexOfScalar(u8, input, ':').? + 1;
    const nums_start = std.mem.indexOfScalarPos(u8, input, winning_nums_start, '|').? + 1;
    var sum: usize = 0;
    var lines = std.mem.tokenizeScalar(u8, input, '\n');
    var hashset = std.AutoHashMap([3]u8, void).init(allocator);
    defer hashset.deinit();

    while (lines.next()) |line| {
        var score: usize = 0;
        var i: usize = winning_nums_start;

        while (i < nums_start - 2) : (i += 3) {
            try hashset.put(line[i..(i + 3)][0..3].*, {});
        }

        i = nums_start;
        while (i < line.len) : (i += 3) {
            if (hashset.contains(line[i..(i + 3)][0..3].*)) {
                score = if (score == 0) 1 else score * 2;
            }
        }

        sum += score;
        hashset.clearRetainingCapacity();
    }

    return sum;
}

fn part2(input: []const u8, allocator: std.mem.Allocator) !usize {
    const winning_nums_start = std.mem.indexOfScalar(u8, input, ':').? + 1;
    const nums_start = std.mem.indexOfScalarPos(u8, input, winning_nums_start, '|').? + 1;
    var sum: usize = 0;
    var lines = std.mem.tokenizeScalar(u8, input, '\n');
    var hashset = std.AutoHashMap([3]u8, void).init(allocator);
    var stack = std.ArrayList(usize).init(allocator);
    defer hashset.deinit();
    defer stack.deinit();

    while (lines.next()) |line| {
        const copies = if (stack.items.len > 0) stack.orderedRemove(0) + 1 else 1;
        var matches: usize = 0;
        var i: usize = winning_nums_start;

        while (i < nums_start - 2) : (i += 3) {
            try hashset.put(line[i..(i + 3)][0..3].*, {});
        }

        i = nums_start;
        while (i < line.len) : (i += 3) {
            if (hashset.contains(line[i..(i + 3)][0..3].*)) {
                matches += 1;
            }
        }

        for (0..matches) |m| {
            if (stack.items.len > m) {
                stack.items[m] += copies;
            } else {
                try stack.append(copies);
            }
        }

        sum += copies;
        hashset.clearRetainingCapacity();
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
