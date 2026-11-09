// Lesson 02's mistake: changing a val. A val is assigned once; to change it, make it a var.
package concepts.lesson02

fun bug() {
    val done = 0
    done = 1
    println(done)
}
