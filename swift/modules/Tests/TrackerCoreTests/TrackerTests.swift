// Tests beside the code. @testable lets them call internal names, such as statusOf.
import Testing
@testable import TrackerCore

@Test func readsStatusTitleAndTags() throws {
    let task = try #require(parseLine("[DONE.] Call mom #Family #urgent,"))
    #expect(task.status == .done)
    #expect(task.title == "Call mom")
    #expect(task.tags == ["family", "urgent"])
    #expect(task.kind == .urgent)
}

@Test func keepsAnUnknownStatus() {
    #expect(statusOf("[ later ]") == .other("later"))
}

@Test func aLineWithoutABracketIsNotATask() {
    #expect(parseLine("Buy milk #home") == nil)
}

@Test func tiesKeepFirstSeenOrder() throws {
    let tasks = ["[todo] a #work #home", "[todo] b #home #work", "[todo] c #play"].compactMap(parseLine)
    #expect(try topTags(tasks, 3).map(\.tag) == ["work", "home", "play"])
}

@Test func zeroIsRefused() {
    #expect(throws: TopTagsError.needAtLeastOne) { try topTags([], 0) }
}

@Test func halvesRoundToEven() {
    let tasks = (["[done] a"] + (0..<7).map { "[todo] t\($0)" }).compactMap(parseLine)
    #expect(summarize(tasks).percent == 12) // 12.5 -> 12, like Python's round()
}

@Test func chartDrawsIntoAnArray() {
    var lines: [String] = []
    drawChart([TagCount(tag: "home", count: 2), TagCount(tag: "work", count: 1)], width: 4) { lines.append($0) }
    #expect(lines == ["home  ████ 2", "work  ██ 1"])
}
