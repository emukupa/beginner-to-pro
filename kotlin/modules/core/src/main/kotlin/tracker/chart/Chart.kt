// The bar chart. It writes through the function it's given: println in the program, a list in a test.
package tracker.chart

import kotlin.math.round
import tracker.models.TagCount
import tracker.text.width

const val CHART_WIDTH = 20 // the longest bar, in characters

fun drawChart(pairs: List<TagCount>, width: Int = CHART_WIDTH, print: (String) -> Unit = ::println) {
    val first = pairs.firstOrNull() ?: return print("No tags yet.")
    val labelWidth = pairs.maxOf { it.tag.width }
    for ((tag, count) in pairs) {
        val blocks = round(count.toDouble() / first.count * width).toInt() // halves to even, like Python
        print("$tag${" ".repeat(labelWidth - tag.width)}  ${"█".repeat(blocks)} $count")
    }
}
