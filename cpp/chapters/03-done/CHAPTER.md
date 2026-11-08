# Chapter 03 — The done command (C++)

**Video:** C++: Done (tag `video/cpp-003`)

**Goal:** the done challenge, in `cpp/modules/`. `./build/tracker done "title"` marks one task
finished, in the tasks file itself, and leaves every other byte alone. Python's chapter 03 is the
reference: the same six `contract/done/` cases, byte for byte.

## Where it goes

| Files | Gets |
| --- | --- |
| `models.hpp` | `Task::status()`, so storage can compare statuses |
| `tasklist.hpp/.cpp` | `find_task(tasks, title)`: a plain `Task*`, borrowed from the list, or `nullptr` |
| `storage.hpp/.cpp` | `[[nodiscard]] bool mark_done(path, task)`, and a private `TempFile` class |
| `cli.cpp` | `done_command(std::span<char*> words)` and the check at the top of `main` |

## Concepts

- **Owned and borrowed, in the types.** The list holds `std::unique_ptr<Task>`: owners. `find_task`
  returns a plain `Task*`: a borrow. Nobody deletes through a plain pointer.
- **Every byte kept.** The file is read whole, as bytes (`std::ios::binary`), and split at each `\n`
  with the ending kept, so `\r\n` files stay `\r\n`. Only the bracket changes.
- **RAII cleanup.** `TempFile` makes the new file beside the old one (`mkstemp`, POSIX), and its
  destructor closes it and deletes it unless `keep()` was called. However `mark_done` returns, the
  half-made file is cleaned up: C's `goto cleanup` and C3's `defer catch`, as a class.
- **`std::filesystem`.** `permissions` copies the old file's permissions; `rename` swaps the new
  file in, atomically, and reports failure through a `std::error_code` instead of throwing.
- **`std::span`.** `done_command` takes the words after `done` as a span: a view of part of `argv`.

## Done when

```bash
cd cpp/modules
make check      # 8 passes, then 6 done passes
make leaks      # no leaks, twice
```

Compare with `git diff course/cpp/03-done/end`.
