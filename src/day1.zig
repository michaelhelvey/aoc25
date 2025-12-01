const std = @import("std");

const Direction = enum(u8) {
    left = 'L',
    right = 'R',
};

const Dial = struct {
    state: i32 = 50,
    counter: usize = 0,

    fn turnPart1(self: *Dial, direction: Direction, amount: i32) void {
        // reduce amount to be at least as small as our dial size
        const realAmount = if (amount > 100) amount - (@divFloor(amount, 100) * 100) else amount;
        switch (direction) {
            .left => {
                const newState = self.state - realAmount;
                if (newState < 0) self.state = 100 + newState else self.state = newState;
            },
            .right => {
                const newState = self.state + realAmount;
                if (newState > 99) self.state = newState - 100 else self.state = newState;
            },
        }

        if (self.state == 0) self.counter += 1;
    }

    fn turnPart2(self: *Dial, direction: Direction, amount: i32) void {
        // I am mentally disabled and this is the only way I can get the right
        // answer I'm not sure why the clever wrapping way doesn't work but it's
        // too big
        var i: usize = 0;
        while (i < @as(usize, @intCast(amount))) : (i += 1) {
            switch (direction) {
                .left => {
                    if (self.state == 0) self.state = 99 else self.state -= 1;
                    if (self.state == 0) {
                        self.counter += 1;
                    }
                },
                .right => {
                    if (self.state == 99) self.state = 0 else self.state += 1;
                    if (self.state == 0) {
                        self.counter += 1;
                    }
                },
            }
        }
    }
};

fn parseEntry(entry: []const u8) !struct { Direction, i32 } {
    const direction: Direction = @enumFromInt(entry[0]);
    const amount = try std.fmt.parseInt(i32, entry[1..], 10);
    return .{ direction, amount };
}

pub fn solve() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    const data = try std.fs.cwd().readFileAlloc(allocator, "./data/day1.txt", std.math.maxInt(usize));
    defer allocator.free(data);

    var it = std.mem.splitSequence(u8, data, "\n");
    var part1Dial = Dial{};
    var part2Dial = Dial{};

    while (it.next()) |val| {
        if (val.len > 0) {
            const parsed = try parseEntry(val);
            part1Dial.turnPart1(parsed[0], parsed[1]);
            part2Dial.turnPart2(parsed[0], parsed[1]);
        }
    }

    std.debug.print("part 1 result: {d}\n", .{part1Dial.counter});
    std.debug.print("part 2 result: {d}\n", .{part2Dial.counter});
}
