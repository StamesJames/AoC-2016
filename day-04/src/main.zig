const std = @import("std");

pub fn main() !void {
    const file = try std.fs.cwd().openFile("input.txt", .{});
    defer file.close();
    const file_size = try file.getEndPos();
    const page_allocator = std.heap.page_allocator;
    const input: []u8 = try page_allocator.alloc(u8, file_size);
    defer page_allocator.free(input);
    _ = try file.readAll(input);
    try first(input);
}

pub fn first(input: []u8) !void {
    var lines = std.mem.tokenizeSequence(u8, input, "\n");
    var sum: i32 = 0;
    outer: while (lines.next()) |line| {
        // std.debug.print("line: {s}\n", .{line});
        var letter_count: [26]u32 = @splat(0);
        const start_id: usize = std.mem.indexOfAny(u8, line, "0123456789").?;
        const start_checksum: usize = std.mem.indexOf(u8, line, "[").?;
        const checksum: []const u8 = line[start_checksum + 1 .. (line.len - 1)];
        var letters = std.mem.tokenizeSequence(u8, line[0..start_id], "-");
        while (letters.next()) |pack| {
            for (pack) |letter| {
                letter_count[letter - 'a'] += 1;
            }
        }
        var bigest_five: [5]u8 = @splat(0);
        for (0..5) |i| {
            var max_i: u8 = 0;
            for (0..26) |j| {
                if (letter_count[j] > letter_count[max_i]) {
                    max_i = @intCast(j);
                }
            }
            bigest_five[i] = max_i;
            letter_count[max_i] = 0;
        }
        // std.debug.print("big five: ", .{});
        // for (bigest_five) |c| {
        //     std.debug.print("{c}", .{c + 'a'});
        // }
        // std.debug.print("\n", .{});

        for (checksum, 0..) |c, i| {
            if (c - 'a' != bigest_five[i]) {
                // std.debug.print("DECOY\n\n", .{});
                continue :outer;
            }
        }
        // std.debug.print("REAL:\n", .{});
        const id = try std.fmt.parseInt(i32, line[start_id..start_checksum], 10);
        sum += id;
        const shif_index = @mod(id, 26);
        var packs = std.mem.tokenizeSequence(u8, line[0..start_id], "-");
        const page_allocator = std.heap.page_allocator;
        while (packs.next()) |pack| {
            var decrypted: []u8 = try page_allocator.alloc(u8, pack.len);
            defer page_allocator.free(decrypted);
            for (pack, 0..) |c, i| {
                const shifted: u8 = @intCast(@mod(c - 'a' + shif_index, 26) + 'a');
                decrypted[i] = shifted;
                // std.debug.print("{c}", .{shifted});
            }

            if (std.mem.eql(u8, decrypted, "northpole") or std.mem.eql(u8, decrypted, "object") or std.mem.eql(u8, decrypted, "storage")) {
                std.debug.print("\n", .{});
                std.debug.print("FOUND:\n", .{});
                std.debug.print("{s}", .{line});
                std.debug.print("\n", .{});
            }
            std.debug.print("{s}", .{decrypted});
            std.debug.print(" ", .{});
        }
        std.debug.print("\n", .{});
    }
    // std.debug.print("endsum: {}\n", .{sum});
}
