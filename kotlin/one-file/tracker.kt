// The task tracker in one Kotlin file. Same prompts, summary and chart as the Python version, byte
// for byte: contract/run.sh checks every one. Read top to bottom: what a task is, Python's text
// rules, parsing a line, the file, counting and ranking, the chart, then main, the only part that
// talks to the user.

import java.io.ByteArrayOutputStream
import java.io.FileDescriptor
import java.io.FileOutputStream
import java.io.IOException
import java.io.PrintStream
import java.nio.file.NoSuchFileException
import java.nio.file.Path
import kotlin.io.path.appendText
import kotlin.io.path.readText
import kotlin.math.round
import kotlin.system.exitProcess

const val CHART_WIDTH = 20 // the longest bar, in characters
const val DEFAULT_TOP = 3 // top tags shown when the answer is empty or invalid
const val TAG_MARKER = "#" // marks a word as a tag: "#work"

// ---- What a task is -------------------------------------------------------------------------

// Classes are final unless they say `open`, so Task has to invite subclasses. val: read-only.
open class Task(val title: String, val status: String, val tags: List<String>) {
    val isDone: Boolean get() = status == "done"

    override fun toString() = "[${if (isDone) "x" else " "}] $title"
}

// Python's UrgentTask(Task): `override` is required, and the compiler checks there's something to override.
class UrgentTask(title: String, status: String, tags: List<String>) : Task(title, status, tags) {
    override fun toString() = super.toString() + "  !!"
}

// A data class: equals, hashCode, toString and copy written for it, and it takes itself apart.
data class TagCount(val tag: String, val count: Int)

// ---- Python's text rules --------------------------------------------------------------------

// Exactly what Python's str.split() and str.strip() treat as space. Kotlin's trim() and
// isWhitespace() are close, but not the same set.
private const val SPACE = "\\t\\n\\u000B\\u000C\\r\\u001C\\u001D\\u001E\\u001F \\u0085\\u00A0\\u1680\\u2000-\\u200A\\u2028\\u2029\\u202F\\u205F\\u3000"
private val EDGE_SPACE = Regex("^[$SPACE]+|[$SPACE]+$")
private val RUN_OF_SPACE = Regex("[$SPACE]+")

// Extension functions: "  x ".pythonStrip() reads as if String had it all along.
fun String.pythonStrip(): String = replace(EDGE_SPACE, "")

fun String.pythonWords(): List<String> = pythonStrip().let { if (it.isEmpty()) emptyList() else it.split(RUN_OF_SPACE) }

// Width in code points, as Python's len() counts.
val String.width: Int get() = codePointCount(0, length)

// ---- Parsing one line -----------------------------------------------------------------------

// "[done.] Call mom #family" -> a Task, or null if the line isn't a task. `Task?` says it can be
// null, and the compiler won't let anyone use the result without checking.
fun parseLine(line: String): Task? {
    val s = line.pythonStrip()
    if (!s.startsWith("[")) return null
    val raw = s.substringBefore("]") // Python's partition("]"): all of s if there's no ]
    val rest = s.substringAfter("]", "")
    val status = raw.trim('[', ']', ' ', '.').lowercase()
    val (tagWords, titleWords) = rest.pythonWords().partition { it.startsWith(TAG_MARKER) }
    val tags = tagWords.map { it.trimStart('#').trim('.', ',').lowercase() }
    val title = titleWords.joinToString(" ")
    return if ("urgent" in tags) UrgentTask(title, status, tags) else Task(title, status, tags)
}

// ---- The file -------------------------------------------------------------------------------

// Every task in the file; lines that aren't tasks are skipped. Lines end at \n, \r\n or \r.
// Kotlin has no checked exceptions: a missing file throws, and main decides what to do.
fun loadTasks(path: Path): MutableList<Task> =
    path.readText().split(Regex("\r\n|\r|\n")).mapNotNull(::parseLine).toMutableList()

// Parses each title as a new "[todo]" task and adds it. Returns how many were added.
fun addTasks(tasks: MutableList<Task>, titles: List<String>): Int {
    val added = titles.mapNotNull { parseLine("[todo] $it") }
    tasks += added
    return added.size
}

