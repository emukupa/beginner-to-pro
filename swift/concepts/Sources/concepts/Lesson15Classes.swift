// Lesson 15: classes and ARC, for contrast. A class is a reference type: assigning one copies the
// reference, so two variables share one object, and a change through either shows in both.
// Swift has no garbage collector. Automatic reference counting (ARC) counts the references to each
// object and frees it the moment the last one goes, so `deinit` runs at a point you can predict.
// The tracker uses structs: nobody can change a value behind your back, and values are safe to send
// between threads. Swift 6 checks that: only Sendable things may cross to another thread.
// BUG15: sharing a class object with another thread while this one still uses it.

enum Lesson15Classes {
    static let title = "Classes and ARC"

    static func run() {
        let home = Notebook(name: "home")
        let alias = home // the same object, not a copy
        alias.tasks.append(Task(title: "Water plants"))
        print("home.tasks.count = \(home.tasks.count) (changed through alias), home === alias: \(home === alias)")

        var task = Task(title: "Call mom") // a struct, for contrast
        var copied = task
        copied.markDone()
        task.title += "!"
        print("struct: task.isDone = \(task.isDone), copied.isDone = \(copied.isDone)")

        // ARC frees an object as soon as nothing refers to it any more.
        var trip: Notebook? = Notebook(name: "trip")
        weak let watcher = trip // weak: looks without keeping it alive, and turns nil when it goes
        print("watcher sees \(watcher?.name ?? "nothing")")
        trip = nil // the last strong reference is gone: deinit runs right here
        print("after trip = nil, watcher sees \(watcher?.name ?? "nothing")")

        // isKnownUniquelyReferenced: how Array's copy-on-write knows whether it must copy first.
        var solo = Notebook(name: "solo")
        print("solo unique: \(isKnownUniquelyReferenced(&solo))")
        let second = solo
        print("solo unique with a second reference: \(isKnownUniquelyReferenced(&solo)) (\(second.name))")

        #if BUG15
        let shared = Notebook(name: "shared")
        _Concurrency.Task.detached { // Swift's own Task (ours is the tracker's): runs on another thread
            shared.tasks.append(Task(title: "from over there"))
        }
        shared.tasks.append(Task(title: "from here")) // both at once: a data race
        #endif
    }
}

/// A class: `final` because nothing inherits from it. It needs its own init; classes get no
/// memberwise one.
final class Notebook {
    let name: String
    var tasks: [Task] = []

    init(name: String) {
        self.name = name
    }

    deinit { // runs when ARC frees the object
        print("deinit: notebook \(name) freed")
    }
}
