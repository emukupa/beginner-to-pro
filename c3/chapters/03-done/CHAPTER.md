# Chapter 03 — The done command (C3)

**Video:** C3: Done (tag `video/c3-003`)

**Goal:** the done challenge, in `c3/modules/`. `./build/tracker done "title"` marks one task
finished, in the tasks file itself, and leaves every other byte alone. Python's chapter 03 is the
reference: the same six `contract/done/` cases, byte for byte.

```bash
cd c3/modules
make
./build/tracker done "Book flights"            # Done: Book flights
./build/tracker done "  review PULL request "  # matches "[ todo ] Review pull request #work."
./build/tracker done buy groceries             # Already done: Buy groceries
./build/tracker done "Walk dog"                # No task called "Walk dog" (exit 1)
./build/tracker done                           # Usage: done "task title" (exit 2)
```

## Where it goes

| Module | Gets | Why there |
| --- | --- | --- |
| `tasklist` | `find_task(tasks, title)`: a `Task*?`, borrowed from the list, or `NO_SUCH_TASK` | finding a task in a list |
| `storage` | `mark_done(path, task)` and its private `write_safely` | the only module that opens files |
| `parsing` | `next_word` becomes public, so `find_task` cleans a title the same way the parser does | one definition of "a word" |
| `cli` | `done_command(words)` and the check at the top of `main` | the only module that talks to the user |

## Concepts

- **An optional pointer.** `find_task` returns `Task*?`: a pointer into the list, or an excuse. The
  list still owns the task; the caller borrows it.
- **Every byte kept.** `file::load_temp` reads the whole file as bytes; the loop splits it at each
  `\n`, keeping the ending with its line, so `\r\n` files stay `\r\n`. Only the bracket changes.
- **Rewriting safely.** Python's chapter 03 opened the file with `"w"`, which empties it first.
  `write_safely` writes a new file beside the old one (`mkstemp`), copies its permissions
  (`fchmod`), `fsync`s it to the disk, then `rename`s it over the old one. A rename is atomic.
- **C3 calls C directly.** `mkstemp`, `fsync` and `fchmod` aren't in C3's standard library, so
  `storage.c3` declares them with `extern fn` and calls them; `stat`, `write`, `close`, `rename` and
  `remove` come from the `libc` module.
- **`defer catch`.** `defer libc::close(fd)` runs however the function ends; `defer catch
  libc::remove(temp)` runs only when it ends with an excuse, so a half-made file is deleted and a
  finished one is kept. C needed `goto cleanup` and a flag for this.
- **Exit codes that mean something.** 0 done (or already done), 1 no such file or task, 2 used wrongly.

## Done when

```bash
cd c3/modules
make check      # 8 passes, then 6 done passes
make leaks      # no leaks, twice: a full run and a done run
```

Compare with `git diff course/c3/03-done/end`.
