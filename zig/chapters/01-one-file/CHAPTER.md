# Chapter 01 — The whole tracker in one file (Zig)

**Video:** Zig: Beginner to Pro (tag `video/zig-001`)

**Goal:** write `zig/one-file/tracker.zig`, the same task tracker as `python/tasks.py`, in Zig 0.16.
Python is the reference: the contract checks every byte of output, every exit code and the tasks
file afterwards.

```bash
cd zig/one-file
zig build            # zig-out/bin/tracker, in Debug: Zig's safe mode
zig build run        # run it on tasks.txt here
zig build check      # the 8 contract cases. A leak would be reported on stderr and fail them.
```

## Concepts, mapped from Python, C and C3

| Python | C | C3 | Zig |
| --- | --- | --- | --- |
| `str` | `char *` and helpers | `String` slices | `[]const u8` slices, `std.mem.trim`, `tokenizeAny` |
| `None` from `parse_line` | `bool` + out-pointer | `Task?` | `?Task` (an optional), inside an error union: `Allocator.Error!?Task` |
| exceptions | `enum load_result` | excuses and `!` | error unions and `try`; `catch \|err\|` in `main` chooses the message |
| `with open(...)` | `fopen`/`fclose` | `defer f.close()` | `defer file.close(io)` |
| garbage collection | `free`, once, by the owner | one `@pool` | one `ArenaAllocator` over the debug allocator; one `defer arena.deinit()` |
| a list | a growable struct | `List{Task}` | `std.ArrayList(Task)`, unmanaged: every `append` is handed the allocator |
| tag counts, first-seen order | a hand-written search | a `List` search | `std.array_hash_map.String(usize)`: a hash map that keeps insertion order |
| `sorted(key=...)` | hand-written stable sort | `mergesort` | `std.mem.sort` (stable) inside a `comptime T: type` generic `top` |
| `round()` | `nearbyint` | `math::roundeven` | `roundHalfEven`, written here: `@round` sends halves away from zero |
| printing a task | `printf` | `Printable` | a `format` method, printed with `{f}` |
| `input()` | `getline` | `treadline` | a buffered stdin reader and `takeDelimiter('\n')`, flushing the prompt first |
| constants | `constexpr` | `const`, `$assert` | `const` and a `comptime` block with `@compileError` |

## Nothing is hidden

Zig has no hidden allocations and no hidden I/O. `main` takes `std.process.Init`, which hands it
`io` (every file and terminal operation goes through it), the debug allocator, the arguments and
the environment. Output goes through a buffered writer that must be flushed, which is why `ask`
flushes the prompt before it waits.

## Done when

```bash
cd zig/one-file
zig build check      # 8 passes
```

Compare with `git diff course/zig/01-one-file/end`.
