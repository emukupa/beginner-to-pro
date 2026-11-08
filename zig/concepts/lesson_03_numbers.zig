// Lesson 03: numbers. Dividing two signed integers has more than one sensible answer when the
// result is negative, so Zig makes you pick: @divTrunc or @divFloor, @rem or @mod. Floats round in
// more than one way too, and the tracker's percentages must round halves to even, like Python.

const std = @import("std");
const build_options = @import("build_options");
const Ctx = @import("main.zig").Ctx;

// done out of total as a whole percent, halves rounded to even: 1 of 8 is 12.5, shown as 12.
// Integers only, so there's no float to round wrongly. Lesson 13 uses it.
pub fn percent(done: usize, total: usize) usize {
    if (total == 0) return 0;
    const whole = done * 100 / total; // unsigned, so plain / and % are fine
    const left = done * 100 % total;
    if (left * 2 > total or (left * 2 == total and whole % 2 == 1)) return whole + 1;
    return whole;
}

pub fn run(c: Ctx) !void {
    const out = c.out;
    const seven: i32 = 7;
    var minus_seven: i32 = -7;
    _ = &minus_seven; // a var we never change is an error; this pretends to, so it stays run-time
    try out.print("7 / 2 = {d}, 7 % 2 = {d} (known while compiling, so plain / is allowed)\n", .{ seven / 2, seven % 2 });
    try out.print("@divTrunc(-7, 2) = {d}, @divFloor(-7, 2) = {d}\n", .{ @divTrunc(minus_seven, 2), @divFloor(minus_seven, 2) });
    try out.print("@rem(-7, 2) = {d}, @mod(-7, 2) = {d}\n", .{ @rem(minus_seven, 2), @mod(minus_seven, 2) });
    try out.print("7.0 / 2 = {d:.1}\n", .{7.0 / 2.0});

    const half: f64 = 12.5;
    try out.print("@round({d:.1}) = {d:.0}: halves go away from zero\n", .{ half, @round(half) });
    try out.print("1 done of 8 is {d:.1}%: the tracker shows {d}%, and 3 of 8 ({d:.1}%) shows {d}%\n", .{ 100.0 / 8.0, percent(1, 8), 300.0 / 8.0, percent(3, 8) });

    // Text to a number can fail, so parseInt returns an error union: a number or an error.
    // `catch` gives a fallback. Lesson 09 covers errors properly.
    const three = std.fmt.parseInt(i32, "3", 10) catch -1;
    const five = std.fmt.parseInt(i32, "five", 10) catch -1;
    try out.print("\"3\" -> {d}, \"five\" -> {d} (the fallback)\n", .{ three, five });

    if (build_options.bug == 3) {
        try out.print("{d}\n", .{minus_seven / 2}); // the compiler: signed / must say how it rounds
    }
}

test "percent rounds halves to even" {
    try std.testing.expectEqual(12, percent(1, 8)); // 12.5
    try std.testing.expectEqual(38, percent(3, 8)); // 37.5
    try std.testing.expectEqual(50, percent(3, 6));
    try std.testing.expectEqual(0, percent(0, 0));
}
