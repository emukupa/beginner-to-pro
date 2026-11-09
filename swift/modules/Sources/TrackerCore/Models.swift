// What a task is. Every other file uses these; this one uses none of ours.

// public: visible to any module that imports TrackerCore. Without it, a name is internal: this
// module only.
public enum Status: Equatable, Sendable {
    case todo, done
    case other(String)
}

public enum Kind: Sendable {
    case plain, urgent
}

public struct Task: CustomStringConvertible, Sendable {
    public let title: String
    public let status: Status
    public let tags: [String]
    public let kind: Kind

    public var isDone: Bool { status == .done }

    public var description: String { "[\(isDone ? "x" : " ")] \(title)" + (kind == .urgent ? "  !!" : "") }
}

public struct TagCount: Equatable, Sendable {
    public let tag: String
    public let count: Int

    public init(tag: String, count: Int) {
        self.tag = tag
        self.count = count
    }
}
