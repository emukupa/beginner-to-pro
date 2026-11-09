# Chapter 01 — The whole tracker in one file (TypeScript)

**Video:** TypeScript: Beginner to Pro (tag `video/node-001`)

**Goal:** write `node/one-file/tracker.ts`, the same task tracker as `python/tasks.py`, in
TypeScript, run directly by Node. Python is the reference: the contract checks every byte of output,
every exit code and the tasks file afterwards.

```bash
cd node
node one-file/tracker.ts                               # run it (Node strips the types, no build)
npm run check                                          # tsc, strict: the type check
../contract/run.sh node "$PWD/one-file/tracker.ts"     # the 8 contract cases
```

## Concepts, mapped from Python, Go and Rust

| Python | Go | Rust | TypeScript |
| --- | --- | --- | --- |
| `class Task` | a struct | a struct | `class Task` with `readonly` fields |
| `class UrgentTask(Task)` | a `Kind` field | a `Kind` enum | `class UrgentTask extends Task`, with `override` required |
| `isinstance(task, UrgentTask)` | `t.Kind == Urgent` | `t.kind == Kind::Urgent` | `task instanceof UrgentTask` |
| `None` from `parse_line` | comma-ok | `Result` | `Task \| null`: the return type says it |
| `str.split()`, `str.strip()` | `strings.Fields` | `split_whitespace` | regexes built from Python's exact whitespace set |
| exceptions | errors as values | `Result` and `?` | exceptions again: `try`/`catch`, where `catch` gives `unknown` |
| a `dict` keeps insertion order | a slice beside a map | a `Vec` beside a `HashMap` | a `Map` keeps insertion order, like a dict |
| `sorted(key=...)` | `slices.SortStableFunc` | `sort_by_key` | `toSorted`, which is stable and returns a new array |
| `round()` | `math.RoundToEven` | `round_ties_even` | `roundHalfEven`, written here: `Math.round` and `toFixed` send halves up |
| `f"{tag:<{w}}"` | `%-*s` | padding by `chars()` | `[...tag].length`: characters, not UTF-16 code units |
| `int(text)` | `parseWholeNumber` | `parse_whole_number` | `parseWholeNumber`: `Number("")` is 0, and `Number("1_000")` is NaN |
| `input()` | `bufio.Reader` | `read_line` | `readline`, read with `await`: an empty line at the end of input |

## Types that are checked, then erased

Node runs `tracker.ts` by deleting the type annotations and running the JavaScript that's left, so
the types cost nothing at run time and can't catch anything there either. `npm run check` runs `tsc`
with `strict` and the extra checks in `tsconfig.json`: `noUncheckedIndexedAccess` makes
`pairs[0]` a `Pair | undefined` that has to be checked, and `exactOptionalPropertyTypes`,
`noImplicitOverride` and `noUnusedLocals` close the other gaps.

## Done when

```bash
cd node
npm run check                                           # no errors
../contract/run.sh node "$PWD/one-file/tracker.ts"      # 8 passes
```

Compare with `git diff course/node/01-one-file/end`.
