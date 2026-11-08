# Chapter 00 — Rust concepts

**Video:** Rust: Concepts (tag `video/rust-000`)

**Goal:** learn Rust before building anything with it. `rust/concepts/` is one Cargo package with
one lesson per module in `src/`. `main.rs` declares them all with `mod` and keeps them in a table
of function pointers; a later lesson borrows from an earlier one with `use crate::lesson_09_structs::Task`.

Safe C made C safe with rules and tools that catch mistakes while the program runs. Rust moves most
of that into the compiler: the borrow checker and the type system refuse to build the mistake at
all. So instead of `BUG=1`, each lesson has a Cargo feature (`bug07`) that compiles its mistake in,
and you watch the compiler say no. Two lessons' mistakes (overflow, an index past the end) can only
show up at run time; those build, then panic with a clear message instead of carrying on wrong.

`main.rs` starts with `#![forbid(unsafe_code)]`, so none of these guarantees can be switched off
anywhere in the package. `Cargo.toml` turns an ignored `#[must_use]` result into an error, the way
C's `-Werror` does for `[[nodiscard]]`.

```bash
cd rust/concepts
cargo run                          # build, then run every lesson
cargo run -- 7                     # just lesson 7
cargo run --features bug07 -- 7    # lesson 7 with its bug compiled in: watch the compiler catch it
cargo test                         # the lessons' #[test]s
cargo clippy -- -D warnings        # the linter, with warnings as errors: must be clean
```

## The lessons

| # | Lesson | Concepts | `--features bugNN` shows | Caught by |
| --- | --- | --- | --- | --- |
| 01 | Hello | `fn main`, `println!` and `print!`, `{name}`, `{}`, `{:?}`, exit codes | a `{}` with no argument to fill it | the compiler (format strings are checked) |
| 02 | Values and types | `let`, `mut`, `i32` `f64` `bool` `char` `usize`, `size_of`, shadowing, tuples, arrays | assigning to a value that isn't `mut` | the compiler, E0384 |
| 03 | Numbers | integer division, `%`, floats, `round` vs `round_ties_even`, `checked_`/`wrapping_`/`saturating_add`, `as` vs `try_from`, `parse` | `255u8 + 1` | a panic: debug builds check overflow |
| 04 | Strings | `String` vs `&str`, `trim` `to_lowercase` `split_whitespace` `split_once`, bytes vs characters, padding by characters, `clean_status` | `title[0]` | the compiler, E0277 |
| 05 | Control flow | `if` as a value, ranges, `while`, `loop` with `break value`, `match` with ranges, guards and `\|`, labelled `break` | an `if` used as a value with no `else` | the compiler, E0317 |
| 06 | Functions and closures | typed parameters, the last expression is the result, `#[must_use]`, copies of arguments, closures, `impl Fn`, `FnMut`, `move` | an ignored `percent(3, 7)` | the `unused_must_use` lint, denied in `Cargo.toml` |
| 07 | Ownership and borrowing | one owner, move, `clone`, `Copy`, `&` and `&mut`, many readers or one writer, `Drop` | using a `String` after it moved | the borrow checker, E0382 |
| 08 | Enums and Option | `enum Status { Todo, Done, Other(String) }`, `enum Kind`, `match` on data, `Option`, `if let`, `let ... else`, `unwrap_or` | a `match` that forgets `Status::Other` | the compiler, E0004 |
| 09 | Structs and impl | `struct Task`, `impl`, `Self`, `&self` vs `&mut self`, `?` on an Option, struct update `..`, `parse_task` | `mark_done()` on a task that isn't `mut` | the borrow checker, E0596 |
| 10 | Traits | `Display` for `Task`, `FromStr` and `.parse::<Task>()`, `#[derive]`, a generic `fn show_all<T: Display>`, `to_string` | printing `Kind` with `{}` | the compiler, E0277 |
| 11 | Errors | `Result`, `?`, a custom `TrackerError` enum, `From` so `?` converts, `std::error::Error`, `fs::read_to_string`, `load_tasks` | `?` in a function that returns `()` | the compiler, E0277 |
| 12 | Collections | `Vec`, push/pop, slices `&tasks[..2]`, `get` gives an Option, `HashMap` and `entry`, `HashSet`, first-seen order kept in a `Vec`, `count_tags` | `tasks[tasks.len()]` | a panic: every index is bounds-checked |
| 13 | Iterators and sorting | `iter`, `filter` `map` `sum` `count` `collect` `enumerate` `find` `max`, laziness, stable `sort_by_key` with `Reverse`, `f64::total_cmp`, `bar` | `sort()` on a `Vec<f64>` | the compiler, E0277 (`f64` isn't `Ord`) |
| 14 | Lifetimes | `TagCount<'a>` borrowing tag names, `'_`, `fn longer<'a>`, `rank_tags`, `draw_chart`: the mini tracker | a ranking kept after its tasks are dropped | the borrow checker, E0597 |
| 15 | Sharing with Rc (and why Arc) | `Rc<str>` shared by every task with that tag, `Rc::clone`, `strong_count`, `ptr_eq`, why threads need `Arc` | sending an `Rc` to another thread | the compiler, E0277 (`Rc` isn't `Send`) |

Pieces carry forward: lesson 04's `clean_status` feeds lesson 08's `parse_status`, which lesson 09's
`parse_task` uses; lesson 10 makes that `FromStr`, lesson 11's `load_tasks` reads the file with it,
and lessons 12–15 load, count, rank and chart `tasks.txt`. Lesson 14 prints the tracker's summary
and tag chart, built only from what the lessons before it made.

## Choices the tracker doesn't make, and why

- **`HashMap` alone** forgets insertion order, and ties must keep file order; the counts live in a `Vec`, with the map finding each tag's place (lesson 12).
- **`sort_unstable_by_key`** is faster, but may swap equal counts; `sort_by_key` is stable, so ties stay in file order (lesson 13).
- **`f64::round`** rounds halves away from zero; the tracker matches Python with `round_ties_even` (lesson 03).
- **`unwrap()` and `expect()`** crash on an error; fine in tests and for "can't happen", never for something the user typed (lesson 11).
- **Owned `String`s in the tag counts** would copy every name; `TagCount<'a>` borrows them instead (lesson 14).
- **`Arc`** is `Rc` for threads, at the cost of atomic counting; the tracker has no threads, so `Rc` is enough (lesson 15).
- **`unsafe`** turns off some of the compiler's checks, for code it can't verify; nothing here needs it, so it's forbidden.
- **Crates** such as `clap` (arguments) or `anyhow` (errors) are what real projects reach for; the course uses only the standard library so you see how the pieces work.

## Done when

```bash
cd rust/concepts && cargo run && cargo test
```

runs every lesson and every test cleanly, `cargo clippy -- -D warnings` finds nothing, and each
`cargo run --features bugNN -- NN` is caught as the table says.
