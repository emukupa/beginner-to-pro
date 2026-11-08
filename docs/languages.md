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

### Safe C (`c/`)

C written to a fixed set of rules that remove its usual footguns, enforced by the compiler and
sanitizers instead of by hope:

- C23, `clang -std=c23 -Wall -Wextra -Wpedantic -Wconversion -Werror`, and
  `-fsanitize=address,undefined` on every contract run, so a leak or overflow fails the build.
- Banned: `gets`, `strcpy`, `strcat`, `sprintf`, `atoi`, and any unbounded read. Use `fgets`
  with sizes, `snprintf`, `strtol` with its error checks.
- Every allocation is checked, has one owner written in a comment, and is freed. Lengths travel
  with their buffers.
- **01:** `c/tracker.c`. A `struct task` with a `kind` field instead of inheritance (composition
  over inheritance, explained on screen); a growable array of tasks.
- **02:** a `.h`/`.c` pair per module, `#pragma once`, `static` for anything private to a file,
  an opaque `struct tasklist` so callers can't touch its insides, and a Makefile that rebuilds only
  what changed.
- **Traps:** `nearbyint` for halves; UTF-8 `█` is three bytes, so pad labels by characters.
- **Contract:** `make -C c && contract/run.sh "$PWD/c/build/tracker"`

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
