# Chapter 03 — The done command (Safe C)

**Video:** [Never Half-Write a File in C: the done Command](https://youtu.be/tdUVaWJdoqQ) on YouTube

**Goal:** the challenge from chapters 01 and 02, in `c/modules/`. `./build/tracker done "title"`
marks one task finished, in the tasks file itself, and leaves every other byte of the file alone.
Python's chapter 03 is the reference: the same six `contract/done/` cases, byte for byte.

```bash
cd c/modules
make
./build/tracker done "Book flights"            # Done: Book flights
./build/tracker done "  review PULL request "  # matches "[ todo ] Review pull request #work."
./build/tracker done buy groceries             # Already done: Buy groceries (words are joined)
./build/tracker done "Walk dog"                # No task called "Walk dog" (exit 1)
./build/tracker done                           # Usage: done "task title" (exit 2)
```

## Where it goes

The same three modules as Python, a header and a source file each. Nothing else changes.

| Files | Gets | Why there |
| --- | --- | --- |
| `tasklist.h/.c` | `find_task(list, title)`: returns a borrowed `const Task *`, or `nullptr` | finding a task in a list: no files, no printing |
| `storage.h/.c` | `[[nodiscard]] bool mark_done(path, task)` | the only module that opens files |
| `cli.c` | `Command`, `read_command`, `done_command`, and `main` choosing between the two modes | the only module that talks to the user and exits |

## Concepts

- **A tagged union.** The command line holds one of two things: a tasks file to track, or a task to
  mark done. `Command` is an `enum` saying which (`kind`) beside an anonymous `union` holding that
  mode's data. Only the member `kind` names may be read. `main` switches on `kind`, and C23's
  `unreachable()` after the switch says every kind has returned; `-Wswitch` makes adding a kind
  without a case a compile error.
- **Borrowed versus owned, again.** `find_task` returns a pointer into the list: the list still owns
  the task, so `done_command` must not free it, and must not use it after `tasklist_free`.
  `Command.done.title` is owned: `main` frees it.
- **Rewriting one line, safely.** Python reads the whole file and writes it back over itself. If
  that's interrupted, the file is half-written. Here `mark_done` copies the file line by line into a
  new file beside it (`mkstemp` picks a name nobody is using), changes one line on the way, checks
  for read and write errors, `fsync`s it to the disk, then `rename`s it over the old one. A rename
  is atomic: anyone reading the file sees the old one or the new one, never half of each. If any
  step fails, the old file is untouched and the new one is deleted. `fchmod` keeps the old file's
  permissions.
- **Every byte kept.** `getline` returns the line's length, ending included, and `fwrite` writes
  exactly that many bytes back, so `\r\n` endings, spaces before the bracket and the tags after it
  stay as they were. Only the bracket part becomes `[done]`.
- **`goto cleanup`.** `mark_done` opens two files, a buffer and a name. Every failure jumps to one
  label that closes and frees exactly what was opened. It's C's idiom for one way out, where Python
  had `with` and other languages have `defer`.
- **Exit codes that mean something.** 0 done (or already done), 1 no such file or task, 2 used
  wrongly. `done_command` returns the code and frees its list on every path; `main` returns it.

## Done when

```bash
cd c/modules
make check      # 8 passes, then 6 done passes, under AddressSanitizer and UBSan
make leaks      # no leaks, twice: a full run and a done run
```

Compare with `git diff course/c/03-done/end`.
