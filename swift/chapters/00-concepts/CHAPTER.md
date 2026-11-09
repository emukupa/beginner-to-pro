# Chapter 00 — Swift concepts

**Video:** Swift: Concepts (tag `video/swift-000`)

**Goal:** learn Swift before building anything with it. `swift/concepts/` is one Swift package
(`Package.swift`) with one executable target. Each lesson is a file in `Sources/concepts/`, holding
a caseless `enum` with a `title` and a `run()`; `main.swift` keeps them in a table. Every file is in
the same module, so a later lesson uses an earlier one's `Task` or `parseTask` with no `import`
(splitting into modules with `public` and `internal` comes later). The tests in
`Tests/ConceptsTests/` use **Swift Testing** (`import Testing`, `@Test`, `#expect`), which ships with
the toolchain, and reach the module's `internal` names through `@testable import concepts`.

Swift comes last, after Kotlin, and borrows from nearly everything before it: structs are values
that copy instead of share, enums carry data like Rust's, `Int?` is Kotlin's null safety, `throws`
and `try` make every failure point visible, `defer` is Zig's, and memory is freed by automatic
reference counting (ARC), not a garbage collector. So instead of `BUG=1`, each lesson has a
compilation condition, `BUG07`, set with `-Xswiftc -DBUG07`; the mistake sits in `#if BUG07`, and
code in an `#if` that isn't set is never compiled. Most mistakes never build. Two (12 and 14) build
and then stop the program with `Fatal error:` and a backtrace pointing at the line, instead of
carrying on wrong.

`Package.swift` sets Swift 6 language mode, where strict concurrency checking turns data races
into compile errors, and `.treatAllWarnings(as: .error)`, the way C's `-Werror` and Rust's `deny`
do: an ignored result or a `var` that never changes stops the build.

```bash
cd swift/concepts
swift run concepts                          # build, then run every lesson
swift run concepts 7                        # just lesson 7 (or several: swift run concepts 4 7)
swift run -Xswiftc -DBUG07 concepts 7       # lesson 7 with its bug compiled in: watch the compiler catch it
swift test                                  # the @Test functions in Tests/ConceptsTests
```

Lessons 11 to 14 read `tasks.txt`, a copy of `contract/tasks.txt`, from the current folder, so run
them from `swift/concepts`. A clean build takes about 15 seconds; after that, about one.

## The lessons

