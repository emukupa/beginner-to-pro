# Chapter 00 — Kotlin concepts

**Video:** Kotlin: Concepts (tag `video/kotlin-000`)

**Goal:** learn Kotlin before building anything with it. `kotlin/concepts/` holds one lesson per
file in `src/`. Each lesson is its own package (`package concepts.lesson07`) with a `TITLE` and a
`run()`, and imports what it borrows from earlier lessons (`import concepts.lesson04.cleanStatus`).
`Main.kt` keeps them all in a table of titles and lambdas.

Kotlin runs on Java's platform, so you've seen the object model already in the Java course:
classes, `extends`, interfaces, exceptions, the same standard library (`java.io.File`, `Math.rint`
are called directly). What Kotlin removes is the ceremony, and what it adds is checks. A `String`
can never be null, a `when` over an enum or a sealed interface must cover every case, classes are
final unless they say `open`, and an `override` must say so. Most of what would be a
`NullPointerException` or a forgotten case in Java becomes a compile error here.

So each lesson's mistake is a file of its own, `bugs/LessonNNBug.kt`, which the normal build
leaves out, like Go's build tags. `make bug N=7` compiles it in with the rest, and kotlinc refuses
to build. Two mistakes (a `!!` on null, an index past the end) build fine and fail when they run:
those files define a `bug()` that `Main.kt` finds by name and runs at the point in the lesson where
it belongs. Every build uses `-Werror`, so a warning fails it too.

Everything is built with plain `kotlinc`: no Gradle, nothing downloaded. `kotlin-test.jar` ships
with the compiler, so the tests use `kotlin.test`'s assertions; its `@Test` needs JUnit, which
doesn't, so `test/ConceptsTest.kt` has a ten-line runner of its own.

```bash
cd kotlin/concepts
make run             # build build/concepts.jar (6-12 s: kotlinc is a JVM program), then every lesson
make run N=7         # just lesson 7 (or: java -jar build/concepts.jar 4 7)
make bug N=7         # lesson 7 with bugs/Lesson07Bug.kt compiled in: watch kotlinc catch it
make test            # kotlin.test assertions on the pieces the tracker reuses
```

Lessons 11 to 14 read `tasks.txt`, a copy of `contract/tasks.txt`, from the current folder, so run
them from `kotlin/concepts/` (which `make` does).

## The lessons

