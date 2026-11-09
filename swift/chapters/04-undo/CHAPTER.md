# Chapter 04 — Undo (Swift)

**Video:** Swift: Undo (tag `video/swift-004`)

**Goal:** `tracker undo "title"` puts a finished task back to `[todo]`, and done and undo share one
function. Python's chapter 04 is the reference: the six `contract/undo/` cases, byte for byte, with
every earlier case still passing.

## Where it goes

| File | Change |
| --- | --- |
| `Sources/TrackerCore/Models.swift` | `Status.word`: how each status is spelled |
| `Sources/TrackerCore/Storage.swift` | `markDone(path, task)` becomes `setStatus(path, task, status)` |
| `Sources/tracker/main.swift` | `enum Change: String, CaseIterable`; `done` becomes `change` |

## Concepts

- **Raw values.** `enum Change: String { case done, undo }` gives each case a string, its own name.
  `Change(rawValue: "undo")` turns the typed word into `.undo`, or `nil` for anything else, so the
  command words can't disagree with the cases. Zig's `std.meta.stringToEnum`, built in.
- **Computed properties.** `sets`, `changed` and `already` answer Python's `CHANGES` questions for
  each case.
- **`if let` with two conditions.** `if let word = arguments.first, let command = Change(rawValue: word)`
  only enters the command mode when both succeed.
- **Exhaustive switches, and a case that carries its own word.** `Status.word` switches over every
  case, and `.other(let word)` spells itself. Add `.doing` to `Status` and the build stops:
  `error: switch must be exhaustive`.

## Done when

```bash
cd swift/modules
swift test && swift build -c release
for c in cases done undo; do CASES=$c ../../contract/run.sh "$PWD/.build/release/tracker"; done   # 8, 6, 6
```

Compare with `git diff course/swift/04-undo/end`.
