// Lesson 05: functions. Parameters are constants, every type is written out, and there are no
// default or named arguments: a struct with default field values does that job, and you can see
// at the call which settings were changed. std.debug.assert states what a function needs; a
// safe build checks it, a release build trusts it.

const std = @import("std");
const assert = std.debug.assert;
const build_options = @import("build_options");
const Ctx = @import("main.zig").Ctx;

pub const BarOptions = struct {
    width: usize = 20, // the default, used when the caller doesn't say
};

// Scales a count to a bar of at most `width` characters. Lesson 13 draws its chart with it.
pub fn barLength(count: usize, biggest: usize, options: BarOptions) usize {
    assert(biggest > 0); // there must be at least one count
    assert(count <= biggest); // no count is bigger than the biggest
    return count * options.width / biggest;
}

fn plural(n: usize, one: []const u8, many: []const u8) []const u8 {
    return if (n == 1) one else many;
}

// More than one result: return a struct. The caller can take it apart in one line.
fn divide(a: usize, b: usize) struct { quotient: usize, remainder: usize } {
    return .{ .quotient = a / b, .remainder = a % b };
}

pub fn run(c: Ctx) !void {
    const out = c.out;
    try out.print("4 of 4 -> {d} blocks, 2 of 4 -> {d}\n", .{ barLength(4, 4, .{}), barLength(2, 4, .{}) });
    try out.print("with .{{ .width = 8 }}: {d}\n", .{barLength(1, 4, .{ .width = 8 })});
    try out.print("1 {s}, 3 {s}\n", .{ plural(1, "task", "tasks"), plural(3, "task", "tasks") });
    const d = divide(17, 5);
    try out.print("17 / 5 = {d} remainder {d}\n", .{ d.quotient, d.remainder });

    // Arguments are copies, and constants: `count += 1` inside barLength wouldn't even compile.
    // Lesson 07 shows how a function changes something it was given.

    if (build_options.bug == 5) {
        try out.flush(); // so the lines above show before the crash
        try out.print("{d}\n", .{barLength(5, 0, .{})}); // a safety check: assert reaches `unreachable`
    }
}
