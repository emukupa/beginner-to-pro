// Lesson 06's mistake: forgetting an argument. percent(done, total) has no default for total.
package concepts.lesson06

fun bug() {
    println(percent(3))
}
