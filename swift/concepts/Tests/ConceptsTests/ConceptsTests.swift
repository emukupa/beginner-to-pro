// Tests for the pieces the tracker will reuse, with Swift Testing (`import Testing`), which ships
// with the toolchain: `@Test` marks a test, `#expect` checks a condition and reports both sides
// when it fails, `#expect(throws:)` checks that something throws.
// @testable import lets the tests reach the module's `internal` names, not just `public` ones.

import Foundation
import Testing
@testable import concepts

/// tasks.txt sits next to Package.swift; #filePath finds it wherever `swift test` runs from.
let tasksFile = URL(fileURLWithPath: #filePath)
    .deletingLastPathComponent().deletingLastPathComponent().deletingLastPathComponent()
    .appendingPathComponent("tasks.txt").path

@Test func cleansMessyStatuses() {
    #expect(cleanStatus("[done.]") == "done")
    #expect(cleanStatus("[DONE]") == "done")
    #expect(cleanStatus("[ todo ]") == "todo")
}

@Test func parsesStatusesIntoTheEnum() {
    #expect(parseStatus("[done.]") == .done)
    #expect(parseStatus("[todo]") == .todo)
    #expect(parseStatus("[later]") == .other("later"))
}

@Test func padsByCodePointsLikePython() {
    #expect(padded("cafe\u{301}", to: 6) == "cafe\u{301} ") // 5 code points, so one space
    #expect(padded("work", to: 2) == "work") // never cuts
}

@Test func roundsHalvesToEven() {
    #expect(bar(1, of: 8) == "██") // 2.5 -> 2, as Python's round() does
    #expect(bar(2, of: 3).count == 13)
    #expect(bar(3, of: 3).count == 20)
}

@Test func parsesALine() throws {
    let task = try #require(parseTask("[todo] Finish quarterly report #work #urgent"))
    #expect(task.title == "Finish quarterly report")
    #expect(task.tags == ["work", "urgent"])
    #expect(task.kind == .urgent)
    #expect(task.description == "[ ] Finish quarterly report  !!")
    #expect(parseTask("[ todo ] Review pull request #work.")?.tags == ["work"])
    #expect(parseTask("no brackets") == nil)
    #expect(parseTask("   ") == nil)
}

@Test func parsesTheTopNumber() throws {
    #expect(try parseTop("") == 3)
    #expect(try parseTop(" 5 ") == 5)
    #expect(throws: TrackerError.badNumber("0")) { try parseTop("0") }
    #expect(throws: TrackerError.badNumber("two")) { try parseTop("two") }
}

@Test func loadsTheFileOrSaysWhy() throws {
    #expect(try loadTasks(tasksFile).count == 6)
    #expect(throws: TrackerError.notFound("nowhere.txt")) { try loadTasks("nowhere.txt") }
}

@Test func ranksTagsWithTiesInFileOrder() throws {
    let counts = countTags(try loadTasks(tasksFile))
    #expect(counts.map(\.tag) == ["home", "work", "urgent", "family", "travel"]) // first-seen order
    let top = topN(counts, 3) { $0.count }
    #expect(top == [TagCount(tag: "work", count: 3), TagCount(tag: "home", count: 2), TagCount(tag: "urgent", count: 1)])
}
