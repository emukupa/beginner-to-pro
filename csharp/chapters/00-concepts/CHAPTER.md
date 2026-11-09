# Chapter 00 — C# concepts

**Video:** C#: Concepts (tag `video/csharp-000`)

**Goal:** learn C# before building anything with it. `csharp/concepts/` is one .NET 10 console
project with one lesson per file. Each lesson is a static class with a `Title` and a `Run()`, all in
the namespace `Concepts`, so a later lesson calls an earlier one by its class name
(`Lesson04Strings.CleanStatus`, `Lesson11Errors.LoadTasks`) with no imports. `Program.cs` is
top-level statements, the program's `Main` without writing one, and keeps the lessons in a table.

TypeScript checks types in a separate step and Node runs the code anyway. C# has no such gap: the
compiler checks everything before there is a program to run. `Concepts.csproj` makes it stricter
still: `<Nullable>enable</Nullable>` makes "might be null" part of the type (`Task?` vs `Task`), and
`<TreatWarningsAsErrors>` turns every warning (an unused variable, a missed enum member, a hidden
method, a possible null) into an error. So each lesson's mistake sits under `#if BUGNN`, the project
turns `-p:Bug=7` into the symbol `BUG07`, and you watch the build fail. Two lessons' mistakes
(overflow, an index past the end) can only show up at run time; those build, then throw an exception
that stops the program with its name and message.

Two more settings in `Concepts.csproj`: `<InvariantGlobalization>` makes numbers print the same on
every machine (`0.5`, never `0,5`), and `<Using Remove="System.Threading.Tasks" />` takes .NET's own
`Task` (for async code) out of the automatic `using`s, so `Task` always means the tracker's task.

```bash
cd csharp/concepts
dotnet run                         # build, then run every lesson
dotnet run -- 7                    # just lesson 7 (or several: dotnet run -- 4 7)
dotnet run -p:Bug=7 -- 7           # lesson 7 with its bug compiled in: watch the compiler catch it
dotnet build                       # build only: must show 0 warnings, 0 errors
cd ../concepts.tests
dotnet test                        # the MSTest tests of the lessons' pieces
```

Lessons 11–14 read `tasks.txt`, a copy of `contract/tasks.txt`. The build copies it next to the
program, so they find it whichever folder you run from (`dotnet run --project csharp/concepts` works
from the top of the repo too). The tests in `concepts.tests/` are a second project that references
this one; MSTest is the only package the course uses, and `dotnet test` fetches it from NuGet the
first time.

## The lessons

