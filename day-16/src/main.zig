const std = @import("std");

const Direction = enum(u8) {
    north = 1,
    south = 2,
    east = 4,
    west = 8,
};

const Beam = struct {
    dir: Direction,
    x: usize,
    y: usize,

    fn init(dir: Direction, x: usize, y: usize) Beam {
        return Beam{
            .dir = dir,
            .x = x,
            .y = y,
        };
    }

    fn getMoved(beam: Beam, dir: Direction) Beam {
        const new_x = switch (dir) {
            .east => beam.x + 1,
            .west => beam.x - 1,
            else => beam.x,
        };
        const new_y = switch (dir) {
            .north => beam.y - 1,
            .south => beam.y + 1,
            else => beam.y,
        };
        return Beam.init(dir, new_x, new_y);
    }

    fn canMove(self: Beam, width: usize, height: usize, dir: Direction) bool {
        return switch (dir) {
            .north => self.y > 0,
            .south => self.y < height - 1,
            .east => self.x < width - 2,
            .west => self.x > 0,
        };
    }
};

fn getEnergizedTileCount(width: usize, height: usize, tiles: []const u8, dir_flags: []u8, beam_stack: *std.ArrayList(Beam)) !usize {
    while (beam_stack.items.len > 0) {
        const beam = beam_stack.pop();
        const index = beam.x + beam.y * width;
        const dir_int: u8 = @intFromEnum(beam.dir);

        if (dir_flags[index] & dir_int != 0) continue;

        dir_flags[index] |= dir_int;
        const tile = tiles[index];
        const split_h = tile == '-' and (beam.dir == .north or beam.dir == .south);
        const split_v = tile == '|' and (beam.dir == .east or beam.dir == .west);

        if (split_h or split_v) {
            const dir_1: Direction = if (split_h) .east else .north;
            const dir_2: Direction = if (split_h) .west else .south;

            if (beam.canMove(width, height, dir_1)) {
                try beam_stack.append(Beam.getMoved(beam, dir_1));
            }
            if (beam.canMove(width, height, dir_2)) {
                try beam_stack.append(Beam.getMoved(beam, dir_2));
            }
        } else {
            const new_dir: Direction = switch (tile) {
                '/' => switch (beam.dir) {
                    .north => .east,
                    .south => .west,
                    .east => .north,
                    .west => .south,
                },
                '\\' => switch (beam.dir) {
                    .north => .west,
                    .south => .east,
                    .east => .south,
                    .west => .north,
                },
                else => beam.dir,
            };

            if (beam.canMove(width, height, new_dir)) {
                try beam_stack.append(Beam.getMoved(beam, new_dir));
            }
        }
    }

    var sum: usize = 0;
    for (dir_flags) |tile| {
        if (tile != 0) sum += 1;
    }

    return sum;
}

fn part1(input: []const u8, allocator: std.mem.Allocator) !usize {
    const width = std.mem.indexOfScalar(u8, input, '\n').? + 1;
    const height = input.len / width;
    var dir_flags = try allocator.alloc(u8, width * height);
    var beam_stack = std.ArrayList(Beam).init(allocator);
    defer allocator.free(dir_flags);
    defer beam_stack.deinit();

    @memset(dir_flags, 0);
    try beam_stack.append(Beam.init(.east, 0, 0));

    return getEnergizedTileCount(width, height, input, dir_flags, &beam_stack);
}

fn part2(input: []const u8, allocator: std.mem.Allocator) !usize {
    const width = std.mem.indexOfScalar(u8, input, '\n').? + 1;
    const height = input.len / width;
    var dir_flags = try allocator.alloc(u8, width * height);
    var beam_stack = std.ArrayList(Beam).init(allocator);
    defer allocator.free(dir_flags);
    defer beam_stack.deinit();

    var max_tiles: usize = 0;

    for (0..width) |x| {
        for (0..2) |i| {
            @memset(dir_flags, 0);
            beam_stack.clearRetainingCapacity();

            const y = if (i == 0) 0 else height - 1;
            try beam_stack.append(Beam.init(.south, x, y));

            const tile_count = try getEnergizedTileCount(width, height, input, dir_flags, &beam_stack);
            max_tiles = @max(max_tiles, tile_count);
        }
    }

    for (0..height) |y| {
        for (0..2) |i| {
            @memset(dir_flags, 0);
            beam_stack.clearRetainingCapacity();

            const x = if (i == 0) 0 else width - 2;
            try beam_stack.append(Beam.init(.east, x, y));

            const tile_count = try getEnergizedTileCount(width, height, input, dir_flags, &beam_stack);
            max_tiles = @max(max_tiles, tile_count);
        }
    }

    return max_tiles;
}

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();
    const input = @embedFile("input.txt");

    std.debug.print("Part 1: {}\n", .{try part1(input, allocator)});
    std.debug.print("Part 2: {}\n", .{try part2(input, allocator)});
}
