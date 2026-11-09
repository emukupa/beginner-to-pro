# Chapter 04 — Undo (Java)

**Video:** Java: Undo (tag `video/java-004`)

**Goal:** `tracker undo "title"` puts a finished task back to `[todo]`, and done and undo share one
method. Python's chapter 04 is the reference: the six `contract/undo/` cases, byte for byte, with
every earlier case still passing.

## Where it goes

| File | Change |
| --- | --- |
| `tracker/models/Status.java` | `enum Status { TODO, DONE }` with `word()` |
| `tracker/storage/Storage.java` | `markDone(path, task)` becomes `setStatus(path, task, status)` |
| `tracker/app/Main.java` | `enum Change` with fields; `done` becomes `change` |

## Concepts

- **Enums are classes.** `Change`'s constants carry data: `DONE(Status.DONE, "Done", "Already done")`
  calls the enum's own constructor. That makes the enum Python's `CHANGES` dict, with the command
  words as the constants' names: `Change.of("undo")` finds `UNDO`.
- **Exhaustive switch expressions.** `Status.word()` is a `switch` expression over `this`, with an
  arm per constant and no `default`. Add `DOING` and the build stops:
  `error: the switch expression does not cover all possible input values`.
- **One method for both.** `change(Change, words)` asks Python's question: does the task already
  have the status this command sets?

## Done when

```bash
cd java/modules
make test && make check                                                             # 8 passes
CASES=done ../../contract/run.sh java -p "$PWD/build" -m tracker.app/tracker.app.Main   # 6 passes
CASES=undo ../../contract/run.sh java -p "$PWD/build" -m tracker.app/tracker.app.Main   # 6 passes
```

Compare with `git diff course/java/04-undo/end`.
