// Drawing (label, count) pairs as bars. Knows nothing about tasks, and draws to any writer:
// the caller decides where the chart goes.

const std = @import("std");
const Io = std.Io;
const TagCount = @import("tasklist.zig").TagCount;
const numbers = @import("numbers.zig");

const bar = "█";

pub fn drawChart(out: *Io.Writer, pairs: []const TagCount, width: usize) Io.Writer.Error!void {
    if (pairs.len == 0) return out.writeAll("No tags yet.\n");
    const biggest: f64 = @floatFromInt(pairs[0].count);
    var label_width: usize = 0;
    for (pairs) |p| label_width = @max(label_width, std.unicode.utf8CountCodepoints(p.tag) catch p.tag.len);
    for (pairs) |p| {
        const chars = std.unicode.utf8CountCodepoints(p.tag) catch p.tag.len;
        const blocks: usize = @intFromFloat(numbers.roundHalfEven(@as(f64, @floatFromInt(p.count)) / biggest * @as(f64, @floatFromInt(width))));
        try out.writeAll(p.tag);
        try out.splatByteAll(' ', label_width - chars + 2); // pad by characters, not bytes
        try out.splatBytesAll(bar, blocks);
        try out.print(" {d}\n", .{p.count});
    }
}