| # | Lesson | Concepts | `-DBUGNN` shows | Caught by |
| --- | --- | --- | --- | --- |
| 01 | Hello | `print`, `\(...)` interpolation, `separator:` and `terminator:`, multi-line `"""` strings, exit codes | a typo inside `\( )` | the compiler: `cannot find 'nmae' in scope` |
| 02 | Values and types | `let` vs `var`, inference, `Int` `Double` `Bool` `Character` `String`, `type(of:)`, `MemoryLayout`, tuples | assigning to a `let` | the compiler: `cannot assign to value: 'name' is a 'let' constant` |
| 03 | Numbers | integer division towards zero, `%`, no implicit conversions, `Int(exactly:)`, `.rounded()` vs `.rounded(.toNearestOrEven)`, `&+`, `addingReportingOverflow`, `Int("42")` is optional | `Double / Int` | the compiler: `binary operator '/' cannot be applied to operands of type 'Double' and 'Int'` |
| 04 | Strings | `String`, `Character`, `Substring`, `count` vs `unicodeScalars.count` vs `utf8.count`, an `extension StringProtocol` for Python's `strip`, `cleanStatus`, `padded` | `title[0]` | the compiler: `'subscript(_:)' is unavailable: cannot subscript String with an Int` |
| 05 | Control flow | `if` and `switch` as values, ranges and `where` in cases, no fallthrough, `...` and `..<`, `stride`, `while`, `repeat`, labelled `break` | `if count` on an `Int` | the compiler: `type 'Int' cannot be used as a boolean` |
| 06 | Functions and closures | argument labels (`of whole`), `_`, defaults, `inout` and `&`, variadic `String...`, `@discardableResult`, closures, `$0`, trailing closures, capture, `percent` | an ignored `percent(3, of: 7)` | the compiler, warnings as errors: `result of call to 'percent(_:of:)' is unused` |
| 07 | Optionals | `Int?`, `if let`, `guard let`, `??`, optional chaining `?.`, `map`, `!` and why not | an `Int?` where an `Int` belongs | the compiler: `value of optional type 'Int?' must be unwrapped` |
| 08 | Enums | `enum Status { case todo, done, other(String) }`, raw values `Kind: String`, `CaseIterable`, `init(rawValue:)`, exhaustive `switch`, `if case`, `parseStatus` | a `switch` that forgets `.other` | the compiler: `switch must be exhaustive` |
| 09 | Structs | `struct Task`, the memberwise initializer, defaults, value semantics (copies), `mutating`, computed properties, `parseTask` returning `Task?` | `markDone()` on a `let` task | the compiler: `cannot use mutating member on immutable value` |
| 10 | Protocols and extensions | `protocol Checkable`, a protocol extension as shared code, `extension Task: CustomStringConvertible`, `Equatable` for free, generics `<T: Checkable>`, `any Checkable`, `compactMap`, why no subclass | a type missing a requirement | the compiler: `type 'Reminder' does not conform to protocol 'Checkable'` |
| 11 | Errors and defer | `enum TrackerError: Error`, `throws(TrackerError)`, `try`, `do`/`catch` on a case, `try?`, `defer` (and its order), `FileHandle`, `loadTasks`, `parseTop` | `parseTop("5")` without `try` | the compiler: `call can throw, but it is not marked with 'try'` |
| 12 | Collections | `Array`, slices, `first`, `indices`, copy-on-write, `Dictionary` and `[key, default:]`, why its order can't be trusted, `Set`, `countTags` in first-seen order | `tasks[tasks.count]` | a runtime trap: `Fatal error: Index out of range` |
| 13 | Sorting and generics | `filter` `map` `reduce` `contains(where:)`, stable `sorted(by:)`, generic `topN` with a `where` clause, `bar` with Python's rounding | `sorted()` on `[Status]` | the compiler: `... requires that 'Status' conform to 'Comparable'` |
| 14 | The mini tracker | `loadTasks`, `countTags`, `topN`, `drawChart` padded by code points: the tracker's summary and chart | `try!` on a file that isn't there | a runtime trap: `Fatal error: 'try!' expression unexpectedly raised an error` |
| 15 | Classes and ARC | `final class`, reference semantics, `===`, `deinit`, ARC, `weak`, `isKnownUniquelyReferenced`, why the tracker uses structs, `Sendable` | sharing a class object with another thread | Swift 6 strict concurrency: `sending value of non-Sendable type ... risks causing data races` |

Pieces carry forward: lesson 04's `cleanStatus` feeds lesson 08's `parseStatus`, which lesson 09's
`parseTask` uses; lesson 10 makes `Task` printable, lesson 11's `loadTasks` reads the file with
`parseTask`, lesson 12's `countTags` counts the tags, lesson 13's `topN` and `bar` rank and draw them,
and lesson 06's `percent` gives the summary. Lesson 14 prints `6 tasks, 3 done (50%), 5 tags`, the
urgent task and a chart of work, home and urgent, the same text Python prints for that file.

## Choices the tracker doesn't make, and why

- **Classes and inheritance** are how Python models `UrgentTask`; Swift prefers values. `Task` is a struct, the urgent difference is an enum field, and shared behaviour lives in a protocol extension (lessons 09, 10). A class appears once, for contrast (lesson 15).
- **`Dictionary` alone** forgets insertion order, and changes it from run to run; ties must keep file order, so the counts live in an `Array`, with the dictionary finding each tag's place (lesson 12).
- **`.rounded()`** sends halves away from zero; the tracker matches Python with `.rounded(.toNearestOrEven)` (lesson 03).
- **`String.count`** counts what a reader sees as one character; Python's `len` counts code points, so the chart pads by `unicodeScalars.count` (lesson 04).
- **`!` and `try!`** crash on nil or an error; fine for values that can't be missing, never for a file name or something the user typed (lessons 07, 14).
- **Untyped `throws`** can throw any error; `throws(TrackerError)` says exactly which, so `catch` can match its cases (lesson 11).
- **`String(contentsOfFile:)`** reads a file in one line, but hides the opening and closing; `FileHandle` with `defer { try? file.close() }` shows the cleanup Swift's `defer` is for (lesson 11).
- **Threads, actors and `async`/`await`** need work that can happen at once; they arrive with the later chapter that loads several task files together. Until then Swift 6's checks only say no (lesson 15).
- **Packages from outside** such as swift-argument-parser are what real projects reach for; the course uses only the standard library and Foundation so you see how the pieces work.

## Done when

```bash
cd swift/concepts && swift run concepts && swift test
```

builds with no warnings (they're errors here), runs every lesson and every test cleanly, and each
`swift run -Xswiftc -DBUGNN concepts NN` is caught as the table says.
