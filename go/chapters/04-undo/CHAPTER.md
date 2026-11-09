# Chapter 04 — Undo (Go)

**Video:** Go: Undo (tag `video/go-004`)

**Goal:** `./modules/build/tracker undo "title"` puts a finished task back to `[todo]`, and done and
undo share one function. Python's chapter 04 is the reference: the six `contract/undo/` cases, byte
for byte, with every earlier case still passing.

## Where it goes

| File | Change |
| --- | --- |
| `internal/models` | `Status.String()` spells each status; `numStatuses` counts them; `models_test.go` checks every one |
| `internal/tasklist` | nothing: `Find` already finds the task |
| `internal/storage` | `MarkDone(path, task)` becomes `SetStatus(path, task, status)` |
| `main.go` | a `change` struct and the `changes` map; `doneCommand` becomes `changeCommand` |

## Concepts

- **A table, as in Python.** `changes` is a `map[string]change`, Python's `CHANGES` dict with types:
  the command words are the keys, and `if _, ok := changes[os.Args[1]]; ok` is the comma-ok lookup
  that decides whether `main` is running a command.
- **`String()` spells a status.** `Status` now has a `String` method, so it prints as `todo` or
  `done` anywhere, `fmt` included. `Other` has no single spelling; each task keeps its own word.
- **Go's switch doesn't check every case, so a test does.** Rust and Zig refuse to build a switch
  that forgets a value. Go doesn't: add a `Doing` status and everything still builds. That's why
  `numStatuses` sits after the last status, and `TestEveryStatusIsSpelled` ranges over every one:
  `status 2 has no spelling: add it to Status.String`. `SetStatus` also refuses a status with no
  spelling before it opens anything.
- **`range` over an integer.** `for s := range numStatuses` counts 0, 1, 2, ... up to the marker.

## Done when

```bash
cd go
go test ./modules/... && go build -o modules/build/tracker ./modules
../contract/run.sh "$PWD/modules/build/tracker"              # 8 passes
CASES=done ../contract/run.sh "$PWD/modules/build/tracker"   # 6 passes
CASES=undo ../contract/run.sh "$PWD/modules/build/tracker"   # 6 passes
```

Compare with `git diff course/go/04-undo/end`.
