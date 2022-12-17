const std = @import("std");
const allocator = std.heap.page_allocator;

const Point = struct { x: i64, y: i64 };

const Material = enum { Wall, Sand };

fn buildWall(map: *std.AutoHashMap(Point, Material), start: Point, end: Point) !void {
    if (start.x == end.x and end.y < start.y) {
        try buildWall(map, end, start);
    }
    if (end.y == start.y and end.x < start.x) {
        try buildWall(map, end, start);
    }

    try map.put(start, Material.Wall);
    try map.put(end, Material.Wall);

    // start is always before end
    var i: i64 = start.x;
    while (i < end.x) : (i += 1) {
        var p: Point = Point{ .x = i, .y = start.y };
        try map.put(p, Material.Wall);
    }
    i = start.y;
    while (i < end.y) : (i += 1) {
        var p: Point = Point{ .x = start.x, .y = i };
        try map.put(p, Material.Wall);
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
    var min_x: i64 = undefined;
    var max_x: i64 = undefined;
    var min_y: i64 = undefined;
    var max_y: i64 = undefined;

    var map = std.AutoHashMap(Point, Material).init(allocator);
    var iline: usize = 0;
    while (try in_stream.readUntilDelimiterOrEof(&buf, '\n')) |line| {
        var walls = std.ArrayList(Point).init(allocator);
        var split = std.mem.split(u8, line, " -> ");
        while (split.next()) |s| {
            var coords_split = std.mem.split(u8, s, ",");
            var x = try std.fmt.parseInt(i64, coords_split.next().?, 10);
            var y = try std.fmt.parseInt(i64, coords_split.next().?, 10);
            var p: Point = Point{ .x = x, .y = y };
            try walls.append(p);
        }

        var i: usize = 0;
        while (i < walls.items.len - 1) : (i += 1) {
            var start = walls.items[i];
            var end = walls.items[i + 1];
            try buildWall(&map, start, end);
            if (i == 0 and iline == 0) {
                min_x = start.x;
                max_x = start.x;
                min_y = start.y;
                max_y = start.y;
            }
            min_x = std.math.min(start.x, min_x);
            min_x = std.math.min(end.x, min_x);
            max_x = std.math.max(start.x, max_x);
            max_x = std.math.max(end.x, max_x);

            min_y = std.math.min(start.y, min_y);
            min_y = std.math.min(end.y, min_y);
            max_y = std.math.max(start.y, max_y);
            max_y = std.math.max(end.y, max_y);
        }
        iline += 1;
    }

    std.debug.print("zones {d},{d} {d},{d}\n", .{min_x, min_y, max_x, max_y});


    // var iterator = map.iterator();
    // while (iterator.next()) |entry| {
    //     if (entry.key_ptr.*.x == 500) {
    //         std.debug.print(" map {d},{d}\n", .{ entry.key_ptr.*.x, entry.key_ptr.*.y });
    //     }
    // }
    var count = map.count();
    var new_sands: usize = 0;
    while (true) {
        if (min_y == 0) { // no more sand (part2)
            break;
        }
        var sand_pos: Point = Point{ .x = 500, .y = min_y - 1 };
        while (true) {
            if (sand_pos.y == max_y + 1) { // ground reached (part 2)
                try map.put(sand_pos, Material.Sand);
                new_sands += 1;
                break;
            }
            // part 1
            // if (sand_pos. y > max_y) {
            //     break;
            // }
            if (!map.contains(Point{ .x = sand_pos.x, .y = sand_pos.y + 1 })) {
                sand_pos.y += 1;
                continue;
            }

            if (!map.contains(Point{ .x = sand_pos.x - 1, .y = sand_pos.y + 1 })) {
                sand_pos.x -= 1;
                sand_pos.y += 1;
                continue;
            }

            if (!map.contains(Point{ .x = sand_pos.x + 1, .y = sand_pos.y + 1 })) {
                sand_pos.x += 1;
                sand_pos.y += 1;
                continue;
            }

            try map.put(sand_pos, Material.Sand);
            new_sands += 1;
            min_x = std.math.min(sand_pos.x, min_x);
            max_x = std.math.max(sand_pos.x, max_x);

            min_y = std.math.min(sand_pos.y, min_y);
            // part 1
            // max_y = std.math.max(sand_pos.y, max_y);
            break;
        }

        if (count == map.count()) {
            break;
        }
        count = map.count();
    }

    std.debug.print("result: {d}\n", .{new_sands});
}
