# Chapter 03 — The done command (Rust)

**Video:** Rust: Done (tag `video/rust-003`)

**Goal:** the done challenge, in `rust/modules/`. `./target/debug/tracker done "title"` marks one
task finished, in the tasks file itself, and leaves every other byte alone. Python's chapter 03 is
the reference: the same six `contract/done/` cases, byte for byte.

## Where it goes

| File | Gets |
| --- | --- |
| `tasklist.rs` | `find_task<'a>(tasks: &'a [Task], title: &str) -> Option<&'a Task>`: a borrow into the list, or `None` |
| `storage.rs` | `mark_done(path, task)`, and the private `TempFile`, `holds` and `bracket` |
| `cli.rs` | `done_command` and the check at the top of `main` |

## Cleanup that belongs to a value

C cleaned up with `goto cleanup`; C3 with `defer catch`; Zig with `errdefer`. Rust has none of those
keywords. Instead the cleanup belongs to a value, in its `Drop`:

```rust
let mut temp = TempFile::beside(path)?;                         // a new file, create_new
temp.file.set_permissions(fs::metadata(path)?.permissions())?;  // the old file's
temp.file.write_all(out.as_bytes())?;
temp.replace(path)                                              // sync_all, rename, kept
```

Every `?` that fails returns early, `temp` is dropped, and `Drop` deletes the half-made file. If
`replace` succeeds, the file has become the tasks file and `Drop` leaves it alone. `replace` takes
`self`, not `&self`: once it's called, the `TempFile` has moved into it, and the compiler won't let
anything use it again. It's the same idea as C++'s RAII `TempFile`, with the move checked.

## Concepts

- **A lifetime you have to write.** `find_task` takes two references and returns one. Rust can't
  guess which one the answer borrows from, so `'a` says: from `tasks`. While `task` is alive, the
  list can't be changed or dropped.
- **Every byte kept.** `split_inclusive('\n')` keeps each line's own ending, so `\r\n` files stay
  `\r\n`. Only the bracket changes.
- **The safe rewrite, from std alone.** A random name from `RandomState` (std's own random hash
  keys), `create_new(true)` so it can't be anyone else's file, the old permissions, `sync_all`, then
  `fs::rename` over the old one.
- **Exit codes that mean something.** 0 done (or already done), 1 no such file or task (or it couldn't
  be written), 2 used wrongly.

## Done when

```bash
cd rust/modules
cargo test                                                                    # 8 passed
cargo build && ../../contract/run.sh "$PWD/target/debug/tracker"              # 8 passes
CASES=done ../../contract/run.sh "$PWD/target/debug/tracker"                  # 6 passes
```

Compare with `git diff course/rust/03-done/end`.
