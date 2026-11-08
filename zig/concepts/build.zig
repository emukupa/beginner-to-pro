// Zig builds Zig with Zig: this file is the build script, and `zig build` runs it.
//
//   zig build run                   every lesson         zig build run -- 7     just lesson 7
//   zig build run -Dbug=7 -- 7      lesson 7 with its mistake compiled in, to watch Zig catch it
//
// The default build mode is Debug, Zig's safe mode: overflow, bounds, null and `unreachable` are
// checked as the program runs, and the allocator reports leaks. ReleaseFast drops those checks.

const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    // -Dbug=N: which lesson's mistake to compile in (0, the default, means none).
    const bug = b.option(u8, "bug", "Compile in lesson N's deliberate mistake") orelse 0;
    const options = b.addOptions();
    options.addOption(u8, "bug", bug);

    const exe = b.addExecutable(.{
        .name = "concepts",
        .root_module = b.createModule(.{
            .root_source_file = b.path("main.zig"),
            .target = target,
            .optimize = optimize,
        }),
    });
    exe.root_module.addOptions("build_options", options); // lessons read it with @import("build_options")
    b.installArtifact(exe);

    const run = b.addRunArtifact(exe);
    run.setCwd(b.path(".")); // so lesson 13 finds tasks.txt
    if (b.args) |args| run.addArgs(args);
    b.step("run", "Run the lessons (all, or the numbers after --)").dependOn(&run.step);

    const tests = b.addTest(.{ .root_module = exe.root_module });
    b.step("test", "Run the tests in the lessons").dependOn(&b.addRunArtifact(tests).step);
}
