// The tasks file: the only package that opens files.
package tracker.storage

import java.nio.channels.FileChannel
import java.nio.file.Files
import java.nio.file.Path
import java.nio.file.StandardCopyOption
import java.nio.file.StandardOpenOption
import kotlin.io.path.appendText
import kotlin.io.path.getPosixFilePermissions
import kotlin.io.path.readText
import kotlin.io.path.setPosixFilePermissions
import tracker.models.Status
import tracker.models.Task
import tracker.parsing.parseLine

// Every task in the file; lines that aren't tasks are skipped. Lines end at \n, \r\n or \r.
fun loadTasks(path: Path): MutableList<Task> =
    path.readText().split(Regex("\r\n|\r|\n")).mapNotNull(::parseLine).toMutableList()

// "[todo] title" lines on the end of the file.
fun appendTitles(path: Path, titles: List<String>) = path.appendText(titles.joinToString("") { "[todo] $it\n" })

// True if this line holds the task: the same title and status after parsing.
private fun holds(line: String, task: Task): Boolean =
    parseLine(line)?.let { it.title == task.title && it.status == task.status } ?: false

// Rewrites the line holding this task as [status], leaving every other byte of the file alone.
fun setStatus(path: Path, task: Task, status: Status) {
    // Each line keeps its own ending (\n, \r\n or \r), as Python's readlines() does with newline="".
    val lines = Regex("[^\r\n]*(?:\r\n|\r|\n)|[^\r\n]+$").findAll(path.readText()).map { it.value }.toMutableList()
    val at = lines.indexOfFirst { holds(it, task) }
    if (at >= 0) {
        val line = lines[at]
        val open = line.indexOf('[')
        val close = line.indexOf(']', open)
        lines[at] = line.substring(0, open) + "[${status.word}]" + line.substring(close + 1)
    }

    // use {} closes the TempFile when the block ends, however it ends. It isn't a keyword: it's an
    // inline function the standard library defines on anything AutoCloseable.
    TempFile(path).use { temp ->
        temp.path.setPosixFilePermissions(path.getPosixFilePermissions()) // keep the old file's
        temp.channel.write(java.nio.ByteBuffer.wrap(lines.joinToString("").toByteArray()))
        temp.replace(path)
    }
}

// A new file beside another, deleted when it's closed unless it replaced the other.
private class TempFile(beside: Path) : AutoCloseable {
    // createTempFile picks a random name and refuses to reuse a file that's already there.
    val path: Path = Files.createTempFile(beside.toAbsolutePath().parent, "${beside.fileName}.", "")
    val channel: FileChannel = FileChannel.open(path, StandardOpenOption.WRITE)
    private var kept = false

    // On the disk first, then moved over the target: readers see the old file or the new one.
    fun replace(target: Path) {
        channel.force(true)
        channel.close()
        Files.move(path, target, StandardCopyOption.ATOMIC_MOVE, StandardCopyOption.REPLACE_EXISTING)
        kept = true
    }

    override fun close() {
        channel.close()
        if (!kept) Files.deleteIfExists(path) // never leave the half-made file behind
    }
}
