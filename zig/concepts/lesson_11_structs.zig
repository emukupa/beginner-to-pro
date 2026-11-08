// Lesson 11: structs, enums and unions. Functions declared inside a struct or enum are its
// methods, called with a dot. An enum is a set of names (and @tagName turns one back into text).
// A tagged union holds exactly one of several kinds of value and remembers which, so a switch on
// it must handle every kind, and reading the wrong kind is caught.

const std = @import("std");
const Allocator = std.mem.Allocator;
const build_options = @import("build_options");
const Ctx = @import("main.zig").Ctx;
const lesson08 = @import("lesson_08_strings.zig");
const lesson09 = @import("lesson_09_errors.zig");

pub const Status = enum(u8) { // stored in one byte
    todo,
    done,
    other,

    // "DONE", "done." or "[ todo ]" -> a Status. Messy files are the norm.
    pub fn parse(raw: []const u8) Status {
        const word = lesson08.cleanStatus(raw);
        if (lesson08.sameWord(word, "done")) return .done;
        if (lesson08.sameWord(word, "todo")) return .todo;
        return .other;
    }
};

pub const Kind = enum { plain, urgent };

pub const Task = struct {
    title: []const u8, // these three are owned by the task: deinit frees them
    tags: []const []const u8,
    status: Status,
    kind: Kind = .plain, // a default: a task is plain unless it says otherwise

    pub fn isDone(task: Task) bool {
        return task.status == .done;
    }

    // How a Task prints with {f}: "[x] Title", and "  !!" on the end of an urgent one.
    pub fn format(task: Task, w: *std.Io.Writer) std.Io.Writer.Error!void {
        try w.print("[{s}] {s}{s}", .{ if (task.isDone()) "x" else " ", task.title, if (task.kind == .urgent) "  !!" else "" });
    }

    pub fn deinit(task: Task, gpa: Allocator) void {
        for (task.tags) |tag| gpa.free(tag);
        gpa.free(task.tags);
        gpa.free(task.title);
    }
};

// "[done.] Call mom #family" -> a Task, or an error. Everything it keeps is copied with the
// allocator you pass, so the caller decides how long the task lives. The errdefers free what was
// built so far if a later step fails: nothing leaks on the way out.
pub fn parseTask(gpa: Allocator, line: []const u8) !Task {
    const raw = try lesson09.rawStatus(line);
    const s = std.mem.trim(u8, line, " ");
    const rest = s[std.mem.findScalar(u8, s, ']').? + 1 ..]; // .? is safe: rawStatus found the ']'

    var title: std.ArrayList(u8) = .empty; // a growable list of bytes: lesson 12 has more
    errdefer title.deinit(gpa);
    var tags: std.ArrayList([]const u8) = .empty;
    errdefer {
        for (tags.items) |tag| gpa.free(tag);
        tags.deinit(gpa);
    }
    var kind: Kind = .plain;
    var words = std.mem.tokenizeScalar(u8, rest, ' ');
    while (words.next()) |word| {
        if (word[0] == '#') {
            const tag = try std.ascii.allocLowerString(gpa, std.mem.trim(u8, word, "#.,")); // "#Work." -> "work"
            errdefer gpa.free(tag);
            if (std.mem.eql(u8, tag, "urgent")) kind = .urgent;
            try tags.append(gpa, tag);
            continue;
        }
        if (title.items.len > 0) try title.append(gpa, ' ');
        try title.appendSlice(gpa, word);
    }
    const owned_title = try title.toOwnedSlice(gpa);
    errdefer gpa.free(owned_title);
    return .{ .title = owned_title, .tags = try tags.toOwnedSlice(gpa), .status = Status.parse(raw), .kind = kind };
}

// What the tracker can be asked to do. Each kind carries what it needs, and nothing else: an add
// carries a title, a done carries a task number, an undo carries nothing.
pub const Command = union(enum) {
    add: []const u8,
    done: usize,
    undo,
    list,
};

pub fn run(c: Ctx) !void {
    const out = c.out;
    for ([_][]const u8{ "[done.] Call mom #family", "[ todo ] Finish report #work #URGENT", "notes" }) |line| {
        const task = parseTask(c.gpa, line) catch |err| {
            try out.print("{s}: {t}\n", .{ line, err });
            continue;
        };
        defer task.deinit(c.gpa);
        try out.print("{f}   status {t} ({d} byte), {d} tags, first \"{s}\"\n", .{ task, task.status, @sizeOf(Status), task.tags.len, task.tags[0] });
    }
    try out.print("@tagName(.urgent) = \"{s}\", @intFromEnum(Status.done) = {d}\n", .{ @tagName(Kind.urgent), @intFromEnum(Status.done) });

    const commands = [_]Command{ .{ .add = "Pay rent" }, .{ .done = 2 }, .undo, .list };
    for (commands) |cmd| {
        switch (cmd) { // every kind must be handled; |title| and |n| capture what each carries
            .add => |title| try out.print("add \"{s}\"", .{title}),
            .done => |n| try out.print("mark task {d} done", .{n}),
            .undo, .list => try out.print("{t}", .{cmd}), // {t} prints which kind it is
        }
        try out.writeAll(if (cmd == .list) "\n" else ", ");
    }
    try out.print("a Command is {d} bytes: the biggest kind plus a tag saying which one\n", .{@sizeOf(Command)});

    if (build_options.bug == 11) {
        try out.flush(); // so the lines above show before the crash
        for (commands) |cmd| { // assumes every command is a done, without asking
            try out.print("{d}\n", .{cmd.done}); // a safety check: the first one is an add
        }
    }
}

test "parseTask frees everything, even when it fails" {
    const task = try parseTask(std.testing.allocator, "[DONE] Fix login bug #work #Urgent.");
    defer task.deinit(std.testing.allocator);
    try std.testing.expectEqualStrings("Fix login bug", task.title);
    try std.testing.expectEqual(.urgent, task.kind);
    try std.testing.checkAllAllocationFailures(std.testing.allocator, struct {
        fn parse(gpa: Allocator) !void {
            (try parseTask(gpa, "[todo] Book flights #travel #home")).deinit(gpa);
        }
    }.parse, .{});
}
