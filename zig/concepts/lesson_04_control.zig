// Lesson 04: decisions and loops. `if` and `switch` are expressions that give back a value, a
// switch must cover every case, `for` walks over things (with an index if you ask), and a label
// lets `break` leave an outer loop or hand a value out of a block.

const std = @import("std");
const build_options = @import("build_options");
const Ctx = @import("main.zig").Ctx;

const Status = enum { todo, done, other };

pub fn run(c: Ctx) !void {
    const out = c.out;
    const count: usize = 1;
    const noun = if (count == 1) "task" else "tasks"; // no ?: operator: `if` gives the value
    try out.print("{d} {s}\n", .{ count, noun });

    // A switch has no fallthrough, so there's no `break` to forget. One prong can take several
    // values or a range, and `else` catches the rest.
    for ([_]u8{ 'x', ' ', '!', '7' }) |ch| {
        const kind = switch (ch) {
            'x', 'X' => "a tick",
            ' ' => "a space",
            '0'...'9' => "a digit",
            else => "something else",
        };
        try out.print("'{c}' is {s}\n", .{ ch, kind });
    }

    // Switching on an enum needs no `else`: the compiler knows every value, so it can check you
    // covered them all. Add a status later and every switch that forgot it stops compiling.
    try out.writeAll("marks:");
    for ([_]Status{ .todo, .done, .other }) |status| {
        const mark = switch (status) {
            .done => "x",
            .todo => " ",
            .other => "?",
        };
        try out.print(" [{s}]", .{mark});
    }
    try out.writeAll("\n");

    // for with an index: two things walked side by side, the items and a counter from 1.
    const titles = [_][]const u8{ "Buy groceries", "Call mom", "Fix login bug" };
    for (titles, 1..) |title, n| try out.print("{d}. {s}\n", .{ n, title });

    // while, with what to do after each pass written next to the condition.
    var i: usize = 3;
    while (i > 0) : (i -= 1) try out.print("{d}, ", .{i});
    try out.writeAll("go\n");

    // A labelled block hands back a value with `break :label value`: no flag variable needed.
    const first_long = find: {
        for (titles) |title| {
            if (title.len > 10) break :find title;
        }
        break :find "none";
    };
    try out.print("first title over 10 letters: {s}\n", .{first_long});

    // A labelled loop: `continue :rows` skips to the next row from inside the inner loop.
    try out.writeAll("pairs:");
    rows: for (0..3) |row| {
        for (0..3) |col| {
            if (col > row) continue :rows;
            try out.print(" ({d},{d})", .{ row, col });
        }
    }
    try out.writeAll("\n");

    if (build_options.bug == 4) {
        const status: Status = .other;
        const word = switch (status) { // the compiler: switch must handle all possibilities
            .done => "done",
            .todo => "todo",
        };
        try out.print("{s}\n", .{word});
    }
}
