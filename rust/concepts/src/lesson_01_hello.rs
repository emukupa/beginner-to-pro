//! Lesson 01: a Rust program starts at `fn main` (ours is in main.rs; each lesson is a `run`).
//! `println!` prints a line. The `!` means it's a macro, which lets the compiler check the format
//! string against its arguments before the program ever runs.
//! bug01: a `{}` with nothing to fill it. The compiler refuses to build.

pub const TITLE: &str = "Hello";

pub fn run() {
    println!("Hello, tasks!");
    let count = 6;
    println!("{count} tasks in the file"); // a name inside {} prints that variable
    println!("{} of {} done", 3, count); // or empty {}, filled from the arguments in order
    println!("{:?} is the debug view", "done"); // {:?} shows the value as code would: with quotes
    print!("print! adds no newline, ");
    println!("so this ends the same line");
    // eprintln! prints to stderr instead, for errors. main returns an ExitCode: 0 means it worked.

    #[cfg(feature = "bug01")]
    println!("{} of {} done", 3); // two holes, one value: checked at compile time, not at run time
}
