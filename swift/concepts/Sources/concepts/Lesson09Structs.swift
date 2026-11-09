// Lesson 09: structs. A struct is a value type: assigning one copies it, so two variables never
// share a struct behind your back. Methods that change the struct are marked `mutating`, and you
// can only call them on a `var`. (Our type is called Task, like Python's. Swift also has a Task,
// for concurrency; inside this module, ours wins.)
// BUG09: calling markDone() on a `let` task. A let struct can't change at all.

enum Lesson09Structs {
    static let title = "Structs"

    static func run() {
        // Swift writes a memberwise initializer for every struct; fields with defaults can be left out.
        var task = Task(title: "Call mom", tags: ["family"])
        print("task = \(task.title), status \(task.status), tags \(task.tags), kind \(task.kind)")
        task.markDone()
        print("after markDone(): isDone = \(task.isDone)")

        // A copy is a separate value. Changing one leaves the other alone.
        var copy = task
        copy.title = "Call dad"
        print("copy.title = \(copy.title), task.title = \(task.title)")

        for line in ["[done.] Call mom #family", "[todo] Finish quarterly report #work #urgent", "[ todo ] Review pull request #work.", "no brackets", ""] {
            if let parsed = parseTask(line) {
                print("parseTask -> \(parsed.title) | \(parsed.status) | \(parsed.tags) | \(parsed.kind)")
            } else {
                print("parseTask(\"\(line)\") -> nil")
            }
        }

        #if BUG09
        let fixed = Task(title: "Fix login bug")
        fixed.markDone() // fixed is a let: its fields can't change, not even through a method
        #endif
    }
}

/// One line of tasks.txt. Every field is a `var`, but a `let Task` still can't change: the struct
/// is one value, and `let` freezes all of it.
struct Task: Equatable {
    var title: String
    var status: Status = .todo
    var tags: [String] = []
    var kind: Kind = .normal

    var isDone: Bool { status.isDone }

    mutating func markDone() { // mutating: this method changes self
        status = .done
    }
}

/// "[done.] Call mom #family" -> a Task, or nil when the line isn't one. The tracker's parse_line.
func parseTask(_ text: String, marker: Character = "#") -> Task? {
    let line = text.stripped()
    guard line.first == "[" else { return nil } // also covers an empty line: first is nil
    let close = line.firstIndex(of: "]") ?? line.endIndex
    let rest = close == line.endIndex ? "" : line[line.index(after: close)...]
    let words = rest.split(whereSeparator: \.isWhitespace)
    let tags = words.filter { $0.first == marker }.map {
        $0.drop { $0 == marker }.stripped { $0 == "." || $0 == "," }.lowercased()
    }
    let title = words.filter { $0.first != marker }.joined(separator: " ")
    return Task(
        title: title,
        status: parseStatus(line[..<close]),
        tags: tags,
        kind: tags.contains("urgent") ? .urgent : .normal
    )
}
