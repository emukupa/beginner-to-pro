# Chapter 02 — Modules: private unless it says pub (Rust)

**Video:** Rust: Modules (tag `video/rust-002`)

**Goal:** build `rust/modules/`: the code of `rust/one-file/src/main.rs` split into
`rust/modules/tracker/`, one file per job, the same split as Python's chapter 02, without changing a
byte of what the program does. The contract proves it.

```bash
cd rust/modules
cargo test                                                         # 7 unit tests
cargo build && ../../contract/run.sh "$PWD/target/debug/tracker"   # 8 passes
```

## Concepts

- **The crate root lists the modules.** `Cargo.toml` names `tracker/cli.rs` as the program's root,
  and its `mod models;` line means "the module in `tracker/models.rs`". A file that no `mod` line
  names isn't part of the program at all.
- **Paths say where things live.** Inside the crate, `use crate::models::Task` names a module by
  its path from the root; `main` calls `storage::load_tasks` and `tasklist::top_tags`, so you can
  see which file every step comes from.
- **Private by default.** Functions, types, constants *and struct fields* are private to their
  module unless they say `pub`. `status_of` in `parsing.rs` has no `pub`; call it from `cli.rs` and
  the build stops: `error[E0603]: function 'status_of' is private`.
- **Tests live beside the code.** Each module ends in `#[cfg(test)] mod tests`, compiled only by
  `cargo test`. Because the tests are inside the module, they can test its private functions too.
- **One compile.** The crate is compiled as one unit; there are no headers to keep in step and
  nothing to link by hand.
- **Dependencies point one way.** Rust allows modules in one crate to use each other in a circle,
  so the rule from Python's chapter 02 is ours to keep.

## The split

| File | Job | Uses of ours |
| --- | --- | --- |
| `models.rs` | `Status`, `Kind`, `Task` (with `Display`) | nothing |
| `parsing.rs` | `impl FromStr for Task`, `TAG_MARKER`; private `status_of` | models |
| `storage.rs` | `LoadError`, `load_tasks`, `append_titles`: the only file that opens files | models (and parsing, through `.parse()`) |
| `tasklist.rs` | `add_tasks`, `TagCount<'a>`, `count_tags`, `top_tags`, `summarize` | models |
| `chart.rs` | `draw_chart(out: &mut impl Write, ...)`: draws to any writer, so a test draws into a `Vec<u8>` | tasklist |
| `cli.rs` | the crate root: the `mod` lines, `ask`, `parse_whole_number`, `main` | all of them |

## Done when

```bash
cd rust/modules
cargo test                                                         # 7 passed
cargo build && ../../contract/run.sh "$PWD/target/debug/tracker"   # 8 passes
cargo clippy --all-targets -- -D warnings                          # nothing
```

Compare with `git diff course/rust/02-modules/end`.
