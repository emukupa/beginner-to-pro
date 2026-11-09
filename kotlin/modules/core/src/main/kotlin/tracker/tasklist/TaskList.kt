// Working with the list: adding, counting, ranking, summing up. No files, no printing.
package tracker.tasklist

import kotlin.math.round
import tracker.models.TagCount
import tracker.models.Task
import tracker.parsing.parseLine
import tracker.text.pythonWords

const val DEFAULT_TOP = 3

// Parses each title as a new "[todo]" task and adds it. Returns how many were added.
fun addTasks(tasks: MutableList<Task>, titles: List<String>): Int {
    val added = titles.mapNotNull { parseLine("[todo] $it") }
    tasks += added
    return added.size
}

// The first task whose title matches, ignoring case and extra spaces; null if there isn't one.
fun findTask(tasks: List<Task>, title: String): Task? {
    val wanted = title.pythonWords().joinToString(" ").lowercase()
    return tasks.firstOrNull { it.title.lowercase() == wanted }
}

// mutableMapOf() keeps the order keys were first put in, so first-seen order is free.
fun countTags(tasks: List<Task>, includeDone: Boolean = true): Map<String, Int> {
    val counts = mutableMapOf<String, Int>()
    for (task in tasks) {
        if (!includeDone && task.isDone) continue
        for (tag in task.tags) counts[tag] = (counts[tag] ?: 0) + 1
    }
    return counts
}

// The n items with the biggest key, biggest first, for any type. sortedByDescending is stable.
fun <T> topN(items: List<T>, n: Int, key: (T) -> Int): List<T> = items.sortedByDescending(key).take(n)

fun topTags(tasks: List<Task>, n: Int, includeDone: Boolean = true): List<TagCount> {
    require(n >= 1) { "n must be at least 1" } // Python's ValueError
    return topN(countTags(tasks, includeDone).map { (tag, count) -> TagCount(tag, count) }, n) { it.count }
}

// The numbers on the summary line: a data class, so the program can take it apart.
data class Summary(val total: Int, val done: Int, val percent: Long, val tags: Int)

fun summarize(tasks: List<Task>): Summary {
    val done = tasks.count { it.isDone }
    val percent = if (tasks.isEmpty()) 0.0 else done.toDouble() / tasks.size * 100
    return Summary(tasks.size, done, round(percent).toLong(), countTags(tasks).size) // round: halves to even
}
