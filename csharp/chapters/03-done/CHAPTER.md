# Chapter 03 — The done command (C#)

**Video:** C#: Done (tag `video/csharp-003`)

**Goal:** the done challenge, in `csharp/modules/`. `./build/tracker done "title"` marks one task
finished, in the tasks file itself, and leaves every other byte alone. Python's chapter 03 is the
reference: the same six `contract/done/` cases, byte for byte.

## Where it goes

| File | Gets |
| --- | --- |
| `Tracker.Core/TaskList.cs` | `FindTask(tasks, title)`: a `Task?`, null when there's no such task |
| `Tracker.Core/Storage.cs` | `MarkDone(path, task)`, and a private `TempFile : IDisposable` and `Holds` |
| `Cli/Program.cs` | `Commands.Done`, and `if (args is ["done", .. var words])` at the top |

## `using var`: cleanup that belongs to a value

```csharp
using var temp = new TempFile(path);   // FileMode.CreateNew: a new file, never someone else's
File.SetUnixFileMode(temp.Path, File.GetUnixFileMode(path));   // the old permissions
temp.Stream.Write(...);
temp.Replace(path);                    // Flush(true) to the disk, File.Move over the old one, kept
// end of the method: temp.Dispose() closes it, and deletes it unless Replace ran
```

A `using` declaration calls `Dispose` when the enclosing block ends, however it ends, so a write that
throws can't leave a half-made file behind. It's TypeScript's `using`, which C# has had since 2019,
and the same idea as Rust's `Drop`.

## Concepts

- **List patterns.** `args is ["done", .. var words]` checks the first argument and takes the rest
  in one test.
- **Property patterns.** `if (TaskList.FindTask(tasks, title) is not { } task)` both checks for null
  and names the result, so the code after it knows `task` isn't null.
- **Every byte kept.** A regular expression splits the file into lines that each keep their own
  ending (`\n`, `\r\n` or `\r`); only the bracket of the matching line changes.
- **Exit codes that mean something.** 0 done (or already done), 1 no such file or task (or it couldn't
  be written), 2 used wrongly.

## Done when

```bash
cd csharp/modules
dotnet test && dotnet build Cli -c Release -o build
../../contract/run.sh "$PWD/build/tracker"              # 8 passes
CASES=done ../../contract/run.sh "$PWD/build/tracker"   # 6 passes
```

Compare with `git diff course/csharp/03-done/end`.
