# Chapter 02 — Modules: headers, source files and make (Safe C)

**Video:** [C Has No import: Header Files, the Linker and Make](https://youtu.be/bb3CNcl9JFE) on YouTube

**Goal:** build `c/modules/`: the code of `c/one-file/tracker.c` split into `c/modules/tracker/`, one `.h`/`.c` pair per job, the same split as
Python's chapter 02, without changing a byte of what the program does. The contract proves it.
The one-file version stays complete beside it, so you can compare the two at any time.

## Concepts

- **C has no import.** `#include "models.h"` pastes the header's text in. A header holds
  declarations (what exists); the `.c` file holds the definitions (how it works).
- **Translation units.** Each `.c` compiles on its own to a `.o` object file; the linker joins them
  and connects each call to its definition. A function declared but never defined is a link error,
  not a compile error.
- **`#pragma once`** stops a header being pasted twice into one file.
- **`static` means private.** A `static` function can only be used inside its own `.c` file, like a
  leading underscore that the compiler actually enforces. A constant in a header is
  `static constexpr`, so each file gets its own copy instead of two files fighting over one name.
- **Opaque types.** `tasklist.h` says only `typedef struct tasklist TaskList;`. Other files can hold
  a `TaskList *` and call its functions, but can't see or touch its fields.
- **Dependencies point one way.** Headers can include each other in a circle and C won't stop you,
  so the rule from Python's chapter 02 matters even more here.
- **make** rebuilds only what changed: each `.o` depends on its `.c` and, through `-MMD`, on every
  header it includes. Touch `chart.h` and exactly `chart.c` and `cli.c` recompile.

## The split

| Files | Job | Includes |
| --- | --- | --- |
| `text.h/.c` | what Python has built in: `fail()`, `checked()`, the `PUSH` macro, `stable_sort`, the string helpers, `parse_whole_number` | nothing |
| `models.h/.c` | `Task`, `StringList`, `task_write` | nothing of ours |
| `parsing.h/.c` | `parse_line` | `models`, `text` |
| `tasklist.h/.c` | the opaque list, `add_tasks`, `count_tags`, `top_tags`, `summarize` | `models`, `parsing`, `text` |
| `storage.h/.c` | `load_tasks` (returns a `LoadResult` enum), `append_titles`: the only files that open files | `parsing`, `tasklist` |
| `chart.h/.c` | `draw_chart(FILE *out, ...)`: draws to any stream | `tasklist` (for `TagCount`), `text` |
| `cli.c` | `main`: the only file that reads input, prints to the screen, or exits | everything |

Two differences from Python, both because of C:

- **`text`** is new: Python's strings come with `strip` and `lower`; C's don't.
- **The list type lives in `tasklist`,** so it can be opaque. That means `storage` uses `tasklist` to
  add the tasks it loads (Python's `storage` only needed `parsing`).

## Done when

```bash
cd c/modules
make check      # 8 passes, under AddressSanitizer and UBSan
make leaks      # no leaks
touch tracker/chart.h && make    # only chart.c and cli.c recompile
```

Compare with `git diff course/c/02-modules/end`.
