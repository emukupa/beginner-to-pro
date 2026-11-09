# The languages plan

Every language builds the same tracker, takes the same two steps, and passes the same
[contract](../contract/README.md). Python is done; the rest are planned in the order below.
Toolchain versions are checked and pinned when each language's chapter 01 is built.

## The same two chapters everywhere

| Chapter | Branch | What it teaches |
| --- | --- | --- |
| 01 One file | `course/<lang>/01-one-file/*` | The whole language through one program: values, text, decisions, loops, collections, functions, errors, files, the command line, types of your own |
| 02 Modules | `course/<lang>/02-modules/*` | The same program split by job, using that language's module system. Behaviour unchanged, proved by the contract |

The split is the same in every language, so the videos can compare them directly:

| Module | Job | May depend on |
| --- | --- | --- |
| `models` | What a task is (a task, an urgent task) | nothing |
| `parsing` | One line of text into a task | models |
| `storage` | Reading and appending the tasks file. The only module that touches files | parsing |
| `tasklist` | Adding, counting, ranking. No printing, no files | parsing |
| `chart` | Drawing (label, count) pairs. Knows nothing about tasks | nothing |
| `cli` | Arguments, prompts, printing, exit codes | everything above |

Dependencies only point one way (down this table), so no language ever hits a circular import.

## Use the whole language

Each version is a tour of its language, not a word-for-word copy of the Python. Every signature
feature gets a real job in the tracker, the way chapter 01 of Python used every core feature for a
reason, and the contract still has to pass byte for byte. Structs and enums appear in every
language.

