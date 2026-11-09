# Chapter 04 — Undo (TypeScript)

**Video:** TypeScript: Undo (tag `video/node-004`)

**Goal:** `node modules/tracker/cli.ts undo "title"` puts a finished task back to `[todo]`, and done
and undo share one function. Python's chapter 04 is the reference: the six `contract/undo/` cases,
byte for byte, with every earlier case still passing.

## Where it goes

| File | Change |
| --- | --- |
| `models.ts` | `type Status = "todo" \| "done"`: the statuses a command can set |
| `tasklist.ts` | nothing: `findTask` already finds the task |
| `storage.ts` | `markDone(path, task)` becomes `setStatus(path, task, status)` |
| `cli.ts` | the `CHANGES` table, the `Command` type, the `isCommand` guard; `doneCommand` becomes `changeCommand` |

## Concepts

- **The status is its own spelling.** `Status` is a union of two string literal types. There's no
  enum to translate: `[${status}]` is the bracket, and only `"todo"` and `"done"` fit.
- **A table that's checked.** `CHANGES` is Python's dict. `as const` keeps each value's exact words
  (`"done"`, not `string`), and `satisfies Record<string, Change>` checks every entry against
  `Change` without losing them. `type Command = keyof typeof CHANGES` is worked out from the table:
  `"done" | "undo"`.
- **A type guard.** `isCommand(word): word is Command` tells TypeScript that, inside the `if`, the
  word is a `Command`, so `CHANGES[name]` needs no checks.
- **Checked, then erased.** Add `start: { sets: "doing", ... }` and `tsc` stops it:
  `error TS2322: Type '"doing"' is not assignable to type 'Status'`. Node, which only strips the
  types, would run it anyway. That's why `npm run check` is part of the build, not an extra.

## Done when

```bash
cd node
npm run check && npm test
../contract/run.sh node "$PWD/modules/tracker/cli.ts"              # 8 passes
CASES=done ../contract/run.sh node "$PWD/modules/tracker/cli.ts"   # 6 passes
CASES=undo ../contract/run.sh node "$PWD/modules/tracker/cli.ts"   # 6 passes
```

Compare with `git diff course/node/04-undo/end`.
