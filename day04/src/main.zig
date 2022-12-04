const std = @import("std");
const allocator = std.heap.page_allocator;

pub fn main() !void {
    const args = try std.process.argsAlloc(allocator);
    defer std.process.argsFree(allocator, args);

    const file = try std.fs.cwd().openFile(args[1], .{});
    defer file.close();

    var buf_reader = std.io.bufferedReader(file.reader());
    var in_stream = buf_reader.reader();

    var buf: [1024]u8 = undefined;
    var total: i64 = 0;

    while (try in_stream.readUntilDelimiterOrEof(&buf, '\n')) |line| {
        var split = std.mem.split(u8, line, ",");
        var split1 = std.mem.split(u8, split.next().?, "-");
        var start1 = try std.fmt.parseInt(i64, split1.next().?, 10);
        var end1 = try std.fmt.parseInt(i64, split1.next().?, 10);

        var split2 = std.mem.split(u8, split.next().?, "-");
        var start2 = try std.fmt.parseInt(i64, split2.next().?, 10);
        var end2 = try std.fmt.parseInt(i64, split2.next().?, 10);

        if (start2 <= start1 and end2 >= start1 or
            start2 <= end1 and end2 >= end1 or
            start1 <= start2 and end1 >= start2 or
            start1 <= end2 and end1 >= end2)
        {
            total += 1;
        }
    }

    std.debug.print("{d}\n", .{total});
}
