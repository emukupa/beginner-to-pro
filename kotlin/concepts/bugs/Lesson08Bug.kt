// Lesson 08's mistake: comparing the enum with the file's text. A Status is never a String;
// compare with Status.DONE (or ask status.isDone).
package concepts.lesson08

fun bug() {
    val status = Status.parse("[done]")
    println(status == "done")
}
