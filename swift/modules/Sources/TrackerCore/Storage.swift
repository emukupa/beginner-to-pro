// The tasks file: the only file that opens files.
import Foundation

public enum LoadError: Error {
    case notFound, unreadable
}

// Every task in the file; lines that aren't tasks are skipped. Lines end at \n, \r\n or \r.
public func loadTasks(_ path: String) throws(LoadError) -> [Task] {
    let text: String
    do {
        text = try String(contentsOfFile: path, encoding: .utf8)
    } catch let error as CocoaError where error.code == .fileReadNoSuchFile {
        throw .notFound
    } catch {
        throw .unreadable
    }
    return splitLines(text).compactMap(parseLine)
}

// The lines of a text, ending at \n, \r\n or \r, without their endings.
func splitLines(_ text: String) -> [String] {
    var lines: [String] = []
    var current = String.UnicodeScalarView()
    var previous: Unicode.Scalar? = nil
    for scalar in text.unicodeScalars {
        defer { previous = scalar }
        if scalar == "\n" && previous == "\r" { continue } // \r\n: one ending
        if scalar == "\n" || scalar == "\r" {
            lines.append(String(current))
            current = String.UnicodeScalarView()
        } else {
            current.append(scalar)
        }
    }
    lines.append(String(current))
    return lines
}

// "[todo] title" lines on the end of the file.
public func appendTitles(_ path: String, _ titles: [String]) throws {
    guard let file = FileHandle(forWritingAtPath: path) else { throw LoadError.unreadable }
    defer { try? file.close() } // runs when this function ends, however it ends
    try file.seekToEnd()
    try file.write(contentsOf: Data(titles.map { "[todo] \($0)\n" }.joined().utf8))
}
