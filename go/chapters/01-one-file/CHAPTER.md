# Chapter 01 — The whole tracker in one file (Go)

**Video:** Go: Beginner to Pro (tag `video/go-001`)

**Goal:** write `go/one-file/main.go`, the same task tracker as `python/tasks.py`, in Go. Python is
the reference: the contract checks every byte of output, every exit code and the tasks file
afterwards.

```bash
cd go
go build -o one-file/build/tracker ./one-file       # build it
cd one-file && ./build/tracker && cd ..             # run it on tasks.txt there
../contract/run.sh "$PWD/one-file/build/tracker"    # the 8 contract cases
go vet ./... && gofmt -l .                          # both must say nothing
```

## Concepts, mapped from Python, C and Rust

| Python | C | Rust | Go |
| --- | --- | --- | --- |
| `str` | `char *` and helpers | `String` / `&str` | `string`, the `strings` package: `TrimSpace`, `Cut`, `Fields`, `Trim` |
| `None` from `parse_line` | `bool` + out-pointer | `Result<Task, NotATask>` | comma-ok: `func parseLine(line string) (Task, bool)` |
| `class UrgentTask(Task)` | a `kind` field | a `Kind` enum | a `Kind` field: Go has no inheritance |
| a status string | an `enum` | `enum Status` | `type Status int` with `iota` constants |
| `__str__` | `printf` | `impl Display` | a `String()` method: `Task` is a `fmt.Stringer` without saying so |
| exceptions | `enum load_result` | `Result` and `?` | errors as values: `if err != nil`, `%w` to wrap, `errors.Is(err, fs.ErrNotExist)` |
| `ValueError` | a return code | `Err(NeedAtLeastOne)` | a sentinel: `var ErrNeedAtLeastOne = errors.New(...)` |
| `with open(...)` | `fopen`/`fclose` | `Drop` | `defer f.Close()` |
| garbage collection | `free`, once, by the owner | ownership | garbage collection, like Python |
| a list | a growable struct | `Vec` | a slice and `append`, which returns the slice to keep |
| tag counts, first-seen order | a hand-written search | `Vec` + `HashMap` | a slice + a `map[string]int`: ranging over a map has no fixed order |
| `sorted(key=...)` | hand-written stable sort | `sort_by_key` | `slices.SortStableFunc` inside a generic `topN[T any]` |
| `round()` | `nearbyint` | `round_ties_even` | `math.RoundToEven`; `%.0f` rounds the same way |
| `f"{tag:<{w}}"` | padding by hand | padding by `chars()` | `%-*s`, which pads by runes |
| `int(text)` | `parse_whole_number` | `parse_whole_number` | `parseWholeNumber`: `strconv.Atoi` takes no spaces or underscores |
| `input()` | `getline` | `read_line` | a `bufio.Reader` and `ReadString('\n')` |

## Errors are values

Go has no exceptions. A function that can fail returns an `error` as its last result, and the
caller checks it right there. `loadTasks` wraps the error with `fmt.Errorf("load tasks: %w", err)`,
and `main` asks `errors.Is(err, fs.ErrNotExist)` to tell a missing file from an unreadable one.

## Done when

```bash
cd go
go build -o one-file/build/tracker ./one-file && ../contract/run.sh "$PWD/one-file/build/tracker"   # 8 passes
go vet ./... && gofmt -l .                                                                          # nothing
```

Compare with `git diff course/go/01-one-file/end`.
