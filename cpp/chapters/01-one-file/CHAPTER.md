# Chapter 01 — The whole tracker in one file (C++)

**Video:** C++: Beginner to Pro (tag `video/cpp-001`)

**Goal:** write `cpp/one-file/tracker.cpp`, the same task tracker as `python/tasks.py`, in C++23.
Python is the reference: the contract checks every byte of output, every exit code and the tasks
file afterwards.

```bash
cd cpp/one-file
make            # build/tracker, with AddressSanitizer and UBSan
make run        # run it on tasks.txt here
make check      # the 8 contract cases
make leaks      # one full run under macOS's leaks tool
```

## Concepts, mapped from Python and C

| Python | C | C++ |
| --- | --- | --- |
| `class Task`, `UrgentTask(Task)` | a `kind` field | `class Task` with `virtual str()` and `urgent()`; `class UrgentTask : public Task` with `override` |
| a list of tasks | a growable array, freed by hand | `std::vector<std::unique_ptr<Task>>`: the list owns its tasks, of either kind |
| `str.strip`, `split` | hand-written, with lengths | `std::string_view`: `strip` and `words` return views into the line, no copies |
| `None` from `parse_line` | `bool` and an out-pointer | an empty `std::unique_ptr` |
| `FileNotFoundError` | `enum load_result` | `std::expected<TaskList, LoadError>` |
| `with open(...)` | `fopen`/`fclose` | `std::ifstream`, closed when it goes out of scope (RAII) |
| `ValueError` from `top_tags` | `false` | `std::optional`, and `value_or` / a fallback |
| `sorted(..., key=...)` | a hand-written stable sort | `std::ranges::stable_sort(items, std::ranges::greater{}, &T::count)` |
| a function for any list of pairs | `void *` and a comparator | `template <Counted T> top_n`, checked by a concept |
| `round()` | `nearbyint` | `std::nearbyint` |
| `print`, f-strings | `printf` | `std::print` / `std::println` with `{}` slots, checked while compiling |
| constants | `constexpr`, `static_assert` | the same |
| filtering urgent tasks | a loop | `tasks | std::views::filter(...)` |

## Memory

Nothing is freed by hand. The list owns each task through `std::unique_ptr`, so the tasks are
deleted when the list goes out of scope at the end of `main`; `std::string` and `std::vector`
manage their own memory; views and `TagCount::tag` only borrow. `make leaks` checks it.

## Done when

```bash
cd cpp/one-file
make check     # 8 passes, under AddressSanitizer and UBSan
make leaks     # no leaks
```

Compare with `git diff course/cpp/01-one-file/end`.
