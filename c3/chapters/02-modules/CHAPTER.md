# Chapter 02 — Modules (C3)

**Video:** C3: Modules (tag `video/c3-002`)

**Goal:** build `c3/modules/`: the code of `c3/one-file/tracker.c3` split into `c3/modules/tracker/`,
one module per file, the same split as Python's and C's chapter 02, without changing a byte of
what the program does. The contract proves it. The one-file version stays complete beside it.

```bash
cd c3/modules
make check      # 8 passes
make leaks      # no leaks
```

## Concepts

- **A module per file, and no headers.** Each file starts `module tracker::parsing;` and imports
  what it uses: `import tracker::models;`. There's no `.h` beside each `.c`, no `#pragma once`, and
  nothing is pasted twice: an import is a real import, as in Python.
- **The prefix says where a function lives.** A function from another module is called through
  its module's last name: `parsing::parse_line(...)`, `storage::load_tasks(...)`. Types don't need
  it (`Task`, `TagCount`), because their names are already unique.
- **`@private`** keeps a function or constant inside its module, like C's `static`, enforced by
  the compiler: calling `parsing::status_of` from `cli.c3` is
  `error: The function 'parsing::status_of' is '@private' and not visible from other modules.`
- **One compile, no linker step to manage.** `c3c` compiles all the modules of the program together
  (`c3c compile tracker/*.c3`). C needed a `.o` per file, `-MMD` dependency files and a link step;
  here a module can't be compiled without the ones it imports, so there's nothing to get out of
  sync. The cost is that every build compiles everything; for a program this size, that's instant.
- **Interfaces at the edge.** `chart::draw_chart(OutStream out, ...)` draws to any output stream:
  standard out, a file, or a string in a test. Return, don't print.
- **Dependencies point one way.** C3, like C, allows two modules to import each other (a circle
  compiles), so the rule from Python's chapter 02 is ours to keep.

## The split

| File | Job | Imports of ours |
| --- | --- | --- |
| `models.c3` | `Task` (`Printable`), `Status` (carrying its word), `Kind` | nothing |
| `parsing.c3` | `parse_line`, `TAG_MARKER`, the `NOT_A_TASK` excuse | models |
| `storage.c3` | `load_tasks`, `append_titles`: the only module that opens files | models, parsing |
| `tasklist.c3` | `add_tasks`, `count_tags`, `top_tags`, `summarize`, `TagCount` | models, parsing |
| `chart.c3` | `draw_chart(OutStream, ...)` | tasklist (for `TagCount`) |
| `cli.c3` | `main`, `ask`, `parse_whole_number`: the only module that talks to the user | all of them |

One difference from C: **there's no `text` module.** C needed one for `strip`, `lower`, `fail`,
`checked` and `PUSH`; C3's standard library already has all of them.

## Done when

```bash
cd c3/modules
make check     # 8 passes
make leaks     # no leaks
```

Compare with `git diff course/c3/02-modules/end`.
