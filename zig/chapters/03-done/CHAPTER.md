# Chapter 03 — The done command (Zig)

**Video:** Zig: Done (tag `video/zig-003`)

**Goal:** the done challenge, in `zig/modules/`. `./zig-out/bin/tracker done "title"` marks one task
finished, in the tasks file itself, and leaves every other byte alone. Python's chapter 03 is the
reference: the same six `contract/done/` cases, byte for byte.

## Where it goes

| File | Gets |
| --- | --- |
| `tasklist.zig` | `findTask(a, tasks, title)`: `?*const Task`, a pointer into the list (borrowed) or null |
| `storage.zig` | `markDone(a, io, path, task)` and a private `holds` |
| `cli.zig` | `doneCommand` and the check at the top of `main` |

## `defer` and `errdefer`

This is why Zig comes right after C and C3. C cleaned up with `goto cleanup` and a flag; C3 with
`defer` and `defer catch`. Zig has the same pair, built in:

```zig
const file = try dir.createFile(io, temp, .{ .exclusive = true });
errdefer dir.deleteFile(io, temp) catch {}; // only if we leave with an error
defer file.close(io);                       // always
```

`errdefer` runs only when the function returns an error, so a half-made file is deleted and a
finished one, once renamed over the tasks file, is kept. Defers run in reverse order: on an error
the file is closed first, then deleted.

## Concepts

- **Every byte kept.** `allocRemaining` reads the whole file; the loop splits it at each `\n` and
  keeps the ending with its line, so `\r\n` files stay `\r\n`. Only the bracket changes.
- **The safe rewrite.** A new file beside the old one, with a random name (`io.random`) created
  `.exclusive`ly, the old file's permissions (`setPermissions`), `sync` to the disk, then `rename`
  over the old one. The standard library also packages this up as `Dir.createFileAtomic` and
  `File.Atomic`; writing it out shows what `errdefer` is for.
- **A borrowed pointer.** `findTask` returns `?*const Task`: an optional pointer into the list.
- **Exit codes that mean something.** 0 done (or already done), 1 no such file or task, 2 used wrongly.

## Done when

```bash
cd zig/modules
zig build check      # 8 passes, then 6 done passes
```

Compare with `git diff course/zig/03-done/end`.
