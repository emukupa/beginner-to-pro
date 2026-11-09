// Lesson 04's mistake: changing a letter in place. Strings never change; make a new one instead,
// with replaceFirstChar { it.uppercase() }.
package concepts.lesson04

fun bug() {
    val title = "fix login bug"
    title[0] = 'F'
    println(title)
}
