// Lesson 13's mistake: a when that forgets one member of the sealed family. With an enum or a
// sealed interface the compiler knows the full list, so it can name what's missing.
package concepts.lesson13

fun bug() {
    val command = parseCommand("#work")
    val text = when (command) {
        is Command.Add -> "added ${command.title}"
        Command.Finish -> "done adding"
    }
    println(text)
}
