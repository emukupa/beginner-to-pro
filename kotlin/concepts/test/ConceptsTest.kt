// Tests for the pieces the tracker reuses, written with kotlin.test (its assertEquals, assertNull,
// assertIs, ...). kotlin-test.jar ships with kotlinc, so nothing is downloaded. Its @Test annotation
// needs a test framework such as JUnit, which kotlinc doesn't ship, so a tiny runner below calls
// each test instead: a name and a lambda, run in order, counting failures.
//   make test
package concepts.tests

import concepts.lesson03.roundHalfEven
import concepts.lesson04.cleanStatus
import concepts.lesson04.pythonSplit
import concepts.lesson04.width
import concepts.lesson06.bar
import concepts.lesson06.percent
import concepts.lesson07.tagOf
import concepts.lesson08.Status
import concepts.lesson09.TagCount
import concepts.lesson09.TaskLine
import concepts.lesson09.parseLine
import concepts.lesson10.UrgentTask
import concepts.lesson10.parseTask
import concepts.lesson11.loadTasks
import concepts.lesson11.parseTop
import concepts.lesson12.countTags
import concepts.lesson13.Command
import concepts.lesson13.parseCommand
import concepts.lesson14.only
import concepts.lesson14.topN
import java.io.FileNotFoundException
import kotlin.system.exitProcess
import kotlin.test.assertEquals
import kotlin.test.assertIs
import kotlin.test.assertNull
import kotlin.test.assertTrue

val tests: List<Pair<String, () -> Unit>> = listOf(
    "halves round to even, like Python" to {
        assertEquals(listOf(0, 2, 4, 12), listOf(0.5, 2.5, 3.5, 12.5).map(::roundHalfEven))
    },
    "messy statuses clean up" to {
        assertEquals(listOf("done", "done", "done", "todo"), listOf("[done]", "[done.]", "[DONE]", "[ todo ]").map { it.cleanStatus() })
        assertEquals(listOf("a", "b"), "  a \t b ".pythonSplit())
        assertEquals(1, "█".width)
    },
    "percent and bar" to {
        assertEquals(50.0, percent(3, 6))
        assertEquals(0.0, percent(0, 0))
        assertEquals("██", bar(1, 2, width = 5)) // 2.5 rounds to 2
        assertEquals(13, bar(2, 3).length)
    },
    "tags and statuses" to {
        assertEquals("work", tagOf("#Work."))
        assertNull(tagOf("work"))
        assertEquals(Status.DONE, Status.parse("[DONE]"))
        assertEquals(Status.OTHER, Status.parse("[later]"))
    },
    "a line parses into a TaskLine, or null" to {
        assertEquals(TaskLine("Review pull request", Status.TODO, listOf("work")), parseLine("[ todo ] Review pull request #work."))
        assertNull(parseLine("buy milk"))
        assertNull(parseLine(""))
    },
    "urgent lines become UrgentTasks" to {
        val task = parseTask("[todo] Finish quarterly report #work #urgent")
        assertIs<UrgentTask>(task)
        assertEquals("[ ] Finish quarterly report  !!", task.toString())
    },
    "loading the file, or saying why not" to {
        assertEquals(6, loadTasks("tasks.txt").getOrThrow().size)
        assertIs<FileNotFoundException>(loadTasks("missing.txt").exceptionOrNull())
    },
    "the top-tags answer" to {
        assertEquals(3, parseTop("").getOrThrow())
        assertEquals(2, parseTop(" 2 ").getOrThrow())
        assertTrue(parseTop("two").isFailure)
        assertTrue(parseTop("0").isFailure)
    },
    "commands" to {
        assertEquals(Command.Finish, parseCommand("  "))
        assertEquals(Command.TagsOnly("#work"), parseCommand("#work"))
        assertEquals(Command.Add("Call the bank"), parseCommand(" Call the bank "))
    },
    "counts keep first-seen order, and ties stay in it" to {
        val tasks = loadTasks("tasks.txt").getOrThrow()
        val ranked = topN(countTags(tasks), 10) { it.count }
        assertEquals(listOf("work", "home", "urgent", "family", "travel"), ranked.map { it.tag })
        assertEquals(TagCount("work", 3), ranked.first())
        assertEquals(1, tasks.only<UrgentTask>().size)
    },
)

fun main() {
    var failed = 0
    for ((name, test) in tests) {
        try {
            test()
            println("ok    $name")
        } catch (e: AssertionError) {
            failed++
            println("FAIL  $name: ${e.message}")
        }
    }
    println("${tests.size - failed} passed, $failed failed")
    if (failed > 0) exitProcess(1)
}
