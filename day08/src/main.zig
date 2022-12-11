const std = @import("std");
const allocator = std.heap.page_allocator;

const Tree = struct {
    height: i32,
    visible: bool,

    fn init(height: i32, visible: bool) Tree {
        return Tree{ .height = height, .visible = visible };
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

    var trees = std.ArrayList(std.ArrayList(Tree)).init(allocator);
    var i: usize = 0;
    while (try in_stream.readUntilDelimiterOrEof(&buf, '\n')) |line| : (i += 1) {
        for (line) |_, j| {
            if (j == 0) {
                try trees.append(std.ArrayList(Tree).init(allocator));
            }
            var height = try std.fmt.parseInt(i32, line[j .. j + 1], 10);
            try trees.items[i].append(Tree.init(height, true));
        }
    }
    i = 1;
    var total: usize = 0;
    var best_scenic_score: usize = 1;
    while (i < trees.items.len - 1) : (i += 1) {
        var j: usize = 1;

        while (j < trees.items[0].items.len - 1) : (j += 1) {
            var scenic_score: usize = 1;
            var pos: usize = j;
            var visible: i32 = 4;
            var current: usize = 0;
            while (pos > 0) : (pos -= 1) {
                current += 1;
                if (trees.items[i].items[pos - 1].height >= trees.items[i].items[j].height) {
                    visible -= 1;
                    break;
                }
            }
            scenic_score = scenic_score * current;

            pos = j + 1;
            current = 0;
            while (pos < trees.items[i].items.len) : (pos += 1) {
                current += 1;
                if (trees.items[i].items[pos].height >= trees.items[i].items[j].height) {
                    visible -= 1;
                    break;
                }
            }
            scenic_score = scenic_score * current;

            pos = i;
            current = 0;
            while (pos > 0) : (pos -= 1) {
                current += 1;
                if (trees.items[pos - 1].items[j].height >= trees.items[i].items[j].height) {
                    visible -= 1;
                    break;
                }
            }
            scenic_score = scenic_score * current;

            pos = i + 1;
            current = 0;
            while (pos < trees.items.len) : (pos += 1) {
                current += 1;
                if (trees.items[pos].items[j].height >= trees.items[i].items[j].height) {
                    visible -= 1;
                    break;
                }
            }

            scenic_score = scenic_score * current;

            trees.items[i].items[j].visible = visible > 0;
            if (visible > 0) {
                total += 1;
            }
            best_scenic_score = std.math.max(best_scenic_score, scenic_score);
        }
    }

    // i = 0;
    // while (i < trees.items.len) : (i += 1) {
    //     var j: usize = 0;

    //     while (j < trees.items[0].items.len) : (j += 1) {
    //         if (trees.items[i].items[j].visible) {
    //             std.debug.print("1", .{});
    //         } else {
    //             std.debug.print("0", .{});
    //         }
    //     }
    //     std.debug.print("\n", .{});
    // }

    // std.debug.print("{d}\n", .{total + trees.items.len * 2 + trees.items[0].items.len * 2 - 4});
    std.debug.print("{d}\n", .{best_scenic_score});
}
