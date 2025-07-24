const std = @import("std");

const print = std.debug.print;

// EXPECTED OUTPUT:
// $ zig run zig/aoc2024/2.zig
// TASK 1: 224 safe reports
// TASK 2: 293 safe reports
pub fn main() !void {
    const pa = std.heap.page_allocator;
    var arena = std.heap.ArenaAllocator.init(pa);
    defer arena.deinit();

    const input = @embedFile("./input.txt");
    print("--- DAY 2 ---\n", .{});
    print("Part One: {d} safe reports\n", .{try partOne(arena.allocator(), input)});
    print("Part Two: {d} safe reports\n", .{try partTwo(arena.allocator(), input)});
    print("\n\n", .{});
}

fn is_safe(items: []const i32) bool {
    var previous_diff: i32 = undefined;
    const end = items.len - 1;

    for (items[0..end], 0..end) |current, i| {
        const next = items[i + 1];

        const current_diff = current - next;
        const abs_diff = @abs(current_diff);

        // if diff with next elem is 0 (which means equality) or greater than 3
        // then we can consider can consider the report as unsafe
        if (!(abs_diff > 0 and abs_diff <= 3)) {
            return false;
        }

        // otherwise we will check that all reports are effectively sorted in consisten
        // order by checking that current diff has the same sign as previous diff
        if (i > 0 and std.math.sign(current_diff) != std.math.sign(previous_diff)) {
            return false;
        }
        // then we skip to next element
        previous_diff = current_diff;
    }

    // only if we didn't detected unsafe report we can assume it's a safe report
    return true;
}

fn parse_report(allocator: std.mem.Allocator, line: []const u8) !std.ArrayList(i32) {
    var report = std.ArrayList(i32).init(allocator);
    var tokens = std.mem.tokenizeScalar(u8, line, ' ');

    while (tokens.next()) |token| {
        try report.append(try std.fmt.parseInt(i32, token, 10));
    }

    return report;
}

fn partOne(allocator: std.mem.Allocator, input: []const u8) !u32 {
    var lines = std.mem.tokenizeScalar(u8, input, '\n');

    var safe_reports: u32 = 0;

    while (lines.next()) |line| {
        const report = try parse_report(allocator, line);

        if (is_safe(report.items)) {
            // print("Considered this as a safe report {s}\n", .{line});
            safe_reports += 1;
        }
    }

    return safe_reports;
}

fn partTwo(allocator: std.mem.Allocator, input: []const u8) !u32 {
    var lines = std.mem.tokenizeScalar(u8, input, '\n');

    var safe_reports: u32 = 0;

    while (lines.next()) |line| {
        const report = try parse_report(allocator, line);

        if (is_safe(report.items)) {
            safe_reports += 1;
        } else {
            // try every combination of report with a given n-th element, if one valid combination if
            // found we can assume it's a safe report
            for (report.items, 0..) |_, i| {
                var copy = try report.clone();
                defer copy.deinit();
                _ = copy.orderedRemove(i);

                if (is_safe(copy.items)) {
                    safe_reports += 1;
                    break;
                }
            }
        }
    }

    return safe_reports;
}
