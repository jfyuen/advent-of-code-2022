const std = @import("std");
const allocator = std.heap.page_allocator;

const Monkey = struct {
    items: std.ArrayList(u64),
    id: u64,
    inspected: u64,
    divisible: u64,
    if_true: usize,
    if_false: usize,

    pub fn init(id: u64, items: []const u64, divisible: u64, if_true: usize, if_false: usize) !*Monkey {
        var a = std.ArrayList(u64).init(allocator);
        try a.appendSlice(items);
        var m = try allocator.create(Monkey);
        m.id = id;
        m.items = a;
        m.inspected = 0;
        m.divisible = divisible;
        m.if_true = if_true;
        m.if_false = if_false;
        return m;
    }

    pub fn do(self: *Monkey, old: u64) usize {
        // test
        // if (self.id == 0) {
        //     return old * 19;
        // } else if (self.id == 1) {
        //     return old + 6;
        // } else if (self.id == 2) {
        //     return old * old;
        // } else if (self.id == 3) {
        //     return old + 3;
        // }

        //real
        if (self.id == 0) {
            return old * 2;
        } else if (self.id == 1) {
            return old + 3;
        } else if (self.id == 2) {
            return old + 6;
        } else if (self.id == 3) {
            return old + 5;
        } else if (self.id == 4) {
            return old + 8;
        } else if (self.id == 5) {
            return old * 5;
        } else if (self.id == 6) {
            return old * old;
        } else if (self.id == 7) {
            return old + 4;
        }
        @panic("monkey not found!");
    }

    pub fn check(self: *Monkey, val: u64) u64 {
        if (@mod(val, self.divisible) == 0) {
            return self.if_true;
        } else {
            return self.if_false;
        }
    }
};

pub fn main() !void {
    // test
    // var monkeys: [4]*Monkey = undefined;
    // monkeys[0] = try Monkey.init(0, &[_]u64{ 79, 98 }, 23, 2, 3);
    // monkeys[1] = try Monkey.init(1, &[_]u64{ 54, 65, 75, 74 }, 19, 2, 0);
    // monkeys[2] = try Monkey.init(2, &[_]u64{ 79, 60, 97 }, 13, 1, 3);
    // monkeys[3] = try Monkey.init(3, &[_]u64{74}, 17, 0, 1);

    // real
    var monkeys: [8]*Monkey = undefined;
    monkeys[0] = try Monkey.init(0, &[_]u64{ 96, 60, 68, 91, 83, 57, 85 }, 17, 2, 5);
    monkeys[1] = try Monkey.init(1, &[_]u64{ 75, 78, 68, 81, 73, 99 }, 13, 7, 4);
    monkeys[2] = try Monkey.init(2, &[_]u64{ 69, 86, 67, 55, 96, 69, 94, 85 }, 19, 6, 5);
    monkeys[3] = try Monkey.init(3, &[_]u64{ 88, 75, 74, 98, 80 }, 7, 7, 1);
    monkeys[4] = try Monkey.init(4, &[_]u64{82}, 11, 0, 2);
    monkeys[5] = try Monkey.init(5, &[_]u64{ 72, 92, 92 }, 3, 6, 3);
    monkeys[6] = try Monkey.init(6, &[_]u64{ 74, 61 }, 2, 3, 1);
    monkeys[7] = try Monkey.init(7, &[_]u64{ 76, 86, 83, 55 }, 5, 4, 0);

    var megadiv: u64 = 1;
    for (monkeys) |monkey| {
        megadiv *= monkey.divisible;
    }

    var round: u64 = 0;
    while (round < 10000) : (round += 1) {
        for (monkeys) |monkey| {
            while (monkey.items.items.len > 0) {
                monkey.inspected += 1;
                var item = monkey.items.orderedRemove(0);
                var new_worry = @mod(monkey.do(item), megadiv);
                // new_worry = @divFloor(new_worry, 3);
                try monkeys[monkey.check(new_worry)].items.append(new_worry);
                // std.debug.print("id: {d} - item: {d} new_worry: {d}\n", .{ monkey.id, item, new_worry });
            }
        }
    }

    var vals: [8]u64 = undefined;
    for (monkeys) |monkey, i| {
        std.debug.print("id: {d} - inspected: {any}\n", .{ monkey.id, monkey.inspected });
        vals[i] = monkey.inspected;
    }

    std.sort.sort(u64, vals[0..], {}, comptime std.sort.desc(u64));
    std.debug.print("{d} * {d} = {d}\n", .{ vals[0], vals[1], vals[0] * vals[1] });
}
