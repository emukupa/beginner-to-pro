// One line of text into a task: the only place that knows the file format.

const std = @import("std");
const Allocator = std.mem.Allocator;
const models = @import("models.zig");
const Task = models.Task;
const Status = models.Status;
const Kind = models.Kind;

pub const tag_marker = '#'; // marks a word as a tag: "#work"
pub const whitespace = " \t\n\r\x0b\x0c";

// Not pub: only this file can call it. C needed static; Zig makes everything private by default.
fn statusOf(word: []const u8) Status {
    if (std.ascii.eqlIgnoreCase(word, "done")) return .done;
    if (std.ascii.eqlIgnoreCase(word, "todo")) return .todo;
    return .other;
}

// "[done.] Call mom #family" -> a Task, or null if the line isn't a task (Python's None). Every
// string the task keeps is copied with `a`; an error only if memory runs out.
pub fn parseLine(a: Allocator, line: []const u8) Allocator.Error!?Task {
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
