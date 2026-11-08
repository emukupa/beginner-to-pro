// Zig concepts, one lesson per file. Every file is a struct of its own: @import gives it back, and
// this one imports them all and keeps them in a table, so it can run any of them.
//
//   zig build run                   every lesson         zig build run -- 7     just lesson 7
//   zig build run -Dbug=7 -- 7      lesson 7 with its mistake compiled in, to watch Zig catch it

const std = @import("std");

// What every lesson is handed. Zig has no hidden globals for output or memory: whoever needs to
// print gets a writer, whoever needs memory gets an allocator, whoever touches files gets an `io`.
pub const Ctx = struct {
    out: *std.Io.Writer,
    io: std.Io,
    gpa: std.mem.Allocator,
};

const Lesson = struct {
    title: []const u8,
    run: *const fn (Ctx) anyerror!void, // a pointer to a function that takes a Ctx and may fail
};

const lessons = [_]Lesson{
    .{ .title = "Hello", .run = @import("lesson_01_hello.zig").run },
    .{ .title = "Types and sizes", .run = @import("lesson_02_types.zig").run },
    .{ .title = "Numbers", .run = @import("lesson_03_numbers.zig").run },
    .{ .title = "Decisions and loops", .run = @import("lesson_04_control.zig").run },
    .{ .title = "Functions", .run = @import("lesson_05_functions.zig").run },
    .{ .title = "Arrays and slices", .run = @import("lesson_06_arrays.zig").run },
    .{ .title = "Pointers and optionals", .run = @import("lesson_07_pointers.zig").run },
    .{ .title = "Strings", .run = @import("lesson_08_strings.zig").run },
    .{ .title = "Errors", .run = @import("lesson_09_errors.zig").run },
    .{ .title = "Memory and allocators", .run = @import("lesson_10_memory.zig").run },
    .{ .title = "Structs, enums and unions", .run = @import("lesson_11_structs.zig").run },
    .{ .title = "Lists, maps and generics", .run = @import("lesson_12_collections.zig").run },
    .{ .title = "Files", .run = @import("lesson_13_files.zig").run },
    .{ .title = "Compile time", .run = @import("lesson_14_comptime.zig").run },
};

fn show(c: Ctx, i: usize) !void {
    try c.out.print("\n=== {d:0>2} {s} ===\n", .{ i + 1, lessons[i].title });
    try c.out.flush(); // the heading is on screen even if the lesson's mistake crashes it
    try lessons[i].run(c);
    try c.out.flush();
}

pub fn main(init: std.process.Init) !u8 {
    // Output goes through a buffer, and flush() hands it to the terminal: one write, not hundreds.
    var buffer: [4096]u8 = undefined;
    var stdout = std.Io.File.stdout().writer(init.io, &buffer);
    const c: Ctx = .{ .out = &stdout.interface, .io = init.io, .gpa = init.gpa };

    const args = try init.minimal.args.toSlice(init.arena.allocator());
    if (args.len == 1) {
        for (0..lessons.len) |i| try show(c, i);
        return 0;
    }
    for (args[1..]) |arg| {
        const n = std.fmt.parseInt(usize, arg, 10) catch 0; // not a number counts as no such lesson
        if (n < 1 or n > lessons.len) {
            std.debug.print("No lesson {s}: pick 1 to {d}.\n", .{ arg, lessons.len });
            return 1;
        }
        try show(c, n - 1);
    }
    return 0;
}

test {
    _ = lessons; // `zig build test` runs the tests inside every lesson this table imports
}
