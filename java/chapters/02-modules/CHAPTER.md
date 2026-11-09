# Chapter 02 — Packages and modules (Java)

**Video:** Java: Modules (tag `video/java-002`)

**Goal:** build `java/modules/`: the code of `java/one-file/Tracker.java` split into packages, one
per job, inside two Java modules, without changing a byte of what the program does. The contract
proves it.

```bash
cd java/modules
make            # javac -Xlint:all -Werror -d build --module-source-path src ...
make test       # 6 checks, plain assert statements, java -ea
make check      # the contract: 8 passes
make run        # java -p build -m tracker.app/tracker.app.Main
```

## Concepts

- **A package is a folder, and its name is written in every file.** `src/tracker.core/tracker/parsing/Parsing.java`
  starts with `package tracker.parsing;`, and other packages `import tracker.parsing.Parsing;`.
- **Package-private by default.** A class or method with no modifier can be used only inside its own
  package. `Parsing.statusOf` has none; call it from `Main` and the build stops:
  `error: statusOf(String) is not public in Parsing; cannot be accessed from outside package`.
- **Modules guard packages.** `module-info.java` names a module and lists the packages it `exports`;
  `tracker.app` says `requires tracker.core;`. A `public` class in a package that isn't exported is
  still out of reach. Delete `exports tracker.chart;` and the app can't even import it:
  `error: package tracker.chart is not visible` (`package tracker.chart is declared in module
  tracker.core, which does not export it`).
- **Module path, not class path.** The program runs with `java -p build -m tracker.app/tracker.app.Main`:
  the module path, and the module and class to start from.
- **No cycles between modules.** Java refuses a module cycle (`tracker.core` can't require
  `tracker.app`), but packages inside one module can still use each other in a circle, so the rule
  from Python's chapter 02 is ours to keep there.
- **Tests outside the modules.** `test/` is compiled on the class path against `build/tracker.core`,
  which ignores `module-info`; the tests use the public API only.

## The split

| Package | Job | Uses of ours |
| --- | --- | --- |
| `tracker.models` | `Task`, `UrgentTask`, `record TagCount` | nothing |
| `tracker.text` | Python's whitespace (`strip`, `words`) and `width` | nothing |
| `tracker.parsing` | `parseLine`, `TAG_MARKER`; package-private `statusOf` | models, text |
| `tracker.storage` | `loadTasks`, `appendTitles`: the only package that opens files | models, parsing |
| `tracker.tasklist` | `addTasks`, `countTags`, generic `topN`, `topTags`, `record Summary` | models, parsing |
| `tracker.chart` | `draw(PrintStream, pairs, width)` | models, text |
| `tracker.app` (its own module) | `Main`: reading input, `parseWholeNumber`, the summary | all of them |

## Done when

```bash
cd java/modules
make test       # 6 passed, 0 failed
make check      # 8 passes
```

Compare with `git diff course/java/02-modules/end`.
