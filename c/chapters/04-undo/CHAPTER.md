# Chapter 04 — The undo command (Safe C)

**Video:** Safe C: Undo (tag `video/c-004`)

**Goal:** the challenge from chapter 03, in `c/modules/`. `./build/tracker undo "title"` sets a
finished task back to `[todo]`. Python's chapter 04 is the reference: the same six `contract/undo/`
cases, byte for byte. Done and undo become one command driven by a table, like Python's `CHANGES`.

```bash
cd c/modules
make
./build/tracker undo "Buy groceries"      # Undone: Buy groceries
./build/tracker undo "  fix LOGIN bug "   # [DONE] Fix login bug  ->  [todo] Fix login bug
./build/tracker undo "Book flights"       # Not done yet: Book flights
./build/tracker undo                      # Usage: undo "task title" (exit 2)
```

## Where it goes

Chapter 03's challenge said to start by adding `COMMAND_UNDO` to the enum: `-Wswitch` then points
at `main`'s switch, the one place that has to learn the new kind.

| Files | Change |
| --- | --- |
| `tasklist.h/.c` | nothing: `find_task` already finds the task |
| `storage.h/.c` | `mark_done(path, task)` becomes `set_status(path, task, status)`; `BRACKETS[]` maps each status to its text |
| `cli.c` | `COMMAND_UNDO`; the union's `done` member becomes `change`, shared by both kinds; `CHANGES[]`; `done_command` becomes `change_command` |

## Concepts

- **Designated initializers for arrays.** `[COMMAND_UNDO] = {"undo", STATUS_TODO, ...}` puts each
  entry at its enum's index, whatever order they're written in, so `CHANGES[command.kind]` is a
  lookup with no searching. `BRACKETS[]` does the same for statuses, with `[STATUS_OTHER] = nullptr`
  so the one status with no single spelling is refused instead of read past the end.
- **A table instead of copies.** Done and undo differ only in the status they set and the words they
  print: a `Change` struct holds those, and one function serves both. Python's `CHANGES` dict of
  `NamedTuple`s, as a `static const` array of structs.
- **Two kinds, one union member.** A tagged union's kind and its member don't have to match one to
  one: `COMMAND_DONE` and `COMMAND_UNDO` both use `change`; `COMMAND_TRACK` uses `track`.
- **Case fallthrough on purpose.** `case COMMAND_DONE: case COMMAND_UNDO:` share one body.
- **`static const`, not `constexpr`.** C23 `constexpr` objects can't hold pointers other than null,
  and `CHANGES` holds strings.

## Done when

```bash
cd c/modules
make check      # 8, then 6 done, then 6 undo passes, under AddressSanitizer and UBSan
make leaks      # no leaks, three times: a full run, a done run, an undo run
```

Compare with `git diff course/c/04-undo/end`.
