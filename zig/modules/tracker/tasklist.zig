// The list of tasks: adding, counting, ranking. No printing, no files.

const std = @import("std");
const Allocator = std.mem.Allocator;
const Task = @import("models.zig").Task;
const parsing = @import("parsing.zig");

// Parses each title as a new "[todo]" task and adds it. Returns how many were added.
pub fn addTasks(a: Allocator, tasks: *std.ArrayList(Task), titles: []const []const u8, created: []const u8) !usize {
    var added: usize = 0;
    for (titles) |title| {
        var task = (try parsing.parseLine(a, try std.fmt.allocPrint(a, "[todo] {s}", .{title}))) orelse continue;
        task.created = created;
        try tasks.append(a, task);
        added += 1;
    }
    return added;
}

// The first task whose title matches, ignoring case and extra spaces: Python's
// " ".join(title.split()).lower(). A pointer into the list: borrowed, the list still owns the
// task. null if there isn't one.
pub fn findTask(a: Allocator, tasks: []const Task, title: []const u8) !?*const Task {
    var wanted: std.ArrayList(u8) = .empty;
    var words = std.mem.tokenizeAny(u8, title, parsing.whitespace);
    while (words.next()) |word| {
        if (wanted.items.len > 0) try wanted.append(a, ' ');
        try wanted.appendSlice(a, word);
    }
    for (tasks) |*task| {
        if (std.ascii.eqlIgnoreCase(task.title, wanted.items)) return task;
    }
    return null;
}

pub const TagCount = struct {
    tag: []const u8, // borrowed from a task
    count: usize,
};

// Every tag with how many tasks carry it, in the order each tag first appears. An array hash map
// keeps its keys in insertion order, so first-seen order comes for free.
pub fn countTags(a: Allocator, tasks: []const Task, include_done: bool) ![]TagCount {
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
pub fn top(comptime T: type, items: []T, n: usize) []T {
    const most_first = struct {
        fn more(_: void, x: T, y: T) bool {
            return x.count > y.count;
        }
    }.more;
    std.mem.sort(T, items, {}, most_first);
    return items[0..@min(items.len, n)];
}

// The n most used tags. error.NeedAtLeastOne when n < 1: Python's ValueError.
pub fn topTags(a: Allocator, tasks: []const Task, n: i64, include_done: bool) ![]TagCount {
    if (n < 1) return error.NeedAtLeastOne;
    return top(TagCount, try countTags(a, tasks, include_done), @intCast(n));
}

pub const Summary = struct {
    total: usize,
    done: usize,
    tags: usize,
    percent: f64,
};

pub fn summarize(a: Allocator, tasks: []const Task) !Summary {
    var done: usize = 0;
    for (tasks) |task| done += @intFromBool(task.isDone());
    const total = tasks.len;
    return .{
        .total = total,
        .done = done,
        .tags = (try countTags(a, tasks, true)).len,
        .percent = if (total == 0) 0 else @as(f64, @floatFromInt(done)) / @as(f64, @floatFromInt(total)) * 100,
    };
}
