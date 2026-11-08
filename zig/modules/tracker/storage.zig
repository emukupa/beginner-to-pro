// Reading and writing the tasks file. The only file that opens files.

const std = @import("std");
const Allocator = std.mem.Allocator;
const Io = std.Io;
const Task = @import("models.zig").Task;
const parsing = @import("parsing.zig");

// Every task in the file; lines that aren't tasks are skipped. error.FileNotFound and friends come
// straight from openFile, passed on by `try`.
pub fn loadTasks(a: Allocator, io: Io, path: []const u8) !std.ArrayList(Task) {
    const file = try Io.Dir.cwd().openFile(io, path, .{});
    defer file.close(io); // however we leave
    var buffer: [64 * 1024]u8 = undefined; // the longest line we accept
    var reader = file.reader(io, &buffer);
    var tasks: std.ArrayList(Task) = .empty;
    while (try reader.interface.takeDelimiter('\n')) |line| {
        if (try parsing.parseLine(a, line)) |task| try tasks.append(a, task);
    }
    return tasks;
}

// "[todo] title" lines on the end of the file.
pub fn appendTitles(io: Io, path: []const u8, titles: []const []const u8) !void {
    const file = try Io.Dir.cwd().createFile(io, path, .{ .truncate = false });
    defer file.close(io);
    var buffer: [4096]u8 = undefined;
    var writer = file.writer(io, &buffer);
    try writer.seekTo(try file.length(io)); // Python's "a": write after what's already there
    for (titles) |title| try writer.interface.print("[todo] {s}\n", .{title});
    try writer.interface.flush();
}

// True if this line holds the task: the same title and status after parsing.
fn holds(a: Allocator, line: []const u8, task: Task) !bool {
    const found = (try parsing.parseLine(a, line)) orelse return false;
    return std.mem.eql(u8, found.title, task.title) and found.status == task.status;
}

// Rewrites the line holding this task as [done], leaving every other byte of the file alone. The
// whole file is written to a new file beside it, then renamed over the old one: a rename is atomic,
// so the file is never left half-written. On any error the old file is untouched.
pub fn markDone(a: Allocator, io: Io, path: []const u8, task: Task) !void {
    const dir = Io.Dir.cwd();
    const old = try dir.statFile(io, path, .{});
    const data = blk: {
        const file = try dir.openFile(io, path, .{});
        defer file.close(io);
        var buffer: [4096]u8 = undefined;
        var reader = file.reader(io, &buffer);
        break :blk try reader.interface.allocRemaining(a, .unlimited); // every byte, endings and all
    };

    var suffix: [8]u8 = undefined;
    io.random(&suffix);
    const temp = try std.fmt.allocPrint(a, "{s}.{x}", .{ path, suffix }); // a name nobody else is using
    const file = try dir.createFile(io, temp, .{ .exclusive = true });
    errdefer dir.deleteFile(io, temp) catch {}; // only if we leave with an error: the half-made file goes
    defer file.close(io); // always: the file is closed however we leave
    try file.setPermissions(io, old.permissions); // keep the old file's permissions

    var buffer: [4096]u8 = undefined;
    var writer = file.writer(io, &buffer);
    const out = &writer.interface;
    var changed = false;
    var start: usize = 0;
    while (start < data.len) {
        const end = if (std.mem.findScalarPos(u8, data, start, '\n')) |i| i + 1 else data.len;
        const line = data[start..end]; // the line's own ending stays with it
        start = end;
        const open = std.mem.findScalar(u8, line, '[') orelse 0;
        const close = std.mem.findScalarPos(u8, line, open, ']');
        if (changed or close == null or !try holds(a, line, task)) {
            try out.writeAll(line);
            continue;
        }
        try out.writeAll(line[0..open]); // any spaces before the bracket
        try out.writeAll("[done]");
        try out.writeAll(line[close.? + 1 ..]); // the title, tags and line ending
        changed = true;
    }
    try out.flush();
    try file.sync(io); // on the disk before it replaces anything
    try dir.rename(temp, dir, path, io); // atomic: readers see the old file or the new one
}