| # | Lesson | Concepts | `-p:Bug=NN` shows | Caught by |
| --- | --- | --- | --- | --- |
| 01 | Hello | top-level statements, `Console.WriteLine` and `Write`, `$"{count}"`, `{0}` holes, `,-8` padding, exit codes | a variable set and never read | the compiler, CS0219 (a warning, as an error) |
| 02 | Values and types | `int` `double` `bool` `char` `string`, `var`, `sizeof`, `const`, value vs reference types, tuples and deconstruction, `default` | reading a variable before it has a value | the compiler, CS0165 |
| 03 | Numbers | integer division, `%`, `double` vs `decimal`, `Math.Round` (halves to even) vs `AwayFromZero`, `F0` vs `"0"` formatting, wrapping vs `checked`, casts, `int.TryParse`, `RoundHalfEven` | `checked(int.MaxValue + 1)` | an `OverflowException` at run time |
| 04 | Strings | immutable strings, `Trim(chars)`, `ToLowerInvariant`, `IndexOf`, ranges `[..i]`, `Split` with `RemoveEmptyEntries`, `Join`, `==` on text, `Length` (UTF-16) vs `EnumerateRunes` vs UTF-8 bytes, `@""` and `"""` strings, `CleanStatus` | `title[0] = 'B'` | the compiler, CS0200 |
| 05 | Control flow | `if`/`else`, `?:`, `for`, `foreach`, `while`, `continue`, `switch` statements with stacked labels, switch expressions with relational and `and` patterns | a `case` with no `break` | the compiler, CS0163 (no falling through) |
| 06 | Methods and lambdas | static methods, expression bodies `=>`, default and named arguments, `params`, `out` and the Try pattern, `ref`, local functions, `Func`/`Action`, closures, `Percent`, `Bar` | a method that doesn't return on every path | the compiler, CS0161 |
| 07 | Enums and switch expressions | `enum Status { Todo, Done, Other }`, exhaustive switch expressions, `or` patterns, enums as numbers, why not `Enum.TryParse`, `ParseStatus`, `Mark` | a switch expression that forgets `Status.Other` | CS8509 (a warning, as an error) |
| 08 | Classes and inheritance | `class Task` with `required` and `init` properties, a computed `IsDone`, `virtual`/`override ToString`, `UrgentTask : Task`, `base`, object initializers, `is` with type and property patterns, identity equality | `ToString` in `UrgentTask` without `override` | CS0114 (a warning, as an error) |
| 09 | Records | `record TagCount(string Tag, int Count)`, value equality, the generated `ToString`, `with` copies, deconstruction, records in a `HashSet` | `work.Count = 4` on a record | the compiler, CS8852 (init-only) |
| 10 | Nullable references | `string?` and `Task?`, `?.`, `??`, `??=`, `is null`, flow analysis, `ReadLine` returning null at the end, why not `!`, `ParseLine` | `ParseLine("just a note").Title` | CS8602 (a warning, as an error) |
| 11 | Exceptions and files | `throw`, `try`/`catch`/`finally`, `when` filters, a custom `TrackerException` with `InnerException`, `using` declarations, `IDisposable` (`TempFile`), `StreamReader`/`StreamWriter`, `LoadTasks`, `ParseTop` | `catch (Exception)` before `catch (FileNotFoundException)` | the compiler, CS0160 |
| 12 | Collections | `List<T>`, `Add`/`RemoveAt`, `^1`, `GetRange`, `Dictionary` with `TryGetValue` and `GetValueOrDefault`, why its order isn't promised, `HashSet`, `CountTags` (first-seen order in a `List`) | `tasks[tasks.Count]` | an `ArgumentOutOfRangeException` at run time |
| 13 | LINQ | `Where` `Select` `SelectMany` `Count` `Any` `Sum` `OfType` `Distinct`, `GroupBy` (first-seen order), stable `OrderByDescending`, `Take`, laziness, `SequenceEqual`, query syntax, `CountTagsLinq`, `TopTags` | a query stored in a `List<Task>` without `ToList()` | the compiler, CS0266 |
| 14 | Generics, and a mini tracker | `TopN<T, TKey>` with `where TKey : IComparable<TKey>`, one method for two types, `DrawChart`: the mini tracker | `TopN` with a `string[]` key | the compiler, CS0311 (the constraint) |

What each mistake prints first (the path before the file name is shortened here):

| Command | First line |
| --- | --- |
| `dotnet run -p:Bug=1 -- 1` | `Lesson01Hello.cs(25,13): error CS0219: The variable 'total' is assigned but its value is never used` |
| `dotnet run -p:Bug=2 -- 2` | `Lesson02Values.cs(51,27): error CS0165: Use of unassigned local variable 'doneCount'` |
| `dotnet run -p:Bug=3 -- 3` | `Unhandled exception. System.OverflowException: Arithmetic operation resulted in an overflow.` |
| `dotnet run -p:Bug=4 -- 4` | `Lesson04Strings.cs(59,9): error CS0200: Property or indexer 'string.this[int]' cannot be assigned to -- it is read only` |
| `dotnet run -p:Bug=5 -- 5` | `Lesson05Control.cs(89,13): error CS0163: Control cannot fall through from one case label ('case "half or more":') to another` |
| `dotnet run -p:Bug=6 -- 6` | `Lesson06Methods.cs(45,19): error CS0161: 'Lesson06Methods.Mark(bool)': not all code paths return a value` |
| `dotnet run -p:Bug=7 -- 7` | `Lesson07Enums.cs(36,50): error CS8509: The switch expression does not handle all possible values of its input type (it is not exhaustive). For example, the pattern 'Concepts.Status.Other' is not covered.` |
| `dotnet run -p:Bug=8 -- 8` | `Lesson08Classes.cs(23,19): error CS0114: 'UrgentTask.ToString()' hides inherited member 'Task.ToString()'. To make the current member override that implementation, add the override keyword. Otherwise add the new keyword.` |
| `dotnet run -p:Bug=9 -- 9` | `Lesson09Records.cs(32,9): error CS8852: Init-only property or indexer 'TagCount.Count' can only be assigned in an object initializer, or on 'this' or 'base' in an instance constructor or an 'init' accessor.` |
| `dotnet run -p:Bug=10 -- 10` | `Lesson10Nullable.cs(79,27): error CS8602: Dereference of a possibly null reference.` |
| `dotnet run -p:Bug=11 -- 11` | `Lesson11Errors.cs(123,16): error CS0160: A previous catch clause already catches all exceptions of this or of a super type ('Exception')` |
| `dotnet run -p:Bug=12 -- 12` | `Unhandled exception. System.ArgumentOutOfRangeException: Index was out of range. Must be non-negative and less than the size of the collection. (Parameter 'index')` |
| `dotnet run -p:Bug=13 -- 13` | `Lesson13Linq.cs(50,27): error CS0266: Cannot implicitly convert type 'System.Collections.Generic.IEnumerable<Concepts.Task>' to 'System.Collections.Generic.List<Concepts.Task>'. An explicit conversion exists (are you missing a cast?)` |
| `dotnet run -p:Bug=14 -- 14` | `Lesson14Generics.cs(76,9): error CS0311: The type 'string[]' cannot be used as type parameter 'TKey' in the generic type or method 'Lesson14Generics.TopN<T, TKey>(IEnumerable<T>, Func<T, TKey>, int)'. There is no implicit reference conversion from 'string[]' to 'System.IComparable<string[]>'.` |

