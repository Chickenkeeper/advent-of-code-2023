const std = @import("std");

fn getGalaxyDistanceSum(input: []const u8, expansion_factor: usize, allocator: std.mem.Allocator) !usize {
    const width = std.mem.indexOfScalar(u8, input, '\n').? + 1;
    const height = input.len / width;
    var sum: usize = 0;
    var empty_rows = try std.ArrayList(bool).initCapacity(allocator, height);
    var empty_cols = try std.ArrayList(bool).initCapacity(allocator, width);
    var galaxies = std.ArrayList(@Vector(2, usize)).init(allocator);
    defer empty_rows.deinit();
    defer empty_cols.deinit();
    defer galaxies.deinit();

    empty_rows.appendNTimesAssumeCapacity(true, height);
    empty_cols.appendNTimesAssumeCapacity(true, width);

    for (0..height) |y| {
        for (0..width) |x| {
            if (input[y * width + x] == '#') {
                empty_rows.items[y] = false;
                empty_cols.items[x] = false;
            }
        }
    }

    var y_expanded: usize = 0;
    for (0..height) |y| {
        var x_expanded: usize = 0;
        for (0..width) |x| {
            if (input[y * width + x] == '#') {
                try galaxies.append(@Vector(2, usize){ x_expanded, y_expanded });
            }
            x_expanded += if (empty_cols.items[x]) expansion_factor else 1;
        }
        y_expanded += if (empty_rows.items[y]) expansion_factor else 1;
    }

    for (galaxies.items[1..], 1..) |a, i| {
        for (galaxies.items[0..i]) |b| {
            sum += @reduce(.Add, @max(a, b) - @min(a, b));
        }
    }

    return sum;
}

fn part1(input: []const u8, allocator: std.mem.Allocator) !usize {
    return try getGalaxyDistanceSum(input, 2, allocator);
}

fn part2(input: []const u8, allocator: std.mem.Allocator) !usize {
    return try getGalaxyDistanceSum(input, 1_000_000, allocator);
}

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();
    const input = @embedFile("input.txt");

    std.debug.print("Part 1: {}\n", .{try part1(input, allocator)});
    std.debug.print("Part 2: {}\n", .{try part2(input, allocator)});
}
