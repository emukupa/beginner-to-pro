// Lesson 08: strings. Zig has no string type: text is a slice of bytes, []const u8, usually
// UTF-8. So trimming or taking part of a string makes no copy and can't run off the end, and
// std.mem does the work with functions that work on slices of anything. You copy only when you
// need to keep the text, and then you choose the memory for it (lesson 10).

const std = @import("std");
const build_options = @import("build_options");
const Ctx = @import("main.zig").Ctx;

// "[DONE.]" -> "DONE": strip brackets, spaces and dots from both ends. A view of the same bytes.
pub fn cleanStatus(raw: []const u8) []const u8 {
    return std.mem.trim(u8, raw, "[] .");
}

// Same letters, ignoring case: "DONE" and "done". There's no == for slices (see the bug below).
pub fn sameWord(a: []const u8, b: []const u8) bool {
    return std.ascii.eqlIgnoreCase(a, b);
}

// Characters on screen, not bytes: "█" is three bytes of UTF-8 but one character. Text that
// isn't valid UTF-8 falls back to its length in bytes.
pub fn width(s: []const u8) usize {
    return std.unicode.utf8CountCodepoints(s) catch s.len;
}

pub fn run(c: Ctx) !void {
    const out = c.out;
    const line = "  [done.] Call mom #family  ";
    try out.print("a literal's type is {s}: a pointer to bytes ending in a zero, for C\n", .{@typeName(@TypeOf("done"))});

    const s = std.mem.trim(u8, line, " ");
    const close = std.mem.findScalar(u8, s, ']') orelse 0; // an optional: there might be no ']'
    const status = cleanStatus(s[0 .. close + 1]);
    const rest = std.mem.trim(u8, s[close + 1 ..], " ");
    try out.print("status \"{s}\", rest \"{s}\"\n", .{ status, rest });
    try out.print("same word as \"DONE\"? {}, exactly equal to \"done\"? {}\n", .{ sameWord(status, "DONE"), std.mem.eql(u8, status, "done") });

    // splitScalar keeps the empty pieces between two spaces; tokenizeScalar skips them.
    var words = std.mem.tokenizeScalar(u8, rest, ' ');
    while (words.next()) |word| { // next() gives ?[]const u8: null when there are no more
        if (word[0] != '#') continue;
        var buffer: [32]u8 = undefined; // lowercase into memory on the stack: no allocation
        try out.print("tag \"{s}\"\n", .{std.ascii.lowerString(&buffer, word[1..])});
    }
    var parts = std.mem.splitScalar(u8, "a  b", ' ');
    var n: usize = 0;
    while (parts.next()) |_| n += 1;
    try out.print("splitScalar keeps empty pieces: {d} parts in \"a  b\"\n", .{n});

    // bufPrint formats into a buffer you own, and gives back the slice it filled.
    var buffer: [64]u8 = undefined;
    const built = try std.fmt.bufPrint(&buffer, "{s} {s}", .{ "Call", "mom" });
    try out.print("built \"{s}\" ({d} bytes)\n", .{ built, built.len });
    try out.print("\"█\" is {d} bytes but {d} character wide\n", .{ "█".len, width("█") });

    if (build_options.bug == 8) {
        // the compiler: == compares two numbers or pointers, not the bytes of two slices
        const done: []const u8 = "done";
        try out.print("{}\n", .{status == done});
    }
}

test "cleanStatus and sameWord" {
    try std.testing.expectEqualStrings("DONE", cleanStatus("[DONE.]"));
    try std.testing.expectEqualStrings("todo", cleanStatus("[ todo ]"));
    try std.testing.expect(sameWord("Done", "DONE"));
    try std.testing.expectEqual(1, width("█"));
}
