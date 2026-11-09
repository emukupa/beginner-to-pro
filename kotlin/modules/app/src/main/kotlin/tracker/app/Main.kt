// The program: the only file that reads input, prints to the screen or exits. Everything else comes
// from the core module.
package tracker.app

import java.io.ByteArrayOutputStream
import java.io.FileDescriptor
import java.io.FileOutputStream
import java.io.IOException
import java.io.PrintStream
import java.nio.file.NoSuchFileException
import java.nio.file.Path
import kotlin.system.exitProcess
import tracker.chart.drawChart
import tracker.models.UrgentTask
import tracker.parsing.TAG_MARKER
import tracker.storage.appendTitles
import tracker.storage.loadTasks
import tracker.storage.markDone
import tracker.tasklist.DEFAULT_TOP
import tracker.tasklist.addTasks
import tracker.tasklist.findTask
import tracker.tasklist.summarize
import tracker.tasklist.topTags
import tracker.text.pythonStrip

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

// tracker done "title": marks one task finished. Returns the exit code.
fun done(words: List<String>): Int {
    val title = words.joinToString(" ").pythonStrip()
    if (title.isEmpty()) {
        System.err.println("Usage: done \"task title\"")
        return 2
    }
    val path = Path.of(System.getenv("TASKS_FILE") ?: "tasks.txt")
    val tasks = try {
        loadTasks(path)
    } catch (e: NoSuchFileException) {
        System.err.println("Couldn't find $path")
        return 1
    } catch (e: IOException) {
        System.err.println("Couldn't read $path")
        return 1
    }
    // ?: with return: if findTask gives null, leave right here. After it, task can't be null.
    val task = findTask(tasks, title) ?: run {
        System.err.println("No task called \"$title\"")
        return 1
    }
    if (task.isDone) {
        println("Already done: ${task.title}")
        return 0
    }
    try {
        markDone(path, task)
    } catch (e: IOException) {
        System.err.println("Couldn't write $path")
        return 1
    }
    println("Done: ${task.title}")
    return 0
}

fun main(args: Array<String>) {
    System.setOut(PrintStream(FileOutputStream(FileDescriptor.out), true, Charsets.UTF_8))
    if (args.firstOrNull() == "done") exitProcess(done(args.drop(1))) // a second mode: tracker done "title"
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
    if (addTasks(tasks, newTitles) > 0) appendTitles(path, newTitles)

    val pairs = try {
        val answer = ask("How many top tags? [3]: ")
        topTags(tasks, if (answer.isEmpty()) DEFAULT_TOP else parseWholeNumber(answer) ?: 0)
    } catch (e: IllegalArgumentException) {
        println("Need a whole number of at least 1 — using 3.")
        topTags(tasks, DEFAULT_TOP)
    }

    val (total, done, percent, tagCount) = summarize(tasks)
    println("\n$total tasks, $done done ($percent%), $tagCount tags")
    tasks.filterIsInstance<UrgentTask>().filter { !it.isDone }.forEach(::println)

    println("\nTop tags")
    drawChart(pairs)
}
