const std = @import("std");
const allocator = std.heap.page_allocator;

const Kind = enum(i64) { ROCK = 1, PAPER = 2, SCISSORS = 3 };

fn kindFromString(v: []u8) Kind {
    if (std.mem.eql(u8, v, "A")) {
        return Kind.ROCK;
    } else if (std.mem.eql(u8, v, "B")) {
        return Kind.PAPER;
    } else if (std.mem.eql(u8, v, "C")) {
        return Kind.SCISSORS;
    } else {
        @panic("not found");
    }
}

const GameResult = enum(i64) { WIN = 6, LOSE = 0, DRAW = 3 };

fn gameResultFromString(v: []u8) GameResult {
    if (std.mem.eql(u8, v, "X")) {
        return GameResult.LOSE;
    } else if (std.mem.eql(u8, v, "Y")) {
        return GameResult.DRAW;
    } else if (std.mem.eql(u8, v, "Z")) {
        return GameResult.WIN;
    } else {
        @panic("not found");
    }
}

fn result(opponent: Kind, me: Kind) GameResult {
    switch (opponent) {
        Kind.ROCK => {
            switch (me) {
                Kind.ROCK => return GameResult.DRAW,
                Kind.PAPER => return GameResult.WIN,
                Kind.SCISSORS => return GameResult.LOSE,
            }
        },
        Kind.PAPER => {
            switch (me) {
                Kind.ROCK => return GameResult.LOSE,
                Kind.PAPER => return GameResult.DRAW,
                Kind.SCISSORS => return GameResult.WIN,
            }
        },
        Kind.SCISSORS => {
            switch (me) {
                Kind.ROCK => return GameResult.WIN,
                Kind.PAPER => return GameResult.LOSE,
                Kind.SCISSORS => return GameResult.DRAW,
            }
        },
    }
}

fn result2(opponent: Kind, r: GameResult) Kind {
    switch (opponent) {
        Kind.ROCK => {
            switch (r) {
                GameResult.DRAW => return Kind.ROCK,
                GameResult.WIN => return Kind.PAPER,
                GameResult.LOSE => return Kind.SCISSORS,
            }
        },
        Kind.PAPER => {
            switch (r) {
                GameResult.DRAW => return Kind.PAPER,
                GameResult.WIN => return Kind.SCISSORS,
                GameResult.LOSE => return Kind.ROCK,
            }
        },
        Kind.SCISSORS => {
            switch (r) {
                GameResult.DRAW => return Kind.SCISSORS,
                GameResult.WIN => return Kind.ROCK,
                GameResult.LOSE => return Kind.PAPER,
            }
        },
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
    var total: i64 = 0;

    while (try in_stream.readUntilDelimiterOrEof(&buf, '\n')) |line| {
        const opponent = kindFromString(line[0..1]);
        const r = gameResultFromString(line[2..3]);
        // const r = result(opponent, me);
        const me = result2(opponent, r);
        total += @enumToInt(me) + @enumToInt(r);
        // std.debug.print("{d}\n", .{total});
    }

    std.debug.print("{d}\n", .{total});
}
