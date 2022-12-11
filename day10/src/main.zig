const std = @import("std");
const allocator = std.heap.page_allocator;

fn getChar(cycle: i32, x: i32) u8 {
    var pos: i32 = @mod(cycle - 1, 40);
    if (x == pos or x == pos - 1 or x == pos + 1) {
        return '#';
    }
    return '.';
}

fn draw(screen: []u8) void {
    for (screen) |c, i| {
        std.debug.print("{c}", .{c});
        if (@mod(i + 1, 40) == 0) {
            std.debug.print("\n", .{});
        }
    }
    std.debug.print("\n", .{});
}

pub fn main() !void {
    const args = try std.process.argsAlloc(allocator);
    defer std.process.argsFree(allocator, args);

    const file = try std.fs.cwd().openFile(args[1], .{});
    defer file.close();

    var buf_reader = std.io.bufferedReader(file.reader());
    var in_stream = buf_reader.reader();

    var buf: [1024]u8 = undefined;

    var x: i32 = 1;
    var cycle: i32 = 1;
    var signal_strength: i32 = 0;
    var screen: [40 * 6]u8 = undefined;

    while (try in_stream.readUntilDelimiterOrEof(&buf, '\n')) |line| {
        var split = std.mem.split(u8, line, " ");
        var command = split.next().?;

        if (std.mem.eql(u8, command, "noop")) {
            std.debug.print("{s}. x={d}, cycle={d}\n", .{ command, x, cycle });
            screen[@intCast(usize, cycle - 1)] = getChar(cycle, x);

            cycle += 1;
            if (cycle == 20 or @mod(cycle - 20, 40) == 0) {
                // std.debug.print("x: {d}, cycle: {d}, signal_strength: {d}\n", .{ x, cycle, cycle * x });
                signal_strength += cycle * x;
            }
        } else {
            var value = try std.fmt.parseInt(i32, split.next().?, 10);
            std.debug.print("{s} {d}. x={d}, cycle={d}\n", .{ command, value, x, cycle });
            screen[@intCast(usize, cycle - 1)] = getChar(cycle, x);

            cycle += 1;

            if (cycle == 20 or @mod(cycle - 20, 40) == 0) {
                // std.debug.print("x: {d}, cycle: {d}, signal_strength: {d}\n", .{ x, cycle, cycle * x });
                signal_strength += cycle * x;
            }
            // if (cycle - 1 < screen.len) {
            screen[@intCast(usize, cycle - 1)] = getChar(cycle, x);

            // }
            x += value;
            cycle += 1;
            if (cycle == 20 or @mod(cycle - 20, 40) == 0) {
                // std.debug.print("x: {d}, cycle: {d}, signal_strength: {d}\n", .{ x, cycle, cycle * x });
                signal_strength += cycle * x;
            }
        }
    }
    // std.debug.print("x: {d}, cycle: {d}, signal_strength: {d}\n", .{ x, cycle, signal_strength });
    draw(&screen);
}
