// Lesson 14: everything so far comes together in a mini tracker, run on tasks.txt: load with
// throws, count tags, rank them with the generic topN, and draw the chart padded by code points.
// The output matches what Python's tasks.py prints for the same file.
// BUG14: `try!` on a file that isn't there. try! says "this can't fail"; when it does, the
// program stops on the spot.

enum Lesson14Tracker {
    static let title = "The mini tracker"

    static func run() {
        let tasks: [Task]
        do {
            tasks = try loadTasks("tasks.txt")
        } catch {
            print("\(error) (run from swift/concepts, next to tasks.txt)")
            return
        }
        let top = (try? parseTop("3")) ?? 3
        let counts = countTags(tasks)
        let done = tasks.filter(\.isDone).count
        let shown = Int(percent(done, of: tasks.count).rounded(.toNearestOrEven)) // Python's {:.0f}
        print("\(tasks.count) tasks, \(done) done (\(shown)%), \(counts.count) tags")
        for task in tasks where task.kind == .urgent && !task.isDone {
            print(task)
        }
        print("\nTop tags")
        drawChart(topN(counts, top) { $0.count })

        #if BUG14
        let typo = try! loadTasks("task.txt") // no such file: try! turns the error into a crash
        print(typo.count)
        #endif
    }
}

/// The tracker's chart: labels padded to the longest, the biggest bar 20 wide.
func drawChart(_ ranked: [TagCount]) {
    guard let first = ranked.first else {
        print("No tags yet.")
        return
    }
    let width = ranked.map(\.tag.unicodeScalars.count).max() ?? 0
    for counted in ranked {
        print("\(padded(counted.tag, to: width))  \(bar(counted.count, of: first.count)) \(counted.count)")
    }
}