| Language | Features, and the job each one does |
| --- | --- |
| Safe C | `struct` + `typedef struct tag { ... } Name;` for every type; `enum`s for the task kind, the cleaned status (C23 `enum task_status : unsigned char`) and load results; a function pointer as the comparator of a stable, `qsort`-shaped sort; a variadic `[[noreturn]] fail(format, ...)`; C23 `constexpr` for the chart width, default and tag marker, `static_assert` that the fallback is valid, `[[nodiscard]]` on every result that must be checked, `typeof` in one `PUSH` macro that grows any array, `auto`; `static`, `const`, opaque types. A tagged `union` waits for chapter 03, where a command line really can hold one of two things |
| C3 | structs and enums (with associated values), methods on types, optionals and faults instead of error codes, `@require`/`@ensure` contracts, `defer` for closing files, slices, generic modules for the growable list, macros |
| Zig | structs with methods; `enum`s with methods and `@tagName`; tagged `union(enum)`; error sets and error unions (`!T`), `try`, `catch`, and `errdefer` beside `defer` for the safe rewrite; optionals (`?T`, `orelse`); slices (`[]const u8`) and `std.mem` for text; explicit allocators passed to every function that allocates, with the debug allocator checking for leaks; `std.ArrayList` and hash maps; `comptime` generics for `topN`; Debug-build safety checks (overflow, bounds, null); `zig build` and `zig fmt` |
| C++ | classes with `virtual`/`override` for `UrgentTask`; `std::vector<std::unique_ptr<Task>>` for owning polymorphic tasks (`make_unique`), and why not `shared_ptr` here; `enum class Status`; plain `struct TagCount`; a function template `top_n` constrained by a concept; `std::optional` from the parser, `std::expected` from loading; `std::string_view` for parsing without copies; ranges and views to filter urgent tasks; `std::print`/`std::format`; RAII file streams; lambdas; `constexpr`; `operator<<` |
| Rust | `struct Task`; `enum Status { Todo, Done, Other(String) }` (an enum carrying data) and `enum Kind`; `impl` blocks, `Display` and `FromStr` traits; `Option`, `Result`, `?` and a custom error enum with `From`; `Vec<Task>`, slices, `HashMap` with first-seen order kept in a `Vec`; iterators and closures; a lifetime on `TagCount<'a>` borrowing tag names; `Rc<str>` to share tag names between tasks, and why `Arc` is needed instead once threads arrive; `#![forbid(unsafe_code)]`; `#[test]` |
| Go | structs; embedding (`UrgentTask` embeds `Task`: Go's answer to inheritance); interfaces (`fmt.Stringer`); value vs pointer receivers; `iota` constants with a `String()` method as Go's enums; slices and maps; multiple returns and error values, sentinel errors, `%w` wrapping and `errors.Is`; `defer`; generics for `TopN[T]`; closures; `sort.SliceStable`; `bufio.Scanner`; goroutines, channels, `select` and `sync.WaitGroup` once there's concurrency; table-driven tests |
| TypeScript | classes and inheritance; interfaces and type aliases; a discriminated union for status (and a TypeScript `enum`, to show why the union is usually better); generics for `topN<T>`; `readonly`; `Map` (it keeps insertion order, which the ties need) and `Set`; generators; `async`/`await` with `readline/promises`; type guards; `satisfies`; optional chaining and `??`; ES modules; `node:test` |
| C# | classes with `virtual`/`override` for `UrgentTask`, and `record` types for values like `TagCount`; `enum Status`; properties with `init`; nullable reference types (`Task?`) checked by the compiler; LINQ (`Where`, `GroupBy`, `OrderByDescending`, which is stable); `Dictionary` with first-seen order kept in a `List`; pattern matching and switch expressions; exceptions with `when` filters; `using` declarations for files and the temp file (`IDisposable`); generics with constraints for `TopN<T>`; `Span`-free string handling with `string.Split` options; top-level statements; xUnit-free tests with `dotnet test` and a minimal MSTest project |
| Java | classes with `extends`/`@Override` for `UrgentTask`; `record TagCount`; `enum Status` with fields and methods; a `sealed interface` and pattern-matching `switch` for commands; `Optional<Task>` from the parser; checked exceptions (`IOException`) vs unchecked; `try`-with-resources (`AutoCloseable`) for files and the temp file; `List`, `LinkedHashMap` (insertion order, which the ties need); streams and collectors; generics for `topN`; `var`; text blocks; packages and `module-info.java`; JUnit-free tests with plain `assert` and a tiny runner |
| Kotlin | `data class Task` and `open`/`override` for `UrgentTask`; `enum class Status` with properties; a `sealed interface` for commands with an exhaustive `when`; null safety (`Task?`, `?.`, `?:`, `!!` and why not); extension functions (`String.pythonStrip()`); `val` vs `var`; collection functions (`filter`, `groupingBy`, `sortedByDescending`, which is stable); `LinkedHashMap` by default from `mutableMapOf`; `use { }` for files and the temp file; `Result` and `runCatching`; generics with `reified` where it helps; packages and `internal`; `kotlin.test` |
| Swift | `struct Task` (a value type) and a `protocol` for anything printable, because classes and inheritance are the exception in Swift; `enum Status` with associated values (`.other(String)`), raw values and an exhaustive `switch`; optionals (`Task?`, `if let`, `guard let`, `??`); `throws`/`try`/`do`-`catch` with a custom `Error` enum; `defer` for cleanup; value semantics and copy-on-write arrays; `Dictionary` with first-seen order kept in an `Array`; `sorted(by:)` (stable since Swift 5); generics with `where` clauses for `topN`; extensions; `CustomStringConvertible`; Swift Package Manager modules with `public`/`internal`; `swift test` |

Features that need a reason the tracker doesn't have yet (threads, channels, `Arc`, futures) get
one in a shared later chapter: **loading several task files at once and merging them**. Python
gets it first as the reference (`concurrent.futures`), then each language uses its own tools:
goroutines and channels, threads with `Arc<Mutex<_>>` or `mpsc`, `std::jthread` and futures,
`Promise.all`, pthreads.

## Chapters after 02

| Chapter | What it adds | Reference |
| --- | --- | --- |
| 03 Done | `tracker done "title"` marks a task finished: matching messy titles, rewriting one line of the file, a second mode for the program | Python, then each language |
| 04 Undo | `tracker undo "title"` sets a task back to todo; done and undo share one table of changes | Python, then each language |
| 05 Several files at once | concurrency, as above | Python, then each language |

## Order and why

1. **Python**: done. The reference the contract was recorded from.
2. **Safe C**: straight from the friendliest language to the one that does nothing for you. Everything
   Python handled quietly (memory, strings, errors) becomes visible, under strict rules.
3. **C3**: the same model as C, with modules, contracts and optionals built in. Shows what C's
   pain points look like when a language fixes them.
4. **Zig**: right after C and C3 on purpose. C cleaned up with `goto cleanup`, C3 with `defer` and
   `defer catch`; Zig's `defer` and `errdefer`, error unions, explicit allocators (with a debug
   allocator that reports leaks) and `comptime` are the next step on the same path, still with no
   hidden control flow and no hidden allocations.
5. **C++**: classes and inheritance back, like Python, with C's control.
6. **Rust**: the safety Safe C enforced by rules, now enforced by the compiler.
7. **Go**: a small language that trades features for simplicity; its compiler refuses import
   cycles outright.
8. **TypeScript (Node)**: types on top of the language of the web, closing the loop back to a
   dynamic runtime.
9. **C#**: classes like TypeScript's, compiled ahead of time, with records, LINQ and nullable
   reference types; `using` for cleanup, as TypeScript just learned.
10. **Java**: the same object model as C#, older and more explicit: checked exceptions,
    try-with-resources, records, sealed interfaces and streams.
