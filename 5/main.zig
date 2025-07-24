const std = @import("std");
const Allocator = std.mem.Allocator;

const print = std.debug.print;

const ParseResult = struct {
    rules: [][2]u32,
    sequences: [][]u32,
};

pub fn main() !void {
    const input = @embedFile("./input.txt");
    const pa = std.heap.page_allocator;
    var arena = std.heap.ArenaAllocator.init(pa);
    const parsed = try parse_input(arena.allocator(), input);

    print("--- DAY 5 ---\n", .{});
    try partOne(arena.allocator(), parsed);
    try partTwo(arena.allocator(), parsed);
    print("\n\n", .{});
}

fn parse_input(allocator: Allocator, input: []const u8) !ParseResult {
    var rules = std.ArrayList([2]u32).init(allocator);
    var sequences = std.ArrayList([]u32).init(allocator);

    const split_idx = std.mem.indexOf(u8, input, "\n\n") orelse {
        return error.MalformedInput;
    };

    const rules_slice = input[0..split_idx];
    var rules_it = std.mem.tokenizeScalar(u8, rules_slice, '\n');

    while (rules_it.next()) |rule| {
        const first_int_slice = std.mem.sliceTo(rule, '|');
        const first_int = try std.fmt.parseInt(u32, first_int_slice, 10);
        const second_int_slice = rule[first_int_slice.len + 1 ..];
        const second_int = try std.fmt.parseInt(u32, second_int_slice, 10);

        try rules.append([2]u32{ first_int, second_int });
    }

    const sequences_slice = input[split_idx..];
    var sequences_it = std.mem.tokenizeScalar(u8, sequences_slice, '\n');
    while (sequences_it.next()) |sequence| {
        var nb_it = std.mem.tokenizeScalar(u8, sequence, ',');
        var numbers = std.ArrayList(u32).init(allocator);

        while (nb_it.next()) |nb| {
            try numbers.append(try std.fmt.parseInt(u32, nb, 10));
        }

        try sequences.append(numbers.items);
    }

    return ParseResult{
        .rules = rules.items,
        .sequences = sequences.items,
    };
}

fn lessByRules(rules: [][2]u32, a: u32, b: u32) bool {
    for (rules) |r| {
        if (a == r[0] and b == r[1]) return true;
        if (a == r[1] and b == r[0]) return false;
    }
    return false;
}

fn partOne(allocator: Allocator, parsed: ParseResult) !void {
    var result: u32 = 0;
    var valid_seqs: u16 = 0;

    for (parsed.sequences) |sequence| {
        var tmp = std.ArrayList(u32).init(allocator);
        defer tmp.deinit();
        try tmp.appendSlice(sequence);

        std.mem.sort(u32, tmp.items, parsed.rules, lessByRules);
        if (std.mem.eql(u32, sequence, tmp.items)) {
            result += sequence[sequence.len / 2];
            valid_seqs += 1;
        }
    }

    print("Part One\n\tResult => {d}\n\tValid sequences detected => {d}\n", .{ result, valid_seqs });
}

fn partTwo(allocator: Allocator, parsed: ParseResult) !void {
    var result: u32 = 0;
    var invalid_seqs: u16 = 0;

    for (parsed.sequences) |sequence| {
        var tmp = std.ArrayList(u32).init(allocator);
        defer tmp.deinit();
        try tmp.appendSlice(sequence);

        std.mem.sort(u32, tmp.items, parsed.rules, lessByRules);
        if (!std.mem.eql(u32, sequence, tmp.items)) {
            result += tmp.items[tmp.items.len / 2];
            invalid_seqs += 1;
        }
    }

    print("Part Two\n\tResult => {d}\n\tInvalid sequences detected => {d}\n", .{ result, invalid_seqs });
}
