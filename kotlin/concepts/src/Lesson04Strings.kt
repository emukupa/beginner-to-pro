// Lesson 04: a String can't be changed; every "change" makes a new one. And you can add your own
// methods to String (or any type) with an extension function: `fun String.cleanStatus()`. It's an
// ordinary function that gets the string as `this`, but it reads like one of String's own.
// bug04: assigning to title[0]. Strings are read-only, so the compiler refuses.
package concepts.lesson04

import concepts.bug

const val TITLE = "Strings and extension functions"

/** Python's strip(chars): drop any of these characters from both ends. Python's default is whitespace. */
fun String.pythonStrip(chars: String? = null): String =
    if (chars == null) trim() else trim { it in chars }

/** Python's split() with no argument: split on runs of whitespace, and never give empty words. */
fun String.pythonSplit(): List<String> = trim().split(Regex("\\s+")).filter { it.isNotEmpty() }

/** "[ DONE. ]" -> "done". Lesson 08's Status.parse uses it on every status in the file. */
fun String.cleanStatus(): String = pythonStrip("[] .").lowercase()

/** How wide the text is on screen: code points, not Java's UTF-16 chars. Lesson 14 pads by it. */
val String.width: Int get() = codePointCount(0, length) // an extension property

/** Pad on the right to `width` columns, like Python's f"{text:<{width}}". */
fun String.padTo(width: Int): String = this + " ".repeat(maxOf(0, width - this.width))

fun run() {
    val line = "[done.] Call mom #family"
    println("line = \"$line\"")
    println("substringBefore(\"]\") = \"${line.substringBefore("]")}\"")
    println("substringAfter(\"]\") = \"${line.substringAfter("]")}\"")
    println("pythonSplit() = ${line.substringAfter("]").pythonSplit()}")
    for (messy in listOf("[done]", "[done.]", "[DONE]", "[ todo ]")) {
        println("${"\"$messy\"".padTo(11)}.cleanStatus() = \"${messy.cleanStatus()}\"")
    }
    println("\"done\" == \"done.\" -> ${"done" == "done."}")
    println("startsWith('#'): ${"#work".startsWith('#')}, trimStart('#'): ${"##work".trimStart('#')}")
    // length counts UTF-16 chars, Java's unit. █ is one; an emoji is two. Code points count what you see.
    for (text in listOf("█", "café", "🚀")) {
        println("\"$text\".length = ${text.length}, width = ${text.width}, UTF-8 bytes = ${text.toByteArray().size}")
    }
    println("aligned: |${"café".padTo(8)}|${"work".padStart(8)}|")
    println("repeated: ${"█".repeat(5)}")
    // A raw string: no escapes, and trimIndent removes the shared indentation.
    val sample = """
        [todo] Book flights #travel
        [done] Buy groceries #home
    """.trimIndent()
    println("raw string has ${sample.lines().size} lines; the first: ${sample.lines().first()}")
    val title = "fix login bug"
    println("first char = ${title[0]}, capitalised: ${title.replaceFirstChar { it.uppercase() }}")
    bug(4)
}
