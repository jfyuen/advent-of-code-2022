const std = @import("std");
const ArrayList = std.ArrayList;
const allocator = std.heap.page_allocator;

pub fn main() !void {
    const args = try std.process.argsAlloc(allocator);
    defer std.process.argsFree(allocator, args);

    const file = try std.fs.cwd().openFile(args[1], .{});
    defer file.close();

    var stacks: [9]ArrayList(u8) = undefined; // input-test == 3, input == 9
    for (stacks) |_, i| {
        stacks[i] = ArrayList(u8).init(allocator);
    }
    //     [D]
    // [N] [C]
    // [Z] [M] [P]
    //  1   2   3
    // try stacks[0].appendSlice(&[_]u8{ 'Z', 'N' });
    // try stacks[1].appendSlice(&[_]u8{ 'M', 'C', 'D' });
    // try stacks[2].appendSlice(&[_]u8{'P'});


    //         [C] [B] [H]
    // [W]     [D] [J] [Q] [B]
    // [P] [F] [Z] [F] [B] [L]
    // [G] [Z] [N] [P] [J] [S] [V]
    // [Z] [C] [H] [Z] [G] [T] [Z]     [C]
    // [V] [B] [M] [M] [C] [Q] [C] [G] [H]
    // [S] [V] [L] [D] [F] [F] [G] [L] [F]
    // [B] [J] [V] [L] [V] [G] [L] [N] [J]
    //  1   2   3   4   5   6   7   8   9
    try stacks[0].appendSlice(&[_]u8{'B', 'S', 'V', 'Z', 'G', 'P', 'W'});
    try stacks[1].appendSlice(&[_]u8{'J', 'V', 'B', 'C', 'Z', 'F'});
    try stacks[2].appendSlice(&[_]u8{'V', 'L', 'M', 'H', 'N', 'Z', 'D', 'C'});
    try stacks[3].appendSlice(&[_]u8{'L', 'D', 'M', 'Z', 'P', 'F', 'J', 'B'});
    try stacks[4].appendSlice(&[_]u8{'V', 'F', 'C', 'G', 'J', 'B', 'Q', 'H'});
    try stacks[5].appendSlice(&[_]u8{'G', 'F', 'Q', 'T', 'S', 'L', 'B'});
    try stacks[6].appendSlice(&[_]u8{'L', 'G', 'C', 'Z', 'V'});
    try stacks[7].appendSlice(&[_]u8{'N', 'L', 'G'});
    try stacks[8].appendSlice(&[_]u8{'J', 'F', 'H', 'C'});

    var buf_reader = std.io.bufferedReader(file.reader());
    var in_stream = buf_reader.reader();

    var buf: [1024]u8 = undefined;

    while (try in_stream.readUntilDelimiterOrEof(&buf, '\n')) |line| {
        if (!std.mem.startsWith(u8, line, "move")) {
            continue;
        }
        var split = std.mem.split(u8, line, " ");
        _ = split.next(); // move
        var count = try std.fmt.parseInt(usize, split.next().?, 10);
        _ = split.next(); // from
        var source = try std.fmt.parseInt(usize, split.next().?, 10);
        _ = split.next(); // to
        var to = try std.fmt.parseInt(usize, split.next().?, 10);

        // std.debug.print("{d} {d} {d} {?}\n", .{count, source, to, stacks[1].items});

        try stacks[to - 1].appendSlice(stacks[source - 1].items[(stacks[source - 1].items.len-count)..(stacks[source - 1].items.len)]);
        stacks[source - 1].shrinkRetainingCapacity(stacks[source - 1].items.len-count);
    }

    for (stacks) |_, i| {
        std.debug.print("{c}", .{stacks[i].items[stacks[i].items.len - 1]});
    }
}
