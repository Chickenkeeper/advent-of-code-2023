const std = @import("std");

const Node = struct {
    springs_start: usize,
    groups_start: usize,
};

fn getArrangementCount(springs: []const u8, groups: []const usize, stack: *std.ArrayList(Node), cache: *std.AutoHashMap(Node, usize)) !usize {
    var sum: usize = 0;

    try stack.append(Node{
        .springs_start = 0,
        .groups_start = 0,
    });

    while (true) {
        const node = stack.getLast();
        const node_springs = springs[node.springs_start..];
        const node_groups = groups[node.groups_start..];
        const group = node_groups[0];
        const cached_node = try cache.getOrPut(node);

        if (cached_node.found_existing) {
            if (cached_node.value_ptr.* > 0) {
                if (stack.items.len > 1) {
                    // Add nodes' sum to its parent
                    const parent_key = stack.items[stack.items.len - 2];
                    const parent_ptr = cache.getPtr(parent_key).?;
                    parent_ptr.* += cached_node.value_ptr.*;
                } else {
                    sum += cached_node.value_ptr.*;
                }
            }

            // Check if node can move and move if so
            if (node_springs.len > group + (node_groups.len - 1) * 2 and
                node_springs[0] != '#')
            {
                stack.items[stack.items.len - 1].springs_start += 1;
            } else if (stack.items.len == 1) {
                break;
            } else {
                _ = stack.pop();
            }
        } else {
            cached_node.value_ptr.* = 0;

            // Check if group is valid
            if (node_springs.len >= group and
                !std.mem.containsAtLeast(u8, node_springs[0..group], 1, ".") and
                !(node_springs.len > group and node_springs[group] == '#'))
            {
                // If last group set node value to 1
                if (node_groups.len == 1 and
                    !std.mem.containsAtLeast(u8, node_springs[group..], 1, "#"))
                {
                    cached_node.value_ptr.* = 1;
                    // Otherwise push next node to stack if possible
                } else if (node_springs.len > group + 1 and
                    node_groups.len > 1)
                {
                    try stack.append(Node{
                        .springs_start = node.springs_start + group + 1,
                        .groups_start = node.groups_start + 1,
                    });
                }
            }
        }
    }

    stack.clearRetainingCapacity();
    cache.clearRetainingCapacity();

    return sum;
}

fn part1(input: []const u8, allocator: std.mem.Allocator) !usize {
    var sum: usize = 0;
    var lines = std.mem.tokenizeScalar(u8, input, '\n');
    var groups = std.ArrayList(usize).init(allocator);
    var stack = std.ArrayList(Node).init(allocator);
    var cache = std.AutoHashMap(Node, usize).init(allocator);
    defer groups.deinit();
    defer stack.deinit();
    defer cache.deinit();

    while (lines.next()) |line| {
        var split = std.mem.indexOfScalar(u8, line, ' ').?;
        var group_nums = std.mem.tokenizeScalar(u8, line[(split + 1)..], ',');
        const springs = std.mem.trim(u8, line[0..split], ".");

        while (group_nums.next()) |num_str| {
            const num = std.fmt.parseInt(usize, num_str, 10) catch unreachable;
            try groups.append(num);
        }

        sum += try getArrangementCount(springs, groups.items, &stack, &cache);
        groups.clearRetainingCapacity();
    }

    return sum;
}

fn part2(input: []const u8, allocator: std.mem.Allocator) !usize {
    var sum: usize = 0;
    var lines = std.mem.tokenizeScalar(u8, input, '\n');
    var springs = std.ArrayList(u8).init(allocator);
    var groups = std.ArrayList(usize).init(allocator);
    var stack = std.ArrayList(Node).init(allocator);
    var cache = std.AutoHashMap(Node, usize).init(allocator);
    defer springs.deinit();
    defer groups.deinit();
    defer stack.deinit();
    defer cache.deinit();

    while (lines.next()) |line| {
        var split = std.mem.indexOfScalar(u8, line, ' ').?;

        for (0..5) |i| {
            try springs.appendSlice(line[0..split]);
            if (i < 4) try springs.append('?');

            var group_nums = std.mem.tokenizeScalar(u8, line[(split + 1)..], ',');
            while (group_nums.next()) |num_str| {
                const num = std.fmt.parseInt(usize, num_str, 10) catch unreachable;
                try groups.append(num);
            }
        }

        const springs_trimmed = std.mem.trim(u8, springs.items, ".");
        sum += try getArrangementCount(springs_trimmed, groups.items, &stack, &cache);
        springs.clearRetainingCapacity();
        groups.clearRetainingCapacity();
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
