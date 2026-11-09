# Chapter 03 — The done command (Kotlin)

**Video:** Kotlin: Done (tag `video/kotlin-003`)

**Goal:** the done challenge, in `kotlin/modules/`. `tracker done "title"` marks one task finished,
in the tasks file itself, and leaves every other byte alone. Python's chapter 03 is the reference:
the same six `contract/done/` cases, byte for byte.

## Where it goes

| Package | Gets |
| --- | --- |
| `tracker.tasklist` | `findTask(tasks, title): Task?` |
| `tracker.storage` | `markDone(path, task)`, and a private `TempFile : AutoCloseable` and `holds` |
| `tracker.app` | `done(words)` and the check at the top of `main` |

## `use { }`: a function, not a keyword

```kotlin
TempFile(path).use { temp ->                       // Files.createTempFile beside the tasks file
    temp.path.setPosixFilePermissions(path.getPosixFilePermissions())
    temp.channel.write(...)
    temp.replace(path)                             // force(true), atomic move, kept
}                                                  // temp.close(): deleted unless kept
```

Java needed new syntax for this (try-with-resources). Kotlin didn't: `use` is an ordinary inline
function in the standard library, defined on anything `AutoCloseable`, that runs your lambda and
closes the resource however the lambda ends. Lambdas as the last argument go outside the brackets,
so it reads like a language feature.

## Concepts

- **`?:` with `return`.** `val task = findTask(tasks, title) ?: run { ...; return 1 }` either gives
  a task or leaves the function, so after that line `task` is a `Task`, not a `Task?`.
- **The same careful file handling as Java, from the same JDK.** `Files.createTempFile`,
  `FileChannel.force(true)` and `Files.move(..., ATOMIC_MOVE, REPLACE_EXISTING)`, called from
  Kotlin as if they were Kotlin.
- **Every byte kept.** `Regex.findAll` walks the file line by line, each line keeping its own ending.
- **Exit codes that mean something.** 0 done (or already done), 1 no such file or task (or it couldn't
  be written), 2 used wrongly.

## Done when

```bash
cd kotlin/modules
./gradlew installDist test
../../contract/run.sh "$PWD/app/build/install/tracker/bin/tracker"              # 8 passes
CASES=done ../../contract/run.sh "$PWD/app/build/install/tracker/bin/tracker"   # 6 passes
```

Compare with `git diff course/kotlin/03-done/end`.
