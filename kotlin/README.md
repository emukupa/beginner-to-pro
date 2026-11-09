# Kotlin

The task tracker in Kotlin: Java's platform with Java's ceremony removed. The same JVM and every
Java library still in reach, but null is part of the type system (`String` vs `String?`), data
classes replace pages of boilerplate, `when` checks it covered every case, and extension functions
add methods to types you don't own. Needs `kotlinc` (written with 2.4.20) on a JDK (written with
27), and `make`; install with `brew install kotlin` or SDKMAN. Everything builds with plain
`kotlinc` and `-Werror`: no Gradle and nothing to download until chapter 02.

| Folder | What | Chapter |
| --- | --- | --- |
| [`concepts/`](concepts/) | one package per concept, run by `src/Main.kt`: `make run` runs them all, `make run N=7` one, `make bug N=7` with its bug | 00 |

```bash
cd kotlin/concepts
make run             # build (about 10 seconds), then every lesson
make test            # the lessons' tests, written with kotlin.test
make bug N=7         # lesson 7 with its mistake compiled in: watch kotlinc refuse it
```

kotlinc is slow to start: a full build takes 6 to 12 seconds on an M-series Mac, even for this
small program, because the compiler is itself a JVM program. `make` only rebuilds when a file in
`src/` changed, and running the built jar is instant.

| Chapter | Start | End | Video |
| --- | --- | --- | --- |
| [00 Concepts](chapters/00-concepts/CHAPTER.md) | `course/kotlin/00-concepts/start` | `course/kotlin/00-concepts/end` | `video/kotlin-000` |

IntelliJ IDEA (Community is free) knows Kotlin out of the box: open `kotlin/concepts/` and it
shows kotlinc's errors as you type, plus hints kotlinc doesn't give, such as unused variables.
VS Code: install a **Kotlin** language extension for highlighting and errors as you type; IntelliJ
is the more complete experience.
