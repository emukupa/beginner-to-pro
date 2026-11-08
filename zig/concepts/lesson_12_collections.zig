// Lesson 12: lists, maps and generics. std.ArrayList(Task) is a growable array of tasks: ArrayList
// is a function that takes a type and returns a new type, and that is all generics are in Zig.
// Lists and maps don't keep an allocator inside them; you pass one to every call that might
// allocate, so you can see where memory is used. A hash map counts fast but forgets the order
// keys arrived in; an array hash map remembers it, and tied tags must keep that order.

const std = @import("std");
const Allocator = std.mem.Allocator;
const build_options = @import("build_options");
const Ctx = @import("main.zig").Ctx;
const lesson11 = @import("lesson_11_structs.zig");
const Task = lesson11.Task;

pub const TagCount = struct {
    tag: []const u8, // borrowed from a task
    count: usize,
};

// Every tag with how many tasks carry it, in the order each tag first appears. The caller owns
// the slice. The map is only scaffolding, freed before we return.
pub fn countTags(gpa: Allocator, tasks: []const Task) ![]TagCount {
    var counts: std.array_hash_map.String(usize) = .empty; // keys stay in the order they were put in
    defer counts.deinit(gpa);
    for (tasks) |task| {
        for (task.tags) |tag| {
            const entry = try counts.getOrPut(gpa, tag); // finds the tag, or makes room for it
            if (!entry.found_existing) entry.value_ptr.* = 0;
            entry.value_ptr.* += 1;
        }
    }
    const result = try gpa.alloc(TagCount, counts.count());
    for (counts.keys(), counts.values(), result) |tag, count, *slot| slot.* = .{ .tag = tag, .count = count };
    return result;
}

fn moreFirst(_: void, a: TagCount, b: TagCount) bool {
    return a.count > b.count;
}

// Most first. std.mem.sort is stable (a block sort): equal counts keep their order, so ties stay
// in first-seen order. std.mem.sortUnstable (pdqsort) is faster but makes no such promise.
pub fn rank(counts: []TagCount) void {
    std.mem.sort(TagCount, counts, {}, moreFirst);
}

// The first n items, or all of them if there are fewer. One function for any T: the compiler
// makes a copy for each type it's used with, checked like hand-written code. Lesson 14 says more.
pub fn topN(comptime T: type, items: []const T, n: usize) []const T {
    return items[0..@min(n, items.len)];
}

pub fn run(c: Ctx) !void {
    const out = c.out;
    // Every task's strings come from one arena, so one deinit frees them all.
    var arena = std.heap.ArenaAllocator.init(c.gpa);
    defer arena.deinit();
    var tasks: std.ArrayList(Task) = .empty;
    defer tasks.deinit(c.gpa);
    for ([_][]const u8{ "[done] Groceries #home", "[todo] Call mom #family", "[todo] Report #work #urgent", "[todo] Fix bug #work", "[done] Taxes #urgent #home" }) |line| {
        try tasks.append(c.gpa, try lesson11.parseTask(arena.allocator(), line));
    }

    const counts = try countTags(c.gpa, tasks.items);
    defer c.gpa.free(counts);
    try out.writeAll("first seen:");
    for (counts) |tc| try out.print(" {s}={d}", .{ tc.tag, tc.count });

    // A plain hash map counts just as fast, but hands its keys back in whatever order its table
    // holds them. Fine for lookups, wrong for "ties in first-seen order".
    var by_tag: std.StringHashMapUnmanaged(usize) = .empty;
    defer by_tag.deinit(c.gpa);
    for (tasks.items) |task| {
        for (task.tags) |tag| {
            const entry = try by_tag.getOrPut(c.gpa, tag);
            entry.value_ptr.* = if (entry.found_existing) entry.value_ptr.* + 1 else 1;
        }
    }
    try out.print("\nhash map:  ", .{});
    var keys = by_tag.keyIterator();
    while (keys.next()) |key| try out.print(" {s}={d}", .{ key.*, by_tag.get(key.*).? });
    rank(counts);
    try out.writeAll("\nranked:    ");
    for (counts) |tc| try out.print(" {s}={d}", .{ tc.tag, tc.count });
    try out.writeAll("\ntop 2:     ");
    for (topN(TagCount, counts, 2)) |tc| try out.print(" {s}", .{tc.tag});
    try out.print("\ntopN works for numbers too: {any}\n", .{topN(u32, &.{ 9, 8, 7 }, 2)});

    if (build_options.bug == 12) {
        try out.flush(); // so the lines above show before the crash
        c.gpa.free(counts); // and the defer above frees it again: the DebugAllocator stops the program
    }
}

test "rank keeps ties in first-seen order" {
    var counts = [_]TagCount{ .{ .tag = "home", .count = 2 }, .{ .tag = "family", .count = 1 }, .{ .tag = "work", .count = 2 }, .{ .tag = "urgent", .count = 2 } };
    rank(&counts);
    for ([_][]const u8{ "home", "work", "urgent", "family" }, counts) |want, got| try std.testing.expectEqualStrings(want, got.tag);
}
