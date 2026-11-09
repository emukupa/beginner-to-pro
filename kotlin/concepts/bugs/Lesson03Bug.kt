// Lesson 03's mistake: an Int stored where a Long belongs. The fix says it out loud: count.toLong().
package concepts.lesson03

fun bug() {
    val count = 6
    val bytes: Long = count
    println(bytes)
}
