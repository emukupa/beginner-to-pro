# Chapter 04 — Undo (Rust)

**Video:** Rust: Undo (tag `video/rust-004`)

**Goal:** `./target/debug/tracker undo "title"` puts a finished task back to `[todo]`, and done and
undo share one function. Python's chapter 04 is the reference: the six `contract/undo/` cases, byte
for byte, with every earlier case still passing.

## Where it goes

| File | Change |
| --- | --- |
| `models.rs` | `Status::word()`: how each status is spelled between the brackets |
| `tasklist.rs` | nothing: `find_task` already finds the task |
| `storage.rs` | `mark_done(path, task)` becomes `set_status(path, task, &status)` |
| `cli.rs` | `enum Change { Done, Undo }` with `FromStr` and four methods; `done_command` becomes `change_command` |

## Concepts

- **The command words are the enum.** `args[1].parse::<Change>()` turns `"undo"` into
  `Change::Undo`, or `Err` for anything else, so `main` only enters the command mode for a real
  command.
- **Questions as matches.** `change.sets()`, `change.changed()`, `change.already()` and
  `change.name()` each `match` on the enum: Python's `CHANGES` dict, C's table of structs, Zig's enum
  methods. Every case must answer every question.
- **Exhaustive matches.** `Status::word()` spells each status with a `match`, and `Other` carries its
  own word, so every status has a spelling. Add a `Doing` status to `models.rs` and the build stops:
  `error[E0004]: non-exhaustive patterns: '&Status::Doing' not covered`. No `default` to hide behind.
- **Comparing enums.** `task.status == change.sets()` works because `Status` derives `PartialEq`.

## Done when

```bash
cd rust/modules
cargo build
../../contract/run.sh "$PWD/target/debug/tracker"              # 8 passes
CASES=done ../../contract/run.sh "$PWD/target/debug/tracker"   # 6 passes
CASES=undo ../../contract/run.sh "$PWD/target/debug/tracker"   # 6 passes
```

Compare with `git diff course/rust/04-undo/end`.
