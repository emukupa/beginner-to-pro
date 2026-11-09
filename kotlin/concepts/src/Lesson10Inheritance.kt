// Lesson 10: inheritance. Kotlin classes are final unless marked `open`, and so are their methods:
// a class has to say it expects children. A child overrides with the `override` keyword, which is
// required (leaving it out is an error, not a silent new method), and calls the parent with super.
// `is` checks what something really is, and after the check it's treated as that type (smart cast).
// bug10: extending lesson 09's data class. Data classes are final, so the compiler refuses. That's
// why the tracker's Task is an open class, and the data classes hold plain values.
package concepts.lesson10

import concepts.bug
import concepts.lesson08.Status
import concepts.lesson09.TaskLine
import concepts.lesson09.parseLine

const val TITLE = "Inheritance"

open class Task(val title: String, val status: Status, val tags: List<String>) {
    val isDone: Boolean get() = status.isDone

    override fun toString(): String = "[${status.mark}] $title" // Any.toString is open; we replace it
}

class UrgentTask(title: String, status: Status, tags: List<String>) : Task(title, status, tags) {
    override fun toString(): String = super.toString() + "  !!"
}

/** A task line from the file, as a Task or an UrgentTask; null if it isn't one. Lessons 12-14 use it. */
fun parseTask(line: String): Task? {
    val parsed: TaskLine = parseLine(line) ?: return null // ?: return: leave early on null
    val (title, status, tags) = parsed
    return if ("urgent" in tags) UrgentTask(title, status, tags) else Task(title, status, tags)
}

fun run() {
    val lines = listOf("[todo] Finish quarterly report #work #urgent", "[DONE] Fix login bug #work")
    val tasks: List<Task> = lines.mapNotNull { parseTask(it) } // an UrgentTask is a Task, so it fits
    for (task in tasks) {
        val kind = if (task is UrgentTask) "UrgentTask" else "Task"
        println("${kind.padEnd(10)} prints as \"$task\"") // toString picks the child's version
    }
    val first = tasks.first()
    if (first is UrgentTask) println("smart cast: first is an UrgentTask with tags ${first.tags}")
    println("as? gives null instead of failing: ${tasks.last() as? UrgentTask}")
    bug(10)
}
