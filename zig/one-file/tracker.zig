// The task tracker in one Zig file. Same prompts, summary and chart as the Python version, byte for
// byte: contract/run.sh checks every one. Read top to bottom: settings, what a task is, parsing a
// line, the file, counting and ranking, the chart, then main, the only part that talks to the user.
//
// Who owns the memory? Everything the tracker keeps lives as long as one run, so main makes one
// arena on top of the debug allocator and hands it to every function that allocates. One
// `defer arena.deinit()` frees it all, and the debug allocator checks at exit that nothing leaked.

const std = @import("std");
const Allocator = std.mem.Allocator;
const Io = std.Io;

// ---- Settings ----------------------------------------------------------------------------------

const chart_width = 20; // the longest bar, in characters
const default_top = 3; // top tags shown when the answer is empty or invalid
const tag_marker = '#'; // marks a word as a tag: "#work"
const bar = "█";
const whitespace = " \t\n\r\x0b\x0c";

comptime {
    if (default_top < 1) @compileError("the fallback must itself be a valid answer");
    if (chart_width == 0) @compileError("a chart needs room for its bars");
}

// ---- What a task is ----------------------------------------------------------------------------

const Status = enum { todo, done, other };

// Zig has no inheritance; Python's UrgentTask(Task) is a kind field.
const Kind = enum { plain, urgent };

const Task = struct {
    title: []const u8,
    tags: []const []const u8,
    status: Status,
    kind: Kind,
    created: []const u8 = "", // "YYYY-MM-DD" for tasks added this run, else ""

    fn isDone(t: Task) bool {
        return t.status == .done;
    }

    // How a task prints with {f}: "[ ] Title", and "  !!" on the end of an urgent one.
    pub fn format(t: Task, w: *Io.Writer) Io.Writer.Error!void {
        try w.print("[{s}] {s}{s}", .{ if (t.isDone()) "x" else " ", t.title, if (t.kind == .urgent) "  !!" else "" });
    }
};

// ---- Parsing one line --------------------------------------------------------------------------

fn statusOf(word: []const u8) Status {
    if (std.ascii.eqlIgnoreCase(word, "done")) return .done;
    if (std.ascii.eqlIgnoreCase(word, "todo")) return .todo;
    return .other;
}

// "[done.] Call mom #family" -> a Task, or null if the line isn't a task (Python's None). Every
// string the task keeps is copied with `a`; an error only if memory runs out.
fn parseLine(a: Allocator, line: []const u8) Allocator.Error!?Task {
    const s = std.mem.trim(u8, line, whitespace);
    if (s.len == 0 or s[0] != '[') return null;

    // Python's partition("]"): what's before the first ], and what's after it.
    const close = std.mem.findScalar(u8, s, ']') orelse s.len;
    const status = std.mem.trim(u8, s[0..close], "[] .");
    const rest = if (close < s.len) s[close + 1 ..] else "";

    var title: std.ArrayList(u8) = .empty;
    var tags: std.ArrayList([]const u8) = .empty;
    var kind: Kind = .plain;
    var words = std.mem.tokenizeAny(u8, rest, whitespace); // Python's split(): any run of whitespace
    while (words.next()) |word| {
        if (word[0] == tag_marker) {
            const bare = std.mem.trim(u8, std.mem.trimStart(u8, word, "#"), ".,");
            const tag = try std.ascii.allocLowerString(a, bare);
            if (std.mem.eql(u8, tag, "urgent")) kind = .urgent;
            try tags.append(a, tag);
        } else {
            if (title.items.len > 0) try title.append(a, ' ');
            try title.appendSlice(a, word);
        }
    }
    return .{
        .title = try title.toOwnedSlice(a),
        .tags = try tags.toOwnedSlice(a),
        .status = statusOf(status),
        .kind = kind,
    };
}

// ---- The file ----------------------------------------------------------------------------------

