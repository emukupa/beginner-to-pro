# Chapter 00 — Java concepts

**Video:** Java: Concepts (tag `video/java-000`)

**Goal:** learn Java before building anything with it. `java/concepts/` holds one lesson per file,
each a class (`Lesson07Arrays.java`) with a `TITLE` and a static `run()`. All of them sit in the
same folder with no `package` line, so `javac *.java` builds them as one program: `Main.java` keeps
them in a table of method references (`Lesson07Arrays::run`), and a later lesson uses an earlier
one's pieces by class name, `Lesson04Strings.cleanStatus(...)` or `Lesson09Classes.Task`, with no
imports. (Packages, and `module-info.java`, are chapter 02.)

The build is plain `javac` with `-Xlint:all -Werror`: every warning javac knows is on, and any one
of them fails the build. The `Makefile` holds nothing more than the commands you'd type.

Each lesson's deliberate mistake lives in its own file, `bugs/LessonNNBug.java`, a small class with
its own `main`. The normal build only compiles `*.java` in `concepts/`, so it never sees `bugs/`.
`make bug N=7` compiles the lessons plus that one file into `build/bug/` and runs it. Most mistakes
stop there, at javac. Two (an index past the end, a method called on `null`) compile fine and then
throw an exception with a message that says exactly what went wrong, instead of carrying on wrong.

```bash
cd java/concepts
make                    # build, then run every lesson
make run N=7            # just lesson 7       (or: java -cp build Main 7, or several: Main 4 7)
make bug N=7            # lesson 7's mistake compiled in: watch Java catch it
make test               # Tests.java: plain assert checks and a ten-line runner, under java -ea
make clean              # delete build/
```

Without `make`: `javac -Xlint:all -Werror -d build *.java && java -cp build Main 7`, and for a bug
`javac -Xlint:all -Werror -d build/bug *.java bugs/Lesson07Bug.java && java -cp build/bug Lesson07Bug`.
Java 22+ can also run straight from source, compiling the other files as it needs them:
`java Main.java 7` (handy, but without the lint flags).

**Tests.** No JUnit: `Tests.java` is a list of named checks, each a lambda full of `assert`
statements, and its `main` runs them and counts failures. `assert` is skipped unless the JVM gets
`-ea`, so the runner refuses to start without it rather than pass without checking anything.

Lessons 12–15 read `tasks.txt`, a copy of `contract/tasks.txt`. They look for it in the current
folder, then in `concepts/`, so run them from `java/concepts/` (as `make` does) or from `java/`.

## The lessons

