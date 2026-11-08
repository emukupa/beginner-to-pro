# Chapter 00 — Go concepts

**Video:** Go: Concepts (tag `video/go-000`)

**Goal:** learn Go before building anything with it. `go/concepts/` holds one lesson per file.
Every file is `package main`, so the folder builds as one program: `main.go` keeps the lessons in a
table of functions, and a later lesson calls an earlier one's functions directly, with no imports.
(Splitting code into packages is chapter 02.)

Each lesson's deliberate mistake lives in its own `lessonNN_bug.go`, which starts with the build
constraint `//go:build bugNN`. A file with a build tag is left out of every build unless you name
the tag with `-tags`, so the normal program, `go vet` and `go test` never see the mistakes. Runtime
mistakes register themselves in main.go's `bugs` table from an `init` function, and the lesson calls
`bug(NN)` at the point where the mistake belongs; compile-time mistakes don't get that far.

```bash
cd go
go run ./concepts                    # every lesson, in order
go run ./concepts 7                  # just lesson 7 (or several: go run ./concepts 4 7)
go run -tags bug07 ./concepts 7      # lesson 7 with its mistake compiled in: watch Go catch it
go vet -tags bug05 ./concepts        # lesson 5's mistake builds; go vet is what catches it
go test ./...                        # the table-driven tests in concepts_test.go
go test -tags bug12 ./concepts       # lesson 12's mistake builds and runs; a test catches it
```

Lessons 13 and 14 read `tasks.txt`, a copy of `contract/tasks.txt`. They look for it in the current
folder, then in `concepts/`, so run them from `go/` or from `go/concepts/` (`go run . 13` there).

## The lessons

| # | Lesson | Concepts | `-tags bugNN` shows | Caught by |
| --- | --- | --- | --- | --- |
| 01 | Hello | `package main`, `func main`, `Println` vs `Printf`, `%v`, exit codes | an unused import | the compiler |
| 02 | Values, types and zero values | `var`, `:=`, `%T`, zero values, `nil`, untyped constants | an unused variable | the compiler |
| 03 | Numbers | integer division towards zero, `%`, int8 wraparound, exact constants vs float64, `math.Round` vs `math.RoundToEven`, `strconv.Atoi` | `int * float64` | the compiler (no implicit conversions) |
| 04 | Strings, bytes and runes | `Trim`, `ToLower`, `Fields`, `Cut`, bytes vs runes, UTF-8 width, `range` over a string, `strings.Builder` | assigning to `s[0]` | the compiler (strings are read-only) |
| 05 | Decisions and loops | `if` with a short statement, `for` in three shapes, `range` over an int, `switch` without fallthrough, `switch` with no value | `%d` given a string | `go vet` (and `go test`, which runs vet's printf check) |
| 06 | Functions | copies of arguments, multiple and named results, `_`, variadic `...`, closures, functions as values | keeping one of `Atoi`'s two results | the compiler |
| 07 | Slices | len/cap/`append`, slicing, shared arrays and the `append` trap, `slices.Clone`, nil slices | `i <= len`, one past the end | a runtime panic: index out of range |
| 08 | Maps | missing keys read as zero, comma ok, `delete`, no order, sets, first-seen order for ties | writing to a nil map | a runtime panic: assignment to entry in nil map |
| 09 | Enums with iota | named types, `iota`, a first method: `String()` | a `Kind` where a `Status` belongs | the compiler |
| 10 | Structs and methods | struct literals, value vs pointer receivers, copies that share a slice, anonymous structs | a method called through a nil `*Task` | a runtime panic: nil pointer dereference |
| 11 | Embedding and interfaces | `UrgentTask` embeds `Task`, promotion, composition not inheritance, `fmt.Stringer`, implicit interfaces, type switch and assertion | a type missing an interface method | the compiler |
| 12 | Errors | errors as values, sentinel errors, `%w`, `errors.Is`, `defer`, `panic`/`recover` for bugs only | an error ignored with `_` | `go test` (`TestParseTasks`) |
| 13 | Files | `os.Open`, `defer Close`, `bufio.Scanner` and `Err()`, `io.Reader`, `fs.ErrNotExist`, `bufio.Writer` and `Flush` | | |
| 14 | Generics and a stable sort | `TopN[T any]`, `cmp.Ordered`, `slices.SortStableFunc`, the mini tracker | a struct passed to `Largest` | the compiler (the constraint) |

Pieces carry forward: lesson 04's `cleanStatus` feeds lesson 06's `splitLine`, which with lesson 09's
`parseStatus` and lesson 10's `Task` becomes lesson 12's `parseTask`. Lesson 13's `loadTasks` reads
the file with it, lesson 08's `countTags` counts the tags, and lesson 14 ranks and charts them.

## Choices the tracker doesn't make, and why

- **`sort.Slice`** isn't stable, so tied tags could swap; `slices.SortStableFunc` (or the older `sort.SliceStable`) keeps file order (lesson 14).
- **Ranging over the map** to print tags would change order on every run; the tracker keeps a first-seen slice beside it (lesson 08).
- **`panic` for bad input** would crash on one messy line; bad lines are errors the caller decides about, and panics stay for bugs (lesson 12).
- **`os.ReadFile` plus `strings.Split`** is fine for small files; `bufio.Scanner` reads one line at a time and handles `\r\n` for you (lesson 13).
- **Inheritance** doesn't exist; embedding reuses `Task`'s fields and methods without pretending `UrgentTask` is a `Task` (lesson 11).
- **Custom error types** with `errors.As` carry structured details; two sentinels and `%w` say all the tracker needs (lesson 12).
- **Goroutines, channels, `select` and `sync.WaitGroup`** need work that can happen at once; they arrive with the later chapter that loads several task files together, along with `go run -race` to catch data races.

## Done when

```bash
cd go && go run ./concepts && go vet ./... && go test ./... && gofmt -l .
```

runs every lesson cleanly, vet and the tests pass, gofmt lists nothing, and each `-tags bugNN` is
caught as the table says.
