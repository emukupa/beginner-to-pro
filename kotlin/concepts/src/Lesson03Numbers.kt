// Lesson 03: arithmetic, integer division, overflow, rounding, and turning text into a number.
// Kotlin never converts one number type into another by itself, not even Int into the bigger Long:
// you say so with toLong(), toDouble(), toInt().
// bug03: an Int where a Long is expected. Java would widen it quietly; Kotlin won't build.
package concepts.lesson03

import concepts.bug
import kotlin.math.roundToInt

const val TITLE = "Numbers"

/** Python's round(): halves go to the even neighbour, so 2.5 -> 2 and 3.5 -> 4. Lesson 06 uses it. */
fun roundHalfEven(x: Double): Int = Math.rint(x).toInt() // Math.rint: Java's, called directly

fun run() {
    println("7 / 2 = ${7 / 2}, 7 % 2 = ${7 % 2}, 7.0 / 2 = ${7.0 / 2}") // Int / Int drops the rest
    println("-7 / 2 = ${-7 / 2} (towards zero), Math.floorDiv(-7, 2) = ${Math.floorDiv(-7, 2)}")
    println("0.1 + 0.2 = ${0.1 + 0.2}") // binary fractions: close, not exact
    // The tracker rounds halves to even, like Python. roundToInt() sends halves up.
    println("2.5.roundToInt() = ${2.5.roundToInt()}, roundHalfEven(2.5) = ${roundHalfEven(2.5)}")
    println("3.5.roundToInt() = ${3.5.roundToInt()}, roundHalfEven(3.5) = ${roundHalfEven(3.5)}")
    // So does "%.0f": it's Java's formatter, which rounds halves up. Python's f"{12.5:.0f}" is "12".
    println("\"%.0f\".format(12.5) = ${"%.0f".format(12.5)}, roundHalfEven(12.5) = ${roundHalfEven(12.5)}")
    // An Int that overflows wraps round without a word, as in Java. Math.addExact refuses instead.
    println("Int.MAX_VALUE + 1 = ${Int.MAX_VALUE + 1}")
    val sum = runCatching { Math.addExact(Int.MAX_VALUE, 1) } // runCatching: lesson 12
    println("Math.addExact(Int.MAX_VALUE, 1) -> ${sum.exceptionOrNull()?.message}")
    // Conversions are always spelled out.
    val count = 2
    val total = 3
    println("count.toDouble() / total = ${count.toDouble() / total}, count / total = ${count / total}")
    // Text to number: toInt() throws on bad text; toIntOrNull() gives null (lesson 07) instead.
    for (text in listOf("5", "five", " 3 ", "-3")) {
        println("\"$text\".toIntOrNull() = ${text.toIntOrNull()}, after trim = ${text.trim().toIntOrNull()}")
    }
    bug(3)
}
