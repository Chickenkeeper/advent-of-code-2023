const std = @import("std");

fn part1(input: []const u8) usize {
    const start = std.mem.indexOfScalar(u8, input, 'S').?;
    const width = std.mem.indexOfScalar(u8, input, '\n').? + 1;
    var tiles = std.BoundedArray(usize, 2).init(0) catch unreachable;
    var prev_tiles = std.BoundedArray(usize, 2).init(0) catch unreachable;

    const north_tile = input[start - width];
    const south_tile = input[start + width];
    const west_tile = input[start - 1];
    const east_tile = input[start + 1];

    if (north_tile == '|') {
        tiles.append(start - width) catch unreachable;
    }

    if (south_tile == '|') {
        tiles.append(start + width) catch unreachable;
    }

    if (west_tile == '-' or west_tile == 'L' or west_tile == 'F') {
        tiles.append(start - 1) catch unreachable;
    }

    if (east_tile == '-' or east_tile == 'J' or east_tile == '7') {
        tiles.append(start + 1) catch unreachable;
    }

    prev_tiles.appendNTimesAssumeCapacity(start, 2);

    var steps: usize = 1;
    while (tiles.buffer[0] != tiles.buffer[1]) : (steps += 1) {
        for (&tiles.buffer, &prev_tiles.buffer) |*tile, *prev_tile| {
            const neighbours = switch (input[tile.*]) {
                '|' => .{ tile.* - width, tile.* + width },
                '-' => .{ tile.* - 1, tile.* + 1 },
                'L' => .{ tile.* - width, tile.* + 1 },
                'J' => .{ tile.* - width, tile.* - 1 },
                '7' => .{ tile.* + width, tile.* - 1 },
                else => .{ tile.* + width, tile.* + 1 },
            };

            if (neighbours[0] == prev_tile.*) {
                prev_tile.* = tile.*;
                tile.* = neighbours[1];
            } else {
                prev_tile.* = tile.*;
                tile.* = neighbours[0];
            }
        }
    }

    return steps;
}

fn part2(input: []const u8, allocator: std.mem.Allocator) !usize {
    const start = std.mem.indexOfScalar(u8, input, 'S').?;
    const width = std.mem.indexOfScalar(u8, input, '\n').? + 1;
    var loop_mask = try std.ArrayList(bool).initCapacity(allocator, input.len);
    defer loop_mask.deinit();

    const north_tile = input[start - width];
    const south_tile = input[start + width];
    const west_tile = input[start - 1];
    var prev_tile = start;
    var tile = start;

    if (north_tile == '|') {
        tile = start - width;
    } else if (south_tile == '|') {
        tile = start + width;
    } else if (west_tile == '-' or west_tile == 'L' or west_tile == 'F') {
        tile = start - 1;
    } else {
        tile = start + 1;
    }

    loop_mask.appendNTimesAssumeCapacity(false, input.len);
    loop_mask.items[start] = true;
    loop_mask.items[tile] = true;

    while (tile != start) {
        const neighbours = switch (input[tile]) {
            '|' => .{ tile - width, tile + width },
            '-' => .{ tile - 1, tile + 1 },
            'L' => .{ tile - width, tile + 1 },
            'J' => .{ tile - width, tile - 1 },
            '7' => .{ tile + width, tile - 1 },
            else => .{ tile + width, tile + 1 },
        };

        if (neighbours[0] == prev_tile) {
            prev_tile = tile;
            tile = neighbours[1];
        } else {
            prev_tile = tile;
            tile = neighbours[0];
        }

        loop_mask.items[tile] = true;
    }

    var tiles_enclosed: usize = 0;
    var prev_char: ?u8 = null;
    var inner = false;
    for (loop_mask.items, 0..) |mask, i| {
        if (mask) {
            switch (input[i]) {
                '\n' => {
                    inner = false;
                },
                'F', 'L' => prev_char = input[i],
                '7' => {
                    if (prev_char == 'L') {
                        inner = !inner;
                    }
                },
                'J' => {
                    if (prev_char == 'F') {
                        inner = !inner;
                    }
                },
                '|' => {
                    prev_char = null;
                    inner = !inner;
                },
                else => continue,
            }
        } else if (inner) {
            tiles_enclosed += 1;
        }
    }

    return tiles_enclosed;
}

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();
    const input = @embedFile("input.txt");

    std.debug.print("Part 1: {}\n", .{part1(input)});
    std.debug.print("Part 2: {}\n", .{try part2(input, allocator)});
}
