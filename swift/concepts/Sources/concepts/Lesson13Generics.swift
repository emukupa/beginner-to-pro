// Lesson 13: sorting, closures over collections, and generics. `sorted(by:)` takes a closure that
// says which of two comes first, and it's stable (since Swift 5): equal items keep their order,
// which the tracker's ties need. A generic function works for any type that meets its `where`
// clause, checked when compiling, not when running.
// BUG13: sorted() on statuses. sorted() needs Comparable, and Status doesn't say how to order.

enum Lesson13Generics {
    static let title = "Sorting and generics"

    static func run() {
        let tasks = (try? loadTasks("tasks.txt")) ?? []
        let counts = countTags(tasks)

        // filter / map / reduce: each takes a closure.
        let open = tasks.filter { !$0.isDone }.map(\.title)
        print("open: \(open)")
        print("tags in all: \(tasks.map(\.tags.count).reduce(0, +))")
        print("contains urgent: \(tasks.contains { $0.kind == .urgent })")

        // Stable: urgent, family and travel all have 1, and stay in the order they were first seen.
        let ranked = counts.sorted { $0.count > $1.count }
        print("ranked: \(ranked.map { "\($0.tag) \($0.count)" })")

        print("topN(counts, 3): \(topN(counts, 3) { $0.count }.map(\.tag))")
        print("topN(titles, 2, by length): \(topN(tasks.map(\.title), 2) { $0.count })")

        // bar() rounds like Python: 2.5 blocks becomes 2, not 3.
        for (count, biggest) in [(3, 3), (2, 3), (1, 3), (1, 8)] {
            print("bar(\(count), of: \(biggest)) = \(padded(bar(count, of: biggest), to: 20))| \(Double(count) / Double(biggest) * 20)")
        }

        #if BUG13
        let order = [Status.done, .todo].sorted() // which comes first, todo or done? Status can't say
        print(order)
        #endif
    }
}

/// The `n` items with the biggest key, biggest first; ties keep their order. Any sequence, any
/// key that can be compared: the `where` clause says so, and the compiler checks every call.
func topN<Items, Key>(_ items: Items, _ n: Int, by key: (Items.Element) -> Key) -> [Items.Element]
where Items: Sequence, Key: Comparable {
    Array(items.sorted { key($0) > key($1) }.prefix(n))
}

/// A bar of █ for `count`, with `biggest` getting the full `width`. Rounds half to even, like Python.
func bar(_ count: Int, of biggest: Int, width: Int = 20) -> String {
    let length = (Double(count) / Double(biggest) * Double(width)).rounded(.toNearestOrEven)
    return String(repeating: "█", count: Int(length))
}
