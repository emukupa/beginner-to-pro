// Swift concepts, one lesson per file. Each lesson is a caseless enum (a namespace: it has no
// values, only a `title` and a `run()`), and every file is in the same module, so later lessons
// use what earlier ones built without any `import`.
//
//   swift run concepts                          every lesson, in order
//   swift run concepts 7                        just lesson 7 (or several: swift run concepts 4 7)
//   swift run -Xswiftc -DBUG07 concepts 7       lesson 7 with its bug compiled in
//   swift test                                  the tests in Tests/ConceptsTests
//
// main.swift is the one file allowed to have code at the top level: it runs from the first line.

import Foundation

// The table of lessons: a title and the function to run. `() -> Void` is a function type.
let lessons: [(title: String, run: () -> Void)] = [
    (Lesson01Hello.title, Lesson01Hello.run),
    (Lesson02Values.title, Lesson02Values.run),
    (Lesson03Numbers.title, Lesson03Numbers.run),
    (Lesson04Strings.title, Lesson04Strings.run),
    (Lesson05Control.title, Lesson05Control.run),
    (Lesson06Functions.title, Lesson06Functions.run),
    (Lesson07Optionals.title, Lesson07Optionals.run),
    (Lesson08Enums.title, Lesson08Enums.run),
    (Lesson09Structs.title, Lesson09Structs.run),
    (Lesson10Protocols.title, Lesson10Protocols.run),
    (Lesson11Errors.title, Lesson11Errors.run),
    (Lesson12Collections.title, Lesson12Collections.run),
    (Lesson13Generics.title, Lesson13Generics.run),
    (Lesson14Tracker.title, Lesson14Tracker.run),
    (Lesson15Classes.title, Lesson15Classes.run),
]

// Top-level code in main.swift runs on the main actor (the main thread), and so does `lessons`.
// @MainActor puts this function there too; without it, Swift 6 refuses to let it read `lessons`.
@MainActor
func runLesson(_ number: Int) {
    let lesson = lessons[number - 1]
    let label = number < 10 ? "0\(number)" : "\(number)"
    print("\n=== \(label) \(lesson.title) ===")
    lesson.run()
}

let args = CommandLine.arguments.dropFirst() // the first one is the program's own name
if args.isEmpty {
    for number in 1...lessons.count {
        runLesson(number)
    }
}
for arg in args {
    // Int(arg) is an Int? (lesson 07): nil when arg isn't a number.
    guard let number = Int(arg), (1...lessons.count).contains(number) else {
        FileHandle.standardError.write(Data("No lesson \(arg)\n".utf8))
        exit(1)
    }
    runLesson(number)
}
