// The build script: `zig build` runs it. Debug, the default, is Zig's safe mode: overflow, bounds,
// null and `unreachable` are checked as the program runs, and the debug allocator reports leaks.
//
//   zig build                  zig-out/bin/tracker
//   zig build run              build, then run it here (zig build run -- work.txt passes arguments)
//   zig build check            the contract against it. A leak would print to stderr and fail it.
//   zig build -Doptimize=ReleaseFast    optimised, the safety checks compiled out

const std = @import("std");

pub fn build(b: *std.Build) void {
    const exe = b.addExecutable(.{
        .name = "tracker",
        .root_module = b.createModule(.{
            .root_source_file = b.path("tracker.zig"),
            .target = b.standardTargetOptions(.{}),
            .optimize = b.standardOptimizeOption(.{}),
        }),
    });
    b.installArtifact(exe);

    const run = b.addRunArtifact(exe);
    run.setCwd(b.path("."));
    if (b.args) |args| run.addArgs(args);
    b.step("run", "Run the tracker on tasks.txt here").dependOn(&run.step);

    // The contract runs each case in its own folder, so it gets the installed program's full path.
    const check = b.addSystemCommand(&.{"../../contract/run.sh"});
    check.addArg(b.getInstallPath(.bin, "tracker"));
    check.setCwd(b.path("."));
    check.step.dependOn(b.getInstallStep());
    b.step("check", "Run the contract against the tracker").dependOn(&check.step);
}
