// Lesson 13: a sealed interface is a closed family: every type that implements it is in this file,
// so the compiler knows the full list. Unlike an enum's values, each member can carry its own data.
// A `when` over it then needs no else, and adding a new member breaks every `when` that forgot it,
// which is what you want. The tracker reads what the user types as one of these commands.
// bug13: a when that forgets the TagsOnly command. The compiler names the missing branch.
package concepts.lesson13

import concepts.bug

const val TITLE = "Sealed interfaces and when"

sealed interface Command {
    data class Add(val title: String) : Command // carries the title
    data class TagsOnly(val text: String) : Command // "#work" alone: a task needs a title
    data object Finish : Command // Enter on an empty line. One object, no data: data object
}

/** What one answer to "New task (Enter to finish): " means, like the tracker's input loop. */
fun parseCommand(answer: String): Command {
    val text = answer.trim()
    return when {
        text.isEmpty() -> Command.Finish
        text.startsWith("#") -> Command.TagsOnly(text)
        else -> Command.Add(text)
    }
}

/** What the tracker does with each command. Exhaustive: every member of Command, no else. */
fun reply(command: Command): String = when (command) {
    is Command.Add -> "added \"${command.title}\"" // smart cast: command is an Add here
    is Command.TagsOnly -> "A task needs a title, not just tags."
    Command.Finish -> "done adding"
}

fun run() {
    val answers = listOf("Water the plants #home", "#work", "  ", "Call the bank")
    val added = mutableListOf<String>()
    for (answer in answers) {
        val command = parseCommand(answer)
        println("${"\"$answer\"".padEnd(26)} -> $command: ${reply(command)}")
        if (command is Command.Add) added.add(command.title)
        if (command == Command.Finish) break // the tracker stops asking here
    }
    println("added before Finish: $added")
    // A data class compares by value, so the same answer twice gives equal commands.
    println("parseCommand(\"#work\") == TagsOnly(\"#work\"): ${parseCommand("#work") == Command.TagsOnly("#work")}")
    bug(13)
}
