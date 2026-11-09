// Lesson 11's mistake: forcing a null with !!. "Buy milk" has no [status], so parseTask gives null,
// and !! throws. Something the user typed can always be wrong: use ?: or ?.let, never !!.
package concepts.lesson11

import concepts.lesson10.parseTask

fun bug() {
    val typed = "Buy milk"
    val task = parseTask(typed)!!
    println(task.title)
}