11. **Kotlin**: Java's platform with Java's ceremony removed: null safety in the type system, data
    classes, `when`, extension functions, and every Java library still in reach.
12. **Swift**: last, and the most different of the four: value types first, enums that carry data
    (like Rust's), optionals, `throws`, and `defer` (like Zig's), compiled with no garbage collector
    but with automatic reference counting.

## Language by language

### Safe C (`c/`) — built

C written to a fixed set of rules that remove its usual footguns, enforced by the compiler and
tools instead of by hope:

- C23 (`-std=c23`: `nullptr`, `bool`), `-Wall -Wextra -Wpedantic -Wconversion -Wshadow -Werror`,
  and AddressSanitizer + UBSan on every contract run (`make check`), so an overflow or undefined
  behaviour fails the run.
- Leaks: ASan can't check them on macOS, so `make leaks` runs the tracker under the system's
  `leaks --atExit` tool.
- Banned: `gets`, `strcpy`, `strcat`, `sprintf`, `atoi`, and any unbounded read. Lines are read
  with `getline` (it grows its own buffer), strings copied with an explicit length, numbers parsed
  by hand with an overflow cap.
- Every allocation goes through `checked()`, has one owner written in a comment, and is freed.
  Lengths travel with their buffers as `size_t`.
- **01:** `c/one-file/tracker.c`, its own Makefile. `typedef struct task { ... } Task;` style types; `Task` has a `kind` field instead of inheritance; growable arrays for
  tasks and strings; the string helpers Python has built in (`strip`, `lower`) written once.
- **02:** `c/modules/tracker/`, beside the one-file version (both stay complete), a `.h`/`.c` pair per module with `#pragma once` and `static` for anything
  private. Two honest differences from Python's split: a `text` module for the string helpers, and
  the list type lives in `tasklist` as an opaque struct (callers only see functions), so `storage`
  uses `tasklist` to add what it loads. The chart draws to whatever `FILE *` it's given. The
  Makefile compiles each module separately and tracks header dependencies, so a change rebuilds
  only what uses it.
- **Traps:** `nearbyint` for halves; `qsort` isn't stable, so ties need an insertion sort; UTF-8
  `█` is three bytes, so pad labels by characters.
- **Contract:** `make -C c/one-file check` and `make -C c/modules check`

### C3 (`c3/`) — built

- **01:** `c3/one-file/tracker.c3`, one module. The same data model as Safe C, with optionals and
  excuses for errors, `@require` contracts, and the whole run inside one `@pool` (no `free`).
- **02:** a module per file in `c3/modules/tracker/` (`module tracker::parsing;`), compiled together
  by `c3c compile` from a Makefile; `@private` for module-private names.
- **03/04:** `extern fn` for `mkstemp`/`fsync`/`fchmod`, `defer catch` for the safe rewrite; an enum
  with associated values as the done/undo table.
- **Contract:** `cd c3/modules && make check`

### Zig (`zig/`)

- **01:** `zig/one-file/tracker.zig`. Structs with methods, error unions and `try`, an allocator
  passed to everything that allocates, and the debug allocator proving there are no leaks.
- **02:** a file per module: in Zig a file *is* a struct, imported with `@import("parsing.zig")`;
  `pub` marks what other files may use. `zig build` builds it.
- **03/04:** `defer` and `errdefer` for the safe rewrite, the step after C's `goto cleanup` and C3's
  `defer catch`; a table of changes for done and undo.
- **Traps:** round half to even by hand or with the right `std.math` call; a stable sort for tied tags.
- **Contract:** `cd zig/modules && zig build check`

### C++ (`cpp/`)

- **01:** `cpp/tracker.cpp`, C++23. `class Task` with a virtual `str()`, `UrgentTask` deriving
  from it, `std::optional` from the parser, `std::vector`, `std::string_view`.
- **02:** a header and a source file per module in `namespace tracker`, built with CMake. A
  stretch section shows the same split as C++20 named modules (`export module tracker.models;`),
  if the toolchain's support is solid when we record.
- **Safe:** `-Wall -Wextra -Werror`, AddressSanitizer and UBSan on in the contract build, no raw
  `new`/`delete`.
- **Traps:** `std::nearbyint` for halves; `std::stable_sort`; keep tag counts in first-seen order
  (`std::map` sorts keys, which breaks ties).
- **Contract:** `cmake --build build && contract/run.sh "$PWD/cpp/build/tracker"`

### Rust (`rust/`)

- **01:** `rust/src/main.rs`. `struct Task`, an enum for the kind of task, `impl Display`,
  `Option` from the parser, `Result` and `?` for the file.
- **02:** `lib.rs` declares `mod models; mod parsing; ...`, items marked `pub`, paths with
  `use crate::models::Task`, and `main.rs` a thin binary on top of the library.
