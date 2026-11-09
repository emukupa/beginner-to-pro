// Lesson 08: enums. A Swift enum lists every value a thing can be, and a case can carry data:
// `.other(String)` keeps whatever odd status the file had, like Rust's `Other(String)`.
// An enum with a raw type (`Kind: String`) maps each case to a fixed value instead.
// A `switch` over an enum must handle every case, so adding a case later shows you every place
// that needs to know about it.
// BUG08: a switch that forgets `.other`. The compiler lists what's missing.

enum Lesson08Enums {
    static let title = "Enums"

    static func run() {
        for text in ["[done.]", "[ todo ]", "[later]"] {
            let status = parseStatus(text)
            print("parseStatus(\"\(text)\") = \(status), isDone = \(status.isDone), label = \(label(for: status))")
        }

        // `if case` checks one case and takes its data out.
        if case .other(let word) = parseStatus("[waiting]") {
            print("if case .other: \(word)")
        }
        print(".done == parseStatus(\"[DONE]\") -> \(Status.done == parseStatus("[DONE]"))") // Equatable

        // Raw values: every case has a String, and init(rawValue:) is optional (lesson 07).
        print("Kind.allCases = \(Kind.allCases.map(\.rawValue))")
        for raw in ["urgent", "later"] {
            print("Kind(rawValue: \"\(raw)\") = \(Kind(rawValue: raw).map { ".\($0)" } ?? "nil")")
        }
    }

    /// No `default:` on purpose. With one, a new case would slip through silently.
    static func label(for status: Status) -> String {
        #if BUG08
        switch status {
        case .todo: "to do"
        case .done: "finished"
        }
        #else
        switch status {
        case .todo: "to do"
        case .done: "finished"
        case .other(let word): "unknown (\(word))"
        }
        #endif
    }
}

/// A task's status. Equatable lets you compare two with ==; Swift writes the code for you.
enum Status: Equatable {
    case todo
    case done
    case other(String) // a case that carries a value

    var isDone: Bool { self == .done } // a computed property: no storage, worked out when asked
}

/// What kind of task. Python used a subclass, UrgentTask; here it's one field (lesson 10 says why).
enum Kind: String, CaseIterable {
    case normal
    case urgent
}

/// "[DONE.]" -> .done. Lesson 04's cleanStatus does the cleaning; switch can match Strings too.
func parseStatus(_ text: some StringProtocol) -> Status {
    switch cleanStatus(text) {
    case "todo": .todo
    case "done": .done
    case let word: .other(word) // matches anything else, and names it
    }
}
