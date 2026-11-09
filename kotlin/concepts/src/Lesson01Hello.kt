// Lesson 01: a Kotlin program starts at `fun main` (ours is in Main.kt; each lesson is a `run`).
// No class to wrap it in, no `public static void`, no semicolons: the same JVM as Java, with the
// ceremony taken away. `println` prints a line; "$name" and "${expression}" fill text in.
// bug01: a misspelt function name. The compiler checks every name before anything runs.
package concepts.lesson01

import concepts.bug

const val TITLE = "Hello"

fun run() {
    println("Hello, tasks!")
    val count = 6
    println("$count tasks in the file") // $name puts a variable's value into the text
    println("${count / 2} of $count done") // ${...} for anything longer than a name
    print("print adds no newline, ")
    println("so this ends the same line")
    System.err.println("System.err is for errors (Java's own, still in reach)")
    // main can end the program with exitProcess(1) to say it failed; 0 (the default) means it worked.
    bug(1)
}
