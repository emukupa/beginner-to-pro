# Chapter 02 — Packages, Gradle modules and internal (Kotlin)

**Video:** Kotlin: Modules (tag `video/kotlin-002`)

**Goal:** build `kotlin/modules/`: the code of `kotlin/one-file/tracker.kt` split into packages, one
per job, in a Gradle build with two modules, without changing a byte of what the program does. The
contract proves it.

```bash
cd kotlin/modules
./gradlew installDist test                                              # build, then the tests
../../contract/run.sh "$PWD/app/build/install/tracker/bin/tracker"      # 8 passes
```

The first `./gradlew` downloads Gradle itself and the Kotlin plugin; after that it works offline.

## Concepts

- **Packages don't have to match folders, but here they do.** `core/src/main/kotlin/tracker/parsing/Parsing.kt`
  starts with `package tracker.parsing`, and the app imports `tracker.parsing.parseLine`: a
  top-level function, no class needed.
- **Four kinds of visibility.** `public` is the default; `private` at the top of a file means that
  file only (`SPACE` in `Text.kt`); `internal` means this module only.
- **A Gradle module is a Kotlin module.** `settings.gradle.kts` includes `core` and `app`, and `app`
  depends on `project(":core")`. `statusOf` is `internal` to `core`; call it from `app` and the
  build stops: `Cannot access 'fun statusOf(raw: String): String': it is internal in file.` The
  tests live in `core` too, so they can call it.
- **The wrapper.** `gradlew` downloads and runs the exact Gradle version the project was written
  with (9.7.1), so nobody needs to install Gradle.
- **`kotlin.test` on JUnit 5.** `core/src/test/kotlin/` holds the tests: `@Test` functions with
  `assertEquals`, `assertIs` (which also casts), `assertNull` and `assertFailsWith`.
- **Warnings are errors** in both modules (`allWarningsAsErrors`), and both target JVM 25: the newest
  target Kotlin 2.4 knows.
- **Dependencies point one way.** Gradle refuses a cycle between modules, but packages inside one
  module can use each other in a circle, so the rule from Python's chapter 02 is ours to keep there.

## The split

| Package | Job | Uses of ours |
| --- | --- | --- |
| `tracker.models` | `Task`, `UrgentTask`, `data class TagCount` | nothing |
| `tracker.text` | `pythonStrip`, `pythonWords`, `width`: extensions on `String` | nothing |
| `tracker.parsing` | `parseLine`, `TAG_MARKER`; `internal statusOf` | models, text |
| `tracker.storage` | `loadTasks`, `appendTitles`: the only package that opens files | models, parsing |
| `tracker.tasklist` | `addTasks`, `countTags`, generic `topN`, `topTags`, `data class Summary` | models, parsing |
| `tracker.chart` | `drawChart(pairs, width, print)` | models, text |
| `tracker.app` (module `app`) | `ask`, `parseWholeNumber`, `main` | all of them |

## Done when

```bash
cd kotlin/modules
./gradlew test                                                          # 7 tests, all pass
./gradlew installDist && ../../contract/run.sh "$PWD/app/build/install/tracker/bin/tracker"   # 8 passes
```

Compare with `git diff course/kotlin/02-modules/end`.
