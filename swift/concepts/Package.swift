// swift-tools-version: 6.2
// Swift concepts, one lesson per file in Sources/concepts, run by main.swift.
//   swift run concepts                          every lesson
//   swift run concepts 7                        lesson 7 alone
//   swift run -Xswiftc -DBUG07 concepts 7       lesson 7 with its bug compiled in: watch the compiler catch it
//   swift test                                  the tests in Tests/ConceptsTests (Swift Testing)
import PackageDescription

// Warnings are errors here, the way C's -Werror and Rust's `deny` make them: an unused result or a
// variable that never changes is a mistake waiting to happen.
let strict: [SwiftSetting] = [.treatAllWarnings(as: .error)]

let package = Package(
    name: "concepts",
    targets: [
        // One executable: main.swift plus a file per lesson, all in one module, so every lesson
        // can use what the lessons before it built without importing anything.
        .executableTarget(name: "concepts", swiftSettings: strict),
        // The tests import the executable's module with @testable, which also opens up its
        // `internal` names (everything not marked `private`).
        .testTarget(name: "ConceptsTests", dependencies: ["concepts"], swiftSettings: strict),
    ],
    // Swift 6 mode: strict concurrency checking is on, so data races are compile errors.
    swiftLanguageModes: [.v6]
)
