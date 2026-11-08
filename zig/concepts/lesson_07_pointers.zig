// Lesson 07: pointers and optionals. *T points at one T, &x takes an address and p.* follows it,
// as in C. What's different: a *T can never be null. "Maybe nothing" is its own type, ?T, and the
// compiler won't let you use a ?T until you've checked it.

const std = @import("std");
const build_options = @import("build_options");
const Ctx = @import("main.zig").Ctx;

const Task = struct {
    title: []const u8,
    done: bool = false,
};

// A pointer lets a function change the caller's value. Arguments alone are copies.
fn markDone(task: *Task) void {
    task.done = true; // no -> in Zig: the . follows the pointer for you
}

fn bump(n: *usize) void {
    n.* += 1; // .* is C's *n
}

// The first task whose title starts with `prefix`, or null when there isn't one. The ? in the
// return type tells every caller that "none" is a possible answer.
fn find(tasks: []Task, prefix: []const u8) ?*Task {
    for (tasks) |*task| {
        if (std.mem.startsWith(u8, task.title, prefix)) return task;
    }
    return null;
}

pub fn run(c: Ctx) !void {
    const out = c.out;
    var n: usize = 41;
    bump(&n);
    try out.print("bump(&n) made n {d}\n", .{n});

    var tasks = [_]Task{ .{ .title = "Call mom" }, .{ .title = "Fix login bug" } };
    markDone(&tasks[1]);
    try out.print("\"{s}\" done? {}\n", .{ tasks[1].title, tasks[1].done });

    // Three ways to open an optional: `if` with a capture, `orelse` for a fallback, and `.?`
    // when you're sure (a safe build checks you were right).
    if (find(&tasks, "Call")) |task| {
        task.done = true;
        try out.print("found \"{s}\" and marked it done\n", .{task.title});
    }
    const missing = find(&tasks, "Book");
    try out.print("\"Book...\" found? {}\n", .{missing != null});
    const title = if (missing) |task| task.title else "(no such task)";
    try out.print("its title: {s}\n", .{title});
    const fallback = find(&tasks, "Book") orelse &tasks[0];
    try out.print("orelse gives \"{s}\"\n", .{fallback.title});
    // An optional pointer costs nothing: null is the zero address, which a *T can never be.
    try out.print("a *Task is {d} bytes, a ?*Task is {d}\n", .{ @sizeOf(*Task), @sizeOf(?*Task) });

    // *const T: a pointer you can read through but not write through.
    const view: *const Task = &tasks[0];
    try out.print("read through a *const: {s}\n", .{view.title});

    if (build_options.bug == 7) {
        try out.flush(); // so the lines above show before the crash
        const task = find(&tasks, "Book").?; // a safety check: "attempt to use null value"
        try out.print("{s}\n", .{task.title});
    }
}
