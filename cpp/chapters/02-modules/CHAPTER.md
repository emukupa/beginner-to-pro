# Chapter 02 — Modules: headers, source files and make (C++)

**Video:** C++: Modules (tag `video/cpp-002`)

**Goal:** build `cpp/modules/`: the code of `cpp/one-file/tracker.cpp` split into
`cpp/modules/tracker/`, one `.hpp`/`.cpp` pair per job, the same split as Python's and C's chapter 02,
without changing a byte of what the program does. The contract proves it.

```bash
cd cpp/modules
make check      # 8 passes, under AddressSanitizer and UBSan
make leaks      # no leaks
touch tracker/chart.hpp && make    # only chart.cpp and cli.cpp recompile
```

## Concepts

- **C's model, kept.** C++ still pastes headers with `#include`, compiles each `.cpp` on its own and
  links the objects; `#pragma once`, `-MMD` and the linker work exactly as in the Safe C modules video.
- **`namespace tracker`.** Every module's names live in one namespace, so `strip` or `Task` can't
  collide with anyone else's. `cli.cpp` says `using namespace tracker;` once.
- **Anonymous namespaces instead of `static`.** `namespace { ... }` in a `.cpp` makes what's inside
  visible to that file only: `status_of` in `parsing.cpp`, `ask` and `parse_whole_number` in `cli.cpp`.
- **Templates live in headers.** `top_n` is a template, and the compiler needs its whole body wherever
  it's used, to write the version for that type. So `tasklist.hpp` holds `Counted` and `top_n`, and
  `tasklist.cpp` holds the ordinary functions.
- **Classes in the header.** `models.hpp` has the whole `Task` and `UrgentTask`, with short methods
  written inline; there's no `models.cpp`. Encapsulation is `private:`, not an opaque type.
- **A text module, again.** C++'s standard library has no `strip`, `lower` or `split`, so like C, a
  small `text` module holds them; they return `std::string_view`s.

## The split

| Files | Job | Includes of ours |
| --- | --- | --- |
| `text.hpp/.cpp` | `strip`, `lower`, `words`, `text_width` | nothing |
| `models.hpp` | `Status`, `Task`, `UrgentTask`, `TaskList` | nothing |
| `parsing.hpp/.cpp` | `parse_line`, `TAG_MARKER` | models, text |
| `storage.hpp/.cpp` | `load_tasks` (returns `std::expected`), `append_titles`: the only files that open files | models, parsing |
| `tasklist.hpp/.cpp` | `add_tasks`, `count_tags`, `TagCount`, and the `top_n` template | models, parsing |
| `chart.hpp/.cpp` | `draw_chart(std::ostream&, ...)` | tasklist, text |
| `cli.cpp` | `main`: the only file that reads input, prints to the screen, or exits | all of them |

## Done when

```bash
cd cpp/modules
make check     # 8 passes
make leaks     # no leaks
```

Compare with `git diff course/cpp/02-modules/end`.
