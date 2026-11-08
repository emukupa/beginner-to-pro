# Chapter 01 — The whole tracker in one file (C3)

**Video:** C3: Beginner to Pro (tag `video/c3-001`)

**Goal:** write `c3/one-file/tracker.c3`, the same task tracker as `python/tasks.py` and
`c/one-file/tracker.c`. Python is the reference: the contract checks every byte of output, every
exit code and the tasks file afterwards.

```bash
cd c3/one-file
make            # build/tracker, in safe mode (-O0): bounds, null and contract checks on
make run        # run it on tasks.txt here
make check      # the 8 contract cases
make leaks      # one full run under macOS's leaks tool
```

## Concepts, mapped from Python and C

| Python | C | C3 |
| --- | --- | --- |
| `str` and its methods | `char *` plus our own `strip`, `lower`, `copy_text` | `String` slices: `trim`, `trim_charset`, `to_lower_copy` |
| `list` | a growable struct and a `PUSH` macro | `List{Task}`, a generic module |
| `class Task`, `UrgentTask(Task)` | `typedef struct`, a `kind` field | `struct Task (Printable)`, a `Kind` enum, `to_format` |
| a status string | `enum task_status : unsigned char` | `enum Status : char (String word)`: each value carries its word |
| `None` from `parse_line` | `bool` return, the task through a pointer | `Task?`: a task or the `NOT_A_TASK` excuse |
| `try`/`except FileNotFoundError` | `enum load_result` | `void?`, passing on `io::FILE_NOT_FOUND` with `!` |
| `raise ValueError` from `top_tags` | `false` | the `NO_TOP_TAGS` excuse, with `??` for the fallback |
| `with open(...)` | `fopen` ... `fclose` | `file::open(...)!` and `defer f.close()` |
| `round()` (halves to even) | `nearbyint` | `math::roundeven` |
| `sorted(..., key=...)` (stable) | a hand-written stable sort | `sort::mergesort` (stable) with a lambda |
| garbage collection | `free`, once, by the owner | one `@pool` for the whole run: every allocation uses `tmem` |
| module constants | `constexpr` and `static_assert` | `const` and `$assert` |
| `input()` | `fputs`, `fflush`, `getline` | `io::print`, `flush`, `io::treadline` |
| `int(text)` | a hand-written parser | a hand-written parser returning `long?` (C3's `to_long` accepts other forms) |

## Memory: one pool for the whole run

The C version tracks an owner for every allocation and frees each once. The tracker's data lives
exactly as long as one run, so the C3 version runs `main` inside `@pool()` and allocates everything
with `tmem`. Every function that keeps text takes the allocator as a parameter (`parse_line(line,
a)`), so the caller decides how long it lives. Nothing is freed by hand, and nothing can leak.

## Done when

```bash
cd c3/one-file
make check     # 8 passes
make leaks     # no leaks
```

Compare with `git diff course/c3/01-one-file/end`.
