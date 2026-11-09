// The task tracker in one Swift file. Same prompts, summary and chart as the Python version, byte
// for byte: contract/run.sh checks every one. Read top to bottom: what a task is, Python's text
// rules, parsing a line, the file, counting and ranking, the chart, then the part that talks to the
// user, which runs from the top level of this file: no main function needed.

import Foundation

let chartWidth = 20 // the longest bar, in characters
let defaultTop = 3 // top tags shown when the answer is empty or invalid
let tagMarker: Unicode.Scalar = "#" // marks a word as a tag: "#work"

// ---- What a task is -------------------------------------------------------------------------

// An enum whose cases can carry data: an unknown status keeps its word inside it.
enum Status: Equatable {
    case todo, done
    case other(String)
}

// Swift prefers structs to classes, and structs have no inheritance, so Python's UrgentTask is a
// kind instead of a subclass.
enum Kind {
    case plain, urgent
}

// A struct is a value: assigning it copies it, so nobody can change a task behind your back.
struct Task: CustomStringConvertible {
    let title: String
    let status: Status
    let tags: [String]
    let kind: Kind

    var isDone: Bool { status == .done }

    // CustomStringConvertible: what print(task) shows.
    var description: String { "[\(isDone ? "x" : " ")] \(title)" + (kind == .urgent ? "  !!" : "") }
}

struct TagCount {
    let tag: String
    let count: Int
}

// ---- Python's text rules --------------------------------------------------------------------

// Swift's Character is a whole grapheme: "\r\n" is one Character, and "é" written as e plus an
// accent is one too. Python works in code points, so this file does too: unicodeScalars.

// Exactly what Python's str.split() and str.strip() treat as space, as code point numbers.
let pythonSpace: Set<UInt32> = [0x09, 0x0A, 0x0B, 0x0C, 0x0D, 0x1C, 0x1D, 0x1E, 0x1F, 0x20, 0x85, 0xA0, 0x1680,
                                0x2000, 0x2001, 0x2002, 0x2003, 0x2004, 0x2005, 0x2006, 0x2007, 0x2008, 0x2009,
                                0x200A, 0x2028, 0x2029, 0x202F, 0x205F, 0x3000]

// Extensions add methods to a type you don't own: "  x ".pythonStrip() reads as if String had it.
extension String {
    func pythonStrip() -> String {
        let scalars = Array(unicodeScalars)
        guard let first = scalars.firstIndex(where: { !pythonSpace.contains($0.value) }),
              let last = scalars.lastIndex(where: { !pythonSpace.contains($0.value) }) else { return "" }
        var out = String.UnicodeScalarView()
        out.append(contentsOf: scalars[first...last])
        return String(out)
    }

    func pythonWords() -> [String] {
        var words: [String] = []
        var current = String.UnicodeScalarView()
        for scalar in unicodeScalars {
            if pythonSpace.contains(scalar.value) {
                if !current.isEmpty { words.append(String(current)); current = String.UnicodeScalarView() }
            } else {
                current.append(scalar)
            }
        }
        if !current.isEmpty { words.append(String(current)) }
        return words
    }

    // Trims any of these code points from both ends, like Python's str.strip(chars).
    func trimming(_ characters: String) -> String {
        let set = Set(characters.unicodeScalars)
        let scalars = Array(unicodeScalars)
        guard let first = scalars.firstIndex(where: { !set.contains($0) }),
              let last = scalars.lastIndex(where: { !set.contains($0) }) else { return "" }
        var out = String.UnicodeScalarView()
        out.append(contentsOf: scalars[first...last])
        return String(out)
    }

    // Width in code points, as Python's len() counts. (count would count graphemes.)
    var width: Int { unicodeScalars.count }
}

// ---- Parsing one line -----------------------------------------------------------------------

// "[done.] Call mom #family" -> a Task, or nil if the line isn't a task. Task? says it can be nil,
// and nobody can use the result without unwrapping it first.
func parseLine(_ line: String) -> Task? {
    let s = line.pythonStrip()
    guard s.unicodeScalars.first == "[" else { return nil }
    // Python's partition("]"): what's before the first ], and what's after it.
    let scalars = Array(s.unicodeScalars)
    let close = scalars.firstIndex(of: "]")
    let raw = String(String.UnicodeScalarView(scalars[..<(close ?? scalars.count)]))
    let rest = close.map { String(String.UnicodeScalarView(scalars[($0 + 1)...])) } ?? ""
    let word = raw.trimming("[] .").lowercased()
    let status: Status = switch word {
    case "done": .done
    case "todo": .todo
    default: .other(word)
    }
    let words = rest.pythonWords()
    let tags = words.filter { $0.unicodeScalars.first == tagMarker }.map { word in
        String(word.unicodeScalars.drop { $0 == "#" }).trimming(".,").lowercased()
    }
    let title = words.filter { $0.unicodeScalars.first != tagMarker }.joined(separator: " ")
    return Task(title: title, status: status, tags: tags, kind: tags.contains("urgent") ? .urgent : .plain)
}

// ---- The file -------------------------------------------------------------------------------

// What can go wrong with the tasks file: an enum that conforms to Error, so it can be thrown.
enum LoadError: Error {
    case notFound, unreadable
}

