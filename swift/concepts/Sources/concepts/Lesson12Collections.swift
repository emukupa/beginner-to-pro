// Lesson 12: collections. Array, Dictionary and Set are value types like structs: assigning one
// copies it. The copy is lazy (copy-on-write), so it costs nothing until one of them changes.
// A Dictionary's order is not the order you added things, and changes from run to run, so the
// tracker keeps its counts in an Array and uses the Dictionary only to find each tag's place.
// BUG12: reading one past the end. Every index is checked, and a bad one stops the program.

enum Lesson12Collections {
    static let title = "Collections"

    static func run() {
        var tags = ["work", "home"]
        tags.append("urgent")
        tags.insert("first", at: 0)
        let last = tags.removeLast()
        print("tags = \(tags), removed \(last), count \(tags.count), isEmpty \(tags.isEmpty)")
        print("tags.first = \(tags.first ?? "none"), tags[1...] = \(tags[1...])") // a slice
        print("tags.indices.contains(9) = \(tags.indices.contains(9))") // check before you index

        // Value semantics: `copy` is its own array. Changing it leaves `tags` alone.
        var copy = tags
        copy.append("travel")
        print("copy.count = \(copy.count), tags.count = \(tags.count)")

        // Dictionary: look-ups give an optional, or use a default.
        var counts: [String: Int] = [:]
        for tag in ["work", "home", "work"] {
            counts[tag, default: 0] += 1
        }
        print("counts[\"work\"] = \(counts["work"] ?? 0), counts[\"gym\"] = \(String(describing: counts["gym"]))")
        print("counts sorted by key = \(counts.sorted { $0.key < $1.key })")

        // Set: each value once, no order. Good for "how many different tags?".
        let unique = Set(["work", "home", "work", "urgent"])
        print("Set count = \(unique.count), contains(\"home\") = \(unique.contains("home"))")

        let tasks = (try? loadTasks("tasks.txt")) ?? []
        for counted in countTags(tasks) {
            print("countTags: \(counted.tag) \(counted.count)")
        }

        #if BUG12
        let missing = tasks[tasks.count] // indexes run 0 to count - 1: this is one past the end
        print(missing)
        #endif
    }
}

/// One tag and how many tasks have it.
struct TagCount: Equatable {
    let tag: String
    var count: Int
}

/// Counts every tag, in the order each one first appears in the file, so ties keep that order.
func countTags(_ tasks: [Task]) -> [TagCount] {
    var counts: [TagCount] = []
    var place: [String: Int] = [:] // tag -> its index in counts
    for tag in tasks.flatMap(\.tags) {
        if let i = place[tag] {
            counts[i].count += 1 // changes the TagCount inside the array, in place
        } else {
            place[tag] = counts.count
            counts.append(TagCount(tag: tag, count: 1))
        }
    }
    return counts
}
