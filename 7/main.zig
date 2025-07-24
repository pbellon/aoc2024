const std = @import("std");
const Allocator = std.mem.Allocator;
const print = std.debug.print;

pub fn main() !void {
    const input = @embedFile("./input.txt");
    const allocator = std.heap.page_allocator;
    var arena = std.heap.ArenaAllocator.init(allocator);

    print("--- DAY 7 ---\n", .{});
    print("Part One => {d}", .{try partOne(arena.allocator(), input)});
    print("\n\n", .{});
}

fn hasCombination(total: u64, numbers: std.ArrayList(u32)) bool {
    const nbs = numbers.items;
    const nb_bits = nbs.len - 1;
    const max = std.math.pow(usize, 2, nb_bits);

    for (0..max) |i| {
        var acc: u64 = @intCast(nbs[0]);
        const i_u: u32 = @intCast(i);

        for (0..nb_bits) |j| {
            // needs to cast as u5 in order to be able to shift bits of u32
            const j_u: u5 = @intCast(j);
            const op_bit = (i_u >> j_u) & 1;
            const next = nbs[j + 1];
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
    var lines_it = std.mem.tokenizeScalar(u8, input, '\n');

    while (lines_it.next()) |line| {
        var numbers = std.ArrayList(u32).init(allocator);
        const total_slice = std.mem.sliceTo(line, ':');
        const numbers_slice = line[total_slice.len + 2 ..];
        const total = try std.fmt.parseInt(u64, total_slice, 10);
        var nb_it = std.mem.tokenizeScalar(u8, numbers_slice, ' ');

        while (nb_it.next()) |nb_slice| {
            try numbers.append(try std.fmt.parseInt(u32, nb_slice, 10));
        }

        if (hasCombination(total, numbers)) {
            result += total;
        }
    }

    return result;
}
