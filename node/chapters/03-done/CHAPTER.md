# Chapter 03 — The done command (TypeScript)

**Video:** TypeScript: Done (tag `video/node-003`)

**Goal:** the done challenge, in `node/modules/`. `node modules/tracker/cli.ts done "title"` marks
one task finished, in the tasks file itself, and leaves every other byte alone. Python's chapter 03
is the reference: the same six `contract/done/` cases, byte for byte.

## Where it goes

| File | Gets |
| --- | --- |
| `tasklist.ts` | `findTask(tasks, title): Task \| undefined` |
| `storage.ts` | `markDone(path, task)`, and the private `TempFile` and `holds` |
| `cli.ts` | `doneCommand` and the check at the top of `main` |

## `using`: cleanup that belongs to a value

C cleaned up with `goto cleanup`; Zig with `errdefer`; Rust with `Drop`; Go with `defer` and a named
result. JavaScript now has explicit resource management: a class with a `[Symbol.dispose]()` method,
declared with `using`, is disposed when its block ends, however it ends.

```ts
using temp = new TempFile(path);                     // "wx": a new file, never someone else's
fchmodSync(temp.fd, statSync(path).mode & 0o7777);   // the old file's permissions
writeSync(temp.fd, lines.join(""));
temp.replace(path);                                  // fsync, rename, and mark it kept
// end of block: temp[Symbol.dispose]() closes it, and deletes it unless it was kept
```

If any line throws, the block ends early, `dispose` runs, and the half-made file is deleted. It's
Rust's `Drop`, written as a declaration you can see.

## Concepts

- **`#private` fields.** `#kept` is private when the program runs, not only to the type checker:
  nothing outside `TempFile` can read or set it.
- **Every byte kept.** The file is split into lines that each keep their own ending (`\n`, `\r\n` or
  `\r`), as Python's `readlines()` does with `newline=""`. Only the bracket changes.
- **`undefined` instead of `null`.** `Array.find` returns `Task | undefined`; the type makes the
  caller check it before using it.
- **Exit codes that mean something.** 0 done (or already done), 1 no such file or task (or it couldn't
  be written), 2 used wrongly.

## Done when

```bash
cd node
npm run check && npm test
../contract/run.sh node "$PWD/modules/tracker/cli.ts"              # 8 passes
CASES=done ../contract/run.sh node "$PWD/modules/tracker/cli.ts"   # 6 passes
```

Compare with `git diff course/node/03-done/end`.
