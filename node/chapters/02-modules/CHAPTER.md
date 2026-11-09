# Chapter 02 — ES modules: export, import, and import type (TypeScript)

**Video:** TypeScript: Modules (tag `video/node-002`)

**Goal:** build `node/modules/`: the code of `node/one-file/tracker.ts` split into ES modules in
`node/modules/tracker/`, one file per job, the same split as Python's chapter 02, without changing a
byte of what the program does. The contract proves it.

```bash
cd node
npm run check && npm test                                   # the type check, then the tests
../contract/run.sh node "$PWD/modules/tracker/cli.ts"       # 8 passes
```

## Concepts

- **A file is a module, and nothing leaves it without `export`.** `parsing.ts` exports `parseLine`
  and `TAG_MARKER`; `statusOf` isn't exported, so it's `parsing.ts`'s alone.
- **Two checks, at two times.** Import `statusOf` from `cli.ts` and `tsc` stops it:
  `error TS2459: Module '"./parsing.ts"' declares 'statusOf' locally, but it is not exported.` Run it
  anyway and Node stops it too, when it links the modules:
  `SyntaxError: The requested module './parsing.ts' does not provide an export named 'statusOf'`.
- **`import type`.** Node runs TypeScript by erasing the types, so an import that is only a type
  must say so: `import type { Pair } from "./tasklist.ts"`. Leave out `type` and `tsc` says
  `'Pair' is a type and must be imported using a type-only import when 'verbatimModuleSyntax' is
  enabled`, because at run time there is no `Pair` to import, and Node fails the same way.
- **Explicit extensions.** Imports name the file, `./models.ts`, exactly as Node will look for it.
- **Tests beside the code.** `parsing.test.ts` sits next to `parsing.ts`; `npm test` runs
  `node --test`, which finds every `*.test.ts`. `drawChart` takes the function to print with, so the
  test hands it one that collects lines into an array.
- **Dependencies point one way.** ES modules allow import cycles, but a module in a cycle can run
  before the module it needs has finished, so the rule from Python's chapter 02 is ours to keep.

## The split

| File | Job | Imports of ours |
| --- | --- | --- |
| `models.ts` | `Task`, `UrgentTask` | nothing |
| `text.ts` | Python's whitespace (`strip`, `words`) and `roundHalfEven` | nothing |
| `parsing.ts` | `parseLine`, `TAG_MARKER`; private `statusOf` | models, text |
| `storage.ts` | `loadTasks`, `appendTitles`: the only file that opens files | models (types only), parsing |
| `tasklist.ts` | `addTasks`, `countTags`, `topTags`, the `Pair` type, `summarize` | models (types only), parsing, text |
| `chart.ts` | `drawChart(pairs, print)` | tasklist (types only), text |
| `cli.ts` | `ask`, `parseWholeNumber`, `main`: the only file that reads input or prints | all of them |

## Done when

```bash
cd node
npm run check                                               # no errors
npm test                                                    # every test passes
../contract/run.sh node "$PWD/modules/tracker/cli.ts"       # 8 passes
```

Compare with `git diff course/node/02-modules/end`.
