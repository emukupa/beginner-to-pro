//! Lesson 02: `let` names a value, and values can't change unless you say `mut`. Every value has
//! a type, which the compiler usually works out for you. Shadowing reuses a name for a new value.
//! bug02: assigning to a value that isn't `mut`. The compiler refuses to build.

pub const TITLE: &str = "Values and types";

pub fn run() {
    let title = "Buy groceries"; // fixed: most values never need to change, so that's the default
    let mut done = 0; // mut: this one can, and the word warns the reader that it will
    done += 1;
    println!("title = {title:?}, done = {done}");

    let count: i32 = 6; // a type written out; without it, whole numbers default to i32
    let share: f64 = 0.5;
    let finished: bool = false;
    let block: char = '█'; // a char is one Unicode character, not one byte
    println!("i32 {count}, f64 {share}, bool {finished}, char {block}");
    println!(
        "sizes in bytes: i32 {}, i64 {}, f64 {}, bool {}, char {}, usize {}",
        size_of::<i32>(),
        size_of::<i64>(),
        size_of::<f64>(),
        size_of::<bool>(),
        size_of::<char>(),
        size_of::<usize>() // usize: the size of a memory address, used for lengths and indexes
    );

    let answer = "3"; // text, as a user would type it...
    let answer: i32 = answer.parse().unwrap_or(0); // ...shadowed by a number with the same name
    println!("answer + 1 = {}", answer + 1);

    let pair = ("work", 3); // a tuple: a few values of different types, together
    let (tag, n) = pair; // and taken apart again
    let counts = [3, 2, 1]; // an array: a fixed number of values of one type
    println!(
        "tuple: {tag} {n}, array: {counts:?} with {} items",
        counts.len()
    );
    // There's no null: a value that might be missing is an Option (lesson 08).

    #[cfg(feature = "bug02")]
    {
        count = 7; // count wasn't declared mut, so the compiler won't let it change
        println!("{count}");
    }
}
