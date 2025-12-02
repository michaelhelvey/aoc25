const std = @import("std");

const ParseResult = struct {
    start: usize,
    end: usize,
};

fn parseRange(raw: []const u8) !ParseResult {
    const trimmed_range = std.mem.trim(u8, raw, &[_]u8{'\n'});

    var range_reader = std.io.Reader.fixed(trimmed_range);
    const first_num_s = try range_reader.takeDelimiter('-');
    const second_num_s = range_reader.buffer[first_num_s.?.len + 1 ..];

    const first_num = try std.fmt.parseInt(usize, first_num_s.?, 10);
    const second_num = try std.fmt.parseInt(usize, second_num_s, 10);

    return .{ .start = first_num, .end = second_num };
}

fn part1() !void {
    const file = try std.fs.cwd().openFile("./data/day2.txt", .{});
    defer file.close();

    var buf: [4096]u8 = undefined;
    var reader = file.reader(&buf);
    // i'm sure zig has a way to create an array out of a buffer but I'm too fucking lazy to look it up
    var invalid_ids: [1024]usize = undefined;
    var invalid_cursor: usize = 0;

    while (true) {
        const range = try reader.interface.takeDelimiter(',') orelse break;
        const parsed = try parseRange(range);

        var print_buf: [128]u8 = undefined;

        var i = parsed.start;
        while (i <= parsed.end) : (i += 1) {
            const str = try std.fmt.bufPrint(&print_buf, "{d}", .{i});
            if (@mod(str.len, 2) != 0) continue;
            const first_part = str[0 .. str.len / 2];
            const second_part = str[str.len / 2 ..];
            if (std.mem.eql(u8, first_part, second_part)) {
                invalid_ids[invalid_cursor] = i;
                invalid_cursor += 1;
            }
        }
    }

    var h: usize = 0;
    var r: usize = 0;
    while (h < invalid_cursor) : (h += 1) {
        r += invalid_ids[h];
    }

    std.debug.print("part 1 answer: {d}\n", .{r});
}

fn isRepeatedSubStrings(s: []const u8) bool {
    var i: usize = 1;
    while (i <= s.len / 2) : (i += 1) { // pattern has to repeat at least twice so we only have to check first half
        if (@mod(s.len, i) != 0) continue; // no point in checking if the str isn't divisible by pattenr len
        const pattern = s[0..i];

        var j = i; // start of 2nd pattern
        var h = j + i - 1; // end of 2nd pattern
        while (h < s.len) {
            // so like if we have "ababab" this would be something like "ab" on the second iteration,
            // (j = 2, h = 3), and pattern would also be "ab" (0..i where i = 2)
            const substr = s[j .. h + 1];
            if (!std.mem.eql(u8, substr, pattern)) break; // break out to next pattern
            j += i;
            h += i;
        }

        // if we never broke, then j+=i will get j up to s.len
        if (j == s.len) {
            return true;
        }
    }

    return false;
}

fn part2() !void {
    const file = try std.fs.cwd().openFile("./data/day2.txt", .{});
    defer file.close();

    var buf: [4096]u8 = undefined;
    var reader = file.reader(&buf);

    var invalid_ids: [1024]usize = undefined;
    var invalid_cursor: usize = 0;

    while (true) {
        const range = try reader.interface.takeDelimiter(',') orelse break;
        const parsed = try parseRange(range);

        var print_buf: [128]u8 = undefined;
        var i = parsed.start;
        while (i <= parsed.end) : (i += 1) {
            // is i made up of some sequence of digits repeated _at least_ twice?
            const str = try std.fmt.bufPrint(&print_buf, "{d}", .{i});

            if (isRepeatedSubStrings(str)) {
                invalid_ids[invalid_cursor] = i;
                invalid_cursor += 1;
            }
        }
    }

    var h: usize = 0;
    var r: usize = 0;
    while (h < invalid_cursor) : (h += 1) {
        r += invalid_ids[h];
    }

    // 65794984383 is too high
    std.debug.print("part 2 answer: {d}\n", .{r});
}

pub fn solve() !void {
    try part1();
    try part2();
}
