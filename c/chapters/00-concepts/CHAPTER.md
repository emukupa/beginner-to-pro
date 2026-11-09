# Chapter 00 — Safe C concepts

**Video:** [Safe C for Beginners: C With Seatbelts](https://youtu.be/6MnMMOOcCuI) on YouTube

**Goal:** learn C, and the Safe C rules, before building anything with it. `c/concepts/` holds one
lesson per file. `main.c` pulls them all in with `#include` (which pastes each file in, so the
whole thing compiles as one and later lessons can call earlier ones' functions) and keeps them in a
table of function pointers.

Every lesson starts with `#pragma once` and `#include "concepts.h"` (the standard library, in one
place), then includes the earlier lessons it borrows from: lesson 10 includes 08 and 09 for `strip`
and `copy_text`. So any lesson also builds on its own, and `#pragma once` stops a lesson being pasted
in twice when main.c and a later lesson both include it.

```bash
cd c/concepts
make              # build, then run every lesson
make 07           # just lesson 7
make 07 BUG=1     # lesson 7 with its Safe C bug compiled in: watch the tools catch it
make solo-10      # lesson 10 built alone (solo.c), with just concepts.h and the lessons it includes
```

## The lessons

| # | Lesson | Concepts | `BUG=1` shows | Caught by |
| --- | --- | --- | --- | --- |
| 01 | Hello | `main`, `printf`, `\n`, exit codes | an unused variable | `-Werror` |
| 02 | Types and sizes | `sizeof`, `int` `long` `double` `size_t` `bool`, unsigned wraparound | `INT_MAX + 1` | UBSan |
| 03 | Numbers | integer division, `%`, floats, `round` vs `nearbyint`, parsing a number by hand | `size_t` into `int` | `-Wconversion` |
| 04 | Decisions and loops | `if`, `switch`, `for`, `while`, `do`/`while` | | |
| 05 | Functions | copies of arguments, `static`, `[[nodiscard]]` | an ignored result | `[[nodiscard]]` |
| 06 | Arrays | fixed size, `sizeof a / sizeof a[0]`, no bounds checks | `i <= n`, one past the end | UBSan |
| 07 | Pointers | `&`, `*`, changing the caller's values, arrays as pointers, `nullptr` | following `nullptr` | UBSan |
| 08 | Strings | `char` arrays, the zero byte, `strlen` vs `sizeof`, `strip`, `snprintf` | `strcpy` 24 bytes into 8 | AddressSanitizer |
| 09 | Memory | stack vs heap, `malloc`/`free`, `checked()`, owners, variadic `fail()` | `free` twice | AddressSanitizer |
| 10 | Structs and enums | `typedef struct task { ... } Task;`, designated initializers, C23 typed enums | | |
| 11 | Growing arrays | len/cap/`realloc`, the `PUSH` macro with C23 `typeof` | | |
| 12 | Files and errors | `fopen`, `getline`, `fclose`, `errno`, errors as an enum | | |
| 13 | Function pointers | comparators, `qsort` vs a stable sort | | |
| 14 | The preprocessor and C23 | macros and their traps, `constexpr`, `static_assert`, `auto` | a failing `static_assert` | the compiler |

Pieces carry forward: lesson 08's `strip`, lesson 09's `checked`/`copy_text`/`fail` and lesson 10's
`parse_task` are used by lessons 11–13, which together load, count and chart the tasks file.

## Choices the tracker doesn't make, and why

- **`qsort`** isn't stable; ties must keep file order, so we write a stable sort (lesson 13).
- **`strtol`** works, but checking it fully is as long as our own parser (lesson 03).
- **Fixed-size arrays** can't hold a file of unknown length; growable ones can (lessons 06, 11).
- **Variable-length arrays** (`int a[n]`) can blow the stack silently; Safe C doesn't use them.
- **`goto cleanup`** is a real C idiom for freeing on every exit path; our functions are small enough not to need it.
- **Unions and bit fields** save memory in tight places; the tracker has nothing that needs them.

## Done when

```bash
cd c/concepts && make
```

runs every lesson cleanly, and each `make NN BUG=1` is caught as the table says.
