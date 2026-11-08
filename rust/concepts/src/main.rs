//! Rust concepts, one lesson per module. Each lesson is a file in src/ with a TITLE and a run();
//! the `mod` lines below pull them in, and later lessons `use` what earlier ones built.
//!
//!   cargo run                          every lesson, in order
//!   cargo run -- 7                     just lesson 7 (or several: cargo run -- 4 7)
//!   cargo run --features bug07 -- 7    lesson 7 with its bug compiled in, to watch the compiler catch it
//!   cargo test                         the #[test]s in the lessons

// No `unsafe` anywhere in this crate, and nothing below can switch it back on. Everything the
// borrow checker promises (no dangling pointers, no data races) then holds for every line here.
#![forbid(unsafe_code)]

mod lesson_01_hello;
mod lesson_02_values;
mod lesson_03_numbers;
mod lesson_04_strings;
mod lesson_05_control;
mod lesson_06_functions;
mod lesson_07_ownership;
mod lesson_08_enums;
mod lesson_09_structs;
mod lesson_10_traits;
mod lesson_11_errors;
mod lesson_12_collections;
mod lesson_13_iterators;
mod lesson_14_lifetimes;
mod lesson_15_sharing;

use std::process::ExitCode;

// The table of lessons: a title and the function to run. `fn()` is a function pointer, like C's.
const LESSONS: [(&str, fn()); 15] = [
    (lesson_01_hello::TITLE, lesson_01_hello::run),
    (lesson_02_values::TITLE, lesson_02_values::run),
    (lesson_03_numbers::TITLE, lesson_03_numbers::run),
    (lesson_04_strings::TITLE, lesson_04_strings::run),
    (lesson_05_control::TITLE, lesson_05_control::run),
    (lesson_06_functions::TITLE, lesson_06_functions::run),
    (lesson_07_ownership::TITLE, lesson_07_ownership::run),
    (lesson_08_enums::TITLE, lesson_08_enums::run),
    (lesson_09_structs::TITLE, lesson_09_structs::run),
    (lesson_10_traits::TITLE, lesson_10_traits::run),
    (lesson_11_errors::TITLE, lesson_11_errors::run),
    (lesson_12_collections::TITLE, lesson_12_collections::run),
    (lesson_13_iterators::TITLE, lesson_13_iterators::run),
    (lesson_14_lifetimes::TITLE, lesson_14_lifetimes::run),
    (lesson_15_sharing::TITLE, lesson_15_sharing::run),
];

fn run(number: usize) {
    let (title, lesson) = LESSONS[number - 1];
    println!("\n=== {number:02} {title} ===");
    lesson();
}

fn main() -> ExitCode {
    let args: Vec<String> = std::env::args().skip(1).collect();
    if args.is_empty() {
        (1..=LESSONS.len()).for_each(run);
        return ExitCode::SUCCESS;
    }
    for arg in &args {
        match arg.parse::<usize>() {
            Ok(n) if (1..=LESSONS.len()).contains(&n) => run(n),
            _ => {
                eprintln!("No lesson {arg}");
                return ExitCode::FAILURE;
            }
        }
    }
    ExitCode::SUCCESS
}
