# Chapter 02 — Projects, namespaces and internal (C#)

**Video:** C#: Modules (tag `video/csharp-002`)

**Goal:** build `csharp/modules/`: the code of `csharp/one-file/Program.cs` split into a class
library with one file per job, a small program that uses it, and a test project, without changing a
byte of what the program does. The contract proves it.

```bash
cd csharp/modules
dotnet build Cli -c Release -o build                # build/tracker
dotnet test                                         # the MSTest tests
../../contract/run.sh "$PWD/build/tracker"          # 8 passes
```

## Concepts

- **Three projects, one solution.** `modules.slnx` lists them: `Tracker.Core` (a class library,
  namespace `Tracker`), `Cli` (the program, built as `tracker`) and `Tracker.Tests`. A project
  uses another through a `<ProjectReference>`.
- **Namespaces group, assemblies guard.** `namespace Tracker.Models;` names things; it doesn't hide
  them. What hides them is the access modifier: `public` is visible to any project that references
  the library, `internal` only inside it. `Parsing.StatusOf` is `internal`; call it from `Cli` and
  the build stops: `error CS0117: 'Parsing' does not contain a definition for 'StatusOf'`. To another
  assembly, it isn't there at all.
- **Tests that can see inside.** `<InternalsVisibleTo Include="Tracker.Tests" />` lets the test
  project, and only it, call `internal` members such as `StatusOf`.
- **Writing to any `TextWriter`.** `Chart.Draw` takes a `TextWriter`: the program passes
  `Console.Out`, a test passes a `StringWriter` and checks every character.
- **Dependencies point one way.** C# allows types in one assembly to use each other freely; project
  references can't form a cycle, but the files inside one can, so the rule from Python's chapter 02
  is ours to keep.

## The split

| File | Job | Uses of ours |
| --- | --- | --- |
| `Tracker.Core/Models.cs` | `Task`, `UrgentTask`, `record TagCount` | nothing |
| `Tracker.Core/Text.cs` | Python's whitespace (`Strip`, `Words`) and `Width` | nothing |
| `Tracker.Core/Parsing.cs` | `ParseLine`, `TagMarker`; `internal StatusOf` | Models, Text |
| `Tracker.Core/Storage.cs` | `LoadTasks`, `AppendTitles`: the only file that opens files | Models, Parsing |
| `Tracker.Core/TaskList.cs` | `AddTasks`, `CountTags`, generic `TopN<T>`, `TopTags`, `Summarize` | Models, Parsing |
| `Tracker.Core/Chart.cs` | `Draw(TextWriter, pairs)` | Models, Text |
| `Cli/Program.cs` | reading input, `ParseWholeNumber`, the summary: the only part that reads or prints | all of them |

## Done when

```bash
cd csharp/modules
dotnet test                                         # Passed: 7
dotnet build Cli -c Release -o build && ../../contract/run.sh "$PWD/build/tracker"   # 8 passes
```

Compare with `git diff course/csharp/02-modules/end`.
