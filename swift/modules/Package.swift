// swift-tools-version: 6.2
// The tracker as a Swift package: a library with one file per job, a program, and tests.
//   swift build -c release                                   .build/release/tracker
//   swift test                                               the tests (Swift Testing)
//   ../../contract/run.sh "$PWD/.build/release/tracker"      the contract
import PackageDescription

let strict: [SwiftSetting] = [.treatAllWarnings(as: .error)]

let package = Package(
    name: "tracker",
    targets: [
        // A module of its own: only what's marked public can be used from outside it.
        .target(name: "TrackerCore", swiftSettings: strict),
        .executableTarget(name: "tracker", dependencies: ["TrackerCore"], swiftSettings: strict),
        .testTarget(name: "TrackerCoreTests", dependencies: ["TrackerCore"], swiftSettings: strict),
    ],
    swiftLanguageModes: [.v6]
)
