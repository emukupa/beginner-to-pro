# Chapter 01 — The whole tracker in one file (Java)

**Video:** Java: Beginner to Pro (tag `video/java-001`)

**Goal:** write `java/one-file/Tracker.java`, the same task tracker as `python/tasks.py`, in Java.
Python is the reference: the contract checks every byte of output, every exit code and the tasks
file afterwards.

```bash
cd java/one-file
java Tracker.java                                    # compile in memory and run: no build step
../../contract/run.sh java "$PWD/Tracker.java"       # the 8 contract cases
javac -Xlint:all -Werror -d build Tracker.java       # the lint check: must say nothing
```

## Concepts, mapped from Python and C#

| Python | C# | Java |
| --- | --- | --- |
| a script | top-level statements | one public class with `public static void main`, run straight from source |
| `class Task` | `required` `init` properties | `final` fields set in the constructor; `List.copyOf` for the tags |
| `class UrgentTask(Task)` | `: Task`, `override` | `extends Task`, `@Override` |
| `isinstance(task, UrgentTask)` | `OfType<UrgentTask>()` | `task instanceof UrgentTask urgent`: the check names it too |
| `None` from `parse_line` | `Task?` | `Optional<Task>`, and `.flatMap(Optional::stream)` drops the empty ones |
| `(tag, count)` tuples | `record TagCount` | `record TagCount(String tag, int count)` |
| `except FileNotFoundError` | `catch ... when` | checked exceptions: `loadTasks` declares `throws IOException`; `NoSuchFileException` is the missing file |
| a dict keeps insertion order | a `List` beside a `Dictionary` | `LinkedHashMap`, which keeps insertion order, and `merge` to count |
| `sorted(key=...)` | `OrderByDescending` | `stream().sorted(...)`, stable on an ordered stream, in a generic `topN<T>` |
| `round()` | `Math.Round` | `Math.rint`: `Math.round` sends halves up |
| `str.split()`, `str.strip()` | Python's whitespace by hand | the same: `String.strip()` and `Character.isWhitespace` are a different set |
| `len(tag)` | `EnumerateRunes().Count()` | `codePointCount`: `length()` counts UTF-16 units |
| `print` | `Console.OutputEncoding` | a `PrintStream` with UTF-8 named: `System.out` follows the system locale |

## Done when

```bash
cd java/one-file
../../contract/run.sh java "$PWD/Tracker.java"       # 8 passes
javac -Xlint:all -Werror -d build Tracker.java       # nothing
```

Compare with `git diff course/java/01-one-file/end`.
