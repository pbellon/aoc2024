const d1 = @import("./1/main.zig");
const d2 = @import("./2/main.zig");
const d3 = @import("./3/main.zig");
const d4 = @import("./4/main.zig");
const d5 = @import("./5/main.zig");
const d6 = @import("./6/main.zig");
const d7 = @import("./7/main.zig");

pub fn main() !void {
    try d1.main();
    try d2.main();
    try d3.main();
    try d4.main();
    try d5.main();
    try d6.main();
    try d7.main();
}
