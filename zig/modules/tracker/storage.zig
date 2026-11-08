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
