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

public enum WriteError: Error {
    case cantWrite
}

// A new file beside another, deleted when it goes away unless it replaced the other.
// ~Copyable: a TempFile can't be copied, only moved, so exactly one owner ever holds the file,
// and its deinit runs exactly once, when that owner is done: at the end of the scope, however it
// ends, or at the end of replace, which consumes it.
struct TempFile: ~Copyable {
    let path: String
    let fd: Int32
    private var kept = false

    // O_EXCL: fail if the file already exists, so a random name can't be anyone else's file.
    init(beside target: String) throws(WriteError) {
        path = "\(target).\(String(UInt64.random(in: 0...UInt64.max), radix: 16))"
        fd = open(path, O_WRONLY | O_CREAT | O_EXCL, 0o600)
        guard fd >= 0 else { throw .cantWrite }
    }

    func copyPermissions(from other: String) throws(WriteError) {
        var info = stat()
        guard stat(other, &info) == 0, fchmod(fd, info.st_mode & 0o7777) == 0 else { throw .cantWrite }
    }

    func write(_ bytes: [UInt8]) throws(WriteError) {
        var written = 0
        while written < bytes.count {
            let n = bytes[written...].withUnsafeBytes { Darwin.write(fd, $0.baseAddress, $0.count) }
            guard n > 0 else { throw .cantWrite }
            written += n
        }
    }

    // On the disk first, then renamed over target: readers see the old file or the new one.
    // consuming: after this call the TempFile is gone; the compiler won't let anyone use it again.
    consuming func replace(_ target: String) throws(WriteError) {
        guard fsync(fd) == 0, rename(path, target) == 0 else { throw .cantWrite }
        kept = true
    }

    deinit {
        close(fd)
        if !kept { unlink(path) } // never leave the half-made file behind
    }
}

// True if this line holds the task: the same title and status after parsing.
func holds(_ line: String, _ task: Task) -> Bool {
    guard let found = parseLine(line) else { return false }
    return found.title == task.title && found.status == task.status
}

// The lines of a text, each keeping its own ending (\n, \r\n or \r), as Python's readlines() does
// with newline="".
func linesKeepingEndings(_ text: String) -> [String] {
    var lines: [String] = []
    var current = String.UnicodeScalarView()
    let scalars = Array(text.unicodeScalars)
    for (i, scalar) in scalars.enumerated() {
        current.append(scalar)
        let ends = scalar == "\n" || (scalar == "\r" && (i + 1 == scalars.count || scalars[i + 1] != "\n"))
        if ends {
            lines.append(String(current))
            current = String.UnicodeScalarView()
        }
    }
    if !current.isEmpty { lines.append(String(current)) }
    return lines
}

// Rewrites the line holding this task as [done], leaving every other byte of the file alone.
public func markDone(_ path: String, _ task: Task) throws(WriteError) {
    guard let text = try? String(contentsOfFile: path, encoding: .utf8) else { throw .cantWrite }
    var lines = linesKeepingEndings(text)
    if let at = lines.firstIndex(where: { holds($0, task) }) {
        let scalars = Array(lines[at].unicodeScalars)
        let open = scalars.firstIndex(of: "[")!
        let close = scalars[open...].firstIndex(of: "]")!
        var line = String.UnicodeScalarView(scalars[..<open])
        line.append(contentsOf: "[done]".unicodeScalars)
        line.append(contentsOf: scalars[(close + 1)...])
        lines[at] = String(line)
    }

    let temp = try TempFile(beside: path)
    try temp.copyPermissions(from: path) // keep the old file's
    try temp.write(Array(lines.joined().utf8))
    try temp.replace(path)
} // if any try above threw, temp's deinit has deleted the half-made file
