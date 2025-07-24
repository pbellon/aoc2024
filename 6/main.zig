const std = @import("std");
const Allocator = std.mem.Allocator;

const print = std.debug.print;

const DirectionType = enum {
    north,
    east,
    south,
    west,
};

const Direction = struct {
    type: DirectionType,
    offset: i32,
};

const Positions = struct {
    list: []i32,
    loop: bool,
};

fn samePosition(a: [2]i32, b: [2]i32) bool {
    return a[0] == b[0] and a[1] == b[1];
}

fn hasLoop(positions: []i32) bool {
    if (positions.len < 8) return false;

    var it = std.mem.window(i32, positions, 4, 1);

    while (it.next()) |window| {
        if (std.mem.count(i32, positions, window) > 1) {
            return true;
        }
    }

    return false;
}

// map chars
const C_OBSTACLE: u8 = '#';
const C_GUARD: u8 = '^';

pub fn main() !void {
    const pa = std.heap.page_allocator;
    var arena = std.heap.ArenaAllocator.init(pa);

    const input = @embedFile("./input.txt");
    print("--- DAY 6 ---\n", .{});

    try partOne(arena.allocator(), input);
    try partTwo(arena.allocator(), input);
}

const Map = struct {
    input: []const u8,
    nb_cols: i32,

    // Directions
    NORTH: Direction,
    EAST: Direction,
    SOUTH: Direction,
    WEST: Direction,

    const Self = @This();

    fn init(input: []const u8) !Self {
        const nb_cols_u = std.mem.indexOf(u8, input, "\n") orelse return error.MalformedInput;
        const nb_cols: i32 = @intCast(nb_cols_u + 1);

        print("Number of cols => {d}\n", .{nb_cols});

        return Self{ .input = input, .nb_cols = nb_cols, .NORTH = Direction{
            .type = .north,
            .offset = -nb_cols,
        }, .EAST = Direction{
            .type = .east,
            .offset = 1,
        }, .SOUTH = Direction{
            .type = .south,
            .offset = nb_cols,
        }, .WEST = Direction{
            .type = .west,
            .offset = -1,
        } };
    }

    fn nextDirection(self: *Self, dir: Direction) Direction {
        return switch (dir.type) {
            .north => self.EAST,
            .east => self.SOUTH,
            .south => self.WEST,
            .west => self.NORTH,
        };
    }

    fn findGuardPosition(self: *Self) !usize {
        for (self.input, 0..) |char, i| {
            if (char == C_GUARD) {
                return i;
            }
        }

        return error.GuardNotFound;
    }

    fn charAt(self: *Self, pos: i32) ?u8 {
        // stop condition => outside of the map
        if (pos < 0 or pos >= self.input.len or pos == self.nb_cols) {
            return null;
        }

        return self.input[@intCast(pos)];
    }

    fn computeAllPossiblePositions(self: *Self, allocator: Allocator) ![]i32 {
        var positions = std.AutoArrayHashMap(i32, void).init(allocator);
        var guard_pos: i32 = @intCast(try self.findGuardPosition());

        try positions.put(guard_pos, {});

        var current_direction = self.NORTH;
        // find initial guard's position

        while (true) {
            const next_pos = guard_pos + current_direction.offset;
            // if next_char is null this mean we're out of the map and can break
            const next_char = self.charAt(next_pos) orelse break;

            // if guard where to encounter an obstacle, change direction
            if (next_char == C_OBSTACLE) {
                current_direction = self.nextDirection(current_direction);
            } else {
                guard_pos = next_pos;
                try positions.put(next_pos, {});
            }
        }

        return positions.keys();
    }

    fn isLoopingWithObstacle(self: *Self, allocator: Allocator, virtual_obstacle: i32) !bool {
        var all_pos_before_obstacles = std.ArrayList(i32).init(allocator);

        var guard_pos: i32 = @intCast(try self.findGuardPosition());
        var current_direction = self.NORTH;

        // find initial guard's position
        while (true) {
            const next_pos = guard_pos + current_direction.offset;
            // if next_char is null this mean we're out of the map and can break
            const next_char = self.charAt(next_pos) orelse return false;

            // if guard where to encounter an obstacle, change direction
            if (next_char == C_OBSTACLE or next_pos == virtual_obstacle) {
                try all_pos_before_obstacles.append(guard_pos);
                current_direction = self.nextDirection(current_direction);
            } else {
                guard_pos = next_pos;
            }

            if (hasLoop(all_pos_before_obstacles.items)) {
                return true;
            }
        }

        return false;
    }
};

// Good answer:
// Guard found at 91-90
// Part One
//      Total number of positions before exiting the map => 5516
fn partOne(allocator: Allocator, input: []const u8) !void {
    var map = try Map.init(input);

    const positions = try map.computeAllPossiblePositions(allocator);

    print("Part One\n\tTotal number of positions before exiting the map => {d}\n\n", .{positions.len});
}

// we need to detect all possible loops, first intuition:
// - start by retrieving all possible guard positions,
// - for each position try to put a virtual obstacle, try detecting if it produces
//   a loop
fn partTwo(allocator: Allocator, input: []const u8) !void {
    var map = try Map.init(input);
    const positions = try map.computeAllPossiblePositions(allocator);

    var loops: u32 = 0;

    // Note: this works bit is hell of slow (multiple seconds)
    for (positions) |pos| {
        const do_loop = try map.isLoopingWithObstacle(allocator, pos);
        if (do_loop) {
            loops += 1;
        }
    }

    print("Part Two\n\tNumber of possible positions for loops => {d}\n\n", .{loops});
}
