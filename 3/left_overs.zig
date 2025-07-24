const std = @import("std");

// Original implementation using while + std.mem.indexOf
// seems to be equally performant with window iterator + std.mem.sliceTo
fn list_mul_pairs_using_indexOf(alloc: std.mem.Allocator, input: []const u8, with_instructions: bool) !std.ArrayList(MulPair) {
    var enabled = true;
    var res = std.ArrayList(MulPair).init(alloc);

    const mul_op_str = "mul(";

    // process line by line
    var tokens = std.mem.tokenizeScalar(u8, input, '\n');
    while (tokens.next()) |line| {
        var i: usize = 0;

        while (i < line.len) {
            if (with_instructions) {
                if (!enabled) {
                    const do_idx_maybe = std.mem.indexOf(u8, line[i..], "do()");
                    if (do_idx_maybe) |do_idx| {
                        enabled = true;
                        i = i + do_idx + 4;
                        continue;
                    }
                }
            }

            // look in the whole line
            const mul_haystack = line[i..];
            // next pos of `mul(`, restricted to i + max possible len
            const mul_idx_maybe = std.mem.indexOf(u8, mul_haystack, mul_op_str);

            if (mul_idx_maybe) |mul_idx| {
                // will check if we should skip some mul instructions
                if (with_instructions and enabled) {
                    const dont_idx_maybe = std.mem.indexOf(u8, line[i..], "don't()");
                    if (dont_idx_maybe) |dont_idx| {
                        if (dont_idx < mul_idx) {
                            enabled = false;
                            i = i + dont_idx + 7;
                            continue;
                        }
                    }
                }

                if (!enabled) {
                    i = i + mul_idx + 1;
                    continue;
                }

                const min_idx_comma = i + mul_idx + mul_op_str.len;
                const max_idx_for_comma = min_idx_comma + 5; // because of max 3 char digits

                if (min_idx_comma >= line.len - 1 or max_idx_for_comma >= line.len - 1) break; // reached end of line
                const comma_haystack = line[min_idx_comma..max_idx_for_comma];

                const comma_idx_maybe = std.mem.indexOf(u8, comma_haystack, ",");

                // if we found a comma then we'll try to lookup for `)`
                if (comma_idx_maybe) |comma_idx| {
                    // print("(i => {d}) - Found `,` at {d} in \"{s}\"\n", .{ i, comma_idx, comma_haystack });

                    const min_idx_close_par = min_idx_comma;
                    const max_idx_close_par = min_idx_close_par + 8;
                    const par_haystack = line[min_idx_comma..max_idx_close_par];
                    const close_par_idx_maybe = std.mem.indexOf(u8, par_haystack, ")");
                    if (close_par_idx_maybe) |close_par_idx| {
                        // in this case we found `mul(`, `,` and `)`, all good, but we need to try
                        // parsing 2 valid integers in order to have a valid pairs

                        const start_first_int_idx = min_idx_comma;
                        const end_first_int_idx = min_idx_comma + comma_idx;
                        const first_int_str = line[start_first_int_idx..end_first_int_idx];

                        const first_int = std.fmt.parseInt(i32, first_int_str, 10) catch {
                            // no valid first int, incr i and go on
                            i += min_idx_comma + close_par_idx + 1;
                            print("Could not parse valid first int in {s}, start => {d}, end => {d}\n", .{ first_int_str, start_first_int_idx, end_first_int_idx });
                            continue;
                        };

                        const start_second_int_idx = min_idx_comma + comma_idx + 1;
                        const end_second_int_idx = min_idx_comma + close_par_idx;
                        const second_int_str = line[start_second_int_idx..end_second_int_idx];

                        const second_int = std.fmt.parseInt(i32, second_int_str, 10) catch {
                            i += min_idx_comma + close_par_idx + 1;
                            print("Could not parse valid second int in {s}, start => {d}, end => {d}\n", .{ second_int_str, start_second_int_idx, end_second_int_idx });
                            continue;
                        };

                        // at this point we have two valid it, we can then construct proper MulPair
                        // and go on in the line
                        try res.append(MulPair{ .a = first_int, .b = second_int });

                        i = min_idx_comma + close_par_idx + 1;
                        continue;
                    } else {
                        i = max_idx_close_par;
                        continue;
                    }
                } else {
                    // in this case we found a `mul(` without `,` so we incr `i` after found `mul(`
                    i = min_idx_comma;
                    continue;
                }
            } else {
                // if we found no `mul(` in the whole line we can assume we're done handling the line and go on
                break;
            }

            i += 1;
        }
    }

    return res;
}
