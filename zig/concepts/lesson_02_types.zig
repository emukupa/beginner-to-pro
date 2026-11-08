// Lesson 02: types and sizes. Every integer type says its size in its name, and the name can be
// any width: u8, i32, u64, even u7 or u21. Overflow isn't undefined (C) or a silent wrap (C3):
// in a safe build it stops the program, and when you want wrapping you write a different operator.

const std = @import("std");
const build_options = @import("build_options");
const Ctx = @import("main.zig").Ctx;

pub fn run(c: Ctx) !void {
    const out = c.out;
    try out.print("u8 {d}, i32 {d}, i64 {d}, u128 {d} bytes\n", .{ @sizeOf(u8), @sizeOf(i32), @sizeOf(i64), @sizeOf(u128) });
    try out.print("usize {d} bytes: the type for sizes and indexes, like C's size_t\n", .{@sizeOf(usize)});
    try out.print("f64 {d} bytes, bool {d} byte\n", .{ @sizeOf(f64), @sizeOf(bool) });

    // Any width you like. A u7 holds 0..127, exactly ASCII; a u21 holds every Unicode code point.
    try out.print("u7 goes up to {d}, u21 to {d}, and a u7 is {d} bits\n", .{ std.math.maxInt(u7), std.math.maxInt(u21), @bitSizeOf(u7) });

    // Text is bytes: a character literal like 'A' is just a number.
    const letter: u8 = 'A';
    try out.print("'A' is the byte {d}, printed with {{c}} it's {c}\n", .{ letter, letter });

    // Overflow is a mistake unless you say otherwise. Each operator says what should happen.
    const biggest: u8 = 255;
    try out.print("255 +% 1 = {d} (wraps), 255 +| 1 = {d} (saturates)\n", .{ biggest +% 1, biggest +| 1 });
    const sum, const overflowed = @addWithOverflow(biggest, 1); // a result and a flag, no surprise
    try out.print("@addWithOverflow(255, 1) = {d}, overflowed: {d}\n", .{ sum, overflowed });

    // Widening is automatic because it can't lose anything. Narrowing needs you to say so:
    // @intCast checks the value fits (a panic if not); @truncate keeps the low bits on purpose.
    const big: u64 = 5_000_000_000; // underscores make long numbers readable
    const millions: u32 = @intCast(big / 1_000_000);
    const wide: u64 = millions;
    try out.print("{d} million fits in a u32 once you cast it, and goes back to a u64 by itself\n", .{wide});
    const three_hundred: u16 = 300;
    try out.print("300 truncated to a u8 keeps the low byte: {d}\n", .{@as(u8, @truncate(three_hundred))});

    if (build_options.bug == 2) {
        try out.flush(); // so the lines above show before the crash
        var count: u8 = 250;
        for (0..10) |_| count += 1; // a safety check: "integer overflow" stops the program
        try out.print("{d}\n", .{count});
    }
}
