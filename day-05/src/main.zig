const std = @import("std");
const md5 = std.crypto.hash.Md5;
const input = "ffykfhsq";

pub fn main() !void {
    // try first();
    try second();
}
fn second() !void {
    var md5_hash: [16]u8 = undefined;
    const page_allocator = std.heap.page_allocator;
    var pasword: [8]?u8 = @splat(null);
    var count: u8 = 0;
    for (0..100_000_000) |i| {
        const concat_str = try std.fmt.allocPrint(page_allocator, "{s}{}", .{ input, i });
        defer page_allocator.free(concat_str);
        md5.hash(concat_str, &md5_hash, .{});
        if (md5_hash[0] == 0 and md5_hash[1] == 0 and md5_hash[2] < 8 and pasword[md5_hash[2]] == null) {
            std.debug.print("{s} hash: ", .{
                concat_str,
            });
            for (md5_hash) |b| {
                std.debug.print("{x:0>2}", .{b});
            }
            std.debug.print("\n", .{});
            const byte_shifted = md5_hash[3] >> 4;
            pasword[md5_hash[2]] = byte_shifted;
            std.debug.print("i: {d} char: {x:0>2}\n", .{ md5_hash[2], byte_shifted });
            count += 1;
            if (count >= 8) {
                break;
            }
        }
    }
    for (pasword) |p| {
        std.debug.print("{?x}", .{p});
    }
}
fn first() !void {
    var md5_hash: [16]u8 = undefined;
    const page_allocator = std.heap.page_allocator;
    var count: u8 = 0;
    for (0..10_000_000) |i| {
        const concat_str = try std.fmt.allocPrint(page_allocator, "{s}{}", .{ input, i });
        defer page_allocator.free(concat_str);
        md5.hash(concat_str, &md5_hash, .{});
        if (md5_hash[0] == 0 and md5_hash[1] == 0 and md5_hash[2] <= 1 + 2 + 4 + 8) {
            std.debug.print("{s} hash: ", .{
                concat_str,
            });
            for (md5_hash) |b| {
                std.debug.print("{x:0>2}", .{b});
            }
            std.debug.print("\n", .{});
            count += 1;
            if (count >= 8) {
                break;
            }
        }
    }
}
