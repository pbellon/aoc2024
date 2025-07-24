const std = @import("std");

const print = std.debug.print;

pub fn main() !void {
    const input = @embedFile("./input.txt");
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);

    defer arena.deinit();

    print("--- DAY 4 ---\n\n", .{});
    print("Part One: \n\t# of XMAS found => {d}\n\n", .{try partOne(arena.allocator(), input)});
    print("Part Two: \n\t# of X-MAS found => {d}\n\n", .{try partTwo(arena.allocator(), input)});
    print("\n\n", .{});
}

pub fn readLines(alloc: std.mem.Allocator, input: []const u8) ![][]const u8 {
    var lines_al = std.ArrayList([]const u8).init(alloc);
    var it = std.mem.tokenizeScalar(u8, input, '\n');
    while (it.next()) |line| {
        try lines_al.append(line);
    }

    return lines_al.items;
}

// Personnal note:
// really not satisfying, really repetitive and not readable.
fn partOne(alloc: std.mem.Allocator, input: []const u8) !u32 {
    const lines = try readLines(alloc, input);

    const word_fw = "XMAS";
    const word_bw = "SAMX";

    var total: u32 = 0;

    for (lines, 0..) |line, r| {
        for (line, 0..) |char, c| {
            // Only check words if current char is X
            if (char != 'X') continue;

            if (c <= line.len - 4) {
                // horizontally, forward
                if (std.mem.eql(u8, word_fw, line[c .. c + 4])) {
                    total += 1;
                }
            }

            if (c >= 3) {
                // horizontal, backward
                if (std.mem.eql(u8, word_bw, line[c - 3 .. c + 1])) {
                    total += 1;
                }

                // south west diagonal
                if (r <= lines.len - 4) {
                    const to_check_swd = [_]u8{ char, lines[r + 1][c - 1], lines[r + 2][c - 2], lines[r + 3][c - 3] };
                    if (std.mem.eql(u8, word_fw, &to_check_swd)) {
                        total += 1;
                    }
                }

                // north west diagonal
                if (r >= 3) {
                    const to_check = [_]u8{ char, lines[r - 1][c - 1], lines[r - 2][c - 2], lines[r - 3][c - 3] };
                    if (std.mem.eql(u8, word_fw, &to_check)) {
                        total += 1;
                    }
                }
            }

            // vertical, forward
            if (r <= lines.len - 4) {
                const to_check_vf = [_]u8{ char, lines[r + 1][c], lines[r + 2][c], lines[r + 3][c] };
                if (std.mem.eql(u8, word_fw, &to_check_vf)) {
                    total += 1;
                }

                // south east diagonal
                if (c <= lines.len - 4) {
                    const to_check_sed = [_]u8{ char, lines[r + 1][c + 1], lines[r + 2][c + 2], lines[r + 3][c + 3] };
                    if (std.mem.eql(u8, word_fw, &to_check_sed)) {
                        total += 1;
                    }
                }
            }

            if (r >= 3) {
                // vertical, backward
                const to_check_vb = [_]u8{ lines[r - 3][c], lines[r - 2][c], lines[r - 1][c], char };
                if (std.mem.eql(u8, word_bw, &to_check_vb)) {
                    total += 1;
                }

                // north east diagonal
                if (c <= lines.len - 4) {
                    const to_check_ned = [_]u8{ char, lines[r - 1][c + 1], lines[r - 2][c + 2], lines[r - 3][c + 3] };
                    if (std.mem.eql(u8, word_fw, &to_check_ned)) {
                        total += 1;
                    }
                }
            }
        }
    }

    return total;
}

// CASES:

// 1.
// M.M
// .A.
// S.S

// 2.
// S.M
// .A.
// S.M

// 3.
// S.S
// .A.
// M.M

// 4.
// M.S
// .A.
// M.S

const PartTwoChecker = struct {
    lines: [][]const u8,

    const Self = @This();

    fn init(alloc: std.mem.Allocator, input: []const u8) !Self {
        return Self{
            .lines = try readLines(alloc, input),
        };
    }

    fn check(self: *Self, pattern: []const u8, r: usize, c: usize) bool {
        return self.lines[r - 1][c - 1] == pattern[0] and
            self.lines[r - 1][c + 1] == pattern[1] and
            self.lines[r + 1][c - 1] == pattern[2] and
            self.lines[r + 1][c + 1] == pattern[3];
    }

    fn total(self: *Self) u32 {
        var res: u32 = 0;

        for (self.lines, 0..) |line, r| {
            // padding of one for rows
            if (r < 1 or r > line.len - 2) continue;

            for (line, 0..) |char, c| {
                // padding of 1 for cols
                if (c < 1 or c > line.len - 2) continue;

                // only check when we're on a 'A' char, the middle one, to ease algo
                if (char != 'A') continue;

                if (self.check("MMSS", r, c)) res += 1; // 1.
                if (self.check("SMSM", r, c)) res += 1; // 2.
                if (self.check("SSMM", r, c)) res += 1; // 3.
                if (self.check("MSMS", r, c)) res += 1; // 4.
            }
        }

        return res;
    }
};

// right answer => 1835
fn partTwo(alloc: std.mem.Allocator, input: []const u8) !u32 {
    var checker = try PartTwoChecker.init(alloc, input);
    return checker.total();
}
