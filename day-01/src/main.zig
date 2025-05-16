const std = @import("std");
pub fn main() !void {
    const page_allocator = std.heap.page_allocator;
    const file = try std.fs.cwd().openFile("input.txt", .{});
    defer file.close();

    const file_size = try file.getEndPos();
    const buffer: []u8 = try page_allocator.alloc(u8, file_size);
    defer page_allocator.free(buffer);

    const bytes_read = try file.readAll(buffer);
    std.debug.print("{}\n", .{bytes_read});

    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const arena_allocator = arena.allocator();

    var set = std.AutoHashMap(@Vector(2, i32), struct {}).init(arena_allocator);
    defer set.deinit();
    var position: @Vector(2, i32) = .{ 0, 0 };
    try set.put(position, .{});

    var direction: @Vector(2, i32) = .{ 1, 0 };
    var it = std.mem.tokenizeSequence(u8, buffer, ", ");
    var found = false;
    while (it.next()) |instruction| {
        // std.debug.print("rot_dir: {c}\n", .{instruction[0]});
        const trimed = std.mem.trim(u8, instruction[1..], "\r\n ");
        // std.debug.print("amount: {s}\n", .{trimed});
        const rot_dir = instruction[0];
        const amount = try std.fmt.parseInt(usize, trimed, 10);
        switch (rot_dir) {
            'L' => direction = rotate_left(direction),
            'R' => direction = rotate_right(direction),
            else => unreachable,
        }

        for (0..amount) |_| {
            position += direction;
            if (!found and set.contains(position)) {
                std.debug.print("found: {}, {} with dist: {}\n", .{ position[0], position[1], @abs(position[0]) + @abs(position[1]) });
                found = true;
            }
            try set.put(position, .{});
        }
    }
    std.debug.print("end position: {}, {}\n", .{ position[0], position[1] });
    std.debug.print("dist: {}", .{@abs(position[0]) + @abs(position[1])});
}

fn rotate_left(vec: @Vector(2, i32)) @Vector(2, i32) {
    return .{ -vec[1], vec[0] };
}
fn rotate_right(vec: @Vector(2, i32)) @Vector(2, i32) {
    return .{ vec[1], -vec[0] };
}
