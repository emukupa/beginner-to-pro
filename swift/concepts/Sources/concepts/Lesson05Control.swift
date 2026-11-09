// Lesson 05: decisions and loops. `if` and `switch` can be values, `switch` never falls through
// to the next case and must cover every possibility, and loops run over ranges and collections.
// BUG05: `if count`. Only a Bool can be a condition; Python's "0 is false" doesn't exist here.

enum Lesson05Control {
    static let title = "Control flow"

    static func run() {
        let done = parseStatus("[done]").isDone // (lesson 08) a literal true would make the else dead code
        let mark = if done { "x" } else { " " } // if as a value: both branches give a String
        print("mark = \(mark)")

        for count in [0, 2, 7, 12] {
            // switch as a value. Cases can be ranges, and `where` adds a condition.
            let size = switch count {
            case 0: "none"
            case 1...3: "a few"
            case let n where n > 10: "lots (\(n))"
            default: "some"
            }
            print("\(count) -> \(size)")
        }

        for i in 1...3 { print("1...3 gives \(i)") } // closed range: includes 3
        for i in 0..<2 { print("0..<2 gives \(i)") } // half-open: stops before 2
        for width in stride(from: 0, through: 20, by: 10) { print("stride gives \(width)") }

        var left = 3
        while left > 0 { left -= 1 }
        print("while counted down to \(left)")

        var tries = 0
        repeat { tries += 1 } while tries < 2 // runs at least once
        print("repeat-while ran \(tries) times")

        // A label lets `break` leave the outer loop, not just the inner one.
        let lines = [["#work", "#home"], ["#urgent", "#work"]]
        var found = "none"
        search: for words in lines {
            for word in words where word == "#urgent" {
                found = word
                break search
            }
        }
        print("found = \(found)")

        #if BUG05
        let count = lines.count
        if count { // an Int is not a Bool: write count > 0
            print("there are lines")
        }
        #endif
    }
}
