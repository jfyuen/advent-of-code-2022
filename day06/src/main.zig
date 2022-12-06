const std = @import("std");
const allocator = std.heap.page_allocator;

pub fn main() !void {
    const args = try std.process.argsAlloc(allocator);
    defer std.process.argsFree(allocator, args);

    const file = try std.fs.cwd().openFile(args[1], .{});
    defer file.close();

    var buf_reader = std.io.bufferedReader(file.reader());
    var in_stream = buf_reader.reader();

    var buf: [10240]u8 = undefined;

    while (try in_stream.readUntilDelimiterOrEof(&buf, '\n')) |line| {
        const message_len = 14;

        var i: usize = message_len;
        while (i < line.len) {
            var map = std.AutoHashMap(u8, bool).init(allocator);
            var j: usize = 0;
            while (j < message_len) {
                try map.put(line[i - j], true);
                j += 1;
            }
            if (map.count() == message_len) {
                std.debug.print("{d}", .{i + 1});
                return;
            }
            i += 1;
        }
    }
}
