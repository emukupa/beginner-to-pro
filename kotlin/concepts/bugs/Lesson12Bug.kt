// Lesson 12's mistake: off by one. The last index is tasks.size - 1 (or tasks.lastIndex); asking for
// tasks.size reads past the end. The JVM checks every index, so it throws instead of reading junk.
package concepts.lesson12

import concepts.lesson11.loadTasks

fun bug() {
    val tasks = loadTasks("tasks.txt").getOrThrow()
    println(tasks[tasks.size])
}
