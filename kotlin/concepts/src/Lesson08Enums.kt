// Lesson 08: an enum class is a fixed set of values. Each value is an object, so it can carry
// properties (`mark`) and methods (`isDone`), and the class can have a companion object: one shared
// object for functions that belong to the type rather than to one value, like Java's static.
// A `when` on an enum can cover every value with no else, and the compiler checks it does.
// bug08: comparing a Status with the text "done". They can never be equal, so the compiler refuses.
package concepts.lesson08

import concepts.bug
import concepts.lesson04.cleanStatus

const val TITLE = "Enums"

enum class Status(val mark: Char) {
    TODO(' '),
    DONE('x'),
    OTHER(' '); // a status the tracker doesn't know, like "later". The ; ends the list of values

    val isDone: Boolean get() = this == DONE // a property computed each time it's read

    companion object {
        /** "[done.]" -> DONE, "[ todo ]" -> TODO, "[later]" -> OTHER. Lesson 09 uses it. */
        fun parse(text: String): Status =
            entries.firstOrNull { it.name.lowercase() == text.cleanStatus() } ?: OTHER
    }
}

fun describe(status: Status): String = when (status) {
    Status.TODO -> "still to do"
    Status.DONE -> "finished"
    Status.OTHER -> "a status the tracker doesn't know" // every value covered: no else needed
}

fun run() {
    for (text in listOf("[done.]", "[ todo ]", "[DONE]", "[later]")) {
        val status = Status.parse(text)
        println("${text.padEnd(9)} -> $status [${status.mark}] isDone=${status.isDone}: ${describe(status)}")
    }
    println("entries = ${Status.entries}") // every value, in the order they're written
    println("DONE.name = ${Status.DONE.name}, DONE.ordinal = ${Status.DONE.ordinal}")
    println("Status.valueOf(\"TODO\") = ${Status.valueOf("TODO")}") // exact name only, or it throws
    bug(8)
}
