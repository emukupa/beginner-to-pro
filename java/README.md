# Java

The task tracker in Java: classes and inheritance where Python had them, plus what Java adds on
top: records, enums with fields, sealed interfaces with pattern-matching `switch`, `Optional`,
checked exceptions and try-with-resources, all checked by `javac` before anything runs. Every build
uses `-Xlint:all -Werror`, so a warning stops it like an error. Needs a JDK, 25 or newer (written
with OpenJDK 27): `javac` and `java` are the whole toolchain, with `make` only to save typing. No
Gradle, Maven or downloads.

| Folder | What | Chapter |
| --- | --- | --- |
| [`concepts/`](concepts/) | one class per concept, run by `Main.java`: `make` runs them all, `make run N=7` one, `make bug N=7` with its mistake compiled in | 00 |
| [`one-file/`](one-file/) | the whole tracker in `Tracker.java`, run straight from source | 01 |
| [`modules/`](modules/) | the same program as packages in two Java modules, with tests | 02 |

```bash
cd java/concepts
make                               # build with javac -Xlint:all -Werror, then run every lesson
make run N=7                       # just lesson 7
make test                          # Tests.java, plain assert statements, run with java -ea
```

Without `make` (Windows, say), the same build is one line:

```bash
javac -Xlint:all -Werror -d build *.java && java -cp build Main 7
```

```bash
cd java/one-file
../../contract/run.sh java "$PWD/Tracker.java"   # must match Python byte for byte
cd ../modules && make test && make check        # the same for modules/
```

| Chapter | Start | End | Video |
| --- | --- | --- | --- |
| [00 Concepts](chapters/00-concepts/CHAPTER.md) | `course/java/00-concepts/start` | `course/java/00-concepts/end` | `video/java-000` |
| [01 One file](chapters/01-one-file/CHAPTER.md) | `course/java/01-one-file/start` | `course/java/01-one-file/end` | `video/java-001` |
| [02 Modules](chapters/02-modules/CHAPTER.md) | `course/java/02-modules/start` | `course/java/02-modules/end` | `video/java-002` |
| [03 Done](chapters/03-done/CHAPTER.md) | `course/java/03-done/start` | `course/java/03-done/end` | `video/java-003` |
| [04 Undo](chapters/04-undo/CHAPTER.md) | `course/java/04-undo/start` | `course/java/04-undo/end` | `video/java-004` |

VS Code: install Microsoft's **Extension Pack for Java**. It compiles as you type, so javac's errors
(and the ones every `make bug` shows) appear under the code before you build.
