# C#

The task tracker in C# on .NET 10: classes like TypeScript's, but compiled before they run, with
records, LINQ and nullable reference types. Every project here turns nullable checking on and treats
warnings as errors, so a possible null, a forgotten `switch` case or a hidden method stops the build.
Needs the [.NET 10 SDK](https://dotnet.microsoft.com/download) (written with 10.0.400), which brings
the `dotnet` command, the C# compiler and the runtime.

| Folder | What | Chapter |
| --- | --- | --- |
| [`concepts/`](concepts/) | one lesson per file, run by `Program.cs`: `dotnet run` runs them all, `dotnet run -- 7` one, `dotnet run -p:Bug=7 -- 7` with its bug; tests in [`concepts.tests/`](concepts.tests/) | 00 |

```bash
cd csharp/concepts
dotnet run                         # build, then every lesson
dotnet run -- 7                    # just lesson 7
dotnet run -p:Bug=7 -- 7           # lesson 7 with its bug compiled in: watch the compiler catch it
cd ../concepts.tests && dotnet test   # the lessons' tests (MSTest, fetched from NuGet the first time)
```

| Chapter | Start | End | Video |
| --- | --- | --- | --- |
| [00 Concepts](chapters/00-concepts/CHAPTER.md) | `course/csharp/00-concepts/start` | `course/csharp/00-concepts/end` | `video/csharp-000` |

VS Code: install the **C# Dev Kit** extension (it brings the C# extension with it). It runs the same
compiler as `dotnet build` as you type, so nullable warnings and missing `switch` cases show up
before you build, and it can run the tests from the Testing panel.
