// Kotlin concepts, one lesson per file. Each lesson is its own package (concepts.lesson07) with a
// TITLE and a run(); a later lesson imports what an earlier one built, like any other library.
// Everything here is compiled together by one kotlinc call, so it is one *module*: `internal`
// means "visible anywhere in this module", and `private` at the top of a file means "this file only".
//
//   make run            build if needed, then every lesson, in order
//   make run N=7        just lesson 7 (or: java -jar build/concepts.jar 4 7)
//   make bug N=7        lesson 7 with its deliberate mistake (bugs/Lesson07Bug.kt) compiled in
//   make test           the tests in test/, written with kotlin.test
package concepts

import java.lang.reflect.InvocationTargetException
import kotlin.system.exitProcess

// The table of lessons: a title and the function to run. `{ ... }` is a lambda, a function as a value.
val lessons: List<Pair<String, () -> Unit>> = listOf(
    concepts.lesson01.TITLE to { concepts.lesson01.run() },
    concepts.lesson02.TITLE to { concepts.lesson02.run() },
    concepts.lesson03.TITLE to { concepts.lesson03.run() },
    concepts.lesson04.TITLE to { concepts.lesson04.run() },
    concepts.lesson05.TITLE to { concepts.lesson05.run() },
    concepts.lesson06.TITLE to { concepts.lesson06.run() },
    concepts.lesson07.TITLE to { concepts.lesson07.run() },
    concepts.lesson08.TITLE to { concepts.lesson08.run() },
    concepts.lesson09.TITLE to { concepts.lesson09.run() },
    concepts.lesson10.TITLE to { concepts.lesson10.run() },
    concepts.lesson11.TITLE to { concepts.lesson11.run() },
    concepts.lesson12.TITLE to { concepts.lesson12.run() },
    concepts.lesson13.TITLE to { concepts.lesson13.run() },
    concepts.lesson14.TITLE to { concepts.lesson14.run() },
)

// The mistakes live in bugs/LessonNNBug.kt, which the normal build leaves out. Most of them never
// build: kotlinc refuses. The ones that do build define a `bug()` function, and kotlinc turns that
// file into a class named concepts.lessonNN.LessonNNBugKt. This looks the class up by name: if it
// isn't in this build, there is no bug to run and nothing happens.
fun bug(lesson: Int) {
    val name = "concepts.lesson%02d.Lesson%02dBugKt".format(lesson, lesson)
    val mistake = runCatching { Class.forName(name).getMethod("bug") }.getOrNull() ?: return
    println("-- bug %02d compiled in --".format(lesson))
    try {
        mistake.invoke(null)
    } catch (e: InvocationTargetException) {
        throw e.cause ?: e // show the bug's own exception, not the wrapper reflection adds
    }
}

fun run(number: Int) {
    val (title, lesson) = lessons[number - 1] // a Pair splits into its two halves
    println("\n=== %02d %s ===".format(number, title))
    lesson()
}

fun main(args: Array<String>) {
    if (args.isEmpty()) {
        for (number in 1..lessons.size) run(number)
        return
    }
    for (arg in args) {
        val number = arg.toIntOrNull() // null instead of an exception when it isn't a number
        if (number == null || number !in 1..lessons.size) {
            System.err.println("No lesson $arg (there are ${lessons.size})")
            exitProcess(1)
        }
        run(number)
    }
}
