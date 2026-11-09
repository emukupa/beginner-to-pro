# Chapter 01 — The whole tracker in one file (C#)

**Video:** C#: Beginner to Pro (tag `video/csharp-001`)

**Goal:** write `csharp/one-file/Program.cs`, the same task tracker as `python/tasks.py`, in C# on
.NET 10. Python is the reference: the contract checks every byte of output, every exit code and the
tasks file afterwards.

```bash
cd csharp/one-file
dotnet build -c Release -o build                    # build/tracker
../../contract/run.sh "$PWD/build/tracker"          # the 8 contract cases
```

## Concepts, mapped from Python, TypeScript and Rust

| Python | TypeScript | Rust | C# |
| --- | --- | --- | --- |
| `if __name__ == "__main__"` | top-level code | `fn main` | top-level statements: `Program.cs` starts with the program itself |
| `class Task` | `class Task` with `readonly` | a struct | `class Task` with `required` `init` properties |
| `class UrgentTask(Task)` | `extends`, `override` | a `Kind` enum | `class UrgentTask : Task`, `override ToString()` |
| `isinstance(task, UrgentTask)` | `instanceof` | `kind == Kind::Urgent` | `tasks.OfType<UrgentTask>()` |
| `None` from `parse_line` | `Task \| null` | `Result` | `Task?`: nullable reference types, checked by the compiler |
| `(tag, count)` tuples | a tuple type | `TagCount<'a>` | `record TagCount(string Tag, int Count)`, taken apart with `var (tag, count)` |
| `except FileNotFoundError` | `catch` and a check | `Result` | `catch (Exception e) when (e is FileNotFoundException or ...)` |
| a dict keeps insertion order | a `Map` | `Vec` + `HashMap` | a `List` beside a `Dictionary`, which promises no order |
| `sorted(key=...)` | `toSorted` | `sort_by_key` | LINQ's `OrderByDescending`, which is stable, in a generic `TopN<T>` |
| `round()` | `roundHalfEven` by hand | `round_ties_even` | `Math.Round`, whose default is to even (so is `{x:F0}`; the custom `"0"` format isn't) |
| `str.split()`, `str.strip()` | Python's whitespace by hand | `split_whitespace` | Python's whitespace by hand: `char.IsWhiteSpace` misses `\x1c`–`\x1f` |
| `len(tag)` | `[...tag].length` | `chars().count()` | `EnumerateRunes().Count()` |
| `input()` | `readline` | `read_line` | bytes up to `\n`: `Console.ReadLine` would also stop at a lone `\r` |

## Done when

```bash
cd csharp/one-file
dotnet build -c Release -o build                    # 0 warnings: warnings are errors here
../../contract/run.sh "$PWD/build/tracker"          # 8 passes
```

Compare with `git diff course/csharp/01-one-file/end`.
