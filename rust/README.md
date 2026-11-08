# Rust

The task tracker in Rust (edition 2024): the safety Safe C enforced by rules, now enforced by the
compiler. The borrow checker stops use-after-free, double frees and data races before the program
builds, `#![forbid(unsafe_code)]` keeps it that way, and `cargo clippy -- -D warnings` must be clean.
Needs Rust with Cargo (written with 1.97; any toolchain that knows edition 2024 should do), installed
with [rustup](https://rustup.rs).

| Folder | What | Chapter |
| --- | --- | --- |
| [`concepts/`](concepts/) | one module per concept, run by `src/main.rs`: `cargo run` runs them all, `cargo run -- 7` one, `cargo run --features bug07 -- 7` with its bug | 00 |

```bash
cd rust/concepts
cargo run                          # every lesson
cargo test                         # the lessons' tests
cargo clippy -- -D warnings        # the linter: must find nothing
```

| Chapter | Start | End | Video |
| --- | --- | --- | --- |
| [00 Concepts](chapters/00-concepts/CHAPTER.md) | `course/rust/00-concepts/start` | `course/rust/00-concepts/end` | `video/rust-000` |

VS Code: install the **rust-analyzer** extension. It runs the same checks as `cargo check` as you
type, so the borrow checker's errors show up before you build.
