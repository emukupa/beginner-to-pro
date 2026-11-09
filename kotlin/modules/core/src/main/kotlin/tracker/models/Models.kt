// What a task is. Every other package uses these; this one uses none of ours.
package tracker.models

open class Task(val title: String, val status: String, val tags: List<String>) {
    val isDone: Boolean get() = status == "done"

    override fun toString() = "[${if (isDone) "x" else " "}] $title"
}

class UrgentTask(title: String, status: String, tags: List<String>) : Task(title, status, tags) {
    override fun toString() = super.toString() + "  !!"
}

data class TagCount(val tag: String, val count: Int)

// The statuses a command can set. A task read from the file keeps whatever word it had, as a string.
enum class Status {
    TODO,
    DONE;

    // How it's spelled between the brackets. `when` used as a value must cover every constant: add
    // one to the enum and the build stops here.
    val word: String
        get() = when (this) {
            TODO -> "todo"
            DONE -> "done"
        }
}
