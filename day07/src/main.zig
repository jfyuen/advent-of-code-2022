const std = @import("std");
const allocator = std.heap.page_allocator;

const Node = struct {
    files: std.ArrayList(u64),
    dirs: std.StringHashMap(*Node),
    name: []u8,
    parent: ?*Node,

    pub fn init(parent: ?*Node, name: []u8) !*Node {
        var n = try allocator.create(Node);
        n.parent = parent;
        n.name = name;
        n.files = std.ArrayList(u64).init(allocator);
        n.dirs = std.StringHashMap(*Node).init(allocator);
        return n;
    }

    pub fn size(self: *Node) u64 {
        var total: u64 = 0;
        for (self.files.items) |f| {
            total += f;
        }

        var iterator = self.dirs.iterator();
        while (iterator.next()) |entry| {
            var dir_size = entry.value_ptr.*.size();
            total += dir_size;
        }
        return total;
    }

    pub fn filter(self: *Node, a: *std.ArrayList(*Node), min_size: u64) !void {
        if (self.size() < min_size) {
            try a.append(self);
        }
        var iterator = self.dirs.iterator();
        while (iterator.next()) |entry| {
            try entry.value_ptr.*.filter(a, min_size);
        }
    }

    pub fn flatten(self: *Node, a: *std.ArrayList(*Node)) !void {
        try a.append(self);
        var iterator = self.dirs.iterator();
        while (iterator.next()) |entry| {
            try entry.value_ptr.*.flatten(a);
        }
    }
};

const State = enum {
    COMMAND,
    LIST,

    fn isList(s: State) bool {
        return s == State.LIST;
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

    var root_name = std.ArrayList(u8).init(allocator);
    try root_name.appendSlice("/");
    const root: *Node = try Node.init(undefined, root_name.items);

    var current: *Node = root;
    var state: State = undefined;
    while (try in_stream.readUntilDelimiterOrEof(&buf, '\n')) |line| {
        if (line[0] == '$') {
            state = State.COMMAND;
        }
        if (std.mem.eql(u8, line, "$ cd /")) {
            current = root;
            continue;
        }
        if (std.mem.eql(u8, line, "$ cd ..")) {
            current = current.parent.?;
            continue;
        } else if (std.mem.eql(u8, line[0..4], "$ cd")) {
            var split = std.mem.split(u8, line, " ");
            _ = split.next().?;
            _ = split.next().?;
            var d = split.next().?;
            current = current.dirs.get(d).?;
            continue;
        } else if (std.mem.eql(u8, line[0..4], "$ ls")) {
            state = State.LIST;
            continue;
        }

        if (!state.isList()) {
            continue;
        }

        if (std.mem.eql(u8, line[0..3], "dir")) {
            var split = std.mem.split(u8, line, " ");
            _ = split.next();
            var s = std.ArrayList(u8).init(allocator);
            try s.appendSlice(split.next().?);
            var name = s.items;
            var dir = try Node.init(current, name);
            try current.dirs.put(name, dir);
        } else {
            var split = std.mem.split(u8, line, " ");
            var size = try std.fmt.parseInt(u64, split.next().?, 10);
            try current.files.append(size);
        }
    }
    var a = std.ArrayList(*Node).init(allocator);
    // try root.filter(&a, 100000);
    // var total: u64 = 0;
    // for (a.items) |item| {
    //     total += item.size();
    // }

    try root.flatten(&a);
    var avail_size = 70000000 - root.size();
    var selected_node = a.items[0];
    for (a.items) |item| {
        var dir_size = item.size();
        if (avail_size + dir_size >= 30000000 and dir_size < selected_node.size()) {
            selected_node = item;
        }
    }
    std.debug.print("{d}\n", .{selected_node.size()});
}
