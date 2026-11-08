// Lesson 14: compile time. Zig has no preprocessor and no macro language: the same Zig code can
// run while compiling, marked `comptime`. Types are values there, so a function can take a type
// and return a new one (that's how ArrayList(T) is built), loop over a struct's fields, or stop
// the build with @compileError. Every BUG switch in these lessons is a comptime `if`: the branch
// that isn't taken isn't compiled.

const std = @import("std");
const build_options = @import("build_options");
const Ctx = @import("main.zig").Ctx;
const lesson03 = @import("lesson_03_numbers.zig");
const lesson11 = @import("lesson_11_structs.zig");

const chart_width = 20;
const default_top = 3;
comptime {
    // Checked while compiling, every build. A wrong setting never reaches a user.
    if (chart_width <= 0) @compileError("a chart needs room for its bars");
    if (default_top < 1) @compileError("the fallback must itself be a valid answer");
}

// A function that returns a type: a history of the last `capacity` items of any type, with no
// allocation, because the size is known while compiling. Chapter 04's undo needs one like it.
fn History(comptime T: type, comptime capacity: usize) type {
    return struct {
        items: [capacity]T = undefined,
        len: usize = 0,

        const Self = @This(); // the struct being defined, which has no name of its own

        // Keeps the newest `capacity` items, dropping the oldest.
        fn push(self: *Self, item: T) void {
            if (self.len == capacity) {
                std.mem.copyForwards(T, self.items[0 .. capacity - 1], self.items[1..]);
                self.len -= 1;
            }
            self.items[self.len] = item;
            self.len += 1;
        }

        fn pop(self: *Self) ?T {
            if (self.len == 0) return null;
            self.len -= 1;
            return self.items[self.len];
        }
    };
}

// The largest item of any type that can be compared with >. `anytype` is filled in at each
// call; give it something that can't be compared and that call fails to compile.
fn largest(items: anytype) @TypeOf(items[0]) {
    var best = items[0];
    for (items[1..]) |item| best = @max(best, item);
    return best;
}

pub fn run(c: Ctx) !void {
    const out = c.out;
    // An ordinary function, run by the compiler: the answer is baked into the program.
    const shown = comptime lesson03.percent(1, 8);
    try out.print("percent(1, 8) worked out while compiling: {d}\n", .{shown});

    // ** repeats while compiling, so the longest bar exists before the program runs.
    const full_bar = "█" ** chart_width;
    try out.print("a full bar is {d} bytes; 6 of 20 is the first 18: {s}\n", .{ full_bar.len, full_bar[0 .. 6 * "█".len] });

    var history: History(lesson11.Command, 2) = .{};
    history.push(.{ .add = "Pay rent" });
    history.push(.{ .done = 1 });
    history.push(.{ .done = 3 }); // the oldest, the add, falls out
    try out.writeAll("undo, newest first:");
    while (history.pop()) |cmd| switch (cmd) {
        .add => |title| try out.print(" add \"{s}\"", .{title}),
        .done => |n| try out.print(" done {d}", .{n}),
        .undo, .list => try out.print(" {t}", .{cmd}),
    };
    try out.print(" (the add, oldest, fell out)\nHistory(Command, 2) is {s}, {d} bytes\n", .{ @typeName(@TypeOf(history)), @sizeOf(@TypeOf(history)) });

    try out.print("largest: {d} and {d:.1}, one function, two types\n", .{ largest([_]u8{ 3, 7, 5 }), largest([_]f64{ 2.5, 1.5 }) });

    // inline for runs while compiling, once per field: one line of code for every field a struct
    // has now or gets later.
    try out.writeAll("Task has the fields:");
    inline for (@typeInfo(lesson11.Task).@"struct".fields) |field| {
        try out.print(" {s}: {s};", .{ field.name, @typeName(field.type) });
    }
    try out.writeAll("\n");

    if (build_options.bug == 14) {
        comptime {
            if (chart_width <= 100) @compileError("is the chart wide enough?"); // the compiler stops here
        }
    }
    try out.writeAll("every comptime check held, or this file wouldn't have compiled\n");
}
