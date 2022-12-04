const std = @import("std");
const allocator = std.heap.page_allocator;

fn getValue(c: u8) i64 {
    if (std.ascii.isLower(c)) {
        return c - 'a' + 1;
    } else {
        return c - 'A' + 27;
    }
}

pub fn main() !void {
    const args = try std.process.argsAlloc(allocator);
    defer std.process.argsFree(allocator, args);

    const file = try std.fs.cwd().openFile(args[1], .{});
    defer file.close();

    var buf_reader = std.io.bufferedReader(file.reader());
    var in_stream = buf_reader.reader();

    var buf: [1024]u8 = undefined;
    var total: i64 = 0;

    var current_group: i32 = 0;
    var all = std.AutoHashMap(u8, bool).init(allocator);
    while (try in_stream.readUntilDelimiterOrEof(&buf, '\n')) |line| {
        if (current_group == 0) {
            all = std.AutoHashMap(u8, bool).init(allocator);
            for (line) |c| {
                try all.put(c, true);
            }
        } else if (current_group == 1) {
            var current = std.AutoHashMap(u8, bool).init(allocator);
            for (line) |c| {
                if (all.get(c)) |_| {
                    try current.put(c, true);
                }
            }
            all = current;
        } else if (current_group == 2) {
            for (line) |c| {
                if (all.get(c)) |_| {
                    total += getValue(c);
                    break;
                }
            }
        }

        current_group += 1;
        current_group = @mod(current_group, 3);
    }

    std.debug.print("{d}\n", .{total});
}
