const std = @import("std");

pub fn main() !void {
    const file = try std.fs.cwd().openFile("input.txt", .{});
    defer file.close();
    const file_size = try file.getEndPos();
    const page_allocator = std.heap.page_allocator;
    const input: []u8 = try page_allocator.alloc(u8, file_size);
    defer page_allocator.free(input);
    _ = try file.readAll(input);
    var counts: [8][26]u32 = @splat(@splat(0));
    var lines = std.mem.tokenizeScalar(u8, input, '\n');
    while (lines.next()) |line| {
        for (line, 0..) |c, i| {
            counts[i][c - 'a'] += 1;
        }
    }
    var first_message: [8]u8 = undefined;
    for (counts, 0..) |p, i| {
        var max_c: u32 = 0;
        for (p, 0..) |c, j| {
            if (c > max_c) {
                first_message[i] = @intCast(j + 'a');
                max_c = c;
            }
        }
    }
    std.debug.print("first_message: {s}\n", .{first_message});

    var second_message: [8]u8 = undefined;
    for (counts, 0..) |p, i| {
        var min_c: u32 = std.math.maxInt(u32);
        for (p, 0..) |c, j| {
            if (c < min_c and c != 0) {
                second_message[i] = @intCast(j + 'a');
                min_c = c;
            }
        }
    }
    std.debug.print("second_message: {s}\n", .{second_message});
}
