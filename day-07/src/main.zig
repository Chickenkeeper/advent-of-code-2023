const std = @import("std");

const Hand = struct {
    card_strengths: [5]u8,
    hand_type: HandType,
    bid: usize,

    fn lessThan(_: void, lhs: Hand, rhs: Hand) bool {
        const lhs_type_strength = @intFromEnum(lhs.hand_type);
        const rhs_type_strength = @intFromEnum(rhs.hand_type);

        if (lhs_type_strength == rhs_type_strength) {
            for (lhs.card_strengths, rhs.card_strengths) |lc, rc| {
                if (lc != rc) {
                    return lc < rc;
                }
            }
        }

        return lhs_type_strength < rhs_type_strength;
    }
};

const HandType = enum(u8) {
    high_card,
    one_pair,
    two_pair,
    three_of_a_kind,
    full_house,
    four_of_a_kind,
    five_of_a_kind,

    fn fromCardStrengths(card_strengths: [5]u8) HandType {
        var card_counts = [_]u8{0} ** 13;
        for (card_strengths) |strength| {
            card_counts[strength] += 1;
        }

        var totals: u32 = 0;
        for (card_counts) |count| {
            if (count > 0) {
                totals += @as(u32, 1) << @as(u5, @intCast(count - 1)) * 4;
            }
        }

        return switch (totals) {
            0x10000 => HandType.five_of_a_kind,
            0x01001 => HandType.four_of_a_kind,
            0x00110 => HandType.full_house,
            0x00102 => HandType.three_of_a_kind,
            0x00021 => HandType.two_pair,
            0x00013 => HandType.one_pair,
            else => HandType.high_card,
        };
    }
};

fn part1(input: []const u8, allocator: std.mem.Allocator) !usize {
    var lines = std.mem.tokenizeScalar(u8, input, '\n');
    var hands = std.ArrayList(Hand).init(allocator);
    defer hands.deinit();

    while (lines.next()) |line| {
        const card_strengths = blk: {
            var strengths: [5]u8 = undefined;
            for (&strengths, line[0..5]) |*strength, card| {
                strength.* = switch (card) {
                    'A' => 12,
                    'K' => 11,
                    'Q' => 10,
                    'J' => 9,
                    'T' => 8,
                    '2'...'9' => |v| v - '0' - 2,
                    else => 0,
                };
            }
            break :blk strengths;
        };
        const hand_type = HandType.fromCardStrengths(card_strengths);
        const bid = std.fmt.parseInt(usize, line[6..], 10) catch unreachable;
        const hand = Hand{
            .card_strengths = card_strengths,
            .hand_type = hand_type,
            .bid = bid,
        };

        try hands.append(hand);
    }

    std.sort.heap(Hand, hands.items, {}, Hand.lessThan);

    var sum: usize = 0;
    for (hands.items, 1..) |hand, rank| {
        sum += hand.bid * rank;
    }

    return sum;
}

fn part2(input: []const u8, allocator: std.mem.Allocator) !usize {
    var lines = std.mem.tokenizeScalar(u8, input, '\n');
    var hands = std.ArrayList(Hand).init(allocator);
    defer hands.deinit();

    while (lines.next()) |line| {
        const card_strengths = blk: {
            var strengths: [5]u8 = undefined;
            for (&strengths, line[0..5]) |*strength, card| {
                strength.* = switch (card) {
                    'A' => 12,
                    'K' => 11,
                    'Q' => 10,
                    'T' => 9,
                    '2'...'9' => |v| v - '0' - 1,
                    else => 0,
                };
            }
            break :blk strengths;
        };
        const hand_type = blk: {
            var strengths = card_strengths;
            var card_counts = [_]u8{0} ** 12;
            for (strengths) |strength| {
                if (strength > 0) {
                    card_counts[strength - 1] += 1;
                }
            }

            const most_common_card: u8 = @intCast(std.mem.indexOfMax(u8, &card_counts) + 1);
            for (&strengths) |*strength| {
                if (strength.* == 0) {
                    strength.* = most_common_card;
                }
            }

            break :blk HandType.fromCardStrengths(strengths);
        };
        const bid = std.fmt.parseInt(usize, line[6..], 10) catch unreachable;
        const hand = Hand{
            .card_strengths = card_strengths,
            .hand_type = hand_type,
            .bid = bid,
        };

        try hands.append(hand);
    }

    std.sort.heap(Hand, hands.items, {}, Hand.lessThan);

    var sum: usize = 0;
    for (hands.items, 1..) |hand, rank| {
        sum += hand.bid * rank;
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
