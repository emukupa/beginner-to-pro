# Chapter 00 — Zig concepts

**Video:** Zig: Concepts (tag `video/zig-000`)

**Goal:** learn Zig before building anything with it. Zig sits where C and C3 sit (no garbage
collector, pointers, manual memory, and it calls C directly) and takes the next step: errors are
values the compiler makes you handle, `defer` and `errdefer` replace C's `goto cleanup` and C3's
`defer catch`, nothing allocates without an allocator you pass in, overflow and bad indexes stop a
safe build instead of corrupting it, and `comptime` replaces both the preprocessor and generics.
`zig/concepts/` holds one lesson per file; every file is a struct of its own, and `main.zig`
imports them all into a table.

```bash
cd zig/concepts
zig build run                   # build, then run every lesson
zig build run -- 7              # just lesson 7 (or several: -- 3 13)
zig build run -Dbug=7 -- 7      # lesson 7 with its mistake compiled in: watch Zig catch it
zig build test                  # the tests inside the lessons
```

The default build mode is Debug, Zig's safe mode: integer overflow, array bounds, null unwraps,
inactive union fields and `unreachable` are checked as the program runs, and the DebugAllocator
reports leaks and double frees. `-Doptimize=ReleaseSafe` keeps those checks and optimises;
`ReleaseFast` and `ReleaseSmall` drop them.

`-Dbug=N` sets `build_options.bug`, a constant the compiler knows. Each lesson's mistake sits in
`if (build_options.bug == N) { ... }`, and a branch the compiler knows is never taken is never
compiled, so the mistake only exists when you ask for it.

## The lessons

