const std = @import("std");
const allocator = std.heap.page_allocator;

const Position = struct { x: usize, y: usize };
const Node = struct {
    value: u8,
    distance: i32,
    position: Position,
    visited: bool,
    previous: ?*Node,

    pub fn update(self: *Node, item: *Node) bool {
        if (self.value + 1 < item.value) {
            return false;
        }
        if (item.distance < self.distance or self.distance == -1) {
            self.distance = item.distance + 1;
            self.previous = item;
        }
        return true;
        // Part 1
        // if (self.value > item.value + 1) {
        //     return false;
        // }
        // if (item.distance < self.distance or self.distance == -1) {
        //     self.distance = item.distance + 1;
        //     self.previous = item;
        // }
        // return true;
    }
};

fn cmp(context: void, a: Node, b: Node) std.math.Order {
    _ = context;
    return std.math.order(a.distance, b.distance);
}

fn printPath(node: *Node) void {
    var n = node;
    var i: i32 = 0;
    while (n.previous) |v| {
        std.debug.print("  from: {d} {d}. val={c}, dist={d}\n", .{ n.position.x, n.position.y, n.value + 'a', node.distance - i });
        n = v;
        i += 1;
    }
}

fn printNodes(nodes: std.AutoHashMap(Position, *Node), i: usize, j: usize) void {
    var a: usize = 0;
    var b: usize = 0;
    while (a < i - 1) : (a += 1) {
        b = 0;
        while (b < j - 1) : (b += 1) {
            var position = Position{ .x = b, .y = a };
            std.debug.print("{c}", .{nodes.get(position).?.value + 'a'});
        }
        std.debug.print("\n", .{});
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

    // var graph = std.ArrayList(std.ArrayList(u8)).init(allocator);
    var end = Position{ .x = 0, .y = 0 };
    var nodes = std.AutoHashMap(Position, *Node).init(allocator);
    var root: *Node = undefined;
    var i: usize = 0;
    var j: usize = 0;
    while (try in_stream.readUntilDelimiterOrEof(&buf, '\n')) |line| {
        j = 0;
        for (line) |c| {
            var val: u8 = undefined;

            if (c == 'S') {
                val = 0;
            } else if (c == 'E') {
                val = 'z' - 'a';
                end.x = j;
                end.y = i;
            } else {
                val = c - 'a';
            }
            var node = try allocator.create(Node);
            node.distance = -1;
            node.value = val;
            node.position = Position{ .x = j, .y = i };
            node.visited = false;
            node.previous = null;
            // std.debug.print("addding node {d}.{d}\n", .{ node.position.x, node.position.y });

            try nodes.put(node.position, node);
            // part 1
            // if (c == 'S') {
            //     node.distance = 0;
            //     root = node;
            // }
            if (c == 'E') {
                node.distance = 0;
                root = node;
            }
            j += 1;
        }
        i += 1;
    }
    std.debug.print("total nodes {d}\n", .{nodes.count()});
    printNodes(nodes, i, j);

    var queue = std.PriorityQueue(Node, void, cmp).init(allocator, undefined);
    try queue.add(root.*);
    defer queue.deinit();
    while (queue.removeOrNull()) |node| {
        var item = nodes.get(node.position).?;
        if (item.visited) {
            continue;
        }

        item.visited = true;

        // part 1
        // if (item.position.x == end.x and item.position.y == end.y) {
        //     std.debug.print("--> found {any}\n", .{item});
        //     break;
        // }

        if (item.position.x > 0) {
            var check = Position{ .x = item.position.x - 1, .y = item.position.y };
            var next = nodes.get(check).?;
            if (next.update(item)) {
                try queue.add(next.*);
            }
        }

        if (item.position.x < j - 1) {
            var check = Position{ .x = item.position.x + 1, .y = item.position.y };
            var next = nodes.get(check).?;
            if (next.update(item)) {
                try queue.add(next.*);
            }
        }

        if (item.position.y > 0) {
            var check = Position{ .x = item.position.x, .y = item.position.y - 1 };
            var next = nodes.get(check).?;
            if (next.update(item)) {
                try queue.add(next.*);
            }
        }

        if (item.position.y < i - 1) {
            var check = Position{ .x = item.position.x, .y = item.position.y + 1 };
            var next = nodes.get(check).?;
            if (next.update(item)) {
                try queue.add(next.*);
            }
        }
    }

    var item = nodes.get(end).?;
    std.debug.print("end: {d}\n", .{item.distance});
    // printPath(item);

    var iterator = nodes.iterator();
    var min_node: *Node = root;
    while (iterator.next()) |n| {
        if (n.value_ptr.*.value > 0 or n.value_ptr.*.distance <= 0) {
            continue;
        }
        if (min_node.distance == 0 or min_node.distance > n.value_ptr.*.distance) {
            min_node = n.value_ptr.*;
        }
    }
    std.debug.print("min_distance: {any}\n", .{min_node});
    // printPath(min_node);
}
