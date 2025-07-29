const std = @import("std");

const INPUTFILE = "input.txt";
const WIDTH = 50;
const HEIGHT = 6;

// const INPUTFILE = "input_test.txt";
// const WIDTH = 7;
// const HEIGHT = 3;

pub fn main() !void {
    const file = try std.fs.cwd().openFile(INPUTFILE, .{});
    defer file.close();
    const page_allocator = std.heap.page_allocator;
    const file_size = try file.getEndPos();
    const input = try page_allocator.alloc(u8, file_size);
    _ = try file.readAll(input);

    var lines = std.mem.tokenizeScalar(u8, input, '\n');
    var monitor: [WIDTH][HEIGHT]bool = @splat(@splat(false));
    while (lines.next()) |line| {
        std.debug.print("line: {s}\n", .{line});
        var words = std.mem.tokenizeScalar(u8, line, ' ');
        const first = words.next().?;
        if (std.mem.eql(u8, first, "rect")) {
            const second = words.next().?;
            var diameters = std.mem.tokenizeScalar(u8, second, 'x');
            const width = try std.fmt.parseInt(usize, diameters.next().?, 10);
            const height = try std.fmt.parseInt(usize, diameters.next().?, 10);
            for (0..width) |x| {
                for (0..height) |y| {
                    monitor[x][y] = true;
                }
            }
        } else if (std.mem.eql(u8, first, "rotate")) {
            const second = words.next().?;
            if (std.mem.eql(u8, second, "row")) {
                const row_number = try std.fmt.parseInt(usize, words.next().?[2..], 10);
                _ = words.next().?;
                const amount = (try std.fmt.parseInt(usize, words.next().?, 10)) % WIDTH;
                var started_at: usize = 0;
                var x: usize = 0;
                var mem = monitor[0][row_number];
                for (0..WIDTH) |_| {
                    const next_x = (x + amount) % WIDTH;
                    const tmp = monitor[next_x][row_number];
                    monitor[next_x][row_number] = mem;
                    mem = tmp;
                    if (next_x == started_at) {
                        x = next_x + 1;
                        started_at = x;
                        mem = monitor[x][row_number];
                    } else {
                        x = next_x;
                    }
                }
            } else if (std.mem.eql(u8, second, "column")) {
                const column_number = try std.fmt.parseInt(usize, words.next().?[2..], 10);
                _ = words.next().?;
                const amount = (try std.fmt.parseInt(usize, words.next().?, 10)) % HEIGHT;
                var started_at: usize = 0;
                var x: usize = 0;
                var mem = monitor[column_number][0];
                for (0..HEIGHT) |_| {
                    const next_x = (x + amount) % HEIGHT;
                    const tmp = monitor[column_number][next_x];
                    monitor[column_number][next_x] = mem;
                    mem = tmp;
                    if (next_x == started_at) {
                        x = next_x + 1;
                        started_at = x;
                        mem = monitor[column_number][x];
                    } else {
                        x = next_x;
                    }
                }
            }
        }
        print_monitor(monitor);
    }
    std.debug.print("\n\n", .{});
    var count: u32 = 0;
    for (0..HEIGHT) |y| {
        for (0..WIDTH) |x| {
            count += if (monitor[x][y]) 1 else 0;
        }
    }
    std.debug.print("count: {}", .{count});
}

fn print_monitor(monitor: [WIDTH][HEIGHT]bool) void {
    std.debug.print("   ", .{});
    for (0..WIDTH) |x| {
        std.debug.print(" ", .{});
        if (x < 10) std.debug.print(" ", .{});
        std.debug.print("{}", .{x});
    }
    std.debug.print("\n", .{});
    for (0..HEIGHT) |y| {
        std.debug.print("{}: ", .{y});
        for (0..WIDTH) |x| {
            std.debug.print("  ", .{});
            const c: u8 = if (monitor[x][y]) '#' else '.';
            std.debug.print("{c}", .{c});
        }
        std.debug.print("\n", .{});
    }
}
