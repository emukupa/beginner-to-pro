# Chapter 02 — Modules: a file is a struct (Zig)

**Video:** Zig: Modules (tag `video/zig-002`)

**Goal:** build `zig/modules/`: the code of `zig/one-file/tracker.zig` split into
`zig/modules/tracker/`, one file per job, the same split as Python's chapter 02, without changing a
byte of what the program does. The contract proves it.

```bash
cd zig/modules
zig build check      # 8 passes
```

## Concepts

- **A file is a struct.** There's no `module` line and no header: `@import("parsing.zig")` returns the
  file as a struct, and you use its declarations through it, `parsing.parseLine(...)`.
- **Private by default.** Only declarations marked `pub` can be used from another file. `statusOf`
  in `parsing.zig` has no `pub`, so it's `parsing.zig`'s alone. C needed `static`; C3 needed `@private`.
- **One compile.** `build.zig` names one root file (`tracker/cli.zig`); the compiler follows the
  `@import`s from there and compiles the whole program as one unit, so there's nothing to link by
  hand and no list of sources to keep up to date.
- **Lazy analysis.** Zig only compiles what's used: an unused `pub fn` in a module is never even
  type-checked until something calls it.
- **Dependencies point one way.** Zig, like C and C3, allows two files to import each other, so the
  rule from Python's chapter 02 is ours to keep.

## The split

| File | Job | Imports of ours |
| --- | --- | --- |
| `models.zig` | `Status`, `Kind`, `Task` (with its `format` method) | nothing |
| `numbers.zig` | `roundHalfEven`, Python's rounding | nothing |
| `parsing.zig` | `parseLine`, `tag_marker`, `whitespace` | models |
| `storage.zig` | `loadTasks`, `appendTitles`: the only file that opens files | models, parsing |
| `tasklist.zig` | `addTasks`, `countTags`, the generic `top`, `topTags`, `summarize` | models, parsing |
| `chart.zig` | `drawChart(out: *Io.Writer, ...)`: draws to any writer | tasklist, numbers |
| `cli.zig` | `main`: the only file that reads input, prints to the screen, or exits | all of them |

## Done when

```bash
cd zig/modules
zig build check      # 8 passes
```

Compare with `git diff course/zig/02-modules/end`.
