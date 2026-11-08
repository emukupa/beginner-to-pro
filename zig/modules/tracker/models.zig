// What a task is. Imports nothing of ours: every other file builds on this one.
// In Zig a file *is* a struct: @import("models.zig") gives it back, and `pub` marks what others may use.

const std = @import("std");
const Io = std.Io;

pub const Status = enum { todo, done, other };

// Zig has no inheritance; Python's UrgentTask(Task) is a kind field.
pub const Kind = enum { plain, urgent };

pub const Task = struct {
    title: []const u8,
    tags: []const []const u8,
    status: Status,
    kind: Kind,
    created: []const u8 = "", // "YYYY-MM-DD" for tasks added this run, else ""

    pub fn isDone(t: Task) bool {
        return t.status == .done;
    }

    // How a task prints with {f}: "[ ] Title", and "  !!" on the end of an urgent one.
    pub fn format(t: Task, w: *Io.Writer) Io.Writer.Error!void {
        try w.print("[{s}] {s}{s}", .{ if (t.isDone()) "x" else " ", t.title, if (t.kind == .urgent) "  !!" else "" });
    }
};
