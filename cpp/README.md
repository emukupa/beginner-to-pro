# C++

The task tracker in C++23: classes and inheritance back, like Python, with C's control. Strict
warnings as errors, AddressSanitizer and UBSan on every run, no raw `new` or `delete`. Needs a
C++23 compiler with `<print>`, `<expected>` and `std::ranges::to` and `make`. It's built and tested
with Apple clang 21; clang 19+ with libc++ should work too. The Makefiles call `clang++`, and the
`BUG=1` lessons rely on clang's warnings (`-Wdangling-gsl` in lesson 04 is clang's own).

| Folder | What | Chapter |
| --- | --- | --- |
| [`concepts/`](concepts/) | one file per concept, run by `main.cpp`: `make` runs them all, `make 07` one, `make 07 BUG=1` with its mistake | 00 |

```bash
cd cpp/concepts
make                 # build/concepts with the sanitizers on, then every lesson
make 07              # one lesson
make 07 BUG=1        # that lesson's deliberate mistake, caught by the compiler or a sanitizer
```

| Chapter | Start | End | Video |
| --- | --- | --- | --- |
| [00 Concepts](chapters/00-concepts/CHAPTER.md) | `course/cpp/00-concepts/start` | `course/cpp/00-concepts/end` | `video/cpp-000` |

VS Code: install the recommended **clangd** extension. It reads `compile_flags.txt` and understands
C++23, using the same clang that builds the code.
