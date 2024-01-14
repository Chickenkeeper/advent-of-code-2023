const std = @import("std");

const Direction = enum {
    up,
    down,
    left,
    right,
};

const Line = struct {
    len: isize,
    height: isize,
    inside: bool,
};

const Command = struct {
    dir: Direction,
    len: isize,

    fn parse(string: []const u8) Command {
        const num_end = std.mem.indexOfScalar(u8, string[2..], ' ').?;
        const len = std.fmt.parseInt(isize, string[2..][0..num_end], 10) catch unreachable;
        const dir: Direction = switch (string[0]) {
            'U' => .up,
            'D' => .down,
            'L' => .left,
            else => .right,
        };

        return .{ .dir = dir, .len = len };
    }

    fn parseHex(string: []const u8) Command {
        const num_start = std.mem.indexOfScalar(u8, string, '#').? + 1;
        const len = std.fmt.parseInt(isize, string[num_start..][0..5], 16) catch unreachable;
        const dir: Direction = switch (string[string.len - 2]) {
            '0' => .right,
            '1' => .down,
            '2' => .left,
            else => .up,
        };

        return .{ .dir = dir, .len = len };
    }
};

fn getLagoonCapacity(input: []const u8, allocator: std.mem.Allocator, comptime parseCommandFn: fn (string: []const u8) Command) !usize {
    var input_lines = std.mem.tokenizeScalar(u8, input, '\n');
    var shape_lines = std.ArrayList(Line).init(allocator);
    defer shape_lines.deinit();

    var y: isize = 0;
    while (input_lines.next()) |line| {
        const cmd = parseCommandFn(line);
        switch (cmd.dir) {
            .up => y += cmd.len,
            .down => y -= cmd.len,
            .left, .right => try shape_lines.append(.{
                .len = cmd.len,
                .height = y,
                .inside = cmd.dir == .right,
            }),
        }
    }

    const min_height: isize = -1 << (@bitSizeOf(isize) / 2);
    var total_area: isize = 0;
    for (0..shape_lines.items.len) |i| {
        const line = shape_lines.items[(i + 1) % shape_lines.items.len];
        const offset: isize = blk: {
            const prev = shape_lines.items[i];
            const next = shape_lines.items[(i + 2) % shape_lines.items.len];

            if (prev.height < line.height and next.height < line.height) {
                break :blk 1;
            } else if (prev.height > line.height and next.height > line.height) {
                break :blk -1;
            } else {
                break :blk 0;
            }
        };

        if (line.inside) {
            total_area += (line.len + offset) * (line.height - min_height + 1);
        } else {
            total_area -= (line.len - offset) * (line.height - min_height);
        }
    }

    return @intCast(total_area);
}

fn part1(input: []const u8, allocator: std.mem.Allocator) !usize {
    return getLagoonCapacity(input, allocator, Command.parse);
}

fn part2(input: []const u8, allocator: std.mem.Allocator) !usize {
    return getLagoonCapacity(input, allocator, Command.parseHex);
}

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();
    const input = @embedFile("input.txt");

    std.debug.print("Part 1: {}\n", .{try part1(input, allocator)});
    std.debug.print("Part 2: {}\n", .{try part2(input, allocator)});
}
