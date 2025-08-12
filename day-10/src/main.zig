const std = @import("std");
const BotQueue = std.SinglyLinkedList;

const Destination = union(enum) {
    bot: u32,
    output: u32,
};

const Instruction = struct {
    source: u32,
    low_dest: Destination,
    high_dest: Destination,
};

const input_file = "input.txt";
pub fn main() !void {
    const file = try std.fs.cwd().openFile(input_file, .{});
    const file_size = try file.getEndPos();
    var page_alloc = std.heap.page_allocator;
    const input: []u8 = try page_alloc.alloc(u8, file_size);
    _ = try file.readAll(input);
    const max_bot_num = try find_highest_bot(input) + 1;
    std.debug.print("{}", .{max_bot_num});
    var bots = try page_alloc.alloc([2]?u32, max_bot_num);
    for (0..bots.len) |i| {
        bots[i][0] = null;
        bots[i][1] = null;
    }
    var bot_instructions = try page_alloc.alloc(?Instruction, max_bot_num);
    for (0..bot_instructions.len) |i| {
        bot_instructions[i] = null;
    }
    var bot_queue: BotQueue = .{};
    var lines = std.mem.tokenizeScalar(u8, input, '\n');
    while (lines.next()) |line| {
        if (line[0] == 'v') {
            const value_get = try parse_value_get(line);
            if (bots[value_get.bot][0] == null) {
                bots[value_get.bot][0] = value_get.value;
            } else if (bots[value_get.bot][1] == null) {
                bots[value_get.bot][1] = value_get.value;
                const bot = .{ .bot = value_get.bot, .node = .{} };
                bot_queue.prepend();
            } else {
                std.debug.print("Bot {} got more then two value\n ", .{value_get.bot});
            }
        } else if (line[0] == 'b') {
            const instruction = try parse_instruction(line);
            if (bot_instructions[instruction.source] == null) {
                bot_instructions[instruction.source] = instruction;
            } else {
                std.debug.print("bot {} got more then one instruction\n", .{instruction.source});
            }
        }
    }
    while (bot_queue.popFirst) |next_bot| {
        std.debug.print("next: {}", .{next_bot});
    }
}

fn parse_value_get(line: []const u8) !struct { value: u32, bot: u32 } {
    var words = std.mem.tokenizeScalar(u8, line, ' ');
    skip(&words, 1);
    const value = try std.fmt.parseInt(u32, words.next().?, 10);
    skip(&words, 3);
    const bot = try std.fmt.parseInt(u32, words.next().?, 10);
    return .{ .value = value, .bot = bot };
}

fn parse_instruction(line: []const u8) !Instruction {
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

    return Instruction{ .source = bot, .low_dest = low_dest, .high_dest = high_dest };
}

fn find_highest_bot(input: []u8) !u32 {
    var max: u32 = 0;
    var lines = std.mem.tokenizeScalar(u8, input, '\n');
    while (lines.next()) |line| {
        var words = std.mem.tokenizeScalar(u8, line, ' ');
        if (line[0] == 'v') {
            skip(&words, 5);
            const bot_num: u32 = try std.fmt.parseInt(u32, words.next().?, 10);
            max = if (max > bot_num) max else bot_num;
        }
        if (line[0] == 'b') {
            skip(&words, 1);
            const bot_num: u32 = try std.fmt.parseInt(u32, words.next().?, 10);
            max = if (max > bot_num) max else bot_num;
            skip(&words, 3);
            if (std.mem.eql(u8, words.next().?, "bot")) {
                const bot_num_1: u32 = try std.fmt.parseInt(u32, words.next().?, 10);
                max = if (max > bot_num_1) max else bot_num_1;
            }
            skip(&words, 3);
            if (std.mem.eql(u8, words.next().?, "bot")) {
                const bot_num_1: u32 = try std.fmt.parseInt(u32, words.next().?, 10);
                max = if (max > bot_num_1) max else bot_num_1;
            }
        }
    }
    return max;
}

fn skip(iter: *std.mem.TokenIterator(u8, std.mem.DelimiterType.scalar), n: usize) void {
    for (0..n) |_| {
        _ = iter.next();
    }
}
