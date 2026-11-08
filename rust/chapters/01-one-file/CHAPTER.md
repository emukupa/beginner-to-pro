# Chapter 01 — The whole tracker in one file (Rust)

**Video:** Rust: Beginner to Pro (tag `video/rust-001`)

**Goal:** write `rust/one-file/src/main.rs`, the same task tracker as `python/tasks.py`, in Rust
(edition 2024). Python is the reference: the contract checks every byte of output, every exit code
and the tasks file afterwards.

```bash
cd rust/one-file
cargo run                                                   # build, then run it on tasks.txt here
cargo build && ../../contract/run.sh "$PWD/target/debug/tracker"   # the 8 contract cases
cargo clippy -- -D warnings                                 # the linter: must find nothing
```

## Concepts, mapped from Python, C and C++

| Python | C | C++ | Rust |
| --- | --- | --- | --- |
| `str` | `char *` and helpers | `std::string`, `string_view` | `String` owns, `&str` borrows; `trim`, `split_whitespace`, `split_once` |
| `None` from `parse_line` | `bool` + out-pointer | `std::optional<Task>` | `impl FromStr for Task`, so `line.parse::<Task>()` returns `Result<Task, NotATask>` |
| `class UrgentTask(Task)` | a `kind` field | a subclass | a `Kind` enum: Rust has no inheritance |
| a status string | an enum + a buffer | `enum class` + a string | `enum Status { Todo, Done, Other(String) }`: an enum that carries data |
| exceptions | `enum load_result` | exceptions | `Result` and `?`; `LoadError` is an enum whose cases carry the path |
| `__str__` | `printf` | `operator<<` | `impl Display`, so `println!("{task}")` |
| garbage collection | `free`, once, by the owner | RAII | ownership: every value has one owner and is dropped when it goes; nothing is freed by hand |
| `(tag, count)` tuples | structs pointing into tasks | `string_view` | `TagCount<'a>` borrows the tag: the lifetime says it can't outlive the tasks |
| tag counts, first-seen order | a hand-written search | a `vector` + `unordered_map` | a `Vec` for the order + a `HashMap<&str, usize>` for the place |
| `sorted(key=...)` | hand-written stable sort | `std::stable_sort` | `sort_by_key(Reverse(count))`: Rust's `sort` is stable |
| `round()` | `nearbyint` | `std::nearbyint` | `f64::round_ties_even` |
| `int(text)` | `parse_whole_number` | the same, by hand | `parse_whole_number`, by hand: `str::parse` doesn't take `1_000` or spaces |
| `input()` | `getline` | `std::getline` | `read_line`, flushing the prompt first |
| `open(path, "a")` | `fopen(path, "a")` | `std::ofstream(..., app)` | `OpenOptions::new().append(true)` |

## The compiler as the safety rules

Safe C had rules a person had to follow: one owner frees, nothing used after it's freed, check every
result. Here the compiler enforces them. `unsafe_code = "forbid"` in `Cargo.toml` means there's no way
out, and `unused_must_use = "deny"` means a `Result` that's ignored doesn't build.

## Done when

```bash
cd rust/one-file
cargo build && ../../contract/run.sh "$PWD/target/debug/tracker"   # 8 passes
cargo clippy -- -D warnings                                        # nothing
```

Compare with `git diff course/rust/01-one-file/end`.
