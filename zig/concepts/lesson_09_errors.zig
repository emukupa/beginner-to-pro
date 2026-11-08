// Lesson 09: errors. A function that can fail says so in its return type: ParseError![]const u8
// is "an error from ParseError, or a []const u8". An error is a value, not an exception, and the
// compiler won't let you use the result, or drop it, until you've said what happens on failure.
// `try` passes the error up, `catch` handles it here, and `errdefer` undoes work when one leaves.

const std = @import("std");
const build_options = @import("build_options");
const Ctx = @import("main.zig").Ctx;
const lesson08 = @import("lesson_08_strings.zig");

// Everything that can go wrong reading a task line. Lesson 11 uses these.
pub const ParseError = error{ NotATask, NoClosingBracket };

// "[done.] Call mom" -> "done.". Errors instead of a sentinel value or a flag in a global.
pub fn rawStatus(line: []const u8) ParseError![]const u8 {
    const s = std.mem.trim(u8, line, " ");
    if (!std.mem.startsWith(u8, s, "[")) return error.NotATask;
    const close = std.mem.findScalar(u8, s, ']') orelse return error.NoClosingBracket;
    return s[1..close];
}

// try: "if this failed, return the same error from here". The error set is worked out for you
// (that's the bare ! in the return type), and here it's ParseError.
fn isDone(line: []const u8) !bool {
    const status = try rawStatus(line);
    return lesson08.sameWord(lesson08.cleanStatus(status), "done");
}

const Board = struct {
    titles: [5][]const u8 = undefined,
    len: usize = 0,

    // Adds both or neither: if the second add fails, errdefer takes the first one back out.
    // C writes this with `goto cleanup`; C3 with `defer catch`.
    fn addPair(board: *Board, a: []const u8, b: []const u8) error{Full}!void {
        try board.add(a);
        errdefer board.len -= 1; // runs only if we leave this function with an error
        try board.add(b);
    }

    fn add(board: *Board, title: []const u8) error{Full}!void {
        if (board.len == board.titles.len) return error.Full;
        board.titles[board.len] = title;
        board.len += 1;
    }
};

pub fn run(c: Ctx) !void {
    const out = c.out;
    for ([_][]const u8{ "[done.] Call mom", "notes", "[todo Fix bug" }) |line| {
        // if/else with two captures: the value when it worked, the error when it didn't.
        if (rawStatus(line)) |status| {
            try out.print("\"{s}\": status \"{s}\"\n", .{ line, status });
        } else |err| {
            try out.print("\"{s}\": {t}\n", .{ line, err }); // {t} prints an error's (or enum's) name
        }
    }

    // catch with a fallback value, or catch |err| and decide by the error.
    const done = isDone("notes") catch false;
    try out.print("isDone(\"notes\") catch false = {}\n", .{done});
    const why = rawStatus("[todo Fix bug") catch |err| switch (err) {
        error.NotATask => "not a task",
        error.NoClosingBracket => "no ']'",
    };
    try out.print("caught and explained: {s}\n", .{why});

    // An optional is "maybe nothing"; an error union is "maybe a reason why not". orelse and
    // catch are the matching pair for giving a fallback.
    const close: ?usize = std.mem.findScalar(u8, "no bracket", ']');
    try out.print("findScalar gives ?usize: {?d}, so orelse 0 = {d}\n", .{ close, close orelse 0 });

    var board: Board = .{};
    try board.addPair("Buy groceries", "Call mom");
    try board.addPair("Fix login bug", "Book flights");
    board.addPair("Review pull request", "Pay rent") catch |err| try out.print("third pair: {t}", .{err});
    try out.print(", and the board still holds {d} titles, not 5\n", .{board.len});

    if (build_options.bug == 9) {
        rawStatus("notes"); // the compiler: an error union can't be dropped on the floor
    }
}
