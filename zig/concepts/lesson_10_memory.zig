// Lesson 10: memory. Zig has no malloc and no hidden allocations: anything that needs memory takes
// an Allocator as a parameter, so you can see from a function's signature that it allocates, and
// the caller picks the strategy. `defer` frees right next to the allocation, `errdefer` frees only
// if something after it fails, and the DebugAllocator tells you what you forgot to free.

const std = @import("std");
const Allocator = std.mem.Allocator;
const build_options = @import("build_options");
const Ctx = @import("main.zig").Ctx;

// Copies of both strings, or neither. If the second copy fails, errdefer frees the first:
// nothing leaks however we leave. The caller owns the result and frees both.
fn copyPair(gpa: Allocator, a: []const u8, b: []const u8) ![2][]u8 {
    const first = try gpa.dupe(u8, a);
    errdefer gpa.free(first);
    const second = try gpa.dupe(u8, b);
    return .{ first, second };
}

pub fn run(c: Ctx) !void {
    const out = c.out;
    // c.gpa is the program's general-purpose allocator, set up by Zig before main. In a Debug
    // build it's a DebugAllocator too, and it checks for leaks when the program ends.
    const kept = try c.gpa.dupe(u8, "Call mom");
    defer c.gpa.free(kept); // runs when run() ends, however it ends
    try out.print("copied \"{s}\" onto the heap\n", .{kept});

    // An arena frees everything at once when it's torn down: no free for each allocation.
    // Good for work with a clear end, like one command in the tracker.
    {
        var arena = std.heap.ArenaAllocator.init(c.gpa);
        defer arena.deinit();
        const temp = arena.allocator();
        const shout = try std.ascii.allocUpperString(temp, "call mom");
        const tags = try temp.alloc([]const u8, 3);
        tags[0] = "work";
        try out.print("arena copy \"{s}\" and {d} slots, freed together when the block ends\n", .{ shout, tags.len });
    }

    // A fixed buffer allocator hands out a buffer you already have, here 64 bytes on the stack.
    // Asking for more than it holds is an error, not a crash.
    var bytes: [64]u8 = undefined;
    var fixed = std.heap.FixedBufferAllocator.init(&bytes);
    const small = fixed.allocator().alloc(u8, 40);
    const big = fixed.allocator().alloc(u8, 40);
    try out.print("40 bytes from 64: {s}; 40 more: {s}\n", .{ if (small) |_| "ok" else |_| "no", if (big) |_| "ok" else |err| @errorName(err) });

    // FailingAllocator fails on purpose, here on the second allocation: copyPair's errdefer
    // frees the first copy, and the DebugAllocator underneath confirms nothing leaked.
    var debug: std.heap.DebugAllocator(.{}) = .init;
    var failing = std.testing.FailingAllocator.init(debug.allocator(), .{ .fail_index = 1 });
    if (copyPair(failing.allocator(), "work", "home")) |pair| {
        failing.allocator().free(pair[0]);
        failing.allocator().free(pair[1]);
    } else |err| try out.print("copyPair: {t}, after {d} allocation and {d} free\n", .{ err, failing.allocations, failing.deallocations });

    // The DebugAllocator remembers every allocation and where it was made, so it can name each
    // one that was never freed. Tests use one (std.testing.allocator) to prove there are no leaks.
    const gpa = debug.allocator();
    const a = try gpa.dupe(u8, "work");
    const b = try gpa.dupe(u8, "home");
    gpa.free(a);
    if (build_options.bug != 10) gpa.free(b); // bug 10 forgets this one: the DebugAllocator reports it
    try out.flush(); // a leak report goes to stderr; this puts it after the lines above
    const leaks = debug.detectLeaks();
    try out.print("leaks: {d}\n", .{leaks});
    debug.deinitWithoutLeakChecks(); // already checked
    if (leaks > 0) return error.MemoryLeaked; // fail loudly, as a test would
}
