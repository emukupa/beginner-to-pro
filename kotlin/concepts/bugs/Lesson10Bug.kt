// Lesson 10's mistake: inheriting from a data class. TaskLine is final (every data class is), so an
// urgent kind of TaskLine can't exist. Extend an open class instead, like Task.
package concepts.lesson10

import concepts.lesson08.Status
import concepts.lesson09.TaskLine

class UrgentLine(title: String, tags: List<String>) : TaskLine(title, Status.TODO, tags)

fun bug() {
    println(UrgentLine("Finish quarterly report", listOf("urgent")))
}