- **Safe:** `#![forbid(unsafe_code)]`; `cargo clippy -- -D warnings` must be clean.
- **Traps:** `f64::round_ties_even`; `sort_by` is already stable.
- **Contract:** `cargo build --release && contract/run.sh "$PWD/rust/target/release/tracker"`

### Go (`go/`)

- **01:** `go/main.go`, one `package main`. Task as a struct; "urgent" as a field rather than
  inheritance (Go has none, which is a lesson in itself). Errors as returned values.
- **02:** `go.mod` (`module github.com/emukupa/beginner-to-pro/go`), `cmd/tracker/main.go`, and
  one package per module under `internal/`. Exported means Capitalised. `internal/` keeps the
  packages private to this module.
- **Traps:** `math.RoundToEven`; `sort.SliceStable` for tied tags.
- **Contract:** `go build -o build/tracker ./cmd/tracker && contract/run.sh "$PWD/go/build/tracker"`

### TypeScript on Node (`node/`)

- **01:** `node/tasks.ts`, run directly by Node's built-in type stripping (no build step).
  `readline` for prompts. A class hierarchy that maps one-to-one to Python's.
- **02:** ES modules in `node/src/`: `export` and `import { Task } from "./models.ts"`,
  `"type": "module"`, and `tsc --noEmit` to check types. `index.ts` re-exports the public names,
  like Python's `__init__.py`.
- **Traps:** `Math.round` rounds halves up, so the chapter writes a round-half-to-even helper.
  Prompts must be written to stdout without a newline.
- **Contract:** `contract/run.sh node "$PWD/node/tasks.ts"`

### C# (`csharp/`)

- **01:** `csharp/one-file/Program.cs`, one file with top-level statements, in a .NET 10 console
  project. `class Task` and `class UrgentTask : Task` with `override`, as in Python.
- **02:** one project with a folder and a namespace per job; `internal` keeps types inside the
  assembly; a test project beside it.
- **Traps:** `Math.Round` defaults to banker's rounding (to even), which is what Python does, and
  so does `$"{x:F0}"` on .NET 10; the custom format `"0"` rounds halves away from zero. `string.Split()` with no arguments splits on
  single whitespace characters, not runs. `Console.ReadLine()` returns `null` at the end of input.
- **Contract:** `dotnet build -c Release && contract/run.sh "$PWD/csharp/one-file/bin/Release/net10.0/tracker"`

### Java (`java/`)

- **01:** `java/one-file/Tracker.java`, run straight from source with `java Tracker.java` (no
  build step for one file).
- **02:** packages in `java/modules/src/`, compiled with `javac -d build`, run with `java -cp build`.
  Package-private by default; `public` is the export.
- **Traps:** `Math.round` rounds halves up, so the tracker uses `Math.rint` (half to even).
  `String.strip()` is Unicode-aware, `trim()` is not; neither is Python's exact set.
  `System.out` must be flushed before reading input.
- **Contract:** `contract/run.sh java "$PWD/java/one-file/Tracker.java"`

### Kotlin (`kotlin/`)

- **01:** `kotlin/one-file/tracker.kt`, compiled with `kotlinc` into a runnable jar.
- **02:** a Gradle project with a package per job; `internal` limits a name to the module.
- **Traps:** `roundToInt()` rounds halves up; `Math.rint` is half to even. `readLine()` returns
  `null` at the end of input. Startup time of the JVM, which the contract doesn't mind.
- **Contract:** `contract/run.sh java -jar "$PWD/kotlin/one-file/build/tracker.jar"`

### Swift (`swift/`)

- **01:** `swift/one-file/tracker.swift`, compiled with `swiftc -O`.
- **02:** a Swift package (`Package.swift`) with a library target and an executable target;
  `public` is the export across modules, `internal` is the default.
- **Traps:** `.rounded()` defaults to `.toNearestOrAwayFromZero`; Python needs
  `.toNearestOrEven`. `String.count` counts grapheme clusters, Python counts code points:
  `unicodeScalars.count` matches. `readLine()` returns `nil` at the end of input.
- **Contract:** `contract/run.sh "$PWD/swift/one-file/build/tracker"`

## Per-language folder shape

```
<lang>/
  README.md                 how to build and run, one paragraph
  chapters/01-one-file/CHAPTER.md
  chapters/02-modules/CHAPTER.md
  tasks.txt                 the student's own copy to play with
  ...source...
```

## Videos

Each chapter is one video, tagged `video/<lang>-NNN` on the commit it was recorded from. The
code-along recordings (VHS terminal + animated code panel, and OBS in VS Code) are driven from
the chapter's `end` branch, so what's on screen is exactly what's in the repo.
