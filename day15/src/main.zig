const std = @import("std");
const allocator = std.heap.page_allocator;

const Point = struct { x: i64, y: i64 };

fn dist(p1: Point, p2: Point) !i64 {
    var diff_x = p1.x - p2.x;
    var diff_y = p1.y - p2.y;
    return try std.math.absInt(diff_x) + try std.math.absInt(diff_y);
}

pub fn main() !void {
    const args = try std.process.argsAlloc(allocator);
    defer std.process.argsFree(allocator, args);

    const file = try std.fs.cwd().openFile(args[1], .{});
    defer file.close();

    var buf_reader = std.io.bufferedReader(file.reader());
    var in_stream = buf_reader.reader();

    var buf: [1024]u8 = undefined;

    var map = std.AutoHashMap(Point, bool).init(allocator);
    var sensors = std.AutoHashMap(Point, i64).init(allocator);
    var max_val: i64 = 4000000; // 20

    while (try in_stream.readUntilDelimiterOrEof(&buf, '\n')) |line| {
        // Parse
        // Sensor
        var split = std.mem.split(u8, line, "Sensor at x=");
        _ = split.next();
        var split1 = std.mem.split(u8, split.next().?, ",");
        var sensor_x: i64 = try std.fmt.parseInt(i64, split1.next().?, 10);
        split = std.mem.split(u8, line, ", y=");
        _ = split.next();
        split1 = std.mem.split(u8, split.next().?, ":");
        var sensor_y: i64 = try std.fmt.parseInt(i64, split1.next().?, 10);

        // beacon
        split = std.mem.split(u8, line, "closest beacon is at x=");
        _ = split.next();
        split1 = std.mem.split(u8, split.next().?, ",");
        var beacon_x: i64 = try std.fmt.parseInt(i64, split1.next().?, 10);

        split = std.mem.split(u8, line, ", y=");
        _ = split.next();
        _ = split.next();
        var beacon_y: i64 = try std.fmt.parseInt(i64, split.next().?, 10);

        // distance
        var range = try dist(Point{ .x = beacon_x, .y = beacon_y }, Point{ .x = sensor_x, .y = sensor_y });
        try sensors.put(Point{ .x = sensor_x, .y = sensor_y }, range);
        range += 1;

        // Beacons at border
        var i: i64 = 0;
        while (i < range) : (i += 1) {
            var p: Point = Point{ .x = sensor_x - i, .y = sensor_y - range + i + 1 };
            if (p.x >= 0 and p.x <= max_val and p.y >= 0 and p.y <= max_val) {
                try map.put(p, true);
            }

            p = Point{ .x = sensor_x + i, .y = sensor_y + range - i };
            if (p.x >= 0 and p.x <= max_val and p.y >= 0 and p.y <= max_val) {
                try map.put(p, true);
            }
            p = Point{ .x = sensor_x + i, .y = sensor_y - range + i + 1 };
            if (p.x >= 0 and p.x <= max_val and p.y >= 0 and p.y <= max_val) {
                try map.put(p, true);
            }

            p = Point{ .x = sensor_x - i, .y = sensor_y + range - i };
            if (p.x >= 0 and p.x <= max_val and p.y >= 0 and p.y <= max_val) {
                try map.put(p, true);
            }
        }
    }

    var iterator = map.iterator();
    while (iterator.next()) |entry| {
        var is_new = true;
        var sensor_iterator = sensors.iterator();
        while (sensor_iterator.next()) |sensor| {
            if (try dist(sensor.key_ptr.*, entry.key_ptr.*) <= sensor.value_ptr.*) {
                is_new = false;
                break;
            }
        }
        if (is_new) {
            std.debug.print("result: {d}\n", .{entry.key_ptr.*.x * 4000000 + entry.key_ptr.*.y});
            break;
        }
    }
}
