// Lesson 01: printing. `print` writes a line; `\(...)` drops any value into a string, and the
// compiler checks every name inside it, just like any other code.
// BUG01: a typo inside \( ). The compiler won't build a name that doesn't exist.

enum Lesson01Hello {
    static let title = "Hello"

    static func run() {
        print("Hello, tracker!")
        let name = "Edward"
        let tasks = 6
        print("Hi \(name), you have \(tasks) tasks") // any expression fits in \( )
        print("Half of them: \(tasks / 2)")
        print("work", "home", "urgent", separator: ", ") // several values, your own separator
        print("no newline here... ", terminator: "") // terminator replaces the "\n" at the end
        print("so this carries on the same line")

        // Triple quotes make a multi-line string; the closing """ sets the indent to strip.
        let banner = """
            [todo] Book flights #travel
            [done] Call mom #family
            """
        print(banner)

        // A program's exit code: 0 means it worked. main.swift calls exit(1) for a lesson
        // that doesn't exist (try `swift run concepts 99`).

        #if BUG01
        print("Bye \(nmae)") // a typo: there is no `nmae`
        #endif
    }
}
