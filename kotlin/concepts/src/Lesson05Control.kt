// Lesson 05: decisions and loops. `if` and `when` are expressions: they produce a value, so there's
// no ?: operator to learn. `when` replaces switch, with ranges, several values per branch, and no
// fall-through. `for` walks anything with values in it: a range, a list, a string.
// bug05: a `when` used as a value with no else branch. Some numbers would have no answer, so it
// won't build.
package concepts.lesson05

import concepts.bug

const val TITLE = "Decisions and loops"

/** A word for how many tasks are left. */
fun describe(left: Int): String = when (left) {
    0 -> "nothing left"
    1, 2 -> "nearly there" // several values, one branch
    in 3..9 -> "a few left" // a range
    else -> "a long list" // a when that gives a value must cover every Int
}

fun run() {
    val done = 3
    val total = 6
    val verdict = if (done * 2 >= total) "at least half done" else "under half done" // if is a value
    println(verdict)
    for (left in listOf(0, 2, 5, 12)) println("$left left: ${describe(left)}")
    // when with no subject: the first true condition wins, like a chain of if / else if
    val line = "[todo] Book flights"
    val kind = when {
        line.isBlank() -> "blank"
        !line.startsWith("[") -> "not a task"
        else -> "a task line"
    }
    println("\"$line\" is $kind")
    print("1..3:")
    for (i in 1..3) print(" $i") // .. includes the end
    print("; 0 until 3:")
    for (i in 0 until 3) print(" $i") // until leaves it out, for indexes
    print("; 10 downTo 0 step 5:")
    for (i in 10 downTo 0 step 5) print(" $i")
    println()
    var n = 1
    while (n < 100) n *= 3
    println("first power of 3 past 100: $n")
    // A label names a loop, so break can leave the outer one from inside the inner one.
    val grid = listOf(listOf("home", "work"), listOf("urgent", "family"))
    outer@ for (row in grid) {
        for (tag in row) {
            if (tag == "urgent") {
                println("found urgent, leaving both loops")
                break@outer
            }
        }
    }
    bug(5)
}
