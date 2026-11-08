// Lesson 13: files. Opening a file returns an error union like everything else that can fail, and
// `defer` closes it on every way out. Files go through `io`, the interface main.zig was handed:
// Zig doesn't hide the operating system behind globals. A reader with a buffer gives one line at
// a time. With the earlier lessons this is a small tracker: load tasks.txt, then count, rank and
// chart its tags.

const std = @import("std");
const Allocator = std.mem.Allocator;
const build_options = @import("build_options");
const Ctx = @import("main.zig").Ctx;
const lesson03 = @import("lesson_03_numbers.zig");
const lesson05 = @import("lesson_05_functions.zig");
const lesson08 = @import("lesson_08_strings.zig");
const lesson11 = @import("lesson_11_structs.zig");
const lesson12 = @import("lesson_12_collections.zig");
const Task = lesson11.Task;

// Every task in the file, its strings allocated with `gpa`; lines that aren't tasks are skipped.
// An error if the file can't be opened or read. The caller owns the list.
pub fn loadTasks(gpa: Allocator, io: std.Io, path: []const u8) !std.ArrayList(Task) {
    const file = try std.Io.Dir.cwd().openFile(io, path, .{});
    defer file.close(io); // runs however we leave
    var buffer: [4096]u8 = undefined; // the longest line we accept
    var reader = file.reader(io, &buffer);
    var tasks: std.ArrayList(Task) = .empty;
    errdefer {
        for (tasks.items) |task| task.deinit(gpa);
        tasks.deinit(gpa);
    }
    while (try reader.interface.takeDelimiter('\n')) |line| { // null at the end of the file
        const task = lesson11.parseTask(gpa, line) catch |err| switch (err) {
            error.NotATask, error.NoClosingBracket => continue,
            else => |e| return e, // out of memory is not a reason to skip a line
        };
        errdefer task.deinit(gpa); // if append fails, this task isn't in the list yet
        try tasks.append(gpa, task);
    }
    return tasks;
}

pub fn run(c: Ctx) !void {
    const out = c.out;
    var arena = std.heap.ArenaAllocator.init(c.gpa); // every string, list and count: freed at once
    defer arena.deinit();
    const a = arena.allocator();

    if (loadTasks(a, c.io, "missing.txt")) |_| {} else |err| try out.print("missing.txt: {t}\n", .{err});

    const tasks = (try loadTasks(a, c.io, "tasks.txt")).items;
    var done: usize = 0;
    for (tasks) |task| {
        if (task.isDone()) done += 1;
    }
    try out.print("{d} tasks, {d} done ({d}%)\n", .{ tasks.len, done, lesson03.percent(done, tasks.len) });
    for (tasks) |task| {
        if (task.kind == .urgent and !task.isDone()) try out.print("{f}\n", .{task});
    }

    const counts = try lesson12.countTags(a, tasks);
    lesson12.rank(counts);
    var widest: usize = 0;
    for (counts) |tc| widest = @max(widest, lesson08.width(tc.tag));
    for (lesson12.topN(lesson12.TagCount, counts, 3)) |tc| {
        try out.writeAll(tc.tag);
        try out.splatByteAll(' ', widest - lesson08.width(tc.tag) + 1); // pad by characters, not bytes
        try out.splatBytesAll("█", lesson05.barLength(tc.count, counts[0].count, .{}));
        try out.print(" {d}\n", .{tc.count});
    }

    if (build_options.bug == 13) {
        // the compiler: openFile gives "an error or a File"; without try there's no File to close
        const file = std.Io.Dir.cwd().openFile(c.io, "tasks.txt", .{});
        file.close(c.io);
    }
}
