// The tasks file: the only package that opens files.
package tracker.storage

import java.nio.file.Path
import kotlin.io.path.appendText
import kotlin.io.path.readText
import tracker.models.Task
import tracker.parsing.parseLine

// Every task in the file; lines that aren't tasks are skipped. Lines end at \n, \r\n or \r.
fun loadTasks(path: Path): MutableList<Task> =
    path.readText().split(Regex("\r\n|\r|\n")).mapNotNull(::parseLine).toMutableList()

// "[todo] title" lines on the end of the file.
fun appendTitles(path: Path, titles: List<String>) = path.appendText(titles.joinToString("") { "[todo] $it\n" })
