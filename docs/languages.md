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
| C++ | classes with `virtual`/`override` for `UrgentTask`; `std::vector<std::unique_ptr<Task>>` for owning polymorphic tasks (`make_unique`), and why not `shared_ptr` here; `enum class Status`; plain `struct TagCount`; a function template `top_n` constrained by a concept; `std::optional` from the parser, `std::expected` from loading; `std::string_view` for parsing without copies; ranges and views to filter urgent tasks; `std::print`/`std::format`; RAII file streams; lambdas; `constexpr`; `operator<<` |
| Rust | `struct Task`; `enum Status { Todo, Done, Other(String) }` (an enum carrying data) and `enum Kind`; `impl` blocks, `Display` and `FromStr` traits; `Option`, `Result`, `?` and a custom error enum with `From`; `Vec<Task>`, slices, `HashMap` with first-seen order kept in a `Vec`; iterators and closures; a lifetime on `TagCount<'a>` borrowing tag names; `Rc<str>` to share tag names between tasks, and why `Arc` is needed instead once threads arrive; `#![forbid(unsafe_code)]`; `#[test]` |
| Go | structs; embedding (`UrgentTask` embeds `Task`: Go's answer to inheritance); interfaces (`fmt.Stringer`); value vs pointer receivers; `iota` constants with a `String()` method as Go's enums; slices and maps; multiple returns and error values, sentinel errors, `%w` wrapping and `errors.Is`; `defer`; generics for `TopN[T]`; closures; `sort.SliceStable`; `bufio.Scanner`; goroutines, channels, `select` and `sync.WaitGroup` once there's concurrency; table-driven tests |
| TypeScript | classes and inheritance; interfaces and type aliases; a discriminated union for status (and a TypeScript `enum`, to show why the union is usually better); generics for `topN<T>`; `readonly`; `Map` (it keeps insertion order, which the ties need) and `Set`; generators; `async`/`await` with `readline/promises`; type guards; `satisfies`; optional chaining and `??`; ES modules; `node:test` |

Features that need a reason the tracker doesn't have yet (threads, channels, `Arc`, futures) get
one in a shared later chapter: **loading several task files at once and merging them**. Python
gets it first as the reference (`concurrent.futures`), then each language uses its own tools:
goroutines and channels, threads with `Arc<Mutex<_>>` or `mpsc`, `std::jthread` and futures,
`Promise.all`, pthreads.

## Chapters after 02

| Chapter | What it adds | Reference |
| --- | --- | --- |
| 03 Done | `tracker done "title"` marks a task finished: matching messy titles, rewriting one line of the file, a second mode for the program | Python, then each language |
| 04 Several files at once | concurrency, as above | Python, then each language |

## Order and why

1. **Python**: done. The reference the contract was recorded from.
2. **Safe C**: straight from the friendliest language to the one that does nothing for you. Everything
   Python handled quietly (memory, strings, errors) becomes visible, under strict rules.
3. **C3**: the same model as C, with modules, contracts and optionals built in. Shows what C's
   pain points look like when a language fixes them.
4. **C++**: classes and inheritance back, like Python, with C's control.
5. **Rust**: the safety Safe C enforced by rules, now enforced by the compiler.
6. **Go**: a small language that trades features for simplicity; its compiler refuses import
   cycles outright.
7. **TypeScript (Node)**: types on top of the language of the web, closing the loop back to a
   dynamic runtime.

More can join on the same pattern (Zig, Java, C#, Swift) without changing anything that exists.

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

### C3 (`c3/`)

- **01:** `c3/src/main.c3`, one module. The same data model as Safe C, now with C3's optionals
  (`?`) for errors and `@require` contracts on functions.
- **02:** a module per file (`module tracker::models;`, `import tracker::parsing;`), a
  `project.json` listing the sources, built with `c3c build`.
- **Traps:** as Safe C.
- **Contract:** `c3c build && contract/run.sh "$PWD/c3/build/tracker"`

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

### TypeScript on Node (`ts/`)

- **01:** `ts/tasks.ts`, run directly by Node's built-in type stripping (no build step).
  `readline` for prompts. A class hierarchy that maps one-to-one to Python's.
- **02:** ES modules in `ts/src/`: `export` and `import { Task } from "./models.ts"`,
  `"type": "module"`, and `tsc --noEmit` to check types. `index.ts` re-exports the public names,
  like Python's `__init__.py`.
- **Traps:** `Math.round` rounds halves up, so the chapter writes a round-half-to-even helper.
  Prompts must be written to stdout without a newline.
- **Contract:** `contract/run.sh node "$PWD/ts/tasks.ts"`

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
