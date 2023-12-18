const std = @import("std");

const Range = struct {
    start: usize,
    end: usize,

    fn containsValue(self: Range, value: usize) bool {
        return value >= self.start and value < self.end;
    }

    fn containsRange(self: Range, range: Range) bool {
        return range.start >= self.start and range.end <= self.end;
    }

    fn overlapsRange(self: Range, range: Range) bool {
        return range.end > self.start and range.start < self.end;
    }

    fn clampedToRange(self: Range, range: Range) ?ClampedRange {
        if (self.overlapsRange(range)) {
            var clamped_range = ClampedRange{
                .range = self,
                .underflow = null,
                .overflow = null,
            };

            if (self.start < range.start) {
                clamped_range.underflow = Range{
                    .start = self.start,
                    .end = range.start,
                };
                clamped_range.range.start = range.start;
            }

            if (self.end > range.end) {
                clamped_range.overflow = Range{
                    .start = range.end,
                    .end = self.end,
                };
                clamped_range.range.end = range.end;
            }

            return clamped_range;
        } else {
            return null;
        }
    }
};

const ClampedRange = struct {
    range: Range,
    underflow: ?Range,
    overflow: ?Range,
};

const MapRow = struct {
    source: Range,
    dest: Range,

    fn convertValue(self: MapRow, value: usize) ?usize {
        if (self.source.containsValue(value)) {
            return self.dest.start + (value - self.source.start);
        } else {
            return null;
        }
    }

    fn convertRange(self: MapRow, range: Range) ?Range {
        if (self.source.containsRange(range)) {
            return Range{
                .start = self.dest.start + (range.start - self.source.start),
                .end = self.dest.start + (range.end - self.source.start),
            };
        } else {
            return null;
        }
    }
};

fn parseSeeds(string: []const u8, allocator: std.mem.Allocator) !std.ArrayList(usize) {
    var seeds = std.ArrayList(usize).init(allocator);
    var seed_strs = std.mem.tokenizeScalar(u8, string, ' ');
    _ = seed_strs.next();

    while (seed_strs.next()) |seed_str| {
        const seed = std.fmt.parseInt(usize, seed_str, 10) catch unreachable;
        try seeds.append(seed);
    }

    return seeds;
}

fn parseMap(string: []const u8, allocator: std.mem.Allocator) !std.ArrayList(MapRow) {
    var map = std.ArrayList(MapRow).init(allocator);
    var lines = std.mem.tokenizeScalar(u8, string, '\n');
    _ = lines.next();

    while (lines.next()) |line| {
        var num_strs = std.mem.tokenizeScalar(u8, line, ' ');
        const dest_start = std.fmt.parseInt(usize, num_strs.next().?, 10) catch unreachable;
        const source_start = std.fmt.parseInt(usize, num_strs.next().?, 10) catch unreachable;
        const len = std.fmt.parseInt(usize, num_strs.next().?, 10) catch unreachable;

        try map.append(MapRow{
            .source = Range{ .start = source_start, .end = source_start + len },
            .dest = Range{ .start = dest_start, .end = dest_start + len },
        });
    }

    return map;
}

fn part1(input: []const u8, allocator: std.mem.Allocator) !usize {
    var lowest: usize = std.math.maxInt(usize);
    var chunks = std.mem.tokenizeSequence(u8, input, "\n\n");
    var seeds = try parseSeeds(chunks.next().?, allocator);
    const maps = blk: {
        var m: [7]std.ArrayList(MapRow) = undefined;
        for (0..7) |i| {
            m[i] = try parseMap(chunks.next().?, allocator);
        }
        break :blk m;
    };
    defer seeds.deinit();
    defer for (maps) |map| map.deinit();

    for (seeds.items) |seed| {
        var num = seed;

        for (maps) |map| {
            for (map.items) |map_row| {
                if (map_row.convertValue(num)) |mapped_num| {
                    num = mapped_num;
                    break;
                }
            }
        }

        lowest = @min(lowest, num);
    }

    return lowest;
}

fn part2(input: []const u8, allocator: std.mem.Allocator) !usize {
    var lowest: usize = std.math.maxInt(usize);
    var chunks = std.mem.tokenizeSequence(u8, input, "\n\n");
    var seeds = try parseSeeds(chunks.next().?, allocator);
    var range_stack = std.ArrayList(Range).init(allocator);
    const maps = blk: {
        var m: [7]std.ArrayList(MapRow) = undefined;
        for (0..7) |i| {
            m[i] = try parseMap(chunks.next().?, allocator);
        }
        break :blk m;
    };
    defer seeds.deinit();
    defer range_stack.deinit();
    defer for (maps) |map| map.deinit();

    var si: usize = 0;
    while (si < seeds.items.len) : (si += 2) {
        try range_stack.append(Range{
            .start = seeds.items[si],
            .end = seeds.items[si] + seeds.items[si + 1],
        });

        for (maps) |map| {
            var ri: usize = 0;
            while (ri < range_stack.items.len) : (ri += 1) {
                for (map.items) |map_row| {
                    if (range_stack.items[ri].clampedToRange(map_row.source)) |clamped_range| {
                        range_stack.items[ri] = map_row.convertRange(clamped_range.range).?;

                        if (clamped_range.underflow) |underflow| {
                            try range_stack.append(underflow);
                        }

                        if (clamped_range.overflow) |overflow| {
                            try range_stack.append(overflow);
                        }

                        break;
                    }
                }
            }
        }

        for (range_stack.items) |seed_range| {
            lowest = @min(lowest, seed_range.start);
        }

        range_stack.clearRetainingCapacity();
    }

    return lowest;
}

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();
    const input = @embedFile("input.txt");

    std.debug.print("Part 1: {}\n", .{try part1(input, allocator)});
    std.debug.print("Part 2: {}\n", .{try part2(input, allocator)});
}
