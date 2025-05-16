const std = @import("std");

pub fn main() !void {
    const file = try std.fs.cwd().openFile("input.txt", .{});
    defer file.close();
    const file_size = try file.getEndPos();
    const page_allocator = std.heap.page_allocator;
    const input: []u8 = try page_allocator.alloc(u8, file_size);
    defer page_allocator.free(input);
    _ = try file.readAll(input);
    first(input);
    second(input);
}

const print = std.debug.print;

pub fn second(input: []u8) void {
    const numpad: [5]([5]?u8) = .{ .{ null, null, '5', null, null }, .{ null, '2', '6', 'A', null }, .{ '1', '3', '7', 'B', 'D' }, .{ null, '4', '8', 'C', null }, .{ null, null, '9', null, null } };
    var pos_x: usize = 0;
    var pos_y: usize = 2;
    var lines = std.mem.splitSequence(u8, input, "\n");
    while (lines.next()) |line| {
        if (line.len < 1) continue;
        for (line) |char| {
            // print("{c}@({d}, {d})", .{ numpad[pos_x][pos_y].?, pos_x, pos_y });
            switch (char) {
                'L' => if (pos_x > 0 and numpad[pos_x - 1][pos_y] != null) {
                    // print(" <- ", .{});
                    pos_x -= 1;
                },
                'R' => if (pos_x < 4 and numpad[pos_x + 1][pos_y] != null) {
                    // print(" -> ", .{});
                    pos_x += 1;
                },
                'U' => if (pos_y > 0 and numpad[pos_x][pos_y - 1] != null) {
                    // print(" ^ ", .{});
                    pos_y -= 1;
                },
                'D' => if (pos_y < 4 and numpad[pos_x][pos_y + 1] != null) {
                    // print(" v ", .{});
                    pos_y += 1;
                },
                else => unreachable,
            }
        }
        std.debug.print("{c}@({}, {})\n{c} pressed\n", .{ numpad[pos_x][pos_y].?, pos_x, pos_y, numpad[pos_x][pos_y].? });
    }
    std.debug.print("\n", .{});
}

pub fn first(input: []u8) void {
    const numpad: [3]([3]u8) = .{ .{ 1, 4, 7 }, .{ 2, 5, 8 }, .{ 3, 6, 9 } };
    var pos_x: usize = 1;
    var pos_y: usize = 1;
    var lines = std.mem.splitSequence(u8, input, "\n");
    while (lines.next()) |line| {
        if (line.len < 1) continue;
        for (line) |char| {
            switch (char) {
                'L' => if (pos_x > 0) {
                    pos_x -= 1;
                },
                'R' => if (pos_x < 2) {
                    pos_x += 1;
                },
                'U' => if (pos_y > 0) {
                    pos_y -= 1;
                },
                'D' => if (pos_y < 2) {
                    pos_y += 1;
                },
                else => unreachable,
            }
        }
        std.debug.print("{d}", .{numpad[pos_x][pos_y]});
    }
    std.debug.print("\n", .{});
}
