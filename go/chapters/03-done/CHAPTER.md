# Chapter 03 — The done command (Go)

**Video:** Go: Done (tag `video/go-003`)

**Goal:** the done challenge, in `go/modules/`. `./modules/build/tracker done "title"` marks one task
finished, in the tasks file itself, and leaves every other byte alone. Python's chapter 03 is the
reference: the same six `contract/done/` cases, byte for byte.

## Where it goes

| File | Gets |
| --- | --- |
| `internal/tasklist` | `Find(tasks, title) *models.Task`: a pointer into the slice, or `nil` |
| `internal/storage` | `MarkDone(path, task) (err error)` and an unexported `holds` |
| `main.go` | `doneCommand` and the check at the top of `main` |

## A named result and a deferred function

C cleaned up with `goto cleanup`; C3 with `defer catch`; Zig with `errdefer`; Rust with `Drop`. Go
has `defer`, which runs however the function returns, and a named result it can read:

```go
func MarkDone(path string, task models.Task) (err error) {
	...
	temp, err := os.CreateTemp(filepath.Dir(path), filepath.Base(path)+".*")
	if err != nil {
		return err
	}
	defer func() {
		if err != nil {             // only when MarkDone is returning an error
			temp.Close()
			os.Remove(temp.Name())  // never leave the half-made file behind
		}
	}()
	...
	return os.Rename(temp.Name(), path)
}
```

Because `err` is named in the signature, `return x` sets it before the deferred function runs, so
the closure sees the error the function is about to return. That's Zig's `errdefer`, built from two
ordinary pieces.

## Concepts

- **The safe rewrite, from the standard library.** `os.CreateTemp` makes a new file with a random
  name that can't be anyone else's, in the same folder (so `os.Rename` stays on one disk);
  `Chmod` copies the old permissions, `Sync` puts it on the disk, `Rename` swaps it in.
- **Every byte kept.** `os.ReadFile` reads the whole file, and `strings.SplitAfterSeq` walks it line
  by line, each line keeping its own ending, so `\r\n` files stay `\r\n`. It's an iterator:
  `for line := range ...` pulls one line at a time without building a slice.
- **A pointer into the slice.** `Find` returns `&tasks[i]`, or `nil`; the caller checks for `nil`.
- **Quoting by hand.** `%q` would escape quotes and backslashes in the title; Python doesn't, so the
  message writes its own `"`.
- **Exit codes that mean something.** 0 done (or already done), 1 no such file or task (or it couldn't
  be written), 2 used wrongly.

## Done when

```bash
cd go
go test ./modules/... && go build -o modules/build/tracker ./modules
../contract/run.sh "$PWD/modules/build/tracker"              # 8 passes
CASES=done ../contract/run.sh "$PWD/modules/build/tracker"   # 6 passes
```

Compare with `git diff course/go/03-done/end`.
