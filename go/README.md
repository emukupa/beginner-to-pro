# Go

The task tracker in Go. Go is small on purpose: one way to loop, errors as plain values, no
inheritance, and a toolchain that formats, vets and tests your code for you. Needs Go 1.27 (the
lessons use `range` over integers, the `slices`, `maps` and `cmp` packages, and iterators).

This folder is one Go module (`go.mod`, module path `github.com/emukupa/beginner-to-pro/go`). Run
every command from `go/`.

| Folder | What | Chapter |
| --- | --- | --- |
| [`concepts/`](concepts/) | one file per concept, run by `main.go`: `go run ./concepts` runs them all, `go run ./concepts 7` one, `go run -tags bug07 ./concepts 7` with its bug | 00 |
| [`one-file/`](one-file/) | the whole tracker in `main.go` | 01 |

```bash
cd go
go run ./concepts    # every lesson
go test ./...        # the table-driven tests
go vet ./...         # Go's own checker: must say nothing
gofmt -l .           # files that aren't gofmt-formatted: must list nothing
```

```bash
cd go
go build -o one-file/build/tracker ./one-file
../contract/run.sh "$PWD/one-file/build/tracker"   # the contract: must match Python byte for byte
```

| Chapter | Start | End | Video |
| --- | --- | --- | --- |
| [00 Concepts](chapters/00-concepts/CHAPTER.md) | `course/go/00-concepts/start` | `course/go/00-concepts/end` | `video/go-000` |
| [01 One file](chapters/01-one-file/CHAPTER.md) | `course/go/01-one-file/start` | `course/go/01-one-file/end` | `video/go-001` |

VS Code: install the official **Go** extension. It runs `gopls`, formats on save with gofmt, and
shows vet's findings as you type.
