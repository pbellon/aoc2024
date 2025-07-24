const std = @import("std");
const fs = std.fs;
const print = std.debug.print;

pub fn main() !void {
    const allocator = std.heap.page_allocator;
    const content = @embedFile("./input.txt");
    print("--- DAY 1 ---\n", .{});
    print("Part One => {d}\n", .{try partOne(allocator, content)});
    print("Part Two => {d}\n", .{try partTwo(allocator, content)});
    print("\n\n", .{});
}

fn partOne(allocator: std.mem.Allocator, input: []const u8) !u32 {
    var alloc = std.heap.ArenaAllocator.init(allocator);
    defer alloc.deinit();

    var listA = std.ArrayList(i32).init(alloc.allocator());
    var listB = std.ArrayList(i32).init(alloc.allocator());

    var lines = std.mem.tokenizeScalar(u8, input, '\n');

    // construct two lists
    while (lines.next()) |line| {
        var nums = std.mem.tokenizeScalar(u8, line, ' ');
        try listA.append(try std.fmt.parseInt(i32, nums.next().?, 10));
        try listB.append(try std.fmt.parseInt(i32, nums.next().?, 10));
    }

    // sort lists
    std.mem.sort(i32, listA.items, void{}, comptime std.sort.asc(i32));
    std.mem.sort(i32, listB.items, void{}, comptime std.sort.asc(i32));

    var distance: u32 = 0;
    for (listA.items, listB.items) |a, b| {
        distance += @abs(a - b);
    }

    return distance;
}

fn partTwo(allocator: std.mem.Allocator, input: []const u8) !u32 {
    var alloc = std.heap.ArenaAllocator.init(allocator);
    defer alloc.deinit();

    var listA = std.ArrayList(i32).init(alloc.allocator());
    var listB = std.ArrayList(i32).init(alloc.allocator());

    var lines = std.mem.tokenizeScalar(u8, input, '\n');

    // construct two lists
    while (lines.next()) |line| {
        var nums = std.mem.tokenizeScalar(u8, line, ' ');
        try listA.append(try std.fmt.parseInt(i32, nums.next().?, 10));
        try listB.append(try std.fmt.parseInt(i32, nums.next().?, 10));
    }

    var frequencies: u32 = 0;
    for (listA.items) |a| {
        var count: i32 = 0;
        for (listB.items) |b| {
            if (a == b) {
                count += 1;
            }
        }
        frequencies += @abs(a * count);
    }

    return frequencies;
}