| # | Lesson | Concepts | `make bug N=` shows | Caught by |
| --- | --- | --- | --- | --- |
| 01 | Hello | `fun main`, `println`/`print`, `"$name"` and `"${expr}"`, `System.err`, `exitProcess` | a misspelt `printn` | the compiler: unresolved reference |
| 02 | Values and types | `val` vs `var`, inference, `Int` `Long` `Double` `Boolean` `Char`, `const val`, `Pair` and destructuring, `==` vs `===` | assigning to a `val` | the compiler: `'val' cannot be reassigned` |
| 03 | Numbers | integer division, `%`, `floorDiv`, `0.1 + 0.2`, `roundToInt` vs `Math.rint`, Java's `"%.0f"` rounding halves up, silent overflow vs `Math.addExact`, `toIntOrNull` | an `Int` stored in a `Long` | the compiler: no implicit widening |
| 04 | Strings and extension functions | `substringBefore`/`After`, `trim { }`, `lowercase`, `String.pythonStrip()`, `pythonSplit()`, `cleanStatus()`, an extension property `width` (code points vs UTF-16 `length`), `padTo`, raw strings | `title[0] = 'F'` | the compiler: strings are read-only |
| 05 | Decisions and loops | `if` and `when` as values, `when` with ranges and no subject, `..` `until` `downTo` `step`, `while`, labelled `break@outer` | a `when` value with no `else` | the compiler: `'when' expression must be exhaustive` |
| 06 | Functions and lambdas | default and named arguments, `=` bodies, `vararg`, lambdas and `it`, function types, a function returning a closure, `internal`, `percent` and `bar` | `percent(3)`, an argument missing | the compiler: `no value passed for parameter 'total'` |
| 07 | Null safety | `String?`, `?.`, `?:`, smart casts, `let`, `mapNotNull`, `toIntOrNull`/`firstOrNull`, `!!` and why not, `tagOf` | `.length` on a `String?` | the compiler: only safe (`?.`) calls on a nullable |
| 08 | Enums | `enum class Status(val mark: Char)`, a computed property, `companion object`, `entries`, an exhaustive `when` with no `else`, `valueOf` | `status == "done"` | the compiler: `==` can't compare `Status` and `String` |
| 09 | Classes and data classes | primary constructors, `data class TaskLine` (`toString`, `==`, `copy`, destructuring), `data class TagCount`, read-only `List`, `partition`, a `private` helper, `parseLine` | calling the file-`private` `splitWords` | the compiler: `it is private in file` |
| 10 | Inheritance | `open class Task`, `UrgentTask : Task`, `override` (required) and `super`, `is` and smart casts, `as?`, `?: return`, `parseTask` | extending the data class `TaskLine` | the compiler: `this type is final` |
| 11 | Errors and files | no checked exceptions, `runCatching` and `Result` (`onSuccess`/`onFailure`/`getOrElse`), `require`, `use { }` on a reader, `lineSequence`, `try` as a value, `loadTasks`, `parseTop` | `!!` on a line the parser rejected | a `NullPointerException` at run time |
| 12 | Collections | read-only vs mutable, `mutableMapOf` is a `LinkedHashMap` (first-seen order), `getOrDefault`, `groupingBy { }.eachCount()`, `HashMap`'s lack of order, `flatMap`, `toSet`, `getOrNull`, `countTags` | `tasks[tasks.size]` | an `IndexOutOfBoundsException` at run time |
| 13 | Sealed interfaces and when | `sealed interface Command` with `data class Add`, `TagsOnly`, `data object Finish`; an exhaustive `when` with smart casts; `parseCommand` (the tracker's input loop) | a `when` that forgets `TagsOnly` | the compiler: names the missing `is TagsOnly` branch |
| 14 | Generics and the mini tracker | `fun <T> topN`, stable `sortedByDescending`, `inline fun <reified T : Task> List<Task>.only()`, `drawChart`, then load, count, rank and chart `tasks.txt` | ranking by `it.title` | the compiler: `return type mismatch: expected 'Int'` |

Pieces carry forward: lesson 03's `roundHalfEven` feeds lesson 06's `bar`; lesson 04's
`cleanStatus` feeds lesson 08's `Status.parse`, which with lesson 07's `tagOf` becomes lesson 09's
`parseLine`; lesson 10 turns its `TaskLine` into a `Task` or an `UrgentTask`, lesson 11's
`loadTasks` reads the file with it, and lesson 12's `countTags` counts the tags. Lesson 14 ranks
them with `topN` and prints the tracker's summary and tag chart, byte for byte what Python prints:

```text
6 tasks, 3 done (50%), 5 tags
[ ] Finish quarterly report  !!

Top tags
work    ████████████████████ 3
home    █████████████ 2
urgent  ███████ 1
```

## Choices the tracker doesn't make, and why

- **`data class Task`** would write `equals`, `copy` and `toString` for free, but data classes are final and `UrgentTask` must extend `Task`; `Task` is an `open class`, and the data classes are the plain values, `TaskLine` and `TagCount` (lessons 09, 10).
- **`roundToInt()` and `"%.0f"`** round halves up; the contract needs Python's halves-to-even, which is `Math.rint` (lesson 03).
- **`!!`** turns a null into a crash; it never touches anything from the file or the user, where `?:` and `?.let` say what to do instead (lessons 07, 11).
- **`hashMapOf()`** forgets insertion order, and ties must keep file order; `mutableMapOf()` (a `LinkedHashMap`) and `groupingBy` keep it (lesson 12).
- **`sortedByDescending`** is stable, so equal counts stay in first-seen order; no extra key needed (lesson 14).
- **Exceptions for expected failures**: a missing file or a bad answer comes back as a `Result` from `runCatching`; Kotlin has no checked exceptions to force a `try` (lesson 11).
- **An enum for commands** couldn't carry each command's data; a `sealed interface` can, and stays exhaustive (lesson 13).
- **`String.length` for padding** counts UTF-16 units; the chart pads by code points, like Python (lesson 04).
- **Gradle** is what real Kotlin projects use, and chapter 02 does; here one `kotlinc` call is enough, and nothing needs downloading.
- **Coroutines and `kotlinx` libraries** need work that happens at once, or a dependency; they wait for the later chapter that loads several task files together.

## Done when

```bash
cd kotlin/concepts && make run && make test
```

builds with no warnings (`-Werror`), runs every lesson and passes every test, and each
`make bug N=NN` is caught as the table says.
