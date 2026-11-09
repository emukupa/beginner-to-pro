// Lesson 10: protocols and extensions. A protocol lists what a type must have; any struct, enum
// or class can promise it. A protocol extension gives every conforming type shared code, which
// is the job a base class does in Python. Structs can't inherit, and they don't need to: Python's
// UrgentTask only changed how a task prints, and Task's `kind` field (lesson 08) does that.
// CustomStringConvertible is the standard library's protocol for "how do I print?".
// BUG10: a type that promises Checkable but forgets `isDone`.

enum Lesson10Protocols {
    static let title = "Protocols and extensions"

    static func run() {
        let tasks = [
            parseTask("[todo] Finish quarterly report #work #urgent"),
            parseTask("[DONE] Fix login bug #work"),
        ].compactMap { $0 } // compactMap drops the nils
        for task in tasks {
            print(task) // print uses description, from CustomStringConvertible
        }

        // Another type, the same protocol: no base class, no shared parent.
        let chore = Chore(title: "Water plants", isDone: true)
        print("chore.checkbox = \(chore.checkbox)")

        // A generic function: works for any T that is Checkable, checked when compiling.
        print("countDone(tasks) = \(countDone(tasks)), countDone([chore]) = \(countDone([chore]))")

        // `any Checkable` holds a value of any conforming type, so one array can mix them.
        let mixed: [any Checkable] = [tasks[0], chore]
        print("mixed: \(mixed.map(\.checkbox))")

        // Equatable came for free (lesson 09): two tasks are equal when every field is.
        print("same line parses equal: \(parseTask("[done] A #x") == parseTask("[ DONE. ] A #x"))")
    }

    static func countDone<T: Checkable>(_ items: [T]) -> Int {
        items.filter(\.isDone).count
    }
}

/// Anything with a title that can be done.
protocol Checkable {
    var title: String { get }
    var isDone: Bool { get }
}

extension Checkable {
    /// Shared by every Checkable type: "[x] title" or "[ ] title", as the tracker prints them.
    var checkbox: String { "[\(isDone ? "x" : " ")] \(title)" }
}

// Task already has title and isDone (lesson 09), so promising Checkable needs no new code.
extension Task: Checkable {}

extension Task: CustomStringConvertible {
    var description: String { kind == .urgent ? checkbox + "  !!" : checkbox }
}

struct Chore: Checkable {
    let title: String
    let isDone: Bool
}

#if BUG10
struct Reminder: Checkable { // promised, but there's no isDone
    let title: String
}
#endif
