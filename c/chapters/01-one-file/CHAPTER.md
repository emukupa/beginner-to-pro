# Chapter 01 — The whole tracker in one file (Safe C)

**Video:** Safe C: Beginner to Pro (tag `video/c-001`)

**Goal:** write `c/one-file/tracker.c`, the same task tracker as `python/tasks.py`, in C23. The reference is
the Python version: the contract checks that every byte of output, every exit code and the tasks
file afterwards are the same.

## The Safe C rules

C does nothing for you, so we make the tools check what Python checked for us:

1. **Strict build.** `-Wall -Wextra -Wpedantic -Wconversion -Wshadow -Werror`: every warning stops
   the build. `-Wconversion` catches the quiet number-type changes that cause most C bugs.
2. **Sanitizers on every test run.** AddressSanitizer stops the program the moment it reads or
   writes outside memory it owns; UBSan stops it on undefined behaviour (overflow, bad shifts).
3. **No leaks.** `make leaks` runs the tracker under macOS's `leaks` tool (ASan can't check leaks
   on macOS; on Linux it does).
4. **No unbounded string functions.** Never `gets`, `strcpy`, `strcat`, `sprintf`, `atoi`. Copy with
   an explicit length (`memcpy`), format with `snprintf`, read lines with `getline`.
5. **Every allocation checked and owned.** Every `malloc`/`realloc` goes through `checked()`. Every
   pointer that owns memory says so in a comment and is freed exactly once.
6. **Lengths travel with their buffers,** as `size_t`, never `int`.
7. **Results that must be checked are `[[nodiscard]]`,** so ignoring one is a compile error.

**Names:** a struct keeps a lowercase tag and gets a PascalCase name in the same declaration,
`typedef struct task { ... } Task;`. Code uses the short name (`Task *t`); the tag is there so a
header can name the struct before it's defined (`typedef struct tasklist TaskList;`). Functions are
snake_case and start with the type they work on (`tasklist_push`, `task_is_done`).

## Concepts, mapped from Python

| Python | C |
| --- | --- |
| `str` and its methods | `char *` plus our own `strip`, `lower`, `copy_text` |
| `list` | a growable array: pointer, length, capacity, `realloc` doubling |
| `class Task` | `typedef struct task { ... } Task` |
| `UrgentTask(Task)` | no inheritance: a `kind` field (`TASK_PLAIN`, `TASK_URGENT`) |
| `None` from `parse_line` | `bool` return, the task through a pointer |
| `try`/`except ValueError` | functions that return `false`, checked by the caller |
| `with open(...)` | `fopen` + `fclose`, checking for `nullptr` |
| `round()` (halves to even) | `nearbyint` |
| `sorted(..., key=lambda ...)` (stable) | `stable_sort` with a function pointer as the comparator, because `qsort` isn't stable |
| a status string, compared with `==` | `enum task_status : unsigned char` (C23 picks the storage) |
| `raise` / a traceback | a variadic `[[noreturn]] fail("Couldn't find %s", path)` |
| `FileNotFoundError` vs other errors | `enum load_result { LOAD_OK, LOAD_NOT_FOUND, LOAD_UNREADABLE }` |
| module-level constants | `constexpr` (C23), checked with `static_assert` |
| `list.append` on any list | one `PUSH` macro, typed with `typeof` (C23) |
| `input()` | `fputs` the prompt, `fflush`, `getline` |
| `int(text)` | a hand-written parser: sign, digits, `_` between digits, overflow capped |
| `datetime.date.today()` | `time`, `localtime_r`, `strftime` |
| garbage collection | `free`, once, by the owner |

## Tasks

Build it in the same order as the Python file: helpers, the `Task` type, `parse_line`,
`load_tasks`, `add_tasks` and `append_titles`, `top_tags`, `draw_chart`, then `main`.

## Done when

```bash
cd c/one-file
make check     # 8 passes, under AddressSanitizer and UBSan
make leaks     # no leaks
```

Compare with `git diff course/c/01-one-file/end`.
