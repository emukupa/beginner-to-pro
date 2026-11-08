# Chapter 02 — Packages: capital letters, internal/, and no cycles (Go)

**Video:** Go: Modules (tag `video/go-002`)

**Goal:** build `go/modules/`: the code of `go/one-file/main.go` split into packages, one folder per
job, the same split as Python's chapter 02, without changing a byte of what the program does. The
contract proves it.

```bash
cd go
go test ./modules/...                                                                   # the tests
go build -o modules/build/tracker ./modules && ../contract/run.sh "$PWD/modules/build/tracker"   # 8 passes
```

## Concepts

- **A package is a folder.** Every `.go` file in `internal/storage/` says `package storage`, and
  they compile together. Code elsewhere imports it by its path,
  `github.com/emukupa/beginner-to-pro/go/modules/internal/storage`, and calls `storage.Load(...)`:
  the package name is part of every call, so names inside it stay short (`Load`, not `LoadTasks`).
- **Capital letters export.** `parsing.Line` starts with a capital, so other packages can use it;
  `statusOf` doesn't, so it's `parsing`'s alone. Call it from `main.go` and the build stops:
  `undefined: parsing.statusOf`. It's the same rule for types, fields, functions and constants.
- **`internal/` is enforced.** Only code inside `go/modules/` may import `go/modules/internal/...`.
  Import it from anywhere else and the compiler says `use of internal package ... not allowed`.
- **No import cycles.** Rust, Zig, C and C3 let two files depend on each other; Go refuses.
  Make `models` import `chart` and the build prints the whole loop, ending in
  `import cycle not allowed`. The one-way rule from Python's chapter 02 is now the compiler's.
- **Tests beside the code.** `parsing_test.go` sits next to `parsing.go`, in the same package, so it
  can test `statusOf` too. The tests are table-driven: a slice of cases and one loop. `go test`
  also runs part of `go vet` first.
- **Interfaces satisfied without saying so.** `chart.Draw` takes an `io.Writer`; `main` passes
  `os.Stdout`, and the test passes a `strings.Builder`. Neither declares that it's a writer.

## The split

| Package | Job | Imports of ours |
| --- | --- | --- |
| `internal/models` | `Status`, `Kind` (iota), `Task` with `String()` | nothing |
| `internal/parsing` | `Line`, `TagMarker`; unexported `statusOf` | models |
| `internal/storage` | `Load`, `AppendTitles`: the only package that opens files | models, parsing |
| `internal/tasklist` | `Add`, `CountTags`, the generic `TopN`, `TopTags`, `ErrNeedAtLeastOne`, `Summarize` | models, parsing |
| `internal/chart` | `Draw(w io.Writer, ...)`, `Width` | tasklist |
| `main.go` | `ask`, `parseWholeNumber`, `main`: the only file that reads input, prints or exits | all of them |

## Done when

```bash
cd go
go test ./modules/...                                              # ok for chart, parsing, tasklist
go build -o modules/build/tracker ./modules
../contract/run.sh "$PWD/modules/build/tracker"                    # 8 passes
go vet ./... && gofmt -l .                                         # nothing
```

Compare with `git diff course/go/02-modules/end`.
