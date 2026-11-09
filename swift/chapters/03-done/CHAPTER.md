# Chapter 03 — The done command (Swift)

**Video:** Swift: Done (tag `video/swift-003`)

**Goal:** the done challenge, in `swift/modules/`. `tracker done "title"` marks one task finished, in
the tasks file itself, and leaves every other byte alone. Python's chapter 03 is the reference: the
same six `contract/done/` cases, byte for byte.

## Where it goes

| File | Gets |
| --- | --- |
| `Sources/TrackerCore/TaskList.swift` | `findTask(tasks, title) -> Task?` |
| `Sources/TrackerCore/Storage.swift` | `markDone(path, task)`, `WriteError`, and the internal `TempFile`, `holds` and `linesKeepingEndings` |
| `Sources/tracker/main.swift` | `done(words)` and the check at the top |

## A noncopyable value with a `deinit`

```swift
struct TempFile: ~Copyable {
    ...
    consuming func replace(_ target: String) throws(WriteError) { fsync, rename; kept = true }
    deinit { close(fd); if !kept { unlink(path) } }
}

let temp = try TempFile(beside: path)        // open(..., O_CREAT | O_EXCL): never someone else's
try temp.copyPermissions(from: path)
try temp.write(Array(lines.joined().utf8))
try temp.replace(path)                       // consumes temp
```

A struct is normally copied freely; `~Copyable` says this one can't be. So there is only ever one
owner of the open file, and its `deinit` runs exactly once: when `markDone` returns early because a
`try` threw (and the half-made file is deleted), or at the end of `replace`, which `consuming` hands
the value to. After `replace`, using `temp` again is a compile error. It's Rust's `Drop` and
`replace(self)`, in Swift. (Swift also has Zig's `defer`, which `appendTitles` uses to close its file.)

## Concepts

- **POSIX from Swift.** `open`, `fchmod`, `write`, `fsync` and `rename` are the C functions, called
  directly: Swift imports C on Apple platforms (and Glibc on Linux) with no wrapper.
- **Typed throws and an exhaustive switch.** `do throws(LoadError) { ... } catch { switch error { ... } }`:
  the catch knows `error` is a `LoadError`, so the `switch` covers both cases with no `default`.
- **Every byte kept.** `linesKeepingEndings` walks the text's code points and keeps each line's own
  ending, `\r\n` included, which a Swift `Character` would treat as one character.
- **Exit codes that mean something.** 0 done (or already done), 1 no such file or task (or it couldn't
  be written), 2 used wrongly.

## Done when

```bash
cd swift/modules
swift test && swift build -c release
../../contract/run.sh "$PWD/.build/release/tracker"              # 8 passes
CASES=done ../../contract/run.sh "$PWD/.build/release/tracker"   # 6 passes
```

Compare with `git diff course/swift/03-done/end`.
