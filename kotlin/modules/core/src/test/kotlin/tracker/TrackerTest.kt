// Tests beside the code, in the same module, so they can call internal functions too.
package tracker

import kotlin.test.Test
import kotlin.test.assertEquals
import kotlin.test.assertFailsWith
import kotlin.test.assertIs
import kotlin.test.assertNull
import tracker.chart.drawChart
import tracker.models.TagCount
import tracker.models.UrgentTask
import tracker.parsing.parseLine
import tracker.parsing.statusOf
import tracker.tasklist.summarize
import tracker.tasklist.topTags

class TrackerTest {
    private fun load(vararg lines: String) = lines.mapNotNull(::parseLine)

    @Test
    fun readsStatusTitleAndTags() {
        val task = assertIs<UrgentTask>(parseLine("[DONE.] Call mom #Family #urgent,"))
        assertEquals("done", task.status)
        assertEquals("Call mom", task.title)
        assertEquals(listOf("family", "urgent"), task.tags)
    }

    @Test
    fun keepsAnUnknownStatus() = assertEquals("later", statusOf("[ later ]"))

    @Test
    fun aLineWithoutABracketIsNotATask() = assertNull(parseLine("Buy milk #home"))

    @Test
    fun tiesKeepFirstSeenOrder() {
        val tasks = load("[todo] a #work #home", "[todo] b #home #work", "[todo] c #play")
        assertEquals(listOf("work", "home", "play"), topTags(tasks, 3).map { it.tag })
    }

    @Test
    fun zeroIsRefused() {
        assertFailsWith<IllegalArgumentException> { topTags(emptyList(), 0) }
    }

    @Test
    fun halvesRoundToEven() {
        val tasks = load("[done] a", *Array(7) { "[todo] t$it" })
        assertEquals(12, summarize(tasks).percent) // 12.5 -> 12, like Python's round()
    }

    @Test
    fun chartDrawsIntoAList() {
        val lines = mutableListOf<String>()
        drawChart(listOf(TagCount("home", 2), TagCount("work", 1)), width = 4) { lines += it }
        assertEquals(listOf("home  ████ 2", "work  ██ 1"), lines)
    }
}
