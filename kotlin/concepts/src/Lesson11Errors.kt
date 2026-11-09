// Lesson 11: errors and files. Kotlin has exceptions, like Java, but no checked exceptions: nothing
// forces a try/catch. For a failure the caller should expect (a missing file, a bad answer) the
// tracker returns a Result instead: runCatching { } runs a block and catches what it throws, and the
// caller decides with getOrElse, onFailure or exceptionOrNull. `use { }` closes a file when the block
// ends, even when it ends by throwing: Java's try-with-resources, as a function.
// bug11: `!!` on a line the parser rejected. It builds, then crashes with a NullPointerException.
package concepts.lesson11

import concepts.bug
import concepts.lesson02.DEFAULT_TOP
import concepts.lesson10.Task
import concepts.lesson10.parseTask
import java.io.File
import java.io.FileNotFoundException

const val TITLE = "Errors and files"

/** Every task line in the file; other lines are skipped, like the tracker. Lessons 12-14 use it. */
fun loadTasks(path: String): Result<List<Task>> = runCatching {
    File(path).bufferedReader().use { reader -> // UTF-8 unless you say otherwise
        reader.lineSequence().mapNotNull { parseTask(it) }.toList()
    } // the file is closed here, whatever happened inside
}

/** The answer to "How many top tags? [3]": Enter means 3, otherwise a whole number of at least 1. */
fun parseTop(answer: String): Result<Int> = runCatching {
    val n = answer.trim().ifEmpty { "$DEFAULT_TOP" }.toInt() // NumberFormatException on bad text
    require(n >= 1) { "n must be at least 1" } // IllegalArgumentException with this message
    n
}

/** Why a load failed, in the tracker's words. */
fun explain(error: Throwable, path: String): String = when (error) {
    is FileNotFoundException -> "Couldn't find $path"
    else -> "Couldn't read $path: ${error.message}"
}

fun run() {
    for (path in listOf("tasks.txt", "missing.txt")) {
        loadTasks(path)
            .onSuccess { tasks -> println("$path: ${tasks.size} tasks, the first: ${tasks.first()}") }
            .onFailure { error -> println("$path: ${explain(error, path)}") }
    }
    for (answer in listOf("3", "", " 2 ", "two", "0")) {
        val result = parseTop(answer)
        val text = result.exceptionOrNull()?.let { "${it::class.simpleName}: ${it.message}" } ?: "top ${result.getOrNull()}"
        println("\"$answer\" -> $text")
    }
    println("parseTop(\"two\").getOrElse { 3 } = ${parseTop("two").getOrElse { 3 }}") // like the tracker
    // try/catch still exists, and is an expression too.
    val n = try { "12abc".toInt() } catch (e: NumberFormatException) { -1 }
    println("try as a value: $n")
    bug(11)
}
