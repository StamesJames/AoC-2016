const std = @import("std");

pub fn main() !void {
    const file = try std.fs.cwd().openFile("input.txt", .{});
    defer file.close();
    const page_allocator = std.heap.page_allocator;
    const file_size = try file.getEndPos();
    const input: []u8 = try page_allocator.alloc(u8, file_size);
    defer page_allocator.free(input);
    _ = try file.readAll(input);

    // try first(input);
    try second(input);
}

pub fn second(input: []u8) !void {
    var lines = std.mem.tokenizeScalar(u8, input, '\n');
    var count: u32 = 0;
    while (lines.next()) |line| {
        var abas: [26][26]bool = @splat(@splat(false));
        var babs: [26][26]bool = @splat(@splat(false));
        var in_brackets = false;
        var found = false;
        for (0..line.len - 2) |i| {
            const ci = line[i];
            const cii = line[i + 1];
            if (ci == '[') in_brackets = true;
            if (ci == ']') in_brackets = false;

            if (ci == line[i + 2] and ci != cii and ci != '[' and ci != ']' and cii != '[' and cii != ']') {
                if (in_brackets) {
                    if (abas[cii - 'a'][ci - 'a'] == true) {
                        found = true;
                        break;
                    }
                    babs[ci - 'a'][cii - 'a'] = true;
                } else {
                    if (babs[cii - 'a'][ci - 'a'] == true) {
                        found = true;
                        break;
                    }
                    abas[ci - 'a'][cii - 'a'] = true;
                }
            }
        }
        if (found) {
            std.debug.print("ABA {s}\n", .{line});
            count += 1;
        } else {
            std.debug.print("Not ABA {s}\n", .{line});
        }
    }
    std.debug.print("counts: {}\n", .{count});
}
pub fn first(input: []u8) !void {
    var lines = std.mem.tokenizeScalar(u8, input, '\n');
    var count: u32 = 0;
    outer: while (lines.next()) |line| {
        var abba_found = false;
        var in_brackets = false;
        for (0..line.len - 3) |i| {
            if (line[i] == '[') in_brackets = true;
            if (line[i] == ']') in_brackets = false;

            if (line[i] == line[i + 3] and line[i + 1] == line[i + 2] and line[i] != line[i + 1]) {
                if (in_brackets) {
                    std.debug.print("Not TLS becuase [] {s}\n", .{line});
                    continue :outer;
                } else {
                    abba_found = true;
                }
            }
        }
        if (abba_found) {
            std.debug.print("TLS {s}\n", .{line});
            count += 1;
        } else {
            std.debug.print("Not TLS no abba {s}\n", .{line});
        }
    }
    std.debug.print("counts: {}\n", .{count});
}
