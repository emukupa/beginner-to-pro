// Lesson 07: null safety. A String can never be null; a String? can. The compiler won't let you
// call a method on a String? until you've dealt with the null: `?.` (skip it if null), `?:` (use
// this instead), an `if (x != null)` check (after which x is a plain String: a smart cast), or `!!`
// ("I promise it isn't", which throws a NullPointerException when you're wrong). Java's
// NullPointerException at run time becomes a compile error here.
// bug07: calling .length on a String?. The compiler refuses until you handle the null.
package concepts.lesson07

import concepts.bug
import concepts.lesson04.pythonStrip

const val TITLE = "Null safety"

/** "#Work." -> "work"; a word that isn't a tag -> null. Like the tracker, "#" alone gives "". Lesson 09 uses it. */
fun tagOf(word: String, marker: Char = '#'): String? {
    if (!word.startsWith(marker)) return null
    return word.trimStart(marker).pythonStrip(".,").lowercase()
}

fun run() {
    for (word in listOf("#Work.", "#home", "mom")) {
        val tag: String? = tagOf(word)
        println("tagOf(\"$word\") = ${tag?.let { "\"$it\"" } ?: "null"}")
    }
    val tag = tagOf("mom")
    println("tag?.length = ${tag?.length}") // ?. gives null instead of calling on null
    println("tag ?: \"untagged\" = ${tag ?: "untagged"}") // ?: (the Elvis operator): a fallback
    val home = tagOf("#Home")
    if (home != null) {
        println("inside the check, home is a plain String: ${home.uppercase()}") // smart cast
    }
    // let runs a block only when the value isn't null, with the value as `it`.
    tagOf("#travel")?.let { println("let: got tag $it") }
    // Kotlin's standard library returns null where Java would throw.
    println("listOf<String>().firstOrNull() = ${listOf<String>().firstOrNull()}, \"x\".toIntOrNull() = ${"x".toIntOrNull()}")
    println("mapNotNull keeps the tags and drops the nulls: ${"Call mom #family #Home.".split(" ").mapNotNull { tagOf(it) }}")
    // !! turns a String? into a String by force. It's the one place a null can still crash you,
    // so the tracker never uses it on anything that came from the file or the user (see lesson 11's bug).
    val sure = tagOf("#work")!!
    println("!! on a value that's there: $sure")
    // The other way round, `sure?.length` or `sure!!` on a plain String is pointless, and kotlinc
    // warns about it. The build uses -Werror, so even that warning stops it.
    bug(7)
}
