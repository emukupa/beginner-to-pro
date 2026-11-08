# Chapter 00 — TypeScript concepts

**Video:** TypeScript: Concepts (tag `video/node-000`)

**Goal:** learn TypeScript, on Node, before building anything with it. `node/concepts/` holds one
lesson per file. Each lesson is an ES module that exports a `TITLE` and a `run` function, and
imports what it borrows from earlier lessons (`import { cleanStatus } from "./lesson_04_strings.ts"`).
`main.ts` imports them all and keeps them in a table.

Node runs the `.ts` files directly: it deletes the types first ("type stripping") and runs what's
left, so there is no build step. That also means **Node never checks the types**. `tsc` does that,
as a separate step, with the strict settings in `tsconfig.json` (`strict`, `noUncheckedIndexedAccess`,
`exactOptionalPropertyTypes`, `noImplicitOverride`, `noUnusedLocals`, `erasableSyntaxOnly`, ...).

```bash
cd node
npm install            # once: TypeScript (tsc) and Node's type definitions
npm run concepts       # every lesson (lesson 13 asks one question)
node concepts/main.ts 7       # just lesson 7 (or several: 7 9)
npm run check          # tsc type-checks every lesson: must be clean
npm test               # node --test: the lessons' reusable pieces, tested
npm run bug -- 7       # type-check lesson 7's deliberate mistake: watch tsc catch it
npm run enum           # the TypeScript enum, which Node can't strip (see lesson 09)
```

**TypeScript's `BUG=1`** is the type checker. C compiles a bug in and lets the sanitizers catch it
at run time; in TypeScript the mistake never gets that far. Each lesson's mistake sits in its own
file, `concepts/bugs/lesson_NN.ts`, which the normal check leaves out. `npm run bug -- N` runs
`concepts/bugs/check.ts`, which type-checks that one file under the project's own `tsconfig.json`,
and tsc refuses it. To see what would have happened without tsc, run the file unchecked:
`node concepts/bugs/lesson_07.ts` crashes with a `TypeError`, because type stripping never looks
at the types.

## The lessons

| # | Lesson | Concepts | `npm run bug` shows | Caught by |
| --- | --- | --- | --- | --- |
| 01 | Hello | `console.log`, template literals, a type annotation, type stripping, `process.exitCode` | an unused variable | `noUnusedLocals` (TS6133) |
| 02 | Values and types | `const`/`let`, the primitive types, `typeof`, `null` vs `undefined`, `==` vs `===`, `any` vs `unknown` | an `unknown` used unchecked | `strict` (TS18046) |
| 03 | Numbers | one number type, `Math.trunc`, `0.1 + 0.2`, safe integers and `bigint`, `NaN`, `Math.round` vs `roundHalfEven`, `parseWholeNumber` | text passed for a number | argument types (TS2345) |
| 04 | Strings | `trim`, `split`, `indexOf`/`slice`, `padEnd`, immutability, `.length` (UTF-16) vs code points vs UTF-8 bytes | `toLowercase`, misspelt | property check (TS2551, with a suggestion) |
| 05 | Decisions and loops | `if`, truthiness, `?:`, `switch`, `for`, `for...of` vs `for...in`, `while`, `break`/`continue` | `status === 1` on a string | no-overlap comparison (TS2367) |
| 06 | Functions | declarations, arrows, default/optional/rest parameters, spread, closures, functions as values | an argument missing | argument count (TS2554) |
| 07 | Arrays, Map and Set | `push`/`pop`, aliasing vs copying, destructuring, `Map` (`countTags`), `Set`, insertion order vs an object's | `tags[0].toUpperCase()` | `noUncheckedIndexedAccess` (TS18048) |
| 08 | Objects, interfaces and readonly | object literals, spread copies, `interface`, `type`, optional properties, `readonly`, `Object.freeze`, `parseLine` | assigning to a parsed title | `readonly` (TS2540) |
| 09 | Unions and type guards | literal unions, `text is Status` guards, a discriminated union (`Line`), `never` for exhaustiveness, `as const` vs `enum` | a union case the switch forgets | the `never` check (TS2345) |
| 10 | Classes and inheritance | fields, `constructor`, `#private`, getters, `static`, `implements`, `extends`, `override`, `instanceof` | an override without `override` | `noImplicitOverride` (TS4114) |
| 11 | Errors | `throw`, `try`/`catch`/`finally`, `unknown` in catch, a custom `Error` with `cause`, a `Result<T, E>` union | `error.message` on a caught value | `strict` (TS18046) |
| 12 | Files and async/await | Promises, `async`/`await`, `Promise.all`, `node:fs/promises`, `readLines`, `readline/promises`, `import.meta.dirname` | a forgotten `await` | property check on `Promise<string>` (TS2339, "Did you forget to use 'await'?") |
| 13 | Generics, and a mini tracker | `topN<T>`, stable `toSorted`, then everything together: load, count, rank and chart `tasks.txt` | ranking by text, not a number | the generic's key type (TS2322) |
| 14 | Generators, satisfies, `?.` and `??` | `function*`/`yield`, lazy and endless generators, `satisfies`, optional chaining, `??` vs `\|\|` | a misspelt key | `satisfies` (TS2561) |

Pieces carry forward: lesson 03's `roundHalfEven` and `parseWholeNumber`, 04's `cleanStatus` and
`textWidth`, 06's `percent` and `bar`, 07's `countTags`, 08's `parseLine`, 09's `Status`, 10's
`Task`, 11's `Result` and 12's `loadTasks` and `ask` come together in lesson 13, which loads the
tasks file, asks how many top tags, and prints the same summary and chart as the tracker.

**The enum.** A TypeScript `enum` isn't erasable: it makes a JavaScript object of its own, so Node's
type stripping refuses it (`ERR_UNSUPPORTED_TYPESCRIPT_SYNTAX`), and `erasableSyntaxOnly` makes tsc
refuse it too. It lives in `concepts/extras/status_enum.ts`, with its own `tsconfig.json` that turns
`erasableSyntaxOnly` off (still checked by `npm run check`), and `npm run enum` runs it with
`--experimental-transform-types`, which rewrites it into JavaScript first. Lesson 09 shows why the
union is usually better: no generated code, no reverse-mapped keys, and the file's text `"done"` is
already a `Status`.

## Choices the tracker doesn't make, and why

- **`enum`** needs a flag Node calls experimental; a union of strings is the same thing, erased (lesson 09).
- **`any`** turns the checker off; values from outside (JSON, files) are `unknown` until checked (lesson 02).
- **`Math.round` and `toFixed`** send halves up; the contract needs halves to even, so we write `roundHalfEven` (lesson 03).
- **`parseInt` and `Number`** accept `"12abc"` and `""`; `parseWholeNumber` checks the text first (lesson 03).
- **Plain objects as counters** reorder number-like keys; a `Map` keeps first-seen order, which the ties need (lesson 07).
- **Parameter properties** (`constructor(readonly title: string)`) aren't erasable; fields are written out (lesson 10).
- **Exceptions for expected failures**: a missing file or a bad answer comes back as a `Result`; `throw` is for the unexpected (lessons 11, 12).
- **`readFileSync`** is simpler, but blocks everything while the disk works; the tracker uses `await` (lesson 12).
- **Generators** aren't needed for a six-line file, but you'll read them in other people's code (lesson 14).
- **A build step** (tsc writing `.js`) isn't needed: Node runs the `.ts` files, and tsc only checks (`noEmit`).

## Done when

```bash
cd node && npm install && npm run check && npm run concepts && npm test
```

type-checks cleanly, runs every lesson and passes every test, and each `npm run bug -- N` fails
with the error the table says.
