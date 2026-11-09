// Lesson 06: functions. Parameters have types and can have defaults; callers can name arguments,
// so one function covers what Java would need several overloads for. A function whose body is one
// expression can be written with `=`. Lambdas are functions as values, and the last lambda argument
// can sit outside the brackets: `tasks.filter { it.isDone }`.
// bug06: calling percent with one argument when it needs two. The compiler names the missing one.
package concepts.lesson06

import concepts.bug
import concepts.lesson03.roundHalfEven

const val TITLE = "Functions and lambdas"

// internal: visible to every file in this module (everything kotlinc builds together), and to nothing
// outside it. The tracker's chart is 20 blocks wide.
internal const val CHART_WIDTH = 20

/** done out of total, as a percentage; 0 when there are no tasks, like the tracker. Lesson 14 uses it. */
fun percent(done: Int, total: Int): Double = if (total == 0) 0.0 else done.toDouble() / total * 100

/** A bar of `char` for `count`, scaled so `biggest` is `width` long. Halves round to even. Lesson 14 uses it. */
fun bar(count: Int, biggest: Int, width: Int = CHART_WIDTH, char: String = "█"): String =
    char.repeat(roundHalfEven(count.toDouble() / biggest * width))

/** vararg: any number of titles, which arrive as an Array. Like Python's *titles. */
fun countTitles(vararg titles: String): Int = titles.count { it.isNotBlank() }

/** A function that returns a function. The lambda remembers `marker` after makeTagTest returns. */
fun makeTagTest(marker: Char): (String) -> Boolean = { word -> word.startsWith(marker) }

fun run() {
    println("percent(3, 6) = ${percent(3, 6)}, percent(0, 0) = ${percent(0, 0)}")
    println("bar(2, 3) = ${bar(2, 3)}") // width and char take their defaults
    println("bar(1, 2, width = 5) = ${bar(1, 2, width = 5)}: 2.5 blocks round to 2")
    println("bar(3, 3, char = \"#\", width = 4) = ${bar(3, 3, char = "#", width = 4)}") // named: any order
    println("countTitles(\"Call mom\", \" \", \"Book flights\") = ${countTitles("Call mom", " ", "Book flights")}")
    val isTag = makeTagTest('#')
    val words = listOf("Call", "mom", "#family")
    println("words that are tags: ${words.filter(isTag)}") // pass the function itself
    println("upper-cased with a lambda: ${words.map { it.uppercase() }}") // `it`: the one parameter
    val longest = words.maxByOrNull { word -> word.length } // or name the parameter yourself
    println("longest word: $longest")
    val twice: (Int) -> Int = { it * 2 } // the type of a function: Int in, Int out
    println("twice(21) = ${twice(21)}, chart width = $CHART_WIDTH")
    bug(6)
}
