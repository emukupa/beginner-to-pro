// Lesson 11: errors and defer. A function that can fail says `throws`; every call to it must be
// marked `try`, so you can see each place that might fail; `do`/`catch` handles the error. Swift 6
// can name the one error type a function throws, `throws(TrackerError)`, so `catch` knows it.
// `defer` runs its block when the scope ends, however it ends: Zig's defer, for closing files.
// BUG11: calling parseTop without `try`. The compiler wants every failure point marked.

import Foundation

enum Lesson11Errors {
    static let title = "Errors and defer"

    static func run() {
        for text in ["5", "", "two", "0"] {
            do {
                let n = try parseTop(text)
                print("parseTop(\"\(text)\") = \(n)")
            } catch .badNumber(let bad) { // typed throws: catch can match TrackerError's cases
                print("parseTop(\"\(text)\") threw badNumber(\"\(bad)\") -> using 3")
            } catch {
                print("parseTop(\"\(text)\") threw \(error)")
            }
        }

        // try? turns an error into nil, when you only care whether it worked.
        print("try? parseTop(\"x\") = \(String(describing: try? parseTop("x")))")

        do {
            let tasks = try loadTasks("tasks.txt")
            print("loadTasks(\"tasks.txt\"): \(tasks.count) tasks, first: \(tasks[0])")
            _ = try loadTasks("nowhere.txt")
        } catch {
            print("caught: \(error)") // description, from CustomStringConvertible
        }

        deferOrder()

        #if BUG11
        let top = parseTop("5") // it can throw, so it needs `try`, inside a do or a throwing function
        print(top)
        #endif
    }

    /// The deferred blocks run last, newest first, on the way out.
    static func deferOrder() {
        print("1. open")
        defer { print("4. close (the first defer runs last)") }
        defer { print("3. flush") }
        print("2. read")
    }
}

/// Everything that can go wrong in the tracker. Error is a protocol with nothing to implement.
enum TrackerError: Error, Equatable, CustomStringConvertible {
    case notFound(String)
    case unreadable(String)
    case badNumber(String)

    var description: String {
        switch self {
        case .notFound(let path): "Couldn't find \(path)"
        case .unreadable(let path): "Couldn't read \(path)"
        case .badNumber(let text): "Need a whole number of at least 1, not \"\(text)\""
        }
    }
}

/// The answer to "How many top tags? [3]": empty means 3, anything else must be a number >= 1.
func parseTop(_ text: String) throws(TrackerError) -> Int {
    let text = text.stripped()
    if text.isEmpty { return 3 }
    guard let n = Int(text), n >= 1 else { throw .badNumber(String(text)) }
    return n
}

/// Reads a tasks file into Tasks, skipping lines that aren't tasks. The tracker's load_tasks.
func loadTasks(_ path: String) throws(TrackerError) -> [Task] {
    guard let file = FileHandle(forReadingAtPath: path) else { throw .notFound(path) }
    defer { try? file.close() } // closed on every way out, error or not
    let data: Data
    do {
        data = try file.readToEnd() ?? Data() // nil means an empty file
    } catch {
        throw .unreadable(path)
    }
    let text = String(decoding: data, as: UTF8.self)
    // isNewline, not "\n": Swift treats "\r\n" as one Character, so splitting on "\n" would miss it.
    return text.split(whereSeparator: \.isNewline).compactMap { parseTask(String($0)) }
}
