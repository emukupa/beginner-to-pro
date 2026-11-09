# Chapter 04 — Undo (C#)

**Video:** C#: Undo (tag `video/csharp-004`)

**Goal:** `./build/tracker undo "title"` puts a finished task back to `[todo]`, and done and undo
share one function. Python's chapter 04 is the reference: the six `contract/undo/` cases, byte for
byte, with every earlier case still passing.

## Where it goes

| File | Change |
| --- | --- |
| `Tracker.Core/Models.cs` | `enum Status { Todo, Done }` and its `Word()` extension method |
| `Tracker.Core/Storage.cs` | `MarkDone(path, task)` becomes `SetStatus(path, task, status)` |
| `Tracker.Core/Tracker.Core.csproj` | `CS8524` off (unnamed enum values), so only real missing members stop the build |
| `Cli/Program.cs` | `record Change`, the `Changes` dictionary; `Commands.Done` becomes `Commands.Change` |

## Concepts

- **A table of records.** `Changes` is Python's `CHANGES` dict: a `Dictionary<string, Change>`
  whose values are `record Change(Status Sets, string Changed, string Already)`, made with
  target-typed `new(...)` and taken apart with `var (sets, changed, already) = Changes[name]`.
- **One pattern for both commands.** `args is [var name, .. var words] && Changes.ContainsKey(name)`
  decides whether the program is running a command.
- **Extension methods.** `status.Word()` is a static method in `StatusWords` that reads as if
  `Status` had it. It's only found where its namespace is imported: `Storage.cs` needs
  `using Tracker.Models;` for it.
- **Exhaustive switch expressions.** `Word()` is a `switch` expression with an arm per member. Add
  `Doing` to the enum and, with warnings as errors, the build stops:
  `error CS8509: The switch expression does not handle all possible values of its input type (it is
  not exhaustive). For example, the pattern 'Tracker.Models.Status.Doing' is not covered.`

## Done when

```bash
cd csharp/modules
dotnet test && dotnet build Cli -c Release -o build
../../contract/run.sh "$PWD/build/tracker"              # 8 passes
CASES=done ../../contract/run.sh "$PWD/build/tracker"   # 6 passes
CASES=undo ../../contract/run.sh "$PWD/build/tracker"   # 6 passes
```

Compare with `git diff course/csharp/04-undo/end`.
