# Chapter 04 — The undo command (C++)

**Video:** C++: Undo (tag `video/cpp-004`)

**Goal:** the undo challenge, in `cpp/modules/`. `./build/tracker undo "title"` sets a finished task
back to `[todo]`. Python's chapter 04 is the reference: the same six `contract/undo/` cases, byte
for byte. Done and undo become one command driven by one table.

## Where it goes

| Files | Change |
| --- | --- |
| `tasklist` | nothing: `find_task` already finds the task |
| `storage` | `mark_done(path, task)` becomes `set_status(path, task, status)`; a private `word(Status)` spells each status |
| `cli.cpp` | `struct Change` and `constexpr std::array<Change, 2> CHANGES`; `done_command` becomes `change_command`; `main` finds the word with `std::ranges::find(CHANGES, word, &Change::name)` |

## Concepts

- **A `constexpr` table.** Python's dict of `NamedTuple`s is an array of structs here, built by the
  compiler (`constexpr`), with `std::string_view` fields pointing at string literals.
- **A projection.** `std::ranges::find(CHANGES, argv[1], &Change::name)` searches by one field.
- **`-Wswitch` as a checklist.** `word(Status)` is a `switch` over `enum class Status` with no
  `default`, so adding a status without a spelling stops the build:
  `error: enumeration value 'Doing' not handled in switch [-Werror,-Wswitch]`.
  `Other` returns no word, and `set_status` refuses it before opening anything.

## Done when

```bash
cd cpp/modules
make check      # 8, then 6 done, then 6 undo passes
make leaks      # no leaks, three times
```

Compare with `git diff course/cpp/04-undo/end`.