// Every task in the file; lines that aren't tasks are skipped. Lines end at \n, \r\n or \r. throws
// says it can fail, and every call must be marked with try.
func loadTasks(_ path: String) throws -> [Task] {
    let text: String
    do {
        text = try String(contentsOfFile: path, encoding: .utf8)
    } catch let error as CocoaError where error.code == .fileReadNoSuchFile {
        throw LoadError.notFound
    } catch {
        throw LoadError.unreadable
    }
    var lines: [String] = []
    var current = String.UnicodeScalarView()
    var previous: Unicode.Scalar? = nil
    for scalar in text.unicodeScalars {
        if scalar == "\n" && previous == "\r" { previous = scalar; continue } // \r\n: one ending
        if scalar == "\n" || scalar == "\r" {
            lines.append(String(current))
            current = String.UnicodeScalarView()
        } else {
            current.append(scalar)
        }
        previous = scalar
    }
    lines.append(String(current))
    return lines.compactMap(parseLine) // compactMap drops the nils
}

// Parses each title as a new "[todo]" task and adds it. inout: the caller's array itself changes.
func addTasks(_ tasks: inout [Task], _ titles: [String]) -> Int {
    let added = titles.compactMap { parseLine("[todo] \($0)") }
    tasks += added
    return added.count
}

// ---- Counting and ranking -------------------------------------------------------------------

// Every tag with how many tasks carry it, in the order each first appears. A Dictionary has no
// order, so the array keeps it and the dictionary finds each tag's place.
func countTags(_ tasks: [Task], includeDone: Bool = true) -> [TagCount] {
    var counts: [TagCount] = []
    var place: [String: Int] = [:]
    for task in tasks where includeDone || !task.isDone {
        for tag in task.tags {
            if let i = place[tag] {
                counts[i] = TagCount(tag: tag, count: counts[i].count + 1)
            } else {
                place[tag] = counts.count
                counts.append(TagCount(tag: tag, count: 1))
            }
        }
    }
    return counts
}

// The n items with the biggest key, biggest first, for any type and any comparable key. sorted(by:)
// is stable, so ties keep their order.
func topN<T, Key>(_ items: [T], _ n: Int, by key: (T) -> Key) -> [T] where Key: Comparable {
    Array(items.sorted { key($0) > key($1) }.prefix(n))
}

enum TopTagsError: Error {
    case needAtLeastOne // Python's ValueError
}

func topTags(_ tasks: [Task], _ n: Int, includeDone: Bool = true) throws -> [TagCount] {
    guard n >= 1 else { throw TopTagsError.needAtLeastOne }
    return topN(countTags(tasks, includeDone: includeDone), n) { $0.count }
}

// ---- The chart ------------------------------------------------------------------------------

func drawChart(_ pairs: [TagCount], width: Int = chartWidth) {
    guard let first = pairs.first else {
        print("No tags yet.")
        return
    }
    let labelWidth = pairs.map(\.tag.width).max() ?? 0
    for pair in pairs {
        // .toNearestOrEven is Python's round(); plain .rounded() sends halves away from zero.
        let blocks = Int((Double(pair.count) / Double(first.count) * Double(width)).rounded(.toNearestOrEven))
        print("\(pair.tag)\(String(repeating: " ", count: labelWidth - pair.tag.width))  \(String(repeating: "█", count: blocks)) \(pair.count)")
    }
}

// ---- Talking to the user --------------------------------------------------------------------

// Python's input(): shows the prompt, reads up to the next \n. readLine() would drop a \r too.
// An empty line at the end of input.
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
    var s = Substring(text.pythonStrip())
    let negative = s.first == "-"
    if s.first == "-" || s.first == "+" { s = s.dropFirst() }
    guard let first = s.first, first.isASCII, first.isNumber else { return nil }
    var value = 0
    var previous: Character = " "
    for (i, c) in s.enumerated() {
        if c == "_", previous != "_", i + 1 < s.count, s[s.index(s.startIndex, offsetBy: i + 1)].isASCII,
           s[s.index(s.startIndex, offsetBy: i + 1)].isNumber {
            previous = c
            continue
        }
        guard c.isASCII, let digit = c.wholeNumberValue else { return nil }
        value = min(value * 10 + digit, Int(Int32.max))
        previous = c
    }
    return negative ? -value : value
}

func fail(_ message: String) -> Never {
    FileHandle.standardError.write(Data((message + "\n").utf8))
    exit(1)
}

let arguments = CommandLine.arguments.dropFirst()
let path = arguments.first ?? ProcessInfo.processInfo.environment["TASKS_FILE"] ?? "tasks.txt"

var tasks: [Task]
do {
    tasks = try loadTasks(path)
} catch LoadError.notFound {
    fail("Couldn't find \(path)")
} catch {
    fail("Couldn't read \(path)")
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
    guard let file = FileHandle(forWritingAtPath: path) else { fail("Couldn't write \(path)") }
    defer { try? file.close() } // runs when this block ends, however it ends
    file.seekToEndOfFile()
    file.write(Data(newTitles.map { "[todo] \($0)\n" }.joined().utf8))
}

let answer = ask("How many top tags? [3]: ")
let pairs: [TagCount]
do {
    pairs = try topTags(tasks, answer.isEmpty ? defaultTop : parseWholeNumber(answer) ?? 0)
} catch {
    print("Need a whole number of at least 1 — using 3.")
    pairs = try! topTags(tasks, defaultTop) // try!: can't fail, because defaultTop is at least 1
}

let done = tasks.filter(\.isDone).count
let percent = tasks.isEmpty ? 0 : Double(done) / Double(tasks.count) * 100
print("\n\(tasks.count) tasks, \(done) done (\(Int(percent.rounded(.toNearestOrEven)))%), \(countTags(tasks).count) tags")
for task in tasks where task.kind == .urgent && !task.isDone {
    print(task)
}

print("\nTop tags")
drawChart(pairs)
