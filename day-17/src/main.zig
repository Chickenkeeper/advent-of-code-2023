const std = @import("std");

const Coord = struct {
    x: usize,
    y: usize,

    fn init(x: usize, y: usize) Coord {
        return .{ .x = x, .y = y };
    }
};

const Direction = enum(usize) {
    north,
    east,
    south,
    west,
};

const State = struct {
    pos: Coord,
    dir: Direction,
    dist: usize,
};

const Node = struct {
    heat_loss: usize,
    state: State,

    fn cmp(_: void, a: Node, b: Node) std.math.Order {
        return std.math.order(a.heat_loss, b.heat_loss);
    }
};

fn getMinHeatLoss(min_dist: usize, max_dist: usize, input: []const u8, allocator: std.mem.Allocator) !usize {
    const width = std.mem.indexOfScalar(u8, input, '\n').?;
    const height = input.len / (width + 1);
    var visited = std.AutoHashMap(State, usize).init(allocator);
    var queue = std.PriorityQueue(Node, void, Node.cmp).init(allocator, {});
    defer visited.deinit();
    defer queue.deinit();

    try queue.add(.{
        .heat_loss = input[1] - '0',
        .state = .{
            .pos = Coord.init(1, 0),
            .dir = .east,
            .dist = 1,
        },
    });
    try queue.add(.{
        .heat_loss = input[width + 1] - '0',
        .state = .{
            .pos = Coord.init(0, 1),
            .dir = .south,
            .dist = 1,
        },
    });

    while (queue.removeOrNull()) |curr| {
        const pos = curr.state.pos;
        if (pos.x == width - 1 and pos.y == height - 1 and curr.state.dist >= min_dist) {
            return curr.heat_loss;
        }

        var stored = try visited.getOrPut(curr.state);
        if (stored.found_existing) {
            if (stored.value_ptr.* <= curr.heat_loss) {
                continue;
            }
        }

        stored.value_ptr.* = curr.heat_loss;

        for (0..4) |i| {
            if ((i + 2) % 4 == @intFromEnum(curr.state.dir)) continue;

            const new_dir: Direction = @enumFromInt(i);
            if (new_dir == curr.state.dir) {
                if (curr.state.dist == max_dist) continue;
            } else {
                if (curr.state.dist < min_dist) continue;
            }

            const new_pos_op = switch (new_dir) {
                .north => if (pos.y > 0) Coord.init(pos.x, pos.y - 1) else null,
                .east => if (pos.x < width - 1) Coord.init(pos.x + 1, pos.y) else null,
                .south => if (pos.y < height - 1) Coord.init(pos.x, pos.y + 1) else null,
                .west => if (pos.x > 0) Coord.init(pos.x - 1, pos.y) else null,
            };
            if (new_pos_op) |new_pos| {
                const new_heat_loss = curr.heat_loss + input[new_pos.x + new_pos.y * (width + 1)] - '0';
                const new_dist = if (new_dir == curr.state.dir) curr.state.dist + 1 else 1;

                try queue.add(.{
                    .heat_loss = new_heat_loss,
                    .state = .{
                        .pos = new_pos,
                        .dir = new_dir,
                        .dist = new_dist,
                    },
                });
            }
        }
    }
    unreachable;
}

fn part1(input: []const u8, allocator: std.mem.Allocator) !usize {
    return getMinHeatLoss(0, 3, input, allocator);
}

fn part2(input: []const u8, allocator: std.mem.Allocator) !usize {
    return getMinHeatLoss(4, 10, input, allocator);
}

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();
    const input = @embedFile("input.txt");

    std.debug.print("Part 1: {}\n", .{try part1(input, allocator)});
    std.debug.print("Part 2: {}\n", .{try part2(input, allocator)});
}
