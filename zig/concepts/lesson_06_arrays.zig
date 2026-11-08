// Lesson 06: arrays and slices. An array's length is part of its type ([3]u8 and [4]u8 are
// different types) and it never decays into a bare pointer. A slice is a pointer and a length
// together, so code that takes a slice always knows where the data ends, and a safe build checks
// every index against it.

const std = @import("std");
const build_options = @import("build_options");
const Ctx = @import("main.zig").Ctx;

// Takes any number of counts, because a slice carries its own length. C needs a second parameter.
fn total(counts: []const usize) usize {
    var sum: usize = 0;
    for (counts) |n| sum += n;
    return sum;
}

pub fn run(c: Ctx) !void {
    const out = c.out;
    var counts = [_]usize{ 3, 2, 2, 1 }; // [_]: count the items for me; the type is [4]usize
    try out.print("{d} counts, {d} bytes, total {d}\n", .{ counts.len, @sizeOf(@TypeOf(counts)), total(&counts) });

    // Slicing with bounds known while compiling gives a pointer to an array (*[2]usize), which
    // turns into a slice wherever one is wanted. With run-time bounds it's a slice, []usize.
    const middle = counts[1..3]; // items 1 and 2: the end is left out, like Python
    const tail = counts[2..]; // from 2 to the end
    try out.print("counts[1..3] = {any}, counts[2..] = {any}, total of the tail {d}\n", .{ middle, tail, total(tail) });

    // |*n| gives a pointer to each item, so the loop can change the array itself.
    for (&counts) |*n| n.* *= 10;
    try out.print("times ten: {any}\n", .{counts});

    // A slice shares the array's memory: change one, and the other sees it.
    middle[0] = 99;
    try out.print("after middle[0] = 99: {any}\n", .{counts});

    // ++ joins arrays and ** repeats them, while compiling: the sizes are known, so no allocation.
    const frame = "+" ++ "-" ** 6 ++ "+";
    try out.print("{s}\n", .{frame});

    if (build_options.bug == 6) {
        try out.flush(); // so the lines above show before the crash
        for (0..counts.len + 1) |i| { // one too many: the classic off-by-one
            try out.print("{d}\n", .{counts[i]}); // a safety check: "index out of bounds"
        }
    }
}
