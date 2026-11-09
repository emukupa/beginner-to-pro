// Lesson 06: functions and closures. Each parameter has a label for callers and a name for the
// body (`of whole`); `_` means no label. Parameters are constants, `inout` lets a function change
// the caller's variable, and `String...` takes any number of values, like Python's *titles.
// A closure is a function without a name that can capture variables around it.
// BUG06: calling percent() and ignoring the answer. That's a warning, and this package makes
// warnings errors; mark a function @discardableResult when ignoring it is fine.

enum Lesson06Functions {
    static let title = "Functions and closures"

    static func run() {
        print("percent(3, of: 6) = \(percent(3, of: 6))") // the label reads like a sentence
        print("percent(0, of: 0) = \(percent(0, of: 0))")
        print("greeting() = \(greeting()), greeting(for: \"Ann\") = \(greeting(for: "Ann"))")

        var count = 1
        bump(&count) // & says "this function may change count"
        print("after bump(&count): \(count)")

        var titles: [String] = []
        let added = add(to: &titles, "Book flights", "Call mom")
        print("added \(added): \(titles)")
        add(to: &titles, "Water plants") // @discardableResult: ignoring the count is fine

        // Closures. $0 is the first argument; a closure last in a call can go after the ().
        let doubled = [1, 2, 3].map { $0 * 2 }
        print("map { $0 * 2 } = \(doubled)")
        let shout: (String) -> String = { word in word.uppercased() + "!" }
        print("shout(\"done\") = \(shout("done"))")

        // A closure keeps the variables it captured alive: each call sees the same `next`.
        let nextID = makeCounter()
        print("nextID() = \(nextID()), then \(nextID()), then \(nextID())")

        #if BUG06
        percent(3, of: 7) // the answer is thrown away: almost always a mistake
        #endif
    }

    static func greeting(for name: String = "there") -> String { "Hello, \(name)" } // a default value

    static func bump(_ number: inout Int) { number += 1 }

    @discardableResult
    static func add(to list: inout [String], _ titles: String...) -> Int {
        list.append(contentsOf: titles) // titles arrives as an array, [String]
        return titles.count
    }

    /// Returns a closure. It escapes this function, taking `next` with it.
    static func makeCounter() -> () -> Int {
        var next = 0
        return {
            next += 1
            return next
        }
    }
}

/// What share of `whole` is `part`, from 0 to 100. The tracker's "3 done (50%)" uses it.
/// A function with one expression returns it without `return`.
func percent(_ part: Int, of whole: Int) -> Double {
    whole == 0 ? 0 : Double(part) / Double(whole) * 100
}
