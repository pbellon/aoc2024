// Day 3: Mull It Over
// "Our computers are having issues, so I have no idea if we have any Chief Historians in stock!
// You're welcome to check the warehouse, though," says the mildly flustered shopkeeper at the North
// Pole Toboggan Rental Shop. The Historians head out to take a look.
//
// The shopkeeper turns to you. "Any chance you can see why our computers are having issues again?"
//
// The computer appears to be trying to run a program, but its memory (your puzzle input) is
// corrupted. All of the instructions have been jumbled up!
//
// It seems like the goal of the program is just to multiply some numbers. It does that with
// instructions like mul(X,Y), where X and Y are each 1-3 digit numbers. For instance, mul(44,46)
// multiplies 44 by 46 to get a result of 2024. Similarly, mul(123,4) would multiply 123 by 4.
//
// However, because the program's memory has been corrupted, there are also many invalid characters
// that should be ignored, even if they look like part of a mul instruction. Sequences like
// mul(4*, mul(6,9!, ?(12,34), or mul ( 2 , 4 ) do nothing.
//
// For example, consider the following section of corrupted memory:
//
// x{mul(2,4)}%&mul[3,7]!@^do_not_{mul(5,5)}+mul(32,64]then({mul(11,8)}{mul(8,5)})
//
// Only the four highlighted sections are real mul instructions. Adding up the result of each
// instruction produces 161 (2*4 + 5*5 + 11*8 + 8*5).
//
// Scan the corrupted memory for uncorrupted mul instructions. What do you get if you add up all of
// the results of the multiplications?
//
// Personnal notes on my solution:
// Probably sub-optimal concerning jumping index when don't() detected, we could in theory directly
// jump after the next do() operation in the string.
//
// By looking at other people solution I do think the best approach, at least to my taste, is to
// rely on `sliceTo`

const std = @import("std");

const print = std.debug.print;

pub fn main() !void {
    const input = @embedFile("./input.txt");
    const pa = std.heap.page_allocator;
    var arena = std.heap.ArenaAllocator.init(pa);
    defer arena.deinit();

    print("--- DAY 3 ---\n", .{});
    print("Part One: {d}\n", .{calculate_mul_ops(input, false)});
    print("Part Two: {d}\n", .{calculate_mul_ops(input, true)});
    print("\n\n", .{});
}

const MulPair = struct {
    a: i32,
    b: i32,
};

fn get_pair(win: []const u8) !MulPair {
    const a_int_slice = std.mem.sliceTo(win[4..], ',');
    const a_int = try std.fmt.parseInt(i32, a_int_slice, 10);

    const b_int_slice = std.mem.sliceTo(win[4 + a_int_slice.len + 1 ..], ')');
    const b_int = try std.fmt.parseInt(i32, b_int_slice, 10);

    return MulPair{ .a = a_int, .b = b_int };
}

// VALID ANSWERS
// TASK 1: 185797128
// TASK 2: 89798695
fn calculate_mul_ops(input: []const u8, with_instructions: bool) i32 {
    var enabled = true;

    var it = std.mem.window(u8, input, 12, 1);
    var total: i32 = 0;

    while (it.next()) |win| {
        // detected valid mul( op
        if (with_instructions and std.mem.eql(u8, win[0..4], "do()")) {
            enabled = true;
        }

        if (with_instructions and std.mem.eql(u8, win[0..7], "don't()")) {
            enabled = false;
        }

        if (enabled and std.mem.eql(u8, win[0..4], "mul(")) {
            const pair = get_pair(win) catch {
                continue;
            };
            total += pair.a * pair.b;
        }
    }

    return total;
}
