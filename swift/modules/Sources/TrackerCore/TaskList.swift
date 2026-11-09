// Working with the list: adding, counting, ranking, summing up. No files, no printing.

public let defaultTop = 3

// Parses each title as a new "[todo]" task and adds it. inout: the caller's array changes.
public func addTasks(_ tasks: inout [Task], _ titles: [String]) -> Int {
    let added = titles.compactMap { parseLine("[todo] \($0)") }
    tasks += added
    return added.count
}

// The first task whose title matches, ignoring case and extra spaces; nil if there isn't one.
public func findTask(_ tasks: [Task], _ title: String) -> Task? {
    let wanted = title.pythonWords().joined(separator: " ").lowercased()
    return tasks.first { $0.title.lowercased() == wanted }
}

// Every tag with how many tasks carry it, in the order each first appears. A Dictionary has no
// order, so the array keeps it and the dictionary finds each tag's place.
public func countTags(_ tasks: [Task], includeDone: Bool = true) -> [TagCount] {
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

// The n items with the biggest key, biggest first. sorted(by:) is stable, so ties keep their order.
public func topN<T, Key>(_ items: [T], _ n: Int, by key: (T) -> Key) -> [T] where Key: Comparable {
    Array(items.sorted { key($0) > key($1) }.prefix(n))
}

public enum TopTagsError: Error {
    case needAtLeastOne // Python's ValueError
}

public func topTags(_ tasks: [Task], _ n: Int, includeDone: Bool = true) throws(TopTagsError) -> [TagCount] {
    guard n >= 1 else { throw .needAtLeastOne }
    return topN(countTags(tasks, includeDone: includeDone), n) { $0.count }
}

// The numbers on the summary line.
public struct Summary: Sendable {
    public let total: Int, done: Int, percent: Int, tags: Int
}

public func summarize(_ tasks: [Task]) -> Summary {
    let done = tasks.filter(\.isDone).count
    let percent = tasks.isEmpty ? 0 : Double(done) / Double(tasks.count) * 100
    // .toNearestOrEven is Python's round().
    return Summary(total: tasks.count, done: done, percent: Int(percent.rounded(.toNearestOrEven)), tags: countTags(tasks).count)
}
