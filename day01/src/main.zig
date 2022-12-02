const std = @import("std");
const ArrayList = std.ArrayList;
const allocator = std.heap.page_allocator;

pub fn main() !void {
    const args = try std.process.argsAlloc(allocator);
    defer std.process.argsFree(allocator, args);

    const file = try std.fs.cwd().openFile(args[1], .{});
    defer file.close();

    var buf_reader = std.io.bufferedReader(file.reader());
    var in_stream = buf_reader.reader();

    var buf: [1024]u8 = undefined;
    var vals = ArrayList(i64).init(allocator);
    var total: i64 = 0;

    while (try in_stream.readUntilDelimiterOrEof(&buf, '\n')) |line| {
        if (line.len == 0) {
            try vals.append(total);
            total = 0;
        } else {
            var v: i64 = try std.fmt.parseInt(i64, line, 10);
            total += v;
        }
    }
    try vals.append(total);

    std.sort.sort(i64, vals.items, {}, comptime std.sort.desc(i64));

    std.debug.print("{d}", .{vals.items[0] + vals.items[1] + vals.items[2]});
}
