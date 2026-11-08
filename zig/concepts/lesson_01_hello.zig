// Lesson 01: a Zig program is made of files, and every file is a struct. main.zig imports this one
// with @import("lesson_01_hello.zig") and calls its run(). Only what's marked `pub` can be seen
// from outside the file; everything else stays private to it.

const build_options = @import("build_options"); // made by build.zig: holds the -Dbug number
const Ctx = @import("main.zig").Ctx;

pub fn run(c: Ctx) !void {
    const out = c.out; // a writer: printing is something you're handed, not a global
    try out.print("Hello from Zig.\n", .{}); // print: a format, then a tuple of values
    try out.print("{s} has {d} lessons.\n", .{ "This course", 14 }); // {s} a string, {d} a number
    try out.writeAll("No formatting at all, "); // writeAll: the bytes as they are
    try out.print("so this finishes the line.\n", .{});
    // `try` is there because writing can fail (a closed pipe, a full disk). Zig won't let you
    // ignore that; lesson 09 is about errors. The writer buffers what you print, and main.zig
    // calls flush() to hand it all to the terminal in one go.
    // std.debug.print is the quick way, straight to stderr with no writer: for debugging only.

    // The format string is checked while compiling, against the values you pass. C's printf
    // trusts you, and a missing argument reads whatever happens to be on the stack.
    if (build_options.bug == 1) {
        try out.print("{s} has {d} lessons.\n", .{"This course"}); // one value for two places
    }
    // Zig is strict in other ways too: an unused variable or parameter is an error, not a
    // warning, and so is a `var` you never change. `_ = x;` says "unused on purpose".
}
