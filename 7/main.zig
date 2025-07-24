const std = @import("std");
const Allocator = std.mem.Allocator;
const print = std.debug.print;

const Parsed = struct {
    target: u64,
    numbers: []u64,
};

pub fn main() !void {
    const input = @embedFile("./input.txt");
    const allocator = std.heap.page_allocator;
    var arena = std.heap.ArenaAllocator.init(allocator);

    print("--- DAY 7 ---\n", .{});
    print("Part One => {d}\n", .{try partOne(arena.allocator(), input)});
    print("Part Two => {d}\n", .{try partTwo(arena.allocator(), input)});
    print("\n\n", .{});
}

fn parseInput(allocator: Allocator, input: []const u8) ![]Parsed {
    var result = std.ArrayList(Parsed).init(allocator);
    var lines_it = std.mem.tokenizeScalar(u8, input, '\n');

    while (lines_it.next()) |line| {
        var numbers = std.ArrayList(u64).init(allocator);
        const total_slice = std.mem.sliceTo(line, ':');
        const numbers_slice = line[total_slice.len + 2 ..];
        const total = try std.fmt.parseInt(u64, total_slice, 10);
        var nb_it = std.mem.tokenizeScalar(u8, numbers_slice, ' ');

        while (nb_it.next()) |nb_slice| {
            try numbers.append(try std.fmt.parseInt(u64, nb_slice, 10));
        }

        try result.append(Parsed{
            .target = total,
            .numbers = numbers.items,
        });
    }

    return result.items;
}

fn hasCombination(total: u64, numbers: []u64) bool {
    const nb_bits = numbers.len - 1;
    const max = std.math.pow(usize, 2, nb_bits);

    for (0..max) |i| {
        var acc: u64 = @intCast(numbers[0]);
        const i_u: u32 = @intCast(i);

        for (0..nb_bits) |j| {
            // needs to cast as u5 in order to be able to shift bits of u32
            const j_u: u5 = @intCast(j);
            const op_bit = (i_u >> j_u) & 1;
            const next = numbers[j + 1];
            if (op_bit == 0) {
                acc += next;
            } else {
                acc *= next;
            }
        }

        if (acc == total) {
            return true;
        }
    }

    return false;
}

fn partOne(allocator: Allocator, input: []const u8) !u64 {
    var result: u64 = 0;
    const parsed = try parseInput(allocator, input);
    for (parsed) |p| {
        if (hasCombination(p.target, p.numbers)) {
            result += p.target;
        }
    }

    return result;
}

fn concat(a: u64, b: u64) u64 {
    const len_b: u64 = std.math.log10_int(b) + 1;
    const exp = std.math.powi(u64, 10, len_b) catch unreachable;
    return a * exp + b;
}

// Spoiled myself the solution from ziggit.dev to rely on recursion instead of combinatorial approach
fn solveRec(target: u64, temp: u64, numbers: []u64) bool {
    return switch (numbers.len) {
        0 => target == temp, // stop condition
        else => solveRec(target, temp + numbers[0], numbers[1..]) or
            solveRec(target, temp * numbers[0], numbers[1..]) or
            solveRec(target, concat(temp, numbers[0]), numbers[1..]),
    };
}

fn partTwo(allocator: Allocator, input: []const u8) !u64 {
    var result: u64 = 0;
    const parsed = try parseInput(allocator, input);
    for (parsed) |p| {
        if (solveRec(p.target, 0, p.numbers)) {
            result += p.target;
        }
    }

    return result;
}
