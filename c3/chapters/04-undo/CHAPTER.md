# Chapter 04 — The undo command (C3)

**Video:** C3: Undo (tag `video/c3-004`)

**Goal:** the undo challenge, in `c3/modules/`. `./build/tracker undo "title"` sets a finished task
back to `[todo]`. Python's chapter 04 is the reference: the same six `contract/undo/` cases, byte
for byte. Done and undo become one command driven by one table.

```bash
cd c3/modules
make
./build/tracker undo "Buy groceries"      # Undone: Buy groceries
./build/tracker undo "  fix LOGIN bug "   # [DONE] Fix login bug  ->  [todo] Fix login bug
./build/tracker undo "Book flights"       # Not done yet: Book flights
./build/tracker undo                      # Usage: undo "task title" (exit 2)
```

## Where it goes

| Module | Change |
| --- | --- |
| `tasklist` | nothing: `find_task` already finds the task |
| `storage` | `mark_done(path, task)` becomes `set_status(path, task, status)`, writing `status.word` in the brackets |
| `cli` | the `Change` enum; `done_command` becomes `change_command(change, words)`; `main` looks the word up in `Change::values` |

## Concepts

- **The table is the enum.** Python used a dict of `NamedTuple`s; C used a struct and an array
  indexed by an enum. C3 enums carry values, so `enum Change : (String name, Status sets, String
  changed, String already)` holds the whole table, and `Change::values` lists every command.
  Adding a third status command is one more line in the enum.
- **The status writes itself.** `Status` already carries its word (`TODO { "todo" }`), so
  `set_status` writes `"[" + status.word + "]"` with no second table.
- **A contract instead of a null check.** `OTHER` has no single spelling, so `set_status` says
  `@require status != OTHER`. Pass it with a value the compiler can see, and the build stops:
  `error: @require "status != OTHER" violated: 'only todo and done have one way to be written'`.
  C needed a `nullptr` entry in its table and a check before opening anything.

## Done when

```bash
cd c3/modules
make check      # 8, then 6 done, then 6 undo passes
make leaks      # no leaks, three times: a full run, a done run, an undo run
```

Compare with `git diff course/c3/04-undo/end`.
