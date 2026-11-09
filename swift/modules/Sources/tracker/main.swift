// The program: the only file that reads input, prints to the screen or exits. Everything else comes
// from the TrackerCore module.
import Foundation
import TrackerCore

// Python's input(): shows the prompt, reads up to the next \n. An empty line at the end of input.
func ask(_ prompt: String) -> String {
    print(prompt, terminator: "")
    fflush(stdout)
    var bytes: [UInt8] = []
    while case let c = getchar(), c != EOF, c != 10 { bytes.append(UInt8(c)) }
    return String(decoding: bytes, as: UTF8.self)
}

// Python's int(text): optional spaces, an optional sign, digits with single underscores between
// them, optional spaces. Int("1_000") is nil. Capped.
func parseWholeNumber(_ text: String) -> Int? {
    var scalars = Substring(text.pythonStrip()).unicodeScalars[...]
    let negative = scalars.first == "-"
    if scalars.first == "-" || scalars.first == "+" { scalars = scalars.dropFirst() }
    let digits = Array(scalars)
    guard let first = digits.first, ("0"..."9").contains(first) else { return nil }
    var value = 0
    for (i, c) in digits.enumerated() {
        if c == "_", digits[i - 1] != "_", i + 1 < digits.count, ("0"..."9").contains(digits[i + 1]) { continue }
        guard ("0"..."9").contains(c) else { return nil }
        value = min(value * 10 + Int(c.value - 48), Int(Int32.max))
    }
    return negative ? -value : value
}

func fail(_ message: String) -> Never {
    FileHandle.standardError.write(Data((message + "\n").utf8))
    exit(1)
}

// What a status command does. A String raw value per case: Change(rawValue: "undo") turns the
// typed word into .undo, or nil for anything else, so the words can't disagree with the cases.
enum Change: String, CaseIterable {
    case done, undo

    var sets: Status {
        switch self {
        case .done: .done
        case .undo: .todo
        }
    }

    var changed: String { self == .done ? "Done" : "Undone" } // printed after changing it
    var already: String { self == .done ? "Already done" : "Not done yet" } // nothing to change
}

// tracker done|undo "title": sets one task's status. Returns the exit code.
func change(_ change: Change, _ words: ArraySlice<String>) -> Int32 {
    let title = words.joined(separator: " ").pythonStrip()
    guard !title.isEmpty else {
        FileHandle.standardError.write(Data("Usage: \(change.rawValue) \"task title\"\n".utf8))
        return 2
    }
    let path = ProcessInfo.processInfo.environment["TASKS_FILE"] ?? "tasks.txt"
    let tasks: [Task]
    do throws(LoadError) {
        tasks = try loadTasks(path)
    } catch {
        switch error {
        case .notFound: FileHandle.standardError.write(Data("Couldn't find \(path)\n".utf8))
        case .unreadable: FileHandle.standardError.write(Data("Couldn't read \(path)\n".utf8))
        }
        return 1
    }
    guard let task = findTask(tasks, title) else {
        FileHandle.standardError.write(Data("No task called \"\(title)\"\n".utf8))
        return 1
    }
    if task.status == change.sets {
        print("\(change.already): \(task.title)")
        return 0
    }
    do {
        try setStatus(path, task, change.sets)
    } catch {
        FileHandle.standardError.write(Data("Couldn't write \(path)\n".utf8))
        return 1
    }
    print("\(change.changed): \(task.title)")
    return 0
}

let arguments = CommandLine.arguments.dropFirst()
if let word = arguments.first, let command = Change(rawValue: word) { // tracker done|undo "title"
    exit(change(command, arguments.dropFirst()))
}
let path = arguments.first ?? ProcessInfo.processInfo.environment["TASKS_FILE"] ?? "tasks.txt"

var tasks: [Task]
do throws(LoadError) {
    tasks = try loadTasks(path)
} catch {
    // error is a LoadError, not any Error, so this switch can cover every case without a default.
    switch error {
    case .notFound: fail("Couldn't find \(path)")
    case .unreadable: fail("Couldn't read \(path)")
    }
}

var newTitles: [String] = []
while true {
    let title = ask("New task (Enter to finish): ").pythonStrip()
    if title.isEmpty { break }
    if title.unicodeScalars.first == tagMarker {
        print("A task needs a title, not just tags.")
        continue
    }
    newTitles.append(title)
}
if addTasks(&tasks, newTitles) > 0 {
    do { try appendTitles(path, newTitles) } catch { fail("Couldn't write \(path)") }
}

let answer = ask("How many top tags? [3]: ")
let pairs: [TagCount]
do {
    pairs = try topTags(tasks, answer.isEmpty ? defaultTop : parseWholeNumber(answer) ?? 0)
} catch {
    print("Need a whole number of at least 1 — using 3.")
    pairs = try! topTags(tasks, defaultTop) // can't fail: defaultTop is at least 1
}

let s = summarize(tasks)
print("\n\(s.total) tasks, \(s.done) done (\(s.percent)%), \(s.tags) tags")
for task in tasks where task.kind == .urgent && !task.isDone {
    print(task)
}

print("\nTop tags")
drawChart(pairs)
