# Chapter 01 — The whole tracker in one file (Kotlin)

**Video:** Kotlin: Beginner to Pro (tag `video/kotlin-001`)

**Goal:** write `kotlin/one-file/tracker.kt`, the same task tracker as `python/tasks.py`, in Kotlin,
compiled to a jar that runs on the JVM. Python is the reference: the contract checks every byte of
output, every exit code and the tasks file afterwards.

```bash
cd kotlin/one-file
make            # kotlinc -Werror tracker.kt -include-runtime -d build/tracker.jar
make check      # the 8 contract cases
make run        # java -jar build/tracker.jar
```

## Concepts, mapped from Python and Java

| Python | Java | Kotlin |
| --- | --- | --- |
| a script | `public static void main` in a class | `fun main(args: Array<String>)` at the top level of a file |
| `class Task` | `final` fields and a constructor | `open class Task(val title: String, ...)`: the constructor is the class header |
| `class UrgentTask(Task)` | `extends`, `@Override` | `: Task(...)`, `override`, and `open` on the parent, because classes are final by default |
| `isinstance(task, UrgentTask)` | `instanceof` | `tasks.filterIsInstance<UrgentTask>()` |
| `None` from `parse_line` | `Optional<Task>` | `Task?`: null is part of the type, and `mapNotNull` drops the nulls |
| `(tag, count)` tuples | a record | `data class TagCount`, taken apart with `for ((tag, count) in pairs)` |
| `except FileNotFoundError` | checked exceptions | no checked exceptions; `try` is an expression that gives a value |
| a dict keeps insertion order | `LinkedHashMap` | `mutableMapOf()`, which is a `LinkedHashMap` |
| `sorted(key=...)` | stable `sorted` | `sortedByDescending`, stable, in a generic `topN<T>` |
| `round()` | `Math.rint` | `kotlin.math.round`, which already rounds halves to even |
| `str.split()`, `str.strip()` | Python's whitespace by hand | the same, as extension functions: `"x".pythonStrip()` |
| `str.partition("]")` | `indexOf` and `substring` | `substringBefore("]")` and `substringAfter("]", "")`; `partition { }` splits the words |
| `raise ValueError` | `throw new IllegalArgumentException` | `require(n >= 1) { "..." }` |

## Done when

```bash
cd kotlin/one-file
make check      # 8 passes; -Werror means a warning stops the build
```

Compare with `git diff course/kotlin/01-one-file/end`.
