const std = @import("std");

const Platform = struct {
    grid: []u8,
    width: usize,
    height: usize,
    allocator: std.mem.Allocator,

    fn init(width: usize, height: usize, allocator: std.mem.Allocator) !Platform {
        return Platform{
            .grid = try allocator.alloc(u8, width * height),
            .width = width,
            .height = height,
            .allocator = allocator,
        };
    }

    fn deinit(self: Platform) void {
        self.allocator.free(self.grid);
    }

    fn clone(self: Platform) !Platform {
        const platform = try Platform.init(self.width, self.height, self.allocator);
        @memcpy(platform.grid, self.grid);
        return platform;
    }

    fn parse(input: []const u8, allocator: std.mem.Allocator) !Platform {
        const width = std.mem.indexOfScalar(u8, input, '\n').?;
        const height = input.len / (width + 1);
        const platform = try Platform.init(width, height, allocator);

        for (0..height) |y| {
            const dest = platform.grid[y * width ..][0..width];
            const source = input[y * (width + 1) ..][0..width];
            @memcpy(dest, source);
        }

        return platform;
    }

    fn getNorthLoad(self: Platform) usize {
        var load: usize = 0;

        for (self.grid, 0..) |char, i| {
            const y = (i - (i % self.width)) / self.width;
            if (char == 'O') {
                load += self.height - y;
            }
        }

        return load;
    }

    fn tiltNorth(self: Platform) void {
        for (0..self.width) |x| {
            var end: usize = x;

            for (0..self.height) |y| {
                const index = x + y * self.width;
                const char = self.grid[index];

                if (char == 'O') {
                    self.grid[index] = '.';
                    self.grid[end] = 'O';
                    end += self.width;
                } else if (char == '#') {
                    end = index + self.width;
                }
            }
        }
    }

    fn tiltWest(self: Platform) void {
        for (0..self.height) |y| {
            var end: usize = y * self.width;

            for (0..self.width) |x| {
                const index = x + y * self.width;
                const char = self.grid[index];

                if (char == 'O') {
                    self.grid[index] = '.';
                    self.grid[end] = 'O';
                    end += 1;
                } else if (char == '#') {
                    end = index + 1;
                }
            }
        }
    }

    fn tiltSouth(self: Platform) void {
        for (0..self.width) |x| {
            var end = self.height;
            var y = self.height;
            while (y > 0) {
                y -= 1;
                const index = x + y * self.width;
                const char = self.grid[index];

                if (char == 'O') {
                    end -= 1;
                    self.grid[index] = '.';
                    self.grid[x + end * self.width] = 'O';
                } else if (char == '#') {
                    end = y;
                }
            }
        }
    }

    fn tiltEast(self: Platform) void {
        for (0..self.height) |y| {
            var end = self.width;
            var x = self.width;
            while (x > 0) {
                x -= 1;
                const index = x + y * self.width;
                const char = self.grid[index];

                if (char == 'O') {
                    end -= 1;
                    self.grid[index] = '.';
                    self.grid[end + y * self.width] = 'O';
                } else if (char == '#') {
                    end = x;
                }
            }
        }
    }

    fn cycle(self: Platform) void {
        self.tiltNorth();
        self.tiltWest();
        self.tiltSouth();
        self.tiltEast();
    }
};

fn part1(input: []const u8, allocator: std.mem.Allocator) !usize {
    const platform = try Platform.parse(input, allocator);
    defer platform.deinit();

    platform.tiltNorth();
    return platform.getNorthLoad();
}

fn part2(input: []const u8, allocator: std.mem.Allocator) !usize {
    const hare = try Platform.parse(input, allocator);
    const tortoise = try hare.clone();
    defer hare.deinit();
    defer tortoise.deinit();

    var i: usize = 1;
    while (true) : (i += 1) {
        hare.cycle();

        if (i & 1 == 0) {
            tortoise.cycle();
        }

        if (std.mem.eql(u8, hare.grid, tortoise.grid)) {
            break;
        }
    }

    const period = i - (i / 2);
    const remaining_cycles = 1_000_000_000 - i;
    for (0..(remaining_cycles % period)) |_| {
        hare.cycle();
    }

    return hare.getNorthLoad();
}

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();
    const input = @embedFile("input.txt");

    std.debug.print("Part 1: {}\n", .{try part1(input, allocator)});
    std.debug.print("Part 2: {}\n", .{try part2(input, allocator)});
}
