// Lesson 14: generics, a stable sort, and everything so far as a mini tracker run on tasks.txt.
// `fun <T> topN(...)` works for a list of anything. On the JVM the T is normally forgotten when the
// program runs, so `it is T` can't be checked; an `inline` function with a `reified` T keeps it,
// which lets only<UrgentTask>() pick out one kind of task. `T : Task` is a bound: T must be a Task.
// sortedByDescending is stable: equal counts stay in the order they were first seen.
// bug14: ranking tasks by their title. topN wants an Int from its lambda, so it won't build.
package concepts.lesson14

import concepts.bug
import concepts.lesson03.roundHalfEven
import concepts.lesson04.padTo
import concepts.lesson04.width
import concepts.lesson06.bar
import concepts.lesson06.percent
import concepts.lesson09.TagCount
import concepts.lesson10.Task
import concepts.lesson10.UrgentTask
import concepts.lesson11.loadTasks
import concepts.lesson11.parseTop
import concepts.lesson12.countTags

const val TITLE = "Generics and the mini tracker"

/** The n items with the biggest count, biggest first; ties keep their order. Any type at all. */
fun <T> topN(items: List<T>, n: Int, count: (T) -> Int): List<T> = items.sortedByDescending(count).take(n)

/** Just the tasks of one kind: tasks.only<UrgentTask>(). An extension function, generic and reified. */
inline fun <reified T : Task> List<Task>.only(): List<T> = mapNotNull { it as? T }

/** The tracker's chart: labels padded to the widest, the biggest bar 20 blocks. */
fun drawChart(pairs: List<TagCount>) {
    if (pairs.isEmpty()) {
        println("No tags yet.")
        return
    }
    val biggest = pairs.first().count
    val labelWidth = pairs.maxOf { it.tag.width }
    for ((tag, count) in pairs) println("${tag.padTo(labelWidth)}  ${bar(count, biggest)} $count")
}

fun run() {
    val tasks = loadTasks("tasks.txt").getOrElse { error("run from kotlin/concepts, next to tasks.txt") }
    val top = parseTop("").getOrElse { 3 } // the tracker asks; Enter means 3
    val pairs = topN(countTags(tasks), top) { it.count }
    val done = tasks.count { it.isDone }
    val uniqueTags = tasks.flatMap { it.tags }.toSet()
    // Python's f"{percent:.0f}" rounds halves to even; Kotlin's "%.0f" wouldn't (lesson 03).
    println("${tasks.size} tasks, $done done (${roundHalfEven(percent(done, tasks.size))}%), ${uniqueTags.size} tags")
    for (task in tasks.only<UrgentTask>().filter { !it.isDone }) println(task)
    println("\nTop tags")
    drawChart(pairs)
    println("\ntopN works on any type: ${topN(listOf("a", "ccc", "bb", "dd"), 2) { it.length }}")
    bug(14)
}
