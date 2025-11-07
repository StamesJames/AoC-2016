const std = @import("std");
const Allocator = std.mem.Allocator;
const ArrayList = std.ArrayList;

const BotQueue = std.DoublyLinkedList;
const BotQueueNode = struct {
    node: BotQueue.Node = .{},
    val: u32,
};
const Destination = union(enum) {
    bot: u32,
    output: u32,
};

const GiveInst = struct {
    low_dest: Destination,
    high_dest: Destination,
};

const Instruction = union(enum) {
    input: u32,
    give: GiveInst,
};

const Line = struct {
    bot: u32,
    inst: Instruction,
};

const input_file = "input.txt";
pub fn main() !void {
    const GPA = std.heap.GeneralPurposeAllocator(.{});
    var dpa = GPA.init;
    const gpa = GPA.allocator(&dpa);
    const input = try read_file(gpa, input_file);
    defer gpa.free(input);

    var lines = try parse_input(gpa, input);
    defer lines.deinit(gpa);

    const max_bot_num = find_highest_bot(lines.items) + 1;

    std.debug.print("{}", .{max_bot_num});
    var bots = try gpa.alloc([2]?u32, max_bot_num);
    var bot_instrs = try gpa.alloc(?GiveInst, max_bot_num);
    for (0..max_bot_num) |i| {
        bots[i][0] = null;
        bots[i][1] = null;
        bot_instrs[i] = null;
    }
    var bot_queue = BotQueue{};
    for (lines.items) |line| {
        switch (line.inst) {
            .give => |give| {
                if (bot_instrs[line.bot] == null) {
                    bot_instrs[line.bot] = give;
                } else {
                    std.debug.print("\n{any}\n", .{bot_instrs[line.bot]});
                    std.debug.print("\n{any}\n", .{give});
                    std.debug.print("\nbot {} got more then one give command\n", .{line.bot});
                    @panic("");
                }
            },
            .input => |x| {
                if (bots[line.bot][0] == null) {
                    bots[line.bot][0] = x;
                } else if (bots[line.bot][1] == null) {
                    bots[line.bot][1] = x;

                    var new_node = try gpa.create(BotQueueNode);
                    new_node.* = .{
                        .val = line.bot,
                    };
                    std.debug.print("\ninitial bot {}: {any}\n", .{ line.bot, bots[line.bot] });
                    bot_queue.append(&new_node.node);
                } else {
                    std.debug.print("bot {} got more then 2 vals", .{line.bot});
                    @panic("");
                }
            },
        }
    }
    std.debug.print("\n", .{});
    print_queue(bot_queue);
    var mul: u32 = 1;
    while (bot_queue.popFirst()) |next_node| {
        const queuenode: *BotQueueNode = @fieldParentPtr("node", next_node);
        defer gpa.destroy(queuenode);
        const next_bot = queuenode.*.val;

        const give_com = bot_instrs[next_bot].?;
        std.debug.print("\nBot {}: {any}\n", .{ next_bot, bots[next_bot] });
        std.debug.print("give: {any}\n", .{give_com});
        const low_val = @min(bots[next_bot][0].?, bots[next_bot][1].?);
        const high_val = @max(bots[next_bot][0].?, bots[next_bot][1].?);
        if (low_val == 17 and high_val == 61) {
            std.debug.print("BOT FOUND {}", .{next_bot});
        }
        switch (give_com.high_dest) {
            .bot => |bot_high| {
                if (bots[bot_high][0] == null) {
                    bots[bot_high][0] = high_val;
                } else if (bots[bot_high][1] == null) {
                    bots[bot_high][1] = high_val;
                    std.debug.print("queue hi bot {}: {any}\n", .{ bot_high, bots[bot_high] });
                    var new_node = try gpa.create(BotQueueNode);
                    new_node.* = .{
                        .val = bot_high,
                    };
                    bot_queue.append(&new_node.node);
                } else {
                    std.debug.print("bot {} got more then 2 vals", .{bot_high});
                    @panic("");
                }
            },
            .output => |output| {
                if (output >= 0 and output <= 2) mul *= high_val;
            },
        }
        switch (give_com.low_dest) {
            .bot => |bot_low| {
                if (bots[bot_low][0] == null) {
                    bots[bot_low][0] = low_val;
                } else if (bots[bot_low][1] == null) {
                    bots[bot_low][1] = low_val;
                    std.debug.print("queue lo bot {}: {any}\n", .{ bot_low, bots[bot_low] });
                    var new_node = try gpa.create(BotQueueNode);
                    new_node.* = .{
                        .val = bot_low,
                    };
                    bot_queue.append(&new_node.node);
                } else {
                    std.debug.print("bot {} got more then 2 vals", .{bot_low});
                    @panic("");
                }
            },
            .output => |output| {
                if (output >= 0 and output <= 2) mul *= low_val;
            },
        }
        bots[next_bot][0] = null;
        bots[next_bot][1] = null;

        std.debug.print("\n", .{});
        print_queue(bot_queue);
        std.debug.print("output val: {}", .{mul});
    }
}
fn print_queue(queue: BotQueue) void {
    var cur_node = queue.first;
    while (cur_node) |node| {
        const elem: *BotQueueNode = @fieldParentPtr("node", node);
        std.debug.print("{}, ", .{elem.val});
        cur_node = node.next;
    }
    std.debug.print("\n", .{});
}
fn find_highest_bot(lines: []Line) u32 {
    var highest: u32 = 0;
    for (lines) |line| {
        highest = @max(highest, line.bot);
        switch (line.inst) {
            .give => |give| {
                switch (give.low_dest) {
                    .bot => |bot| {
                        highest = @max(highest, bot);
                    },
                    else => {},
                }
                switch (give.high_dest) {
                    .bot => |bot| {
                        highest = @max(highest, bot);
                    },
                    else => {},
                }
            },
            else => {},
        }
    }
    return highest;
}

