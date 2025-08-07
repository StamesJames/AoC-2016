const std = @import("std");

const INPUT = "input.txt";

pub fn main() !void {
    const file = try std.fs.cwd().openFile(INPUT, .{});
    defer file.close();
    const file_size = try file.getEndPos();
    const page_allocator = std.heap.page_allocator;
    const input = try page_allocator.alloc(u8, file_size);
    defer page_allocator.free(input);
    _ = try file.readAll(input);

    // const input = "ADVENT"; // correct 6
    // const input = "A(1x5)BC"; // correct 7
    // const input = "(3x3)XYZ"; // correct 9
    // const input = "A(2x2)BCD(2x2)EFG"; // correct 11
    // const input = "(6x1)(1x3)A"; // correct 6
    // const input = "X(8x2)(3x3)ABCY"; // correct 18
    // first_star(input);

    // const input = "(3x3)XYZ"; // correct 9
    // const input = "X(8x2)(3x3)ABCY"; // correct 20
    // const input = "(27x12)(20x12)(13x14)(7x10)(1x12)A"; // correct 241920
    // const input = "(25x3)(3x3)ABC(2x3)XY(5x2)PQRSTX(18x9)(3x2)TWO(5x7)SEVEN"; // correct 445
    _ = try second_star(input);
}

const Mark = struct { first: u32, second: u32, length: usize };

fn second_star(input: []const u8) !void {
    var count: u64 = 0;
    var i: usize = 0;
    while (i < input.len) {
        const c = input[i];
        switch (c) {
            ' ', '\n' => {},
            '(' => {
                const mark = try scan_mark(input[i..]);
                i += mark.length;
                const mark_calc = try calc_next_mark(mark, input[i..]);
                count += mark_calc;
                i += mark.first - 1;
                std.debug.print("i: {}\n", .{i});
            },
            else => {
                count += 1;
                std.debug.print("counted {c}\n", .{c});
            },
        }
        i += 1;
    }
    std.debug.print("{}", .{count});
}

fn calc_next_mark(mark: Mark, input: []const u8) !u64 {
    var i: usize = 0;
    var count: u64 = 0;
    while (i < mark.first) {
        const c = input[i];
        switch (c) {
            ' ', '\n' => {},
            '(' => {
                const next_mark = try scan_mark(input[i..]);
                if (i + next_mark.length < mark.first) {
                    i += next_mark.length;
                    const next_calc = try calc_next_mark(next_mark, input[i..]);
                    count += next_calc;
                    i += next_mark.first - 1;
                }
            },
            else => {
                count += 1;
                std.debug.print("counted {c}\n", .{c});
            },
        }
        i += 1;
    }
    count *= mark.second;
    return count;
}
fn scan_mark(input: []const u8) !Mark {
    var i: usize = 1;
    const start_first = i;
    while (i < input.len and input[i] != 'x') i += 1;
    const end_first = i;
    i += 1;
    const start_second = i;
    while (i < input.len and input[i] != ')') i += 1;
    const end_second = i;
    const first = try std.fmt.parseInt(u32, input[start_first..end_first], 10);
    const second = try std.fmt.parseInt(u32, input[start_second..end_second], 10);
    const length = i + 1;
    std.debug.print("found mark: {s}\n", .{input[0..length]});
    return Mark{ .first = first, .second = second, .length = length };
}

fn first_star(input: []u8) void {
    var count: u32 = 0;
    var i: usize = 0;
    while (i < input.len) {
        const c = input[i];
        switch (c) {
            ' ', '\n' => {},
            '(' => {
                i += 1;
                const start_first = i;
                while (i < input.len and input[i] != 'x') i += 1;
                const end_first = i;
                i += 1;
                const start_second = i;
                while (i < input.len and input[i] != ')') i += 1;
                const end_second = i;
                const first = try std.fmt.parseInt(u32, input[start_first..end_first], 10);
                const second = try std.fmt.parseInt(u32, input[start_second..end_second], 10);
                count += first * second;
                i += first;
            },
            else => count += 1,
        }
        i += 1;
    }
    std.debug.print("{}", .{count});
}
