// Lesson 07's mistake: treating a String? as a String. tagOf("mom") is null; Java would crash at
// run time. Write tag?.length, or tag?.length ?: 0.
package concepts.lesson07

fun bug() {
    val tag = tagOf("mom")
    println(tag.length)
}