// Every task in the file; lines that aren't tasks are skipped. error.FileNotFound and friends come
// straight from openFile, passed on by `try`.
fn loadTasks(a: Allocator, io: Io, path: []const u8) !std.ArrayList(Task) {
    const file = try Io.Dir.cwd().openFile(io, path, .{});
    defer file.close(io); // however we leave
    var buffer: [64 * 1024]u8 = undefined; // the longest line we accept
    var reader = file.reader(io, &buffer);
    var tasks: std.ArrayList(Task) = .empty;
    while (try reader.interface.takeDelimiter('\n')) |line| {
        if (try parseLine(a, line)) |task| try tasks.append(a, task);
    }
    return tasks;
}

// Parses each title as a new "[todo]" task and adds it. Returns how many were added.
fn addTasks(a: Allocator, tasks: *std.ArrayList(Task), titles: []const []const u8, created: []const u8) !usize {
    var added: usize = 0;
    for (titles) |title| {
        var task = (try parseLine(a, try std.fmt.allocPrint(a, "[todo] {s}", .{title}))) orelse continue;
        task.created = created;
        try tasks.append(a, task);
        added += 1;
    }
    return added;
}

// "[todo] title" lines on the end of the file.
fn appendTitles(io: Io, path: []const u8, titles: []const []const u8) !void {
    const file = try Io.Dir.cwd().createFile(io, path, .{ .truncate = false });
    defer file.close(io);
    var buffer: [4096]u8 = undefined;
    var writer = file.writer(io, &buffer);
    try writer.seekTo(try file.length(io)); // Python's "a": write after what's already there
    for (titles) |title| try writer.interface.print("[todo] {s}\n", .{title});
    try writer.interface.flush();
}

// ---- Counting and ranking ----------------------------------------------------------------------

const TagCount = struct {
    tag: []const u8, // borrowed from a task
    count: usize,
};

// Every tag with how many tasks carry it, in the order each tag first appears. An array hash map
// keeps its keys in insertion order, so first-seen order comes for free.
fn countTags(a: Allocator, tasks: []const Task, include_done: bool) ![]TagCount {
    var counts: std.array_hash_map.String(usize) = .empty;
    for (tasks) |task| {
        if (!include_done and task.isDone()) continue;
        for (task.tags) |tag| {
            const entry = try counts.getOrPut(a, tag);
            if (!entry.found_existing) entry.value_ptr.* = 0;
            entry.value_ptr.* += 1;
        }
    }
    const out = try a.alloc(TagCount, counts.count());
    for (counts.keys(), counts.values(), out) |tag, count, *pair| pair.* = .{ .tag = tag, .count = count };
    return out;
}

// The n items with the biggest counts, most first, for any type T with a `count` field: the
// compiler writes a version for each T it's used with. std.mem.sort is stable, so ties keep order.
fn top(comptime T: type, items: []T, n: usize) []T {
    const most_first = struct {
        fn more(_: void, x: T, y: T) bool {
            return x.count > y.count;
        }
    }.more;
    std.mem.sort(T, items, {}, most_first);
    return items[0..@min(items.len, n)];
}

// The n most used tags. error.NeedAtLeastOne when n < 1: Python's ValueError.
fn topTags(a: Allocator, tasks: []const Task, n: i64, include_done: bool) ![]TagCount {
    if (n < 1) return error.NeedAtLeastOne;
    return top(TagCount, try countTags(a, tasks, include_done), @intCast(n));
}

// ---- Numbers -----------------------------------------------------------------------------------

// Python's round() for the same float: halves go to the even neighbour (12.5 -> 12, 13.5 -> 14).
// Zig's @round sends halves away from zero, so the tie is handled here.
fn roundHalfEven(x: f64) f64 {
    if (x - @trunc(x) == 0.5) return 2 * @round(x / 2);
    return @round(x);
}

// ---- The chart ---------------------------------------------------------------------------------

