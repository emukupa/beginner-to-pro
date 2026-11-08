# Zig

The task tracker in [Zig](https://ziglang.org): C's model (no garbage collector, pointers, manual
memory, and it calls C directly) with error unions, `defer`/`errdefer`, allocators you pass in,
safety-checked builds and `comptime` built in. Needs Zig 0.16.0 (`brew install zig`); the build
script is `build.zig`, so there's no Makefile.

| Folder | What | Chapter |
| --- | --- | --- |
| [`concepts/`](concepts/) | one lesson per file, run by `main.zig`: `zig build run` runs them all, `zig build run -- 7` one, `zig build run -Dbug=7 -- 7` with its mistake | 00 |
| [`one-file/`](one-file/) | the whole tracker in `tracker.zig` | 01 |

```bash
cd zig/concepts
zig build run                   # every lesson, in Debug (Zig's safe mode)
zig build run -Dbug=7 -- 7      # lesson 7 with its mistake compiled in
zig build test                  # the tests inside the lessons
```

```bash
cd zig/one-file
zig build check                 # the contract: must match Python byte for byte
```

| Chapter | Start | End | Video |
| --- | --- | --- | --- |
| [00 Concepts](chapters/00-concepts/CHAPTER.md) | `course/zig/00-concepts/start` | `course/zig/00-concepts/end` | `video/zig-000` |
| [01 One file](chapters/01-one-file/CHAPTER.md) | `course/zig/01-one-file/start` | `course/zig/01-one-file/end` | `video/zig-001` |
