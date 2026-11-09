# Chapter 04 — Undo (Kotlin)

**Video:** Kotlin: Undo (tag `video/kotlin-004`)

**Goal:** `tracker undo "title"` puts a finished task back to `[todo]`, and done and undo share one
function. Python's chapter 04 is the reference: the six `contract/undo/` cases, byte for byte, with
every earlier case still passing.

## Where it goes

| File | Change |
| --- | --- |
| `tracker/models/Models.kt` | `enum class Status { TODO, DONE }` with a `word` property |
| `tracker/storage/Storage.kt` | `markDone(path, task)` becomes `setStatus(path, task, status)` |
| `tracker/app/Main.kt` | `enum class Change(...)` with a `companion object`; `done` becomes `change` |

## Concepts

- **Enum constructors.** `enum class Change(val sets: Status, val changed: String, val already: String)`
  puts Python's `CHANGES` dict into the enum: each constant passes its values to the constructor.
- **Companion objects.** `Change.of("undo")` is called on the class, like Java's `static`; Kotlin
  puts such functions in a `companion object` instead.
- **`?.let`.** `Change.of(args.firstOrNull())?.let { exitProcess(change(it, ...)) }` runs only when
  the word is a command; otherwise the line does nothing and the tracker carries on.
- **Exhaustive `when`.** `Status.word` is a `when (this)` used as a value, with a branch per constant
  and no `else`. Add `DOING` and the build stops:
  `'when' expression must be exhaustive. Add the 'DOING' branch or an 'else' branch.`

## Done when

```bash
cd kotlin/modules
./gradlew installDist test
for c in cases done undo; do CASES=$c ../../contract/run.sh "$PWD/app/build/install/tracker/bin/tracker"; done   # 8, 6, 6
```

Compare with `git diff course/kotlin/04-undo/end`.