pub fn parse_input(allocator: Allocator, file_content: []const u8) !ArrayList(Line) {
    var lines = std.mem.tokenizeScalar(u8, file_content, '\n');
    const line_count = count_line_numbers(file_content);
    var line_insts = try std.ArrayList(Line).initCapacity(allocator, line_count);
    errdefer line_insts.deinit(allocator);
    var i: usize = 0;
    while (lines.next()) |line| : (i += 1) {
        if (line[0] == 'v') {
            try line_insts.append(allocator, try parse_value_get(line));
        } else {
            try line_insts.append(allocator, try parse_instruction(line));
        }
    }

    return line_insts;
}

fn count_line_numbers(content: []const u8) u32 {
    var count: u32 = 1;
    for (content) |c| {
        if (c == '\n') count += 1;
    }
    return count;
}

fn parse_value_get(line: []const u8) !Line {
    var words = std.mem.tokenizeScalar(u8, line, ' ');
    skip(&words, 1);
    const value = try std.fmt.parseInt(u32, words.next().?, 10);
    skip(&words, 3);
    const bot = try std.fmt.parseInt(u32, words.next().?, 10);
    return .{ .bot = bot, .inst = .{ .input = value } };
}

fn parse_instruction(line: []const u8) !Line {
    var words = std.mem.tokenizeScalar(u8, line, ' ');
    skip(&words, 1);
    const bot = try std.fmt.parseInt(u32, words.next().?, 10);
    skip(&words, 3);
    const low_dest_string = words.next().?;
    const low_dest_num = try std.fmt.parseInt(u32, words.next().?, 10);
    skip(&words, 3);
    const high_dest_string = words.next().?;
    const high_dest_num = try std.fmt.parseInt(u32, words.next().?, 10);

    var low_dest: Destination = undefined;
    var high_dest: Destination = undefined;

    if (std.mem.eql(u8, low_dest_string, "bot")) {
        low_dest = Destination{ .bot = low_dest_num };
    } else {
        low_dest = Destination{ .output = low_dest_num };
    }

    if (std.mem.eql(u8, high_dest_string, "bot")) {
        high_dest = Destination{ .bot = high_dest_num };
    } else {
        high_dest = Destination{ .output = high_dest_num };
    }

    return .{
        .bot = bot,
        .inst = .{
            .give = .{
                .low_dest = low_dest,
                .high_dest = high_dest,
            },
        },
    };
}

fn skip(iter: *std.mem.TokenIterator(u8, std.mem.DelimiterType.scalar), n: usize) void {
    for (0..n) |_| {
        _ = iter.next();
    }
}

pub fn read_file(allocator: Allocator, file_url: []const u8) ![]u8 {
    const file_desc = try std.fs.cwd().openFile(file_url, .{});
    defer file_desc.close();
    const file_size = try file_desc.getEndPos();
    const file_content: []u8 = try allocator.alloc(u8, file_size);
    _ = try file_desc.readAll(file_content);
    return file_content;
}
