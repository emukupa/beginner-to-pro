# Chapter 02 — A Swift package: modules, public and internal (Swift)

**Video:** Swift: Modules (tag `video/swift-002`)

**Goal:** build `swift/modules/`: the code of `swift/one-file/tracker.swift` split into a library
module with one file per job, a program that uses it, and tests, without changing a byte of what
the program does. The contract proves it.

```bash
cd swift/modules
swift build -c release                                    # .build/release/tracker
swift test                                                # 7 tests, Swift Testing
../../contract/run.sh "$PWD/.build/release/tracker"       # 8 passes
```

## Concepts

- **A target is a module.** `Package.swift` lists three targets: `TrackerCore` (a library, one file
  per job in `Sources/TrackerCore/`), `tracker` (the program) and `TrackerCoreTests`. Every file in
  a target sees every other file in it with no imports at all.
- **`internal` by default, `public` to export.** Inside `TrackerCore`, nothing needs a modifier. To
  be used from `tracker`, a type, its properties and functions must say `public`. `statusOf` doesn't;
  call it from `main.swift` and the build stops: `error: cannot find 'statusOf' in scope`. To another
  module it doesn't exist.
- **`@testable import`.** The tests write `@testable import TrackerCore`, which opens up `internal`
  names to them, so they can test `statusOf` directly.
- **Typed throws.** `loadTasks` says `throws(LoadError)`: it can only throw a `LoadError`, so `main`
  catches `.notFound` and `.unreadable` and needs no catch-all.
- **Swift Testing.** `@Test` functions with `#expect`, `#require` (which unwraps an optional or
  stops the test) and `#expect(throws:)`.
- **Swift 6 mode and warnings as errors** for every target. The public types are `Sendable`, so
  they could be shared between threads safely if a later chapter needs it.

## The split

| File | Job | Uses of ours |
| --- | --- | --- |
| `Sources/TrackerCore/Models.swift` | `Status`, `Kind`, `Task`, `TagCount` | nothing |
| `Sources/TrackerCore/Text.swift` | `pythonStrip`, `pythonWords`, `width`: extensions on `String` | nothing |
| `Sources/TrackerCore/Parsing.swift` | `parseLine`, `tagMarker`; internal `statusOf` | Models, Text |
| `Sources/TrackerCore/Storage.swift` | `loadTasks`, `appendTitles`, `LoadError`: the only file that opens files | Models, Parsing |
| `Sources/TrackerCore/TaskList.swift` | `addTasks`, `countTags`, generic `topN`, `topTags`, `summarize` | Models, Parsing |
| `Sources/TrackerCore/Chart.swift` | `drawChart(pairs, width:, print:)` | Models, Text |
| `Sources/tracker/main.swift` | `ask`, `parseWholeNumber`, the program itself | all of them |

## Done when

```bash
cd swift/modules
swift test                                                # 7 tests passed
swift build -c release && ../../contract/run.sh "$PWD/.build/release/tracker"   # 8 passes
```

Compare with `git diff course/swift/02-modules/end`.
