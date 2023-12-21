const std = @import("std");

const Node = struct {
    left: [3]u8,
    right: [3]u8,
};

const PrimeIter = struct {
    i: usize,

    fn init() PrimeIter {
        return PrimeIter{
            .i = 0,
        };
    }

    fn next(self: *PrimeIter) usize {
        outer: while (true) {
            self.i += 2;

            if (self.i == 2) {
                self.i = 1;
                return 2;
            }

            var n: usize = 3;
            while (n <= std.math.sqrt(self.i)) : (n += 2) {
                if (self.i % n == 0) {
                    continue :outer;
                }
            }

            return self.i;
        }
    }
};

fn part1(input: []const u8, allocator: std.mem.Allocator) !usize {
    var lines = std.mem.tokenizeScalar(u8, input, '\n');
    const directions = lines.next().?;
    var steps: usize = 0;
    var nodes = std.AutoHashMap([3]u8, Node).init(allocator);
    defer nodes.deinit();

    while (lines.next()) |line| {
        const key = line[0..3].*;
        const node = Node{
            .left = line[7..10].*,
            .right = line[12..15].*,
        };

        try nodes.put(key, node);
    }

    var next_key: [3]u8 = "AAA".*;
    var i: usize = 0;
    while (true) : (i = (i + 1) % directions.len) {
        const node = nodes.get(next_key).?;
        steps += 1;

        if (directions[i] == 'L') {
            next_key = node.left;
        } else {
            next_key = node.right;
        }

        if (std.mem.eql(u8, &next_key, "ZZZ")) {
            break;
        }
    }

    return steps;
}

fn part2(input: []const u8, allocator: std.mem.Allocator) !usize {
    var lines = std.mem.tokenizeScalar(u8, input, '\n');
    const directions = lines.next().?;
    var nodes = std.AutoHashMap([3]u8, Node).init(allocator);
    var next_keys = std.ArrayList([3]u8).init(allocator);
    var path_steps = std.ArrayList(usize).init(allocator);
    var prime_factors = std.AutoHashMap(usize, usize).init(allocator);
    defer nodes.deinit();
    defer next_keys.deinit();
    defer path_steps.deinit();
    defer prime_factors.deinit();

    while (lines.next()) |line| {
        const key = line[0..3].*;
        const node = Node{
            .left = line[7..10].*,
            .right = line[12..15].*,
        };

        try nodes.put(key, node);

        if (key[2] == 'A') {
            try next_keys.append(key);
            try path_steps.append(0);
        }
    }

    for (next_keys.items, path_steps.items) |*next_key, *steps| {
        var i: usize = 0;

        while (next_key.*[2] != 'Z') : (i = (i + 1) % directions.len) {
            const node = nodes.get(next_key.*).?;
            steps.* += 1;

            if (directions[i] == 'L') {
                next_key.* = node.left;
            } else {
                next_key.* = node.right;
            }
        }
    }

    for (path_steps.items) |steps| {
        var iter = PrimeIter.init();
        var prime = iter.next();
        var prime_count: usize = 0;
        var div = steps;

        while (true) {
            const new_div = div / prime;

            if (new_div * prime == div) {
                prime_count += 1;
                div = new_div;
            } else {
                if (prime_count > 0) {
                    var factor = try prime_factors.getOrPut(prime);

                    if (factor.found_existing) {
                        factor.value_ptr.* = @max(factor.value_ptr.*, prime_count);
                    } else {
                        factor.value_ptr.* = 1;
                    }
                }

                if (div <= 1) {
                    break;
                }

                prime = iter.next();
                prime_count = 0;
            }
        }
    }

    var factors_iter = prime_factors.iterator();
    var highest_common_factor: usize = 1;
    while (factors_iter.next()) |factor| {
        highest_common_factor *= std.math.pow(usize, factor.key_ptr.*, factor.value_ptr.*);
    }

    return highest_common_factor;
}

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();
    const input = @embedFile("input.txt");

    std.debug.print("Part 1: {}\n", .{try part1(input, allocator)});
    std.debug.print("Part 2: {}\n", .{try part2(input, allocator)});
}
