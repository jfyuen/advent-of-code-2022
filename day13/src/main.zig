const std = @import("std");
const allocator = std.heap.page_allocator;

fn compare(left: []std.json.Value, right: []std.json.Value) i32 {
    var i: usize = 0;
    while (i < left.len and i < right.len) : (i += 1) {
        if (left[i] == std.json.Value.Integer and right[i] == std.json.Value.Integer) {
            if (left[i].Integer == right[i].Integer) {
                continue;
            }
            if (left[i].Integer < right[i].Integer) {
                return 1;
            }
            return -1;
        } else if (left[i] == std.json.Value.Array and right[i] == std.json.Value.Array) {
            var compared = compare(left[i].Array.items, right[i].Array.items);
            if (compared != 0) {
                return compared;
            }
        } else if (left[i] == std.json.Value.Integer and right[i] == std.json.Value.Array) {
            var compared = compare(&[1]std.json.Value{left[i]}, right[i].Array.items);
            if (compared != 0) {
                return compared;
            }
        } else if (left[i] == std.json.Value.Array and right[i] == std.json.Value.Integer) {
            var compared = compare(left[i].Array.items, &[1]std.json.Value{right[i]});
            if (compared != 0) {
                return compared;
            }
        }
    }
    if (i < left.len) {
        return -1;
    }
    if (i < right.len) {
        return 1;
    }
    return 0;
}

fn sortCompare(_: void, left: []std.json.Value, right: []std.json.Value) bool {
    return compare(left, right) == 1;
}

pub fn main() !void {
    const args = try std.process.argsAlloc(allocator);
    defer std.process.argsFree(allocator, args);

    const file = try std.fs.cwd().openFile(args[1], .{});
    defer file.close();

    var buf_reader = std.io.bufferedReader(file.reader());
    var in_stream = buf_reader.reader();

    var buf: [1024]u8 = undefined;

    var parser = std.json.Parser.init(allocator, false);
    var packets = std.ArrayList([]std.json.Value).init(allocator);
    var divider1 = try parser.parse("[[2]]");
    try packets.append(divider1.root.Array.items);
    parser.reset();

    var divider2 = try parser.parse("[[6]]");
    try packets.append(divider2.root.Array.items);

    while (try in_stream.readUntilDelimiterOrEof(&buf, '\n')) |line| {
        if (line.len == 0) {
            continue;
        }
        parser.reset();
        var tree = try parser.parse(line);
        try packets.append(tree.root.Array.items);
    }
    defer parser.deinit();

    std.sort.sort([]std.json.Value, packets.items, {}, comptime sortCompare);
    var answer: usize = 1;
    for (packets.items) |item, i| {
        if (std.meta.eql(item, divider1.root.Array.items) or std.meta.eql(item, divider2.root.Array.items)) {
            answer *= i + 1;
        }
    }
    std.debug.print("{d}\n", .{answer});
}
