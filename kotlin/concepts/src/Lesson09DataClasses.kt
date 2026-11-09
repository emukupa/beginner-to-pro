// Lesson 09: classes, and data classes. A class's constructor is written in its header, and
// `val title: String` there makes a property in one go. Mark it `data class` and kotlinc also writes
// equals, hashCode, toString, copy and destructuring for you: everything a Java record or a page of
// Java boilerplate would give. A data class is for a value that is just its fields.
// bug09: calling splitWords, which is private to this file. Outside the file it doesn't exist.
package concepts.lesson09

import concepts.bug
import concepts.lesson04.pythonSplit
import concepts.lesson04.pythonStrip
import concepts.lesson07.tagOf
import concepts.lesson08.Status

const val TITLE = "Classes and data classes"

/** What one line of the file says. Lesson 10 turns it into a Task or an UrgentTask. */
data class TaskLine(
    val title: String,
    val status: Status,
    val tags: List<String>, // List is read-only: nobody can add to a TaskLine's tags behind its back
) {
    val isDone: Boolean get() = status.isDone
}

/** One tag and how many tasks use it: lessons 11 and 14 count into these. */
data class TagCount(val tag: String, val count: Int)

// private at the top of a file: only this file can call it.
private fun splitWords(rest: String): Pair<List<String>, List<String>> =
    rest.pythonSplit().partition { tagOf(it) == null } // (words that aren't tags, words that are)

/** "[done.] Call mom #family" -> TaskLine("Call mom", DONE, ["family"]); not a task line -> null. */
fun parseLine(line: String): TaskLine? {
    val text = line.pythonStrip()
    if (!text.startsWith("[")) return null // blank lines and notes aren't tasks
    val status = Status.parse(text.substringBefore("]"))
    val (words, tagWords) = splitWords(text.substringAfter("]", ""))
    return TaskLine(words.joinToString(" "), status, tagWords.mapNotNull { tagOf(it) })
}

fun run() {
    val task = parseLine("[done.] Call mom #family")
    println("parsed: $task") // the toString kotlinc wrote: every property, by name
    println("not a task: ${parseLine("buy milk")}, blank: ${parseLine("   ")}")
    if (task == null) return // from here on, task is a TaskLine (a smart cast, lesson 07)
    val again = parseLine("[DONE] Call mom #Family.")
    println("same line, messier: equal? ${task == again}") // equals compares the properties
    val reopened = task.copy(status = Status.TODO) // a new value with one property changed
    println("copy(status = TODO): $reopened, isDone=${reopened.isDone}; the original is still ${task.status}")
    val (title, status, tags) = task // destructuring, in property order
    println("destructured: title=$title status=$status tags=$tags")
    val counts = setOf(TagCount("work", 3), TagCount("work", 3), TagCount("home", 2))
    println("a set of TagCounts drops the duplicate (hashCode and equals): $counts")
    bug(9)
}
