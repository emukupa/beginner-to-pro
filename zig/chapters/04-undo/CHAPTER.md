# Chapter 04 — The undo command (Zig)

**Video:** Zig: Undo (tag `video/zig-004`)

**Goal:** the undo challenge, in `zig/modules/`. `./zig-out/bin/tracker undo "title"` sets a
finished task back to `[todo]`. Python's chapter 04 is the reference: the same six `contract/undo/`
cases, byte for byte. Done and undo become one command driven by one enum.

## Where it goes

| File | Change |
| --- | --- |
| `tasklist.zig` | nothing: `findTask` already finds the task |
| `storage.zig` | `markDone` becomes `setStatus(a, io, path, task, status)` |
| `cli.zig` | `const Change = enum { done, undo }` with methods; `doneCommand` becomes `changeCommand` |

## Concepts

- **The command words are the enum.** `std.meta.stringToEnum(Change, args[1])` turns `"undo"` into
  `.undo`, or null for anything else, so the table can't disagree with what's typed. Usage prints
  the value's name with `{t}`.
- **Enums with methods.** `change.sets()`, `change.changed()` and `change.already()` are switches over
  the enum: Python's `CHANGES` dict, C's table of structs and C3's associated values, as code.
- **Exhaustive switches.** A `switch` on an enum must handle every value. `setStatus` spells each
  status with one, and `other` returns `error.NoSpelling` before anything is opened. Add a status to
  `models.zig` and the build stops there: `error: switch must handle all possibilities`. No warning
  flag needed; the language insists.

## Done when

```bash
cd zig/modules
zig build check      # 8, then 6 done, then 6 undo passes
```

Compare with `git diff course/zig/04-undo/end`.
