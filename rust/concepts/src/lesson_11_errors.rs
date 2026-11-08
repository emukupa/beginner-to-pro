//! Lesson 11: Rust has no exceptions. A function that can fail returns a Result: Ok(value) or
//! Err(error). `?` hands an Err straight back to the caller, converting it with From on the way,
//! so one error enum can collect every way the tracker can fail.
//! bug11: `?` inside a function that returns nothing. There's nowhere to send the error, so the
//! compiler refuses to build.

use std::error::Error;
use std::fmt;
use std::fs;
use std::io;
use std::num::ParseIntError;

use crate::lesson_09_structs::Task;

pub const TITLE: &str = "Errors";

#[derive(Debug)]
pub enum TrackerError {
    NotFound(String),
    Io(io::Error),
    NotANumber(ParseIntError),
    Zero,
}

impl fmt::Display for TrackerError {
    fn fmt(&self, f: &mut fmt::Formatter) -> fmt::Result {
        match self {
            TrackerError::NotFound(path) => write!(f, "Couldn't find {path}"),
            TrackerError::Io(e) => write!(f, "Couldn't read the file: {e}"),
            TrackerError::NotANumber(e) => write!(f, "Not a whole number: {e}"),
            TrackerError::Zero => write!(f, "Need at least 1"),
        }
    }
}

impl Error for TrackerError {} // marks it as an error type, so other error-handling code accepts it

// From is the trait ? uses: with these two, ? turns an io::Error or a ParseIntError into ours.
impl From<io::Error> for TrackerError {
    fn from(e: io::Error) -> Self {
        TrackerError::Io(e)
    }
}

impl From<ParseIntError> for TrackerError {
    fn from(e: ParseIntError) -> Self {
        TrackerError::NotANumber(e)
    }
}

/// The answer to "How many top tags?": a whole number of at least 1. Lesson 14 uses it.
pub fn parse_top(text: &str) -> Result<usize, TrackerError> {
    let n: usize = text.trim().parse()?; // a ParseIntError becomes TrackerError::NotANumber
    if n == 0 {
        return Err(TrackerError::Zero);
    }
    Ok(n)
}

/// Every task line in the file, parsed with lesson 10's FromStr. Lessons 12-15 use it.
pub fn load_tasks(path: &str) -> Result<Vec<Task>, TrackerError> {
    let text = match fs::read_to_string(path) {
        Err(e) if e.kind() == io::ErrorKind::NotFound => {
            return Err(TrackerError::NotFound(path.to_string()));
        }
        other => other?, // any other io::Error becomes TrackerError::Io, through From
    };
    let mut tasks = Vec::new();
    for line in text.lines() {
        if let Ok(task) = line.parse::<Task>() {
            tasks.push(task); // lines that aren't tasks are skipped, like the tracker does
        }
    }
    Ok(tasks) // the file was closed when `text` was read: nothing to clean up
}

pub fn run() {
    for path in ["tasks.txt", "missing.txt"] {
        match load_tasks(path) {
            Ok(tasks) => println!("{path}: {} tasks, the first: {}", tasks.len(), tasks[0]),
            Err(e) => println!("{path}: {e}"),
        }
    }
    for answer in ["3", "", "two", "0"] {
        match parse_top(answer) {
            Ok(n) => println!("{answer:?} -> top {n}"),
            Err(e) => println!("{answer:?} -> {e}"),
        }
    }
    // Like the tracker: a bad answer falls back to 3.
    println!(
        "parse_top(\"two\").unwrap_or(3) = {}",
        parse_top("two").unwrap_or(3)
    );
    // unwrap() and expect() turn an Err into a panic: fine in tests and for "can't happen",
    // never for something the user typed.

    #[cfg(feature = "bug11")]
    {
        let tasks = load_tasks("tasks.txt")?; // run() returns (), so ? has nowhere to send an Err
        println!("{}", tasks.len());
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn top_must_be_a_positive_number() {
        assert_eq!(parse_top(" 2 ").unwrap(), 2);
        assert!(matches!(parse_top("two"), Err(TrackerError::NotANumber(_))));
        assert!(matches!(parse_top("0"), Err(TrackerError::Zero)));
    }

    #[test]
    fn loads_the_file_or_says_why_not() {
        assert_eq!(load_tasks("tasks.txt").unwrap().len(), 6);
        assert!(matches!(
            load_tasks("missing.txt"),
            Err(TrackerError::NotFound(_))
        ));
    }
}
