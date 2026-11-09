// Lesson 14's mistake: ranking tasks by their title. topN's count must give an Int for every item;
// this lambda gives a String, and the generic signature catches it before anything runs.
package concepts.lesson14

import concepts.lesson11.loadTasks

fun bug() {
    val tasks = loadTasks("tasks.txt").getOrThrow()
    println(topN(tasks, 3) { it.title })
}
