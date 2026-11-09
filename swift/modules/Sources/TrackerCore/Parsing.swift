// Turning one line of text into a task. No files, no printing: text in, a Task out.

public let tagMarker: Unicode.Scalar = "#" // marks a word as a tag: "#work"

// No modifier: internal, so only this module (and its @testable tests) can call it.
func statusOf(_ raw: String) -> Status {
    let word = raw.trimming("[] .").lowercased()
    return switch word {
    case "done": .done
    case "todo": .todo
    default: .other(word)
    }
}

// "[done.] Call mom #family" -> a Task, or nil if the line isn't a task.
public func parseLine(_ line: String) -> Task? {
    let s = line.pythonStrip()
    guard s.unicodeScalars.first == "[" else { return nil }
    let scalars = Array(s.unicodeScalars)
    let close = scalars.firstIndex(of: "]") // Python's partition("]")
    let raw = String(String.UnicodeScalarView(scalars[..<(close ?? scalars.count)]))
    let rest = close.map { String(String.UnicodeScalarView(scalars[($0 + 1)...])) } ?? ""
    let words = rest.pythonWords()
    let tags = words.filter { $0.unicodeScalars.first == tagMarker }.map { word in
        String(word.unicodeScalars.drop { $0 == "#" }).trimming(".,").lowercased()
    }
    let title = words.filter { $0.unicodeScalars.first != tagMarker }.joined(separator: " ")
    return Task(title: title, status: statusOf(raw), tags: tags, kind: tags.contains("urgent") ? .urgent : .plain)
}