| # | Lesson | Concepts | `-Dbug=N` shows | Caught by |
| --- | --- | --- | --- | --- |
| 01 | Hello | files are structs, `@import`, `pub`, a writer, `print` with `{s}`/`{d}`, `try`, buffering and `flush` | a format string with two places and one value | the compiler: `too few arguments` |
| 02 | Types and sizes | `u8`…`u128`, any width (`u7`, `u21`), `usize`, `@sizeOf`, `+%` wraps, `+\|` saturates, `@addWithOverflow`, widening is free, `@intCast` and `@truncate` | a `u8` counted past 255 | Debug safety check: `panic: integer overflow` |
| 03 | Numbers | `@divTrunc`/`@divFloor`, `@rem`/`@mod`, `@round` vs round-half-to-even (`percent`), `parseInt` gives an error union | `/` on a signed run-time integer | the compiler: `signed integers must use @divTrunc, @divFloor, or @divExact` |
| 04 | Decisions and loops | `if` and `switch` as expressions, ranges and lists in a prong, `for` with an index, `while` with a continue expression, labelled blocks and loops | a `switch` on an enum missing a value | the compiler: `switch must handle all possibilities` |
| 05 | Functions | constant parameters, a struct with defaults instead of default/named arguments, returning a struct, `std.debug.assert` | breaking `barLength`'s `assert(biggest > 0)` | Debug safety check: `panic: reached unreachable code` |
| 06 | Arrays and slices | `[_]T`, length in the type, slices `a[1..3]`/`a[2..]`, `\|*x\|` to change items, `++` and `**` | one past the end in a loop | Debug safety check: `panic: index out of bounds: index 4, len 4` |
| 07 | Pointers and optionals | `&`, `p.*`, changing the caller's value, `*const T`, `?*T`, `if (x) \|v\|`, `orelse`, `.?` | `.?` on a search that found nothing | Debug safety check: `panic: attempt to use null value` |
| 08 | Strings | `[]const u8`, literals as `*const [N:0]u8`, `std.mem.trim`/`findScalar`/`eql`/`startsWith`, `tokenizeScalar` vs `splitScalar`, `std.ascii`, `bufPrint`, UTF-8 width | comparing two strings with `==` | the compiler: `operator == not allowed for type '[]const u8'` |
| 09 | Errors | error sets, `E!T` and `!T`, `try`, `catch` with a value or a `switch`, `if … else \|err\|`, `{t}`, `errdefer` (add both or neither), optionals vs errors | calling `rawStatus` and dropping the result | the compiler: `error union is ignored` |
| 10 | Memory and allocators | `Allocator` as a parameter, `dupe`/`alloc`/`free`, `defer`, `errdefer`, arena, fixed buffer, `FailingAllocator`, `DebugAllocator` | a forgotten `free` | the DebugAllocator: `memory address … leaked` with the allocating stack trace; the lesson then fails with `error: MemoryLeaked` |
| 11 | Structs, enums and unions | methods, enums with methods and a backing type, `@tagName`/`@intFromEnum`, a `format` method for `{f}`, `parseTask` with an allocator and `errdefer`, `union(enum)` for commands | reading `.done` from a command that is an `add` | Debug safety check: `panic: access of union field 'done' while field 'add' is active` |
| 12 | Lists, maps and generics | `std.ArrayList(T)` (pass the allocator to each call), `std.array_hash_map.String` (keeps first-seen order) vs `StringHashMapUnmanaged` (doesn't), stable `std.mem.sort`, generic `topN(comptime T, …)` | freeing the counts twice | the DebugAllocator: `Double free detected` with three stack traces (allocated, freed, freed again); a second free of small memory is safe to skip, so the program carries on and exits 0 |
| 13 | Files | `std.Io.Dir.cwd().openFile(io, …)`, `defer file.close(io)`, a buffered reader, `takeDelimiter('\n')`, `error.FileNotFound`; a small tracker over `tasks.txt` | `openFile` without `try`, then `.close` | the compiler: `no field or member function named 'close' in 'error{…}!Io.File'` |
| 14 | Compile time | `comptime` blocks and `@compileError`, running `percent` while compiling, a function returning a type (`History(T, n)`), `anytype`, `inline for` over `@typeInfo` fields | a comptime check that fails | the compiler: `is the chart wide enough?` |

Pieces carry forward: lesson 03's `percent`, lesson 05's `barLength`, lesson 08's `cleanStatus`,
`sameWord` and `width`, lesson 09's `ParseError` and `rawStatus`, lesson 11's `Task` and
`parseTask` and lesson 12's `countTags`, `rank` and `topN` come together in lesson 13, which loads
`tasks.txt` and prints 6 tasks, 3 done (50%), the urgent task, and a chart of work, home and
urgent. Lesson 14's `History` reuses lesson 11's `Command`.

Some mistakes can't be switched on with `-Dbug`, because Zig rejects them before it looks at any
`if`: an unused local variable or parameter, a `var` that is never changed, and a name that
doesn't exist are errors in every build, whichever branch they sit in. Lesson 01 says so; try one
by hand.

## What C and C3 did, what Zig does

| C | C3 | Zig |
| --- | --- | --- |
| `#include` pastes text; one name space | modules with a prefix | every file is a struct; `@import` and `pub` (01) |
| `printf` trusts its arguments | `printf` that knows each argument's type | the format string is checked while compiling (01) |
| signed overflow is undefined | overflow wraps | overflow stops a safe build; `+%` wraps and `+\|` saturates on purpose (02) |
| `-7 / 2` rounds towards zero, silently | the same | signed `/` won't compile; pick `@divTrunc` or `@divFloor` (03) |
| `case` falls through unless you `break` | no fallthrough | no fallthrough, and a switch must cover every value (04) |
| comments say what a function needs | `@require` / `@ensure` | `std.debug.assert`, checked in safe builds (05) |
| an array decays to a pointer | slices with checked indexes | slices with checked indexes; the length is in an array's type (06) |
| any pointer may be `NULL` | pointers may be `null` | `*T` is never null; `?*T` must be unwrapped first (07) |
| `char *`, `strlen`, `strcmp` | `String` slices, `==` compares text | `[]const u8`; `==` refuses, `std.mem.eql` compares (08) |
| return codes, `errno`, `goto cleanup` | optionals with excuses, `defer catch` | error unions, `try`/`catch`, `errdefer` (09) |
| `malloc`/`free`, AddressSanitizer | allocators, `@pool`, a tracking allocator | an `Allocator` parameter everywhere, arenas, the DebugAllocator (10) |
| tagged unions by hand, unchecked | enums with values | `union(enum)`: switches must cover it, wrong reads are caught (11) |
| `void *` containers or macros | generic modules | functions that take a `comptime T: type` and return a type (12) |
| `#define`, `#if` | macros, `$if`, `$assert` | `comptime` Zig code, `@compileError` (14) |

## Choices the tracker doesn't make, and why

- **`std.StringHashMap`** counts as fast as anything, but hands its keys back in table order, and
  tied tags must keep file order. The tracker counts with `std.array_hash_map.String`, which keeps
  insertion order (lesson 12).
- **`std.mem.sortUnstable`** (pdqsort) is a little faster, but makes no promise about ties.
  `std.mem.sort` is a stable block sort in Zig 0.16, so ties keep first-seen order (lesson 12).
- **`std.debug.print`** is the quick way to print, but it goes to stderr, unbuffered. The tracker
  writes its output to stdout through a buffered writer and flushes it (lesson 01).
- **A global allocator** (`std.heap.page_allocator` called from anywhere) would be shorter; the
  tracker passes an `Allocator` to everything that allocates, so tests can hand it the testing
  allocator and catch leaks (lesson 10).
- **Interfaces built from function pointers** give run-time polymorphism; the tracker's commands
  are a tagged union, which the compiler can check (lesson 11).
- **`ReleaseFast`** removes the safety checks; the tracker always develops in Debug.

## Done when

```bash
cd zig/concepts && zig build run && zig build test && zig fmt --check .
```

runs every lesson cleanly, the tests pass, the formatting is Zig's own, and each
`zig build run -Dbug=N -- N` is caught as the table says.
