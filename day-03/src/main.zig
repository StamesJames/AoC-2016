const std = @import("std");
const print = std.debug.print;

pub fn main() !void {
    const page_allocator = std.heap.page_allocator;
    const file = try std.fs.cwd().openFile("input.txt", .{});
    defer file.close();

    const file_size = try file.getEndPos();
    const input = try page_allocator.alloc(u8, file_size);

    _ = try file.readAll(input);

    print("first: {}\n", .{try first(input)});
    print("second: {}\n", .{try second(input)});
}

const columns = 3;
pub fn second(input: []u8) !u32 {
    var triangles: [columns]([3]u32) = .{ .{ undefined, undefined, undefined }, .{ undefined, undefined, undefined }, .{ undefined, undefined, undefined } };
    var lines = std.mem.tokenizeSequence(u8, input, "\n");
    var count: u32 = 0;
    while (lines.peek()) |line| {
        if (line.len < 1) continue;
        for (0..3) |i| {
            var sides = std.mem.tokenizeSequence(u8, lines.next().?, " ");
            for (0..columns) |j| {
                const side = try std.fmt.parseInt(u32, sides.next().?, 10);
                triangles[j][i] = side;
            }
        }
        for (0..columns) |i| {
            if (triangle_possible(triangles[i])) count += 1;
        }
    }
    return count;
}

pub fn first(input: []u8) !u32 {
    var lines = std.mem.tokenizeSequence(u8, input, "\n");
    var count: u32 = 0;
    while (lines.next()) |line| {
        if (line.len < 1) continue;
        var sides = std.mem.tokenizeSequence(u8, line, " ");
        const side_1 = try std.fmt.parseInt(u32, sides.next().?, 10);
        const side_2 = try std.fmt.parseInt(u32, sides.next().?, 10);
        const side_3 = try std.fmt.parseInt(u32, sides.next().?, 10);
        if (triangle_possible(.{ side_1, side_2, side_3 })) count += 1;
    }

    return count;
}

fn triangle_possible(sides: [3]u32) bool {
    return (sides[0] + sides[1] > sides[2] and
        sides[0] + sides[2] > sides[1] and
        sides[1] + sides[2] > sides[0]);
}
