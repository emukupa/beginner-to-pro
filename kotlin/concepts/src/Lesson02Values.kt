// Lesson 02: `val` names a value that never changes; `var` names one that can. Prefer val: most
// names in the tracker never change, and the compiler then guarantees they don't. Every value has a
// type, which kotlinc usually works out by itself (type inference), and writing it down is optional.
// bug02: assigning to a val. The compiler refuses to build.
package concepts.lesson02

import concepts.bug

const val TITLE = "Values and types"

const val DEFAULT_TOP = 3 // const val: a value fixed when the program is compiled

fun run() {
    val title = "Call mom" // String, worked out from the value
    var done = 0 // Int; var, because it changes below
    done += 1
    val share: Double = 0.5 // or say the type yourself
    val urgent = false // Boolean
    val mark = 'x' // Char: one character, in single quotes
    val big = 3_000_000_000L // Long: an Int stops at about 2.1 billion
    println("title=$title done=$done share=$share urgent=$urgent mark=$mark big=$big")
    // These look like Java's int and double, and compile to them, but they're objects you can call
    // methods on. ::class asks a value what it is.
    println("types: ${title::class.simpleName}, ${done::class.simpleName}, ${share::class.simpleName}, ${big::class.simpleName}")
    println("Int goes up to ${Int.MAX_VALUE}, Long to ${Long.MAX_VALUE}")
    println("default top: $DEFAULT_TOP")
    // A Pair holds two values; destructuring takes them apart again.
    val pair = "work" to 3
    val (tag, count) = pair
    println("pair = $pair, tag = $tag, count = $count")
    // == compares values (it calls equals); === asks "the very same object?"
    val a = "do" + "ne"
    println("a == \"done\": ${a == "done"}")
    bug(2)
}
