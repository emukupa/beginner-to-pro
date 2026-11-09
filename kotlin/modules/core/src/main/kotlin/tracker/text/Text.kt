// Python's text rules, as extension functions, shared by the parser, the chart and the program.
package tracker.text

// Exactly what Python's str.split() and str.strip() treat as space. private: this file only.
private const val SPACE = "\\t\\n\\u000B\\u000C\\r\\u001C\\u001D\\u001E\\u001F \\u0085\\u00A0\\u1680\\u2000-\\u200A\\u2028\\u2029\\u202F\\u205F\\u3000"
private val EDGE_SPACE = Regex("^[$SPACE]+|[$SPACE]+$")
private val RUN_OF_SPACE = Regex("[$SPACE]+")

fun String.pythonStrip(): String = replace(EDGE_SPACE, "")

fun String.pythonWords(): List<String> = pythonStrip().let { if (it.isEmpty()) emptyList() else it.split(RUN_OF_SPACE) }

// Width in code points, as Python's len() counts.
val String.width: Int get() = codePointCount(0, length)
