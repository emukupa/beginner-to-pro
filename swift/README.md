# Swift

The task tracker in Swift, the last language in the course: value types first (a `struct Task`
is copied, never shared), enums that carry data like Rust's, optionals instead of null, `throws`
and `defer` like Zig's, and no garbage collector, with automatic reference counting freeing each
object the moment nothing refers to it. Swift 6 language mode makes data races compile errors, and
the package treats warnings as errors. Needs Swift 6.2 or later with the Swift Package
Manager (written with Swift 6.4.2, from Xcode on macOS; on Linux, install from
[swift.org](https://www.swift.org/install/)).

| Folder | What | Chapter |
| --- | --- | --- |
| [`concepts/`](concepts/) | a Swift package, one file per concept in `Sources/concepts/`, run by `main.swift`: `swift run concepts` runs them all, `swift run concepts 7` one, `swift run -Xswiftc -DBUG07 concepts 7` with its bug | 00 |
| [`one-file/`](one-file/) | the whole tracker in `tracker.swift`, compiled with `swiftc` | 01 |

```bash
cd swift/concepts
swift run concepts                 # every lesson
swift test                         # the lessons' tests (Swift Testing)
```

```bash
cd swift/one-file
make check                         # the contract: must match Python byte for byte
```

| Chapter | Start | End | Video |
| --- | --- | --- | --- |
| [00 Concepts](chapters/00-concepts/CHAPTER.md) | `course/swift/00-concepts/start` | `course/swift/00-concepts/end` | `video/swift-000` |
| [01 One file](chapters/01-one-file/CHAPTER.md) | `course/swift/01-one-file/start` | `course/swift/01-one-file/end` | `video/swift-001` |

VS Code: install the **Swift** extension (from the Swift Server Work Group). It runs SourceKit-LSP,
so the compiler's errors, Swift 6's data-race checks included, show up as you type, and it can run
`swift test` from the editor. Or open `Package.swift` in Xcode, which does the same.
