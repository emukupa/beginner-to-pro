//! Lesson 10: a trait is a set of methods a type promises to have. Implement Display and your type
//! prints with {}; implement FromStr and text turns into it with .parse(). `#[derive(...)]` writes
//! the simple ones (Debug, Clone, PartialEq) for you.
//! bug10: printing Kind with {}. Kind only derives Debug, so the compiler says Display is missing.

use std::fmt;
use std::str::FromStr;

use crate::lesson_08_enums::{Kind, Status};
use crate::lesson_09_structs::{Task, parse_task};

pub const TITLE: &str = "Traits";

impl fmt::Display for Status {
    fn fmt(&self, f: &mut fmt::Formatter) -> fmt::Result {
        match self {
            Status::Todo => write!(f, "todo"),
            Status::Done => write!(f, "done"),
            Status::Other(text) => write!(f, "{text}"),
        }
    }
}

/// How the tracker shows a task: "[x] Call mom", with "  !!" after an urgent one.
impl fmt::Display for Task {
    fn fmt(&self, f: &mut fmt::Formatter) -> fmt::Result {
        let mark = if self.is_done() { 'x' } else { ' ' };
        write!(f, "[{mark}] {}", self.title)?; // writing can fail; ? passes that on (lesson 11)
        if self.kind == Kind::Urgent {
            write!(f, "  !!")?;
        }
        Ok(())
    }
}

/// The error when a line isn't a task. It keeps the line, so the message can show it.
#[derive(Debug, PartialEq)]
pub struct NotATask(pub String);

impl fmt::Display for NotATask {
    fn fmt(&self, f: &mut fmt::Formatter) -> fmt::Result {
        write!(f, "not a task: {:?}", self.0)
    }
}

/// "[done.] Call mom".parse::<Task>(). Lesson 11 loads the file with it.
impl FromStr for Task {
    type Err = NotATask;

    fn from_str(line: &str) -> Result<Self, Self::Err> {
        parse_task(line).ok_or_else(|| NotATask(line.to_string()))
    }
}

/// Works for any type that implements Display: `T: fmt::Display` is the promise it relies on.
fn show_all<T: fmt::Display>(label: &str, items: &[T]) {
    print!("{label}:");
    for item in items {
        print!(" <{item}>");
    }
    println!();
}

pub fn run() {
    for line in [
        "[done.] Call mom #family",
        "[todo] Finish quarterly report #work #urgent",
        "Shopping list:",
    ] {
        match line.parse::<Task>() {
            Ok(task) => println!("{task}"),
            Err(e) => println!("{e}"),
        }
    }
    let statuses = [
        Status::Todo,
        Status::Done,
        Status::Other("later".to_string()),
    ];
    show_all("statuses", &statuses);
    show_all("numbers", &[3, 2, 1]); // the same function, a different type
    let text = Task::new("Pay rent").to_string(); // Display gives you to_string() for free
    println!("to_string() -> {text:?}");

    #[cfg(feature = "bug10")]
    println!("{}", Kind::Urgent); // {} needs Display; Kind has only Debug, so {:?} would work
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn shows_and_parses_tasks() {
        let task: Task = "[todo] Finish report #urgent".parse().unwrap();
        assert_eq!(task.to_string(), "[ ] Finish report  !!");
        assert_eq!("hello".parse::<Task>(), Err(NotATask("hello".to_string())));
    }
}
