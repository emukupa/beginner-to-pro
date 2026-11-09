// Turning one line of text into a task. No files, no printing: text in, a Task out.
package tracker.parsing

import tracker.models.Task
import tracker.models.UrgentTask
import tracker.text.pythonStrip
import tracker.text.pythonWords

const val TAG_MARKER = "#"

// internal: visible anywhere in this module (core, and its tests), but not to the app module.
internal fun statusOf(raw: String): String = raw.trim('[', ']', ' ', '.').lowercase()

// "[done.] Call mom #family" -> a Task, or null if the line isn't a task.
fun parseLine(line: String): Task? {
    val s = line.pythonStrip()
    if (!s.startsWith("[")) return null
    val raw = s.substringBefore("]") // Python's partition("]")
    val rest = s.substringAfter("]", "")
    val (tagWords, titleWords) = rest.pythonWords().partition { it.startsWith(TAG_MARKER) }
    val tags = tagWords.map { it.trimStart('#').trim('.', ',').lowercase() }
    val title = titleWords.joinToString(" ")
    val status = statusOf(raw)
    return if ("urgent" in tags) UrgentTask(title, status, tags) else Task(title, status, tags)
}
