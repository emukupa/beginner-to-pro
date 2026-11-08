# Chapter 00 — C3 concepts

**Video:** C3: Concepts (tag `video/c3-000`)

**Goal:** learn C3 before building anything with it. C3 is C's model (the same types, pointers,
manual memory and speed, and it calls C directly) with the parts of C that went wrong most often
fixed in the language: modules instead of `#include`, slices that know their length, errors you
can't ignore, contracts, and macros that are part of the language. `c3/concepts/` holds one lesson
per file; each file is its own module, and `main.c3` imports them all.

```bash
cd c3/concepts
make              # build, then run every lesson
make 07           # just lesson 7
make 07 BUG=1     # lesson 7 with its mistake compiled in (-D BUG07): watch C3 catch it
```

The build uses `-O0`, C3's safe mode: array bounds, null pointers and contracts are checked as the
program runs. A release build (`-O2` and up) drops those checks.

## The lessons

| # | Lesson | Concepts | `BUG=1` shows | Caught by |
| --- | --- | --- | --- | --- |
| 01 | Hello | modules, `import`, `io::printn`/`printfn`, calling across modules | calling `printn` without `io::` | the compiler |
| 02 | Types and sizes | fixed-size integers everywhere, `sz`, `char` as a byte, overflow wraps (defined), widening is free, narrowing needs a cast | a `long` into an `int` | the compiler |
| 03 | Numbers | `/`, `%`, `math::round` vs `math::roundeven`, `"five".to_int()` gives an optional | `7 / 0` | the compiler |
| 04 | Decisions and loops | `switch` without fallthrough, switching on strings, `foreach` (with index, `foreach_r`), labelled `break` | | |
| 05 | Functions and contracts | default and named arguments, `=>` bodies, `@require`/`@ensure` | breaking a `@require` with constants | the compiler |
| 06 | Arrays and slices | fixed arrays, slices (`[1..2]`, `[:3]`), `foreach (&x : ...)`, checked indexes | one past the end | safe mode: a panic with a stack trace |
| 07 | Pointers | `&`, `*`, changing the caller's value, returning `null` | following `null` | safe mode: a panic |
| 08 | Strings | `String` as a slice, `trim`, `trim_charset`, `tsplit`, `to_lower_tcopy`, `DString`, UTF-8 width | | |
| 09 | Optionals and excuses | `T?`, `excuse { ... }`, `~` to fail, `!` to pass a failure on, `catch`, `try`, `??` | using a `String?` as a `String` | the compiler |
| 10 | Memory and allocators | `mem` and `tmem`, `@pool()`, `defer`, a `TrackingAllocator` | a forgotten `free` | the tracking allocator reports the leak |
| 11 | Structs, enums and methods | enums carrying values, `Type.method(&self)`, `Printable` and `to_format`, `inline` struct members, `parse_task` with an allocator parameter | | |
| 12 | Lists, maps and generics | `List{T}`, `HashMap` (no order), counting in first-seen order, a generic module of our own, stable `mergesort` | | |
| 13 | Files | `file::open`, `defer close`, `io::readline`, `io::FILE_NOT_FOUND`; a small tracker over `tasks.txt` | | |
| 14 | Compile time | `const`, `$assert`, macros (`@max`, `#expr`), `$Typeof`, `$if $feat(...)` | a failing `$assert` | the compiler |

Pieces carry forward: lesson 08's `clean_status`, `same_word` and `width`, lesson 09's excuses and
lesson 05's `bar_length` are used by lessons 11–13, which together load, count, rank and chart the
tasks file.

## What C3 fixes, lesson by lesson

| C | C3 |
| --- | --- |
| `#include` pastes text; one name space for everything | modules, called with their prefix (01) |
| `int` and `long` sizes depend on the machine; signed overflow is undefined | fixed sizes; overflow wraps (02) |
| `strtol` and checking `errno` | `to_int()` returns an optional (03) |
| `case` falls through unless you `break` | no fallthrough; empty cases share a body (04) |
| comments say what a function needs | `@require` / `@ensure`, checked (05) |
| an array decays to a pointer and forgets its length | slices carry their length; indexes are checked (06) |
| `char *` plus `strlen`, zero bytes, `strcpy` overflows | `String` slices; no copy until you ask (08) |
| return a `bool`, write through a pointer, hope the caller checks | `T?` can't be used until the excuse is handled (09) |
| `malloc`/`free`, found by AddressSanitizer | allocators you name, `@pool`, `defer`, a tracking allocator (10) |
| `#define` macros that evaluate arguments twice | macros in the language (14) |

## Choices the tracker doesn't make, and why

- **`HashMap`** is the fast way to count, but it doesn't keep insertion order, and tied tags must
  keep file order. The tracker counts into a `List` (lesson 12).
- **`quicksort`** isn't stable; `mergesort` is, so ties keep their order (lesson 12).
- **Interfaces with `@dynamic` methods** give run-time polymorphism; the tracker's urgent tasks are
  a `kind` field, like the C version, and `inline` shows the other route (lesson 11).
- **Release builds** (`-O2` and up) remove the safety checks; the tracker always develops in `-O0`.
- **`--sanitize=address`** exists in c3c, but the Homebrew build doesn't ship the runtime it needs;
  the tracking allocator covers leaks instead.

## Done when

```bash
cd c3/concepts && make
```

runs every lesson cleanly, and each `make NN BUG=1` is caught as the table says.