A build error is followed by `The build failed. Fix the build errors and run again.` and nothing
runs. The two exceptions print the lesson's earlier lines first, then the exception and the line it
came from, and the program exits with code 134.

Pieces carry forward: lesson 03's `RoundHalfEven` feeds lesson 06's `Bar`; lesson 04's
`CleanStatus` feeds lesson 07's `ParseStatus`, which lesson 08's `Task` prints with `Mark`; lesson
10's `ParseLine` makes `Task`s and `UrgentTask`s, lesson 11's `LoadTasks` reads the file with it,
lesson 12's `CountTags` and lesson 13's `CountTagsLinq` count the tags into lesson 09's `TagCount`
records, and lesson 14's `TopN` and `DrawChart` print the tracker's summary and tag chart, built only
from what the lessons before it made:

```
6 tasks, 3 done (50%), 5 tags
[ ] Finish quarterly report  !!

Top tags
work    ████████████████████ 3
home    █████████████ 2
urgent  ███████ 1
```

## Choices the tracker doesn't make, and why

- **`Dictionary` alone** usually lists keys in the order they went in, but nothing promises it, and a removal breaks it; the order lives in a `List`, with the dictionary finding each tag's place (lesson 12).
- **`List<T>.Sort`** is unstable, so equal counts may swap; LINQ's `OrderByDescending` is stable, so ties stay in file order (lesson 13).
- **`MidpointRounding.AwayFromZero` and the custom `"0"` format** send halves up; the tracker matches Python with `Math.Round`'s default, halves to even, and rounds before it prints (lesson 03).
- **`string.Split(' ')`** leaves empty strings between runs of spaces; `Split(null, RemoveEmptyEntries)` splits on any whitespace, like Python's `split()` (lesson 04).
- **`Enum.TryParse`** accepts `"42"` and hands back a `Status` that isn't one of the three; `ParseStatus` is a switch expression that can only give a real member (lesson 07).
- **A `record` for `Task`**: records compare by value and are for data that doesn't change; a task has an identity and `UrgentTask` overrides its behaviour, so it's a class. `TagCount` is a plain value, so it's a record (lessons 08, 09).
- **The `!` operator** silences a nullable warning, and if you're wrong it's a `NullReferenceException` at run time; the tracker checks with `is null` instead (lesson 10).
- **Exceptions for expected failures**: a number the user typed goes through `TryParse`; exceptions are for the file that isn't there, caught with `when` so only the expected ones are (lessons 06, 11).
- **`File.ReadAllText`** is one line, but it holds the whole file in memory at once; `LoadTasks` reads line by line with a `using` declaration that closes the file however the method ends (lesson 11).
- **`System.Threading.Tasks`**: async code isn't needed to read one small file, and its `Task` would clash with ours, so it's left out of the automatic `using`s.
- **NuGet packages** such as `System.CommandLine` (arguments) are what real projects reach for; the lessons use only the base library, and the tests only MSTest.

## Done when

```bash
cd csharp/concepts && dotnet build && dotnet run && cd ../concepts.tests && dotnet test
```

builds with 0 warnings, runs every lesson, passes every test, and each `dotnet run -p:Bug=N -- N`
fails as the table says.
