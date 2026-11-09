// Lesson 05's mistake: a when that gives a value but forgets most numbers. Add an else branch.
package concepts.lesson05

fun bug() {
    val left = 7
    val word = when (left) {
        0 -> "nothing left"
        1, 2 -> "nearly there"
    }
    println(word)
}
