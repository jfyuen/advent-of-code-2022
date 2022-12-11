const std = @import("std");
const allocator = std.heap.page_allocator;

const Position = struct { x: i32, y: i32 };

fn move(head_pos: Position, tail_pos: Position) !Position {
    var new_pos = Position{ .x = tail_pos.x, .y = tail_pos.y };
    if (head_pos.y == tail_pos.y and head_pos.x > tail_pos.x + 1) {
        new_pos.x += 1;
    } else if (head_pos.y == tail_pos.y and head_pos.x < tail_pos.x - 1) {
        new_pos.x -= 1;
    } else if (head_pos.x == tail_pos.x and head_pos.y > tail_pos.y + 1) {
        new_pos.y += 1;
    } else if (head_pos.x == tail_pos.x and head_pos.y < tail_pos.y - 1) {
        new_pos.y -= 1;
    } else if (head_pos.y != tail_pos.y and head_pos.x != tail_pos.x) {
        var diff = try std.math.absInt(head_pos.y - tail_pos.y) + try std.math.absInt(head_pos.x - tail_pos.x);
        if (diff < 3) {
            return new_pos;
        }

        if (head_pos.y < tail_pos.y) {
            new_pos.y -= 1;
        } else if (head_pos.y > tail_pos.y) {
            new_pos.y += 1;
        }
        if (head_pos.x < tail_pos.x) {
            new_pos.x -= 1;
        } else if (head_pos.x > tail_pos.x) {
            new_pos.x += 1;
        }
    }
    return new_pos;
}

pub fn main() !void {
    const args = try std.process.argsAlloc(allocator);
    defer std.process.argsFree(allocator, args);

    const file = try std.fs.cwd().openFile(args[1], .{});
    defer file.close();

    var buf_reader = std.io.bufferedReader(file.reader());
    var in_stream = buf_reader.reader();

    var buf: [1024]u8 = undefined;

    var visited = std.AutoHashMap(Position, void).init(allocator);
    var knots: [10]Position = undefined;
    for (knots) |*pt| {
        pt.* = Position{
            .x = @intCast(i32, 0),
            .y = @intCast(i32, 0),
        };
    }

    while (try in_stream.readUntilDelimiterOrEof(&buf, '\n')) |line| {
        var split = std.mem.split(u8, line, " ");
        var direction = split.next().?;
        var count = try std.fmt.parseInt(i32, split.next().?, 10);

        var i: i32 = 0;
        std.debug.print("{s} {d}\n", .{ direction, count });

        while (i < count) : (i += 1) {
            // Move head
            if (std.mem.eql(u8, direction, "R")) {
                knots[0].x += 1;
            } else if (std.mem.eql(u8, direction, "U")) {
                knots[0].y += 1;
            } else if (std.mem.eql(u8, direction, "L")) {
                knots[0].x -= 1;
            } else if (std.mem.eql(u8, direction, "D")) {
                knots[0].y -= 1;
            }

            // Move tail
            var j: usize = 1;
            while (j < knots.len) : (j += 1) {
                knots[j] = try move(knots[j-1], knots[j]);
            }

            // std.debug.print("head: {d} {d}, tail: {d} {d}\n", .{ head_pos.x, head_pos.y, tail_pos.x, tail_pos.y });

            try visited.put(knots[knots.len - 1], {});
        }
    }
    std.debug.print("tail visited: {d}\n", .{visited.count()});
}
