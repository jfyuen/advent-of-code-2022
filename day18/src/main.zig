const std = @import("std");
const allocator = std.heap.page_allocator;

const Point = struct {
    x: i64,
    y: i64,
    z: i64,

    fn adjacent(self: Point) ![]Point {
        var a = std.ArrayList(Point).init(allocator);
        var possibilities = [_]i64{ -1, 1 };
        for (possibilities) |x| {
            var neighbor = Point{ .x = self.x + x, .y = self.y, .z = self.z };
            try a.append(neighbor);
        }

        for (possibilities) |y| {
            var neighbor = Point{ .x = self.x, .y = self.y + y, .z = self.z };
            try a.append(neighbor);
        }
        for (possibilities) |z| {
            var neighbor = Point{ .x = self.x, .y = self.y, .z = self.z + z };
            try a.append(neighbor);
        }

        return a.items;
    }
};

pub fn main() !void {
    const args = try std.process.argsAlloc(allocator);
    defer std.process.argsFree(allocator, args);

    const file = try std.fs.cwd().openFile(args[1], .{});
    defer file.close();

    var buf_reader = std.io.bufferedReader(file.reader());
    var in_stream = buf_reader.reader();

    var buf: [1024]u8 = undefined;

    var connected = std.AutoHashMap(Point, i64).init(allocator);
    var min_x: i64 = undefined;
    var max_x: i64 = undefined;
    var min_y: i64 = undefined;
    var max_y: i64 = undefined;
    var min_z: i64 = undefined;
    var max_z: i64 = undefined;

    while (try in_stream.readUntilDelimiterOrEof(&buf, '\n')) |line| {
        var split = std.mem.split(u8, line, ",");
        var point = Point{ .x = try std.fmt.parseInt(i64, split.next().?, 10), .y = try std.fmt.parseInt(i64, split.next().?, 10), .z = try std.fmt.parseInt(i64, split.next().?, 10) };

        if (connected.count() == 0) {
            min_x = point.x;
            max_x = point.x;
            min_y = point.y;
            max_y = point.y;
            min_z = point.z;
            max_z = point.z;
        }
        min_x = std.math.min(min_x, point.x);
        max_x = std.math.max(max_x, point.x);
        min_y = std.math.min(min_y, point.y);
        max_y = std.math.max(max_y, point.y);
        min_z = std.math.min(min_z, point.z);
        max_z = std.math.max(max_z, point.z);
        try connected.put(point, 0);
    }

    var step: i64 = 1;
    var water = std.AutoHashMap(Point, i64).init(allocator);
    try water.put(Point{ .x = min_x - 1, .y = min_y - 1, .z = min_z - 1 }, step);
    while (true) : (step += 1) {
        var found = false;
        var batch = std.AutoHashMap(Point, i64).init(allocator);
        var iterator = water.iterator();
        while (iterator.next()) |entry| {
            if (entry.value_ptr.* != step) {
                continue;
            }

            for (try entry.key_ptr.*.adjacent()) |neighbor| {
                if (neighbor.x < min_x - 1 or neighbor.x > max_x + 1 or neighbor.y < min_y - 1 or neighbor.y > max_y + 1 or neighbor.z < min_z - 1 or neighbor.z > max_z + 1) {
                    continue;
                }

                if (connected.contains(neighbor) or batch.contains(neighbor)) {
                    continue;
                }

                if (!water.contains(neighbor)) {
                    try batch.put(neighbor, step + 1);
                    found = true;
                }
            }
        }
        if (!found) {
            break;
        }
        iterator = batch.iterator();
        while (iterator.next()) |entry| {
            try water.put(entry.key_ptr.*, entry.value_ptr.*);
        }
    }

    var total: i64 = 0;
    var iterator = connected.iterator();
    while (iterator.next()) |entry| {
        for (try entry.key_ptr.*.adjacent()) |neighbor| {
            if (water.contains(neighbor)) {
                total += 1;
            }
        }
    }
    std.debug.print("{any}\n", .{total});
}
