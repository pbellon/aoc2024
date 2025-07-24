const std = @import("std");
const Allocator = std.mem.Allocator;
const print = std.debug.print;

const Pos = struct { x: usize, y: usize };

const ParseResult = struct {
    antenas: std.AutoArrayHashMap(u8, std.ArrayListUnmanaged(Pos)),
    cols: usize,
    rows: usize,
};

pub fn main() !void {
    const input = @embedFile("./input.txt");
    const allocator = std.heap.page_allocator;
    var arena = std.heap.ArenaAllocator.init(allocator);

    print("--- DAY 8 ---\n", .{});
    print("Part One => {d}\n", .{try partOne(arena.allocator(), input)});
    // print("Part Two => {d}\n", .{try partTwo(arena.allocator(), input)});
    print("\n\n", .{});
}

fn parse(allocator: Allocator, input: []const u8) !ParseResult {
    var antenas = std.AutoArrayHashMap(u8, std.ArrayListUnmanaged(Pos)).init(allocator);

    var it = std.mem.tokenizeScalar(u8, input, '\n');
    var y: usize = 0;
    var cols: usize = 0;
    while (it.next()) |line| {
        if (cols == 0) {
            cols = line.len;
        }

        for (line, 0..) |c, x| {
            if (c != '.' and c != '#') {
                var arr = try antenas.getOrPutValue(c, .empty);
                try arr.value_ptr.append(allocator, Pos{ .x = x, .y = y });
            }
        }

        if (line.len > 0) {
            y += 1;
        }
    }

    return ParseResult{
        .antenas = antenas,
        .cols = cols,
        .rows = y,
    };
}

// returns null if out-of-bounds
fn antinode(a: Pos, o: Pos, rows: usize, cols: usize) ?Pos {
    const a_x: i64 = @intCast(a.x);
    const a_y: i64 = @intCast(a.y);

    const o_x: i64 = @intCast(o.x);
    const o_y: i64 = @intCast(o.y);

    const dx: i64 = o_x - a_x;
    const dy: i64 = o_y - a_y;

    const anx = o_x + dx;
    const any = o_y + dy;

    if (anx < 0 or any < 0) return null;
    if (anx >= cols) return null;
    if (any >= rows) return null;

    return Pos{
        .x = @intCast(anx),
        .y = @intCast(any),
    };
}

fn partOne(allocator: Allocator, input: []const u8) !usize {
    const res = try parse(allocator, input);
    var antinodes = std.AutoArrayHashMap(Pos, void).init(allocator);

    print("Grid is {d} x {d} with {d} detected antenas\n", .{ res.cols, res.rows, res.antenas.count() });

    var it = res.antenas.iterator();

    while (it.next()) |value| {
        const items = value.value_ptr.items;
        for (items, 0..) |a, i| {
            for (items[i + 1 ..]) |b| {
                if (antinode(a, b, res.rows, res.cols)) |aa| {
                    try antinodes.put(aa, {});
                }
                if (antinode(b, a, res.rows, res.cols)) |ba| {
                    try antinodes.put(ba, {});
                }
            }
        }
    }

    return antinodes.count();
}

// fn partTwo(allocator: Allocator, input: []const u8) u8 {}
