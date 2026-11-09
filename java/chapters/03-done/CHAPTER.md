# Chapter 03 — The done command (Java)

**Video:** Java: Done (tag `video/java-003`)

**Goal:** the done challenge, in `java/modules/`. `tracker done "title"` marks one task finished, in
the tasks file itself, and leaves every other byte alone. Python's chapter 03 is the reference: the
same six `contract/done/` cases, byte for byte.

## Where it goes

| Package | Gets |
| --- | --- |
| `tracker.tasklist` | `findTask(tasks, title)`: an `Optional<Task>` |
| `tracker.storage` | `markDone(path, task)`, and a private `TempFile implements AutoCloseable` and `holds` |
| `tracker.app` | `done(words)` and the check at the top of `main` |

## try-with-resources

```java
try (TempFile temp = new TempFile(path)) {                       // Files.createTempFile beside it
    Files.setPosixFilePermissions(temp.path, Files.getPosixFilePermissions(path));
    temp.channel.write(...);
    temp.replace(path);                                          // force(true), atomic move, kept
}                                                                // temp.close(): deleted unless kept
```

Anything declared in the brackets after `try` is closed when the block ends, however it ends, in
reverse order of opening. Java has had this since 2011: it's C#'s `using` and TypeScript's `using`,
and it's why `markDone` needs no `finally`.

## Concepts

- **Checked exceptions all the way.** `markDone` declares `throws IOException`, so `done` must catch
  it: that's where "Couldn't write" comes from.
- **The standard library does the careful parts.** `Files.createTempFile` picks a random name and
  refuses to reuse a file; `FileChannel.force(true)` puts the bytes on the disk;
  `Files.move(..., ATOMIC_MOVE, REPLACE_EXISTING)` swaps the files in one step.
- **Every byte kept.** A `Matcher` walks the file line by line, each line keeping its own ending.
- **Exit codes that mean something.** 0 done (or already done), 1 no such file or task (or it couldn't
  be written), 2 used wrongly.

## Done when

```bash
cd java/modules
make test && make check                                                             # 8 passes
CASES=done ../../contract/run.sh java -p "$PWD/build" -m tracker.app/tracker.app.Main   # 6 passes
```

Compare with `git diff course/java/03-done/end`.
