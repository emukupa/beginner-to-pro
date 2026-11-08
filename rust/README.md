# Rust

The task tracker in Rust (edition 2024): the safety Safe C enforced by rules, now enforced by the
compiler. The borrow checker stops use-after-free, double frees and data races before the program
builds, `#![forbid(unsafe_code)]` keeps it that way, and `cargo clippy -- -D warnings` must be clean.
Needs Rust with Cargo (written with 1.97; any toolchain that knows edition 2024 should do), installed
with [rustup](https://rustup.rs).

| Folder | What | Chapter |
| --- | --- | --- |
| [`concepts/`](concepts/) | one module per concept, run by `src/main.rs`: `cargo run` runs them all, `cargo run -- 7` one, `cargo run --features bug07 -- 7` with its bug | 00 |
| [`one-file/`](one-file/) | the whole tracker in `src/main.rs` | 01 |
| [`modules/`](modules/) | the same program split into modules in `tracker/`, one per job, with unit tests | 02 |

```bash
cd rust/concepts
cargo run                          # every lesson
cargo test                         # the lessons' tests
cargo clippy -- -D warnings        # the linter: must find nothing
```

```bash
cd rust/one-file                   # or rust/modules
cargo build && ../../contract/run.sh "$PWD/target/debug/tracker"   # must match Python byte for byte
```

| Chapter | Start | End | Video |
| --- | --- | --- | --- |
| [00 Concepts](chapters/00-concepts/CHAPTER.md) | `course/rust/00-concepts/start` | `course/rust/00-concepts/end` | `video/rust-000` |
| [01 One file](chapters/01-one-file/CHAPTER.md) | `course/rust/01-one-file/start` | `course/rust/01-one-file/end` | `video/rust-001` |
| [02 Modules](chapters/02-modules/CHAPTER.md) | `course/rust/02-modules/start` | `course/rust/02-modules/end` | `video/rust-002` |
| [03 Done](chapters/03-done/CHAPTER.md) | `course/rust/03-done/start` | `course/rust/03-done/end` | `video/rust-003` |
| [04 Undo](chapters/04-undo/CHAPTER.md) | `course/rust/04-undo/start` | `course/rust/04-undo/end` | `video/rust-004` |

VS Code: install the **rust-analyzer** extension. It runs the same checks as `cargo check` as you
type, so the borrow checker's errors show up before you build.
