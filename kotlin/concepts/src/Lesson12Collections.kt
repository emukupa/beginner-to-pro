// Lesson 12: collections. Every collection comes in two kinds: read-only (List, Set, Map), which
// has no add or put at all, and mutable (MutableList, ...), which does. Functions hand out read-only
// ones, so nobody changes your list behind your back. mutableMapOf() is a LinkedHashMap: it keeps
// keys in the order they were first added, which is exactly what the tracker's ties need.
// bug12: reading tasks[tasks.size], one past the end. It builds, then throws IndexOutOfBoundsException.
package concepts.lesson12

import concepts.bug
import concepts.lesson09.TagCount
import concepts.lesson10.Task
import concepts.lesson11.loadTasks

const val TITLE = "Collections"

/** How many tasks use each tag, in the order tags first appear. Lesson 14 ranks these. */
fun countTags(tasks: List<Task>): List<TagCount> {
    val counts = mutableMapOf<String, Int>() // a LinkedHashMap underneath: first-seen order
    for (task in tasks) {
        for (tag in task.tags) {
            counts[tag] = counts.getOrDefault(tag, 0) + 1
        }
    }
    return counts.map { (tag, count) -> TagCount(tag, count) } // read-only from here on
}

fun run() {
    val tasks = loadTasks("tasks.txt").getOrElse { error("run from kotlin/concepts, next to tasks.txt") }
    println("${tasks.size} tasks; the first two: ${tasks.take(2)}")
    println("tasks.getOrNull(99) = ${tasks.getOrNull(99)}") // null instead of an exception
    val titles = mutableListOf<String>() // mutable: we add to it
    for (task in tasks) if (!task.isDone) titles.add(task.title)
    println("still to do: $titles")
    println("countTags: ${countTags(tasks)}")
    // The same count in one line: groupingBy + eachCount also keeps first-seen order.
    val allTags = tasks.flatMap { it.tags } // every tag of every task, in one list
    println("groupingBy { it }.eachCount(): ${allTags.groupingBy { it }.eachCount()}")
    // A plain HashMap makes no promise about order: here "urgent" comes out first.
    println("HashMap: ${HashMap(allTags.groupingBy { it }.eachCount())}")
    val unique: Set<String> = allTags.toSet() // a Set drops repeats (and keeps first-seen order too)
    println("${allTags.size} tag uses, ${unique.size} different tags: $unique")
    println("\"work\" in unique: ${"work" in unique}")
    val (done, todo) = tasks.partition { it.isDone }
    println("${done.size} done, ${todo.size} to do")
    bug(12)
}