fn drawChart(out: *Io.Writer, pairs: []const TagCount, width: usize) !void {
    if (pairs.len == 0) return out.writeAll("No tags yet.\n");
    const biggest: f64 = @floatFromInt(pairs[0].count);
    var label_width: usize = 0;
    for (pairs) |p| label_width = @max(label_width, std.unicode.utf8CountCodepoints(p.tag) catch p.tag.len);
    for (pairs) |p| {
        const chars = std.unicode.utf8CountCodepoints(p.tag) catch p.tag.len;
        const blocks: usize = @intFromFloat(roundHalfEven(@as(f64, @floatFromInt(p.count)) / biggest * @as(f64, @floatFromInt(width))));
        try out.writeAll(p.tag);
        try out.splatByteAll(' ', label_width - chars + 2); // pad by characters, not bytes
        try out.splatBytesAll(bar, blocks);
        try out.print(" {d}\n", .{p.count});
    }
}

// ---- Talking to the user -----------------------------------------------------------------------

// Like Python's input(): shows the prompt, reads one line. An empty line at the end of input.
fn ask(out: *Io.Writer, in: *Io.Reader, prompt: []const u8) ![]const u8 {
    try out.writeAll(prompt);
    try out.flush(); // the prompt must be on screen before we wait
    return (try in.takeDelimiter('\n')) orelse "";
}

// Python's int(text): optional spaces, an optional sign, digits with single underscores between
// them, optional spaces. error.NotANumber for anything else. Huge numbers are capped.
fn parseWholeNumber(text: []const u8) error{NotANumber}!i64 {
    const s = std.mem.trim(u8, text, whitespace);
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

// Today's date, "YYYY-MM-DD", in UTC: Zig's standard library has no time zones.
fn today(a: Allocator, io: Io) ![]const u8 {
    const now = Io.Clock.real.now(io);
    const seconds: u64 = @intCast(@divFloor(now.nanoseconds, std.time.ns_per_s));
    const day = (std.time.epoch.EpochSeconds{ .secs = seconds }).getEpochDay().calculateYearDay();
    const month_day = day.calculateMonthDay();
    return std.fmt.allocPrint(a, "{d}-{d:0>2}-{d:0>2}", .{ day.year, month_day.month.numeric(), month_day.day_index + 1 });
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

    var tasks = loadTasks(a, io, path) catch |err| {
        std.debug.print("Couldn't {s} {s}\n", .{ if (err == error.FileNotFound) "find" else "read", path });
        return 1;
    };

    var new_titles: std.ArrayList([]const u8) = .empty;
    while (true) {
        const title = std.mem.trim(u8, try ask(out, in, "New task (Enter to finish): "), whitespace);
        if (title.len == 0) break;
        if (title[0] == tag_marker) {
            try out.writeAll("A task needs a title, not just tags.\n");
            continue;
        }
        try new_titles.append(a, try a.dupe(u8, title)); // the reader reuses its buffer: keep a copy
    }
    if (try addTasks(a, &tasks, new_titles.items, try today(a, io)) > 0) try appendTitles(io, path, new_titles.items);

    const answer = try ask(out, in, "How many top tags? [3]: ");
    const n = if (answer.len == 0) default_top else parseWholeNumber(answer) catch 0;
    const pairs = topTags(a, tasks.items, n, true) catch |err| switch (err) {
        error.NeedAtLeastOne => blk: {
            try out.writeAll("Need a whole number of at least 1 — using 3.\n");
            break :blk try topTags(a, tasks.items, default_top, true);
        },
        else => |e| return e,
    };

    var done: usize = 0;
    for (tasks.items) |task| done += @intFromBool(task.isDone());
    const total = tasks.items.len;
    const percent: f64 = if (total == 0) 0 else @as(f64, @floatFromInt(done)) / @as(f64, @floatFromInt(total)) * 100;
    const all_tags = (try countTags(a, tasks.items, true)).len;
    try out.print("\n{d} tasks, {d} done ({d}%), {d} tags\n", .{ total, done, @as(u64, @intFromFloat(roundHalfEven(percent))), all_tags });
    for (tasks.items) |task| {
        if (task.kind == .urgent and !task.isDone()) try out.print("{f}\n", .{task});
    }

    try out.writeAll("\nTop tags\n");
    try drawChart(out, pairs, chart_width);
    return 0;
}
