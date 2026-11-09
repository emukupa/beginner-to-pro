// Lesson 07: optionals. `Int?` means "an Int, or nil". There's no null hiding inside other types:
// an Int is always an Int, and to use what's inside an Int? you must unwrap it first, with
// `if let`, `guard let`, `??` or optional chaining. Kotlin's `?` and Rust's Option, in one symbol.
// BUG07: putting an Int? where an Int belongs. Swift won't build it until you unwrap.

enum Lesson07Optionals {
    static let title = "Optionals"

    static func run() {
        let found: Int? = Int("3") // parsing can fail, so the answer is optional
        let missing = Int("three") // nil
        print("found = \(String(describing: found)), missing = \(String(describing: missing))")

        if let n = found { // inside the braces, n is a plain Int
            print("if let: \(n) * 2 = \(n * 2)")
        }
        if let missing { // shorthand: same name, unwrapped
            print("never printed: \(missing)")
        } else {
            print("if let ... else: missing is nil")
        }

        print("missing ?? 3 = \(missing ?? 3)") // ?? gives a default for nil

        // Optional chaining: ?. carries on only if there's a value; the whole thing is optional.
        let line = "[todo] Book flights #travel"
        let firstTag = line.split(separator: "#").dropFirst().first?.uppercased()
        print("first tag = \(firstTag ?? "none")")
        print("found.map { $0 + 1 } = \(found.map { $0 + 1 } ?? 0)")

        for text in ["[done] Call mom", "Call mom", ""] {
            print("status(of: \"\(text)\") = \(status(of: text) ?? "nil")")
        }

        // `!` force-unwraps: it crashes on nil. Only for values that can't be nil by construction.
        let sure = Int("7")!
        print("Int(\"7\")! = \(sure)")

        #if BUG07
        let n: Int = Int("3") // Int("3") is an Int?, and an Int can't hold nil
        print(n)
        #endif
    }

    /// guard let unwraps or leaves early, so the rest of the function reads straight down.
    static func status(of line: String) -> String? {
        guard line.hasPrefix("["), let close = line.firstIndex(of: "]") else {
            return nil
        }
        return cleanStatus(line[..<close])
    }
}
