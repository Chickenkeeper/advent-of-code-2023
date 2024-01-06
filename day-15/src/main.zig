const std = @import("std");

const Lens = struct {
    label: []const u8,
    focal_len: u8,
};

fn hash(string: []const u8) u8 {
    var h: u8 = 0;
    for (string) |char| {
        h = (h +% char) *% 17;
    }
    return h;
}

fn part1(input: []const u8) usize {
    var steps = std.mem.tokenizeAny(u8, input, ",\n");
    var sum: usize = 0;

    while (steps.next()) |step| {
        sum += hash(step);
    }

    return sum;
}

fn part2(input: []const u8, allocator: std.mem.Allocator) !usize {
    var steps = std.mem.tokenizeAny(u8, input, ",\n");
    var boxes = blk: {
        var b: [256]std.ArrayList(Lens) = undefined;

        for (&b) |*box| {
            box.* = std.ArrayList(Lens).init(allocator);
        }

        break :blk b;
    };
    defer for (boxes) |box| box.deinit();

    while (steps.next()) |step| {
        const op_index = std.mem.indexOfAny(u8, step, "-=").?;
        const op = step[op_index];
        const label = step[0..op_index];
        const box_index = hash(label);
        const box = &boxes[box_index];

        if (op == '-') {
            for (box.items, 0..) |lens, i| {
                if (std.mem.eql(u8, label, lens.label)) {
                    _ = box.orderedRemove(i);
                    break;
                }
            }
        } else {
            const focal_len = step[op_index + 1] - '0';

            for (box.items) |*lens| {
                if (std.mem.eql(u8, label, lens.label)) {
                    lens.focal_len = focal_len;
                    break;
                }
            } else {
                try box.append(Lens{
                    .label = label,
                    .focal_len = focal_len,
                });
            }
        }
    }

    var sum: usize = 0;
    for (boxes, 1..) |box, i| {
        for (box.items, 1..) |lens, j| {
            sum += i * j * lens.focal_len;
        }
    }

    return sum;
}

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();
    const input = @embedFile("input.txt");

    std.debug.print("Part 1: {}\n", .{part1(input)});
    std.debug.print("Part 2: {}\n", .{try part2(input, allocator)});
}
