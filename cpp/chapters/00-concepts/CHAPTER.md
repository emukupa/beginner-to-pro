# Chapter 00 — C++ concepts

**Video:** C++: Concepts (tag `video/cpp-000`)

**Goal:** learn modern C++ (C++23) before building anything with it. `cpp/concepts/` holds one
lesson per file. `main.cpp` pulls them all in with `#include` (which pastes each file in, so the
whole thing compiles as one and later lessons can use earlier ones' functions and classes) and
keeps them in a table of function pointers.

Every lesson starts with `#pragma once` and `#include "concepts.hpp"` (the standard library, in
one place), then includes the earlier lessons it borrows from: lesson 11 includes 03 and 10 for
`whole_percent`, `parse_line` and `make_task`. So clangd understands any lesson file on its own, and
`#pragma once` stops a lesson being pasted in twice when main.cpp and a later lesson both include
it. Real projects use headers and source files instead; that's chapter 02.

```bash
cd cpp/concepts
make              # build, then run every lesson
make 07           # just lesson 7
make 07 BUG=1     # lesson 7 with its deliberate mistake compiled in: watch the tools catch it
```

Every build uses `-std=c++23 -Wall -Wextra -Wpedantic -Wconversion -Wshadow -Werror` with
AddressSanitizer and UBSan on, so a warning stops the build and a memory or undefined-behaviour
mistake stops the run.

## The lessons

| # | Lesson | Concepts | `BUG=1` shows | Caught by |
| --- | --- | --- | --- | --- |
| 01 | Hello | `main`, `std::print`/`std::println`, `{}` placeholders, alignment | two `{}` for one value | the compiler (format strings are checked while compiling) |
| 02 | Types | `int` `double` `bool` `char` `std::string` `std::size_t`, `sizeof`, `auto`, `const`, brace initialisation, unsigned wraparound | `int whole{2.5}` | the compiler (braces refuse to narrow) |
| 03 | Numbers | integer division, `%`, float precision, `std::round` vs `std::nearbyint` (halves to even), `std::from_chars` | `size_t` into `int` | `-Wconversion` |
| 04 | Strings and views | `std::string`, `std::string_view`, `find` `substr` `starts_with`, `strip`, `lower`, padding by characters | a view of a temporary string | `-Wdangling-gsl` + `-Werror` |
| 05 | Decisions, loops and `enum class` | `if`, `if` with an initialiser, `switch`, `for`, range-`for`, `while`, `? :`, `enum class Status` | a `switch` missing a status | `-Wswitch` + `-Werror` |
| 06 | Functions and lambdas | copies vs `&` vs `const&`, default arguments, overloading, `[[nodiscard]]`, lambdas and captures | an ignored result | `[[nodiscard]]` + `-Werror` |
| 07 | Collections | `std::vector`, `at()` vs `[]`, `std::map` (sorted), `std::unordered_map` (hash order), `struct TagCount`, counting in first-seen order | `i <= size()`, one past the end | AddressSanitizer |
| 08 | Classes and inheritance | `class Task`, private data, constructors, `const` methods, `virtual`/`override`, `UrgentTask`, `operator<<`, slicing | an override that doesn't match | `override` (the compiler) |
| 09 | Ownership | RAII and destructors, `std::unique_ptr`, `make_unique`, `std::move`, `vector<unique_ptr<Task>>`, why not `shared_ptr` | using a moved-from `unique_ptr` | UBSan |
| 10 | Errors | `std::optional` from the parser, `parse_line`, `make_task`, exceptions with `try`/`catch` | `.value()` on an empty optional | an uncaught exception: the program aborts |
| 11 | Files | `std::ifstream`, `std::getline`, `std::ofstream` and append, RAII closing, `std::expected` from `load_tasks` | | |
| 12 | Templates and concepts | function templates, a `Counted` concept, `top_n` with `std::ranges::stable_sort` | `top_n` on a vector of `int` | the concept (the compiler) |
| 13 | Ranges, views and a mini tracker | `views::iota` `transform` `filter`, `ranges::to`, `count_if`; load, count and chart `tasks.txt` | `max_element` on a temporary vector | `std::ranges::dangling` (the compiler) |
| 14 | `constexpr` and `static_assert` | compile-time functions and tables, checking the contract's rounding while compiling | a failing `static_assert` | the compiler |

Pieces carry forward: lesson 03's `whole_percent`, 04's `strip`/`clean_status`, 05's `Status`,
06's `bar`, 07's `count_tags`, 08's `Task`/`UrgentTask`, 10's `parse_line`/`make_task`, 11's
`load_tasks` and 12's `top_n` all meet in lesson 13, which loads, counts and charts the tasks file
the way the tracker will.

## Choices the tracker doesn't make, and why

- **`std::shared_ptr`** counts owners and frees on the last; the task list is the one owner, so
  `std::unique_ptr` says that exactly and costs nothing extra (lesson 09).
- **`std::map` or `std::unordered_map` for tag counts** sort by key or by hash; ties must keep
  file order, so the tracker counts into a `std::vector<TagCount>` in first-seen order (lesson 07).
- **`std::sort`** may swap equal items; `std::ranges::stable_sort` keeps ties in order (lesson 12).
- **`std::round`** sends 2.5 to 3; the contract wants halves to even, so `std::nearbyint` (lesson 03).
- **`std::stoi`** throws on bad input; a bad answer is ordinary, so `std::from_chars` and
  `std::optional` (lessons 03, 10). Exceptions stay for what nobody nearby can handle.
- **Raw `new` and `delete`** are how C++ used to own memory; `make_unique` never leaks or frees
  twice (lesson 09).
- **`printf` and `std::cout` with `<<` everywhere**: `std::print` checks its format while compiling
  and pads by characters; the tracker still gives `Task` an `operator<<`, because you'll meet streams
  in other people's code (lesson 08).
- **C++20 named modules** (`export module`) are the newer way to split a program; chapter 02 uses
  headers, which every toolchain handles today, and shows modules as a stretch.

## Done when

```bash
cd cpp/concepts && make
```

runs every lesson cleanly, and each `make NN BUG=1` is caught as the table says.
