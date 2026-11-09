// Lesson 04: a String is a sequence of Characters, and a Character is what a person sees as one
// letter, even when it's built from several Unicode code points. So `count` counts what you see,
// while Python's len() counts code points: `unicodeScalars.count` is the one that matches Python.
// An `extension` adds methods to a type you didn't write, here Python's strip().
// BUG04: `title[0]`. Swift won't index text by number: finding character 0 means walking the text.

enum Lesson04Strings {
    static let title = "Strings"

    static func run() {
        var line = "Call mom"
        line += " #family" // a var String can grow
        line.append("!")
        print("line = \(line)")

        print("\"done\" == \"done.\" -> \("done" == "done.")") // == compares the text
        print("\"DONE\".lowercased() -> \("DONE".lowercased())")
        print("\"  done  \".stripped() -> \"\("  done  ".stripped())\"")
        print("hasPrefix(\"[\") -> \("[done] x".hasPrefix("[")), contains(\"#\") -> \(line.contains("#"))")
        print("split -> \("Book flights #travel".split(separator: " "))")

        for messy in ["[done]", "[done.]", "[DONE]", "[ todo ]"] {
            print("cleanStatus(\(padded("\"\(messy)\"", to: 10))) -> \"\(cleanStatus(messy))\"")
        }

        // Three ways to count. A █ is one Character, one code point, three UTF-8 bytes.
        let block = "█"
        print("\"█\": count \(block.count), unicodeScalars \(block.unicodeScalars.count), utf8 \(block.utf8.count)")
        // "e" + a combining accent: one Character on screen, two code points. Python's len() says 2.
        let accented = "cafe\u{301}"
        print("\"\(accented)\": count \(accented.count), unicodeScalars \(accented.unicodeScalars.count), utf8 \(accented.utf8.count)")
        // Pad by code points, as Python's f"{tag:<8}" does, and the columns match Python's.
        print("aligned: |\(padded(accented, to: 8))|\(padded("work", to: 8))|")
        print("repeated: \(String(repeating: "█", count: 5))")

        // Slicing uses String.Index values, not numbers. prefix and first are the easy way.
        let title = "Fix login bug"
        print("title.prefix(3) = \(title.prefix(3)), title.first = \(title.first ?? "?")")
        // A slice is a Substring: it shares the original's memory. String(...) makes it its own.
        let word: Substring = title.prefix(3)
        let kept = String(word)
        print("kept = \(kept)")

        #if BUG04
        let first = title[0] // which Character is number 0? Swift makes you walk there
        print(first)
        #endif
    }
}

extension StringProtocol {
    /// Python's strip(chars): drop matching characters from both ends. StringProtocol covers both
    /// String and Substring, so this works on slices too.
    func stripped(_ drop: (Character) -> Bool = { $0.isWhitespace }) -> SubSequence {
        let start = firstIndex { !drop($0) } ?? endIndex
        let end = lastIndex { !drop($0) }.map { index(after: $0) } ?? start
        return self[start..<end]
    }
}

/// "[ DONE. ]" -> "done", like Python's status.strip("[] .").lower(). Lesson 08 builds on it.
func cleanStatus(_ text: some StringProtocol) -> String {
    text.stripped { "[] .".contains($0) }.lowercased()
}

/// Pads with spaces to `width` code points, the way Python's f"{text:<width}" does.
func padded(_ text: String, to width: Int) -> String {
    text + String(repeating: " ", count: max(0, width - text.unicodeScalars.count))
}
