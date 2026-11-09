# Chapter 01 — The whole tracker in one file (Swift)

**Video:** Swift: Beginner to Pro (tag `video/swift-001`)

**Goal:** write `swift/one-file/tracker.swift`, the same task tracker as `python/tasks.py`, in Swift.
Python is the reference: the contract checks every byte of output, every exit code and the tasks
file afterwards.

```bash
cd swift/one-file
make            # swiftc -O -warnings-as-errors tracker.swift -o build/tracker
make check      # the 8 contract cases
make run        # ./build/tracker
```

## Concepts, mapped from Python, Rust and Kotlin

| Python | Rust | Kotlin | Swift |
| --- | --- | --- | --- |
| a script | `fn main` | `fun main` | top-level code in the file: the program starts at the first line |
| `class Task` | `struct Task` | `open class Task` | `struct Task`: a value, copied when assigned, with `let` fields |
| `class UrgentTask(Task)` | a `Kind` enum | a subclass | a `Kind` enum: structs have no inheritance |
| a status string | `enum Status { Todo, Done, Other(String) }` | `enum class` | `enum Status { case todo, done; case other(String) }`, with a `switch` expression |
| `__str__` | `impl Display` | `toString()` | `CustomStringConvertible`'s `description`, used by `print` |
| `None` from `parse_line` | `Result` | `Task?` | `Task?`, and `compactMap` drops the nils |
| exceptions | `Result` and `?` | exceptions | `throws`, `try`, `do`/`catch`, and `enum LoadError: Error` |
| a dict keeps insertion order | `Vec` + `HashMap` | `mutableMapOf()` | an array beside a `Dictionary`, which has no order |
| `sorted(key=...)` | `sort_by_key` | `sortedByDescending` | `sorted(by:)`, stable, in a generic `topN<T, Key> where Key: Comparable` |
| `round()` | `round_ties_even` | `round()` | `.rounded(.toNearestOrEven)`: plain `.rounded()` sends halves away from zero |
| `len(tag)` | `chars().count()` | `codePointCount` | `unicodeScalars.count`: `count` counts graphemes, and `"\r\n"` is one `Character` |
| `str.split()`, `str.strip()` | `split_whitespace` | extensions | extensions on `String`, working on `unicodeScalars` against Python's exact space set |
| `input()` | `read_line` | bytes to `\n` | bytes to `\n` with `getchar()`: `readLine()` would also drop a `\r` |
| list mutation | `&mut Vec` | `MutableList` | `inout`: `addTasks(&tasks, titles)` changes the caller's array |

## Done when

```bash
cd swift/one-file
make check      # 8 passes; -warnings-as-errors means a warning stops the build
```

Compare with `git diff course/swift/01-one-file/end`.
