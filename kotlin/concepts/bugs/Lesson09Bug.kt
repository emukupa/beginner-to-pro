// Lesson 09's mistake: reaching for a private helper from another file. Same package or not,
// private at the top of Lesson09DataClasses.kt means that file only. Call parseLine instead.
package concepts.lesson09

fun bug() {
    println(splitWords("Call mom #family"))
}