// ---- Counting and ranking -------------------------------------------------------------------

// mutableMapOf() is a LinkedHashMap: it keeps the order keys were first put in, so first-seen order is free.
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
    require(n >= 1) { "n must be at least 1" } // throws IllegalArgumentException: Python's ValueError
    return topN(countTags(tasks, includeDone).map { (tag, count) -> TagCount(tag, count) }, n) { it.count }
}

// ---- The chart ------------------------------------------------------------------------------

fun drawChart(pairs: List<TagCount>, width: Int = CHART_WIDTH) {
    val first = pairs.firstOrNull() ?: return println("No tags yet.")
    val labelWidth = pairs.maxOf { it.tag.width }
    for ((tag, count) in pairs) {
        // kotlin.math.round sends halves to the even neighbour, like Python's round().
        val blocks = round(count.toDouble() / first.count * width).toInt()
        println("$tag${" ".repeat(labelWidth - tag.width)}  ${"█".repeat(blocks)} $count")
    }
}

// ---- Talking to the user --------------------------------------------------------------------

// Python's input(): shows the prompt, reads up to the next \n. An empty line at the end of input.
fun ask(prompt: String): String {
    print(prompt)
    System.out.flush()
    val line = ByteArrayOutputStream()
    while (true) {
        val b = System.`in`.read()
        if (b == -1 || b == '\n'.code) break
        line.write(b)
    }
    return line.toString(Charsets.UTF_8)
}

// Python's int(text): optional spaces, an optional sign, digits with single underscores between
// them, optional spaces. toIntOrNull takes no spaces or underscores. Capped.
fun parseWholeNumber(text: String): Int? {
    val match = Regex("([+-]?)([0-9]+(?:_[0-9]+)*)").matchEntire(text.pythonStrip()) ?: return null
    val (sign, number) = match.destructured
    val digits = number.replace("_", "").trimStart('0').ifEmpty { "0" }
    val value = if (digits.length > 9) Int.MAX_VALUE else digits.toInt()
    return if (sign == "-") -value else value
}

fun main(args: Array<String>) {
    // UTF-8 for the bars whatever the system's locale says.
    System.setOut(PrintStream(FileOutputStream(FileDescriptor.out), true, Charsets.UTF_8))
    val path = Path.of(args.firstOrNull() ?: System.getenv("TASKS_FILE") ?: "tasks.txt")

    val tasks = try {
        loadTasks(path)
    } catch (e: NoSuchFileException) {
        System.err.println("Couldn't find $path")
        exitProcess(1)
    } catch (e: IOException) {
        System.err.println("Couldn't read $path")
        exitProcess(1)
    }

    val newTitles = mutableListOf<String>()
    while (true) {
        val title = ask("New task (Enter to finish): ").pythonStrip()
        if (title.isEmpty()) break
        if (title.startsWith(TAG_MARKER)) {
            println("A task needs a title, not just tags.")
            continue
        }
        newTitles += title
    }
    if (addTasks(tasks, newTitles) > 0) path.appendText(newTitles.joinToString("") { "[todo] $it\n" })

    // try is an expression: its value is the last line of whichever branch ran.
    val pairs = try {
        val answer = ask("How many top tags? [3]: ")
        topTags(tasks, if (answer.isEmpty()) DEFAULT_TOP else parseWholeNumber(answer) ?: 0)
    } catch (e: IllegalArgumentException) {
        println("Need a whole number of at least 1 — using 3.")
        topTags(tasks, DEFAULT_TOP)
    }

    val done = tasks.count { it.isDone }
    val percent = if (tasks.isEmpty()) 0.0 else done.toDouble() / tasks.size * 100
    println("\n${tasks.size} tasks, $done done (${round(percent).toLong()}%), ${countTags(tasks).size} tags")
    tasks.filterIsInstance<UrgentTask>().filter { !it.isDone }.forEach(::println)

    println("\nTop tags")
    drawChart(pairs)
}