| # | Lesson | Concepts | `make bug N=NN` shows | Caught by |
| --- | --- | --- | --- | --- |
| 01 | Hello | classes, `main`, `println` vs `print`, `printf` and `formatted`, `+` joining left to right, `IO.println`, exit codes | `println` misspelt as `printn` | javac: `cannot find symbol` |
| 02 | Values and types | `int` `long` `double` `boolean` `char`, `var`, `final`, `char` as a number, boxing to `Integer`, `==` vs `equals`, `null` | assigning to a `final` variable | javac: `cannot assign a value to final variable` |
| 03 | Numbers | integer division towards zero, `floorDiv`/`floorMod`, silent `int` overflow vs `Math.addExact`, casts, `Math.round` vs `Math.rint`, `%.0f` rounds halves up, `pythonRound`, `parseInt` | a `double` stored in an `int` | javac: `possible lossy conversion from double to int` |
| 04 | Strings | immutability, `equals` vs `==`, `strip` vs `trim`, `toLowerCase(Locale.ROOT)`, `indexOf`/`substring`, `split` with a regex, `length` vs code points vs UTF-8 bytes, text blocks, `stripChars`, `cleanStatus` | `title[0]` | javac: `array required, but String found` |
| 05 | Decisions and loops | `if`/`else if`, `?:`, `for`, for-each, `while`, labelled `break`, arrow `switch` with no fallthrough, switch expressions and `yield` | reading a variable set on only one path | javac: `might not have been initialized` |
| 06 | Methods and lambdas | static methods, overloading, varargs, pass by value (of references), lambdas, `Predicate`/`Function`, method references, `Comparator`, `percent`, `bar` | a lambda changing a local | javac: `must be final or effectively final` |
| 07 | Arrays and lists | fixed-length arrays, `Arrays.copyOf` vs aliasing, `List.of` can't change, `ArrayList`, `subList` views, the `remove(int)` vs `remove(Object)` trap | `i <= length`, one past the end | an exception: `ArrayIndexOutOfBoundsException` |
| 08 | Enums | `enum Status` with fields, a constructor and methods, `values()`, `valueOf`, `name`, `ordinal`, exhaustive `switch`, `EnumMap`, `Status.parse` | a switch that forgets `Status.OTHER` | javac: `the switch expression does not cover all possible input values` |
| 09 | Classes | `class Task`, `private final` fields, constructors and `this(...)`, `static`, getters, `toString`, references vs `equals`, `List.copyOf` | writing to a private field | javac: `has private access` |
| 10 | Inheritance | `UrgentTask extends Task`, `super(...)`, `@Override` and `super.toString()`, polymorphism, `instanceof` with a pattern, `Object` | `@Override` on `toStrng` | javac: `does not override or implement a method from a supertype` |
| 11 | Null and Optional | `null` from `Map.get`, helpful NullPointerExceptions, `Optional` (`ofNullable`, `map`, `filter`, `orElse`, `ifPresentOrElse`), `parseLine` | `notes.get("Call dad").length()` | an exception: `NullPointerException`, naming what was null |
| 12 | Exceptions and files | checked vs unchecked, `throws`, `catch` order, `finally`, try-with-resources, `BufferedReader`, `NoSuchFileException`, an `AutoCloseable` `TempFile`, `loadTasks`, `parseTop` | `loadTasks` with its `IOException` ignored | javac: `unreported exception IOException` |
| 13 | Maps, sets and records | `HashMap` vs `LinkedHashMap` order, `merge`, `getOrDefault`, `HashSet`/`LinkedHashSet`/`TreeSet`, `record TagCount` with a compact constructor, `countTags` | `tags.add(3)` on a `List<String>` | javac: `int cannot be converted to String` |
| 14 | Streams and generics | `filter` `map` `flatMap` `distinct` `count` `toList`, `groupingBy` into a `LinkedHashMap`, laziness, stable `sorted`, `<T> topN`, `<T extends Comparable<? super T>> largest`, `rankTags` | `largest` given `TagCount`s | javac: `cannot be applied to given types` (the bound) |
| 15 | Sealed types: the mini tracker | `sealed interface Command permits ...`, records as cases, `switch` with record patterns and `when`, no `default`, a text block for usage, then everything together: load, summarise, rank and chart `tasks.txt` | a `record Delete` not in `permits` | javac: `not allowed to extend sealed class` |

Pieces carry forward: lesson 03's `pythonRound` feeds lesson 06's `bar`; lesson 04's `cleanStatus`
feeds lesson 08's `Status.parse`, which lesson 09's `Task` and lesson 10's `UrgentTask` hold;
lesson 11's `parseLine` builds them, lesson 12's `loadTasks` reads the file with it and `parseTop`
reads the top-N answer, lesson 13's `countTags` counts tags in first-seen order and lesson 14's
`topN` ranks them. Lesson 15 turns those into commands and prints the tracker's summary and tag
chart, built only from what the lessons before it made.

## Choices the tracker doesn't make, and why

- **`HashMap`** keeps no order you can rely on, and ties must keep file order; `LinkedHashMap` remembers first-seen order, so no separate list is needed (lesson 13).
- **An unstable sort** might swap equal counts; `List.sort` and `Stream.sorted` are both stable, so tied tags stay in file order (lesson 14).
- **`Math.round`** and `%.0f` round halves up; the tracker matches Python with `Math.rint`, half to even (lesson 03).
- **`trim()`** only knows ASCII spaces; `strip()` knows Unicode's. Neither is exactly Python's set, which the sample file never tests (lesson 04).
- **Returning `null`** for "not a task" moves the crash to whoever forgets to check; `Optional<Task>` puts the "maybe" in the type (lesson 11).
- **Catching `Exception`** everywhere would hide bugs; the tracker catches the `IOException` it expects and lets unchecked exceptions mean bugs or bad input (lesson 12).
- **An enum for commands** can't carry a value per use (a chart's `n`, a title to add); a sealed interface of records can, and the `switch` still checks every case (lesson 15).
- **A Java enum with an "other" text**, like Rust's `Other(String)`, isn't possible; `Status.OTHER` is one shared value, which is all the tracker needs, since only "done" counts (lesson 08).
- **JUnit, Gradle and Maven** are what real projects reach for; the course uses only the JDK so you see how the pieces work, and `java -ea` with plain `assert` is enough here.
- **Threads, `ExecutorService` and virtual threads** need work that can happen at once; they arrive with the later chapter that loads several task files together.

## Done when

```bash
cd java/concepts && make && make test
```

builds with no warnings under `-Xlint:all -Werror`, runs every lesson and every check cleanly, and
each `make bug N=NN` is caught as the table says.
