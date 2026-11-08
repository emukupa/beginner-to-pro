// The program the user talks to. The only file that reads input, prints to the screen, or exits.
//
// Who owns the memory? Everything the tracker keeps lives as long as one run, so main makes one
// arena on top of the debug allocator and hands it to every function that allocates.

const std = @import("std");
const Allocator = std.mem.Allocator;
const Io = std.Io;
const parsing = @import("parsing.zig");
const storage = @import("storage.zig");
const tasklist = @import("tasklist.zig");
const chart = @import("chart.zig");
const numbers = @import("numbers.zig");

const chart_width = 20; // the longest bar, in characters
const default_top = 3; // top tags shown when the answer is empty or invalid

comptime {
    if (default_top < 1) @compileError("the fallback must itself be a valid answer");
    if (chart_width == 0) @compileError("a chart needs room for its bars");
}

// Today's date, "YYYY-MM-DD", in UTC: Zig's standard library has no time zones.
fn today(a: Allocator, io: Io) ![]const u8 {
    const now = Io.Clock.real.now(io);
    const seconds: u64 = @intCast(@divFloor(now.nanoseconds, std.time.ns_per_s));
    const day = (std.time.epoch.EpochSeconds{ .secs = seconds }).getEpochDay().calculateYearDay();
    const month_day = day.calculateMonthDay();
    return std.fmt.allocPrint(a, "{d}-{d:0>2}-{d:0>2}", .{ day.year, month_day.month.numeric(), month_day.day_index + 1 });
}

// Like Python's input(): shows the prompt, reads one line. An empty line at the end of input.
fn ask(out: *Io.Writer, in: *Io.Reader, prompt: []const u8) ![]const u8 {
    try out.writeAll(prompt);
    try out.flush(); // the prompt must be on screen before we wait
    return (try in.takeDelimiter('\n')) orelse "";
}

// Python's int(text): optional spaces, an optional sign, digits with single underscores between
// them, optional spaces. error.NotANumber for anything else. Huge numbers are capped.
fn parseWholeNumber(text: []const u8) error{NotANumber}!i64 {
    const s = std.mem.trim(u8, text, parsing.whitespace);
    var i: usize = 0;
    var negative = false;
    if (i < s.len and (s[i] == '+' or s[i] == '-')) {
        negative = s[i] == '-';
        i += 1;
    }
    if (i == s.len or !std.ascii.isDigit(s[i])) return error.NotANumber;
    var value: i64 = 0;
    while (i < s.len) : (i += 1) {
        if (s[i] == '_' and i + 1 < s.len and std.ascii.isDigit(s[i + 1]) and std.ascii.isDigit(s[i - 1])) continue;
        if (!std.ascii.isDigit(s[i])) return error.NotANumber;
        const digit: i64 = s[i] - '0';
        value = if (value > @divTrunc(std.math.maxInt(i64) - digit, 10)) std.math.maxInt(i64) else value * 10 + digit;
    }
    return if (negative) -value else value;
}

pub fn main(init: std.process.Init) !u8 {
    const io = init.io;
    var arena = std.heap.ArenaAllocator.init(init.gpa);
    defer arena.deinit(); // every string, list and count, freed at once
    const a = arena.allocator();

    var out_buffer: [4096]u8 = undefined;
    var stdout = Io.File.stdout().writer(io, &out_buffer);
    const out = &stdout.interface;
    defer out.flush() catch {};
    var in_buffer: [64 * 1024]u8 = undefined;
    var stdin = Io.File.stdin().reader(io, &in_buffer);
    const in = &stdin.interface;

    const args = try init.minimal.args.toSlice(a);
    const path = if (args.len > 1) args[1] else init.environ_map.get("TASKS_FILE") orelse "tasks.txt";

    var tasks = storage.loadTasks(a, io, path) catch |err| {
        std.debug.print("Couldn't {s} {s}\n", .{ if (err == error.FileNotFound) "find" else "read", path });
        return 1;
    };

    var new_titles: std.ArrayList([]const u8) = .empty;
    while (true) {
        const title = std.mem.trim(u8, try ask(out, in, "New task (Enter to finish): "), parsing.whitespace);
        if (title.len == 0) break;
        if (title[0] == parsing.tag_marker) {
            try out.writeAll("A task needs a title, not just tags.\n");
            continue;
        }
        try new_titles.append(a, try a.dupe(u8, title)); // the reader reuses its buffer: keep a copy
    }
    if (try tasklist.addTasks(a, &tasks, new_titles.items, try today(a, io)) > 0) try storage.appendTitles(io, path, new_titles.items);

    const answer = try ask(out, in, "How many top tags? [3]: ");
    const n = if (answer.len == 0) default_top else parseWholeNumber(answer) catch 0;
    const pairs = tasklist.topTags(a, tasks.items, n, true) catch |err| switch (err) {
        error.NeedAtLeastOne => blk: {
            try out.writeAll("Need a whole number of at least 1 — using 3.\n");
            break :blk try tasklist.topTags(a, tasks.items, default_top, true);
        },
        else => |e| return e,
    };

    const s = try tasklist.summarize(a, tasks.items);
    try out.print("\n{d} tasks, {d} done ({d}%), {d} tags\n", .{ s.total, s.done, @as(u64, @intFromFloat(numbers.roundHalfEven(s.percent))), s.tags });
    for (tasks.items) |task| {
        if (task.kind == .urgent and !task.isDone()) try out.print("{f}\n", .{task});
    }

    try out.writeAll("\nTop tags\n");
    try chart.drawChart(out, pairs, chart_width);
    return 0;
}
