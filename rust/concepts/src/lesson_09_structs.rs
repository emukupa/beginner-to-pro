//! Lesson 09: a struct bundles named fields; an `impl` block gives it methods. `&self` methods
//! read, `&mut self` methods change. There are no classes and no inheritance: a Kind field says
//! what sort of task it is.
//! bug09: calling a `&mut self` method on a task that wasn't declared `mut`.

use crate::lesson_08_enums::{Kind, Status, parse_status, tag_of};

pub const TITLE: &str = "Structs and impl";

#[derive(Debug, Clone, PartialEq)]
pub struct Task {
    pub title: String,
    pub status: Status,
    pub kind: Kind,
    pub tags: Vec<String>, // a Vec: a list that grows (lesson 12)
}

impl Task {
    /// A new task to do. `Self` means the type this impl is for.
    pub fn new(title: &str) -> Self {
        Self {
            title: title.to_string(),
            status: Status::Todo,
            kind: Kind::Plain,
            tags: Vec::new(),
        }
    }

    pub fn is_done(&self) -> bool {
        self.status == Status::Done
    }

    pub fn mark_done(&mut self) {
        self.status = Status::Done;
    }
}

/// "[done.] Call mom #family" -> a Task, or None if the line isn't a task. Lesson 10 uses it.
pub fn parse_task(line: &str) -> Option<Task> {
    let rest = line.trim().strip_prefix('[')?; // ? on an Option: if it's None, return None now
    let (status, rest) = rest.split_once(']')?;
    let mut task = Task::new("");
    task.status = parse_status(status);
    let mut words = Vec::new();
    for word in rest.split_whitespace() {
        if !word.starts_with('#') {
            words.push(word);
        } else if let Some(tag) = tag_of(word) {
            if tag == "urgent" {
                task.kind = Kind::Urgent;
            }
            task.tags.push(tag);
        }
    }
    task.title = words.join(" ");
    Some(task)
}

pub fn run() {
    let mut task = Task::new("Pay rent");
    println!("{task:?}");
    task.mark_done(); // the same as Task::mark_done(&mut task)
    println!("after mark_done: is_done() = {}", task.is_done());

    if let Some(parsed) = parse_task("[DONE.] Fix login bug #work #urgent") {
        println!(
            "parsed: title {:?}, status {:?}, kind {:?}, tags {:?}",
            parsed.title, parsed.status, parsed.kind, parsed.tags
        );
    }
    println!(
        "parse_task(\"Shopping list:\") = {:?}",
        parse_task("Shopping list:")
    );
    let bills = Task {
        title: "Pay bills".to_string(),
        ..task.clone()
    }; // the rest copied from task
    println!(
        "struct update: {:?} is done? {}",
        bills.title,
        bills.is_done()
    );

    #[cfg(feature = "bug09")]
    {
        let fresh = Task::new("Walk dog");
        fresh.mark_done(); // mark_done needs &mut, and `fresh` isn't mut: changes must be declared
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn parses_a_messy_line() {
        let task = parse_task("[ todo ] Review pull request #work.").unwrap();
        assert_eq!(task.title, "Review pull request");
        assert_eq!(task.status, Status::Todo);
        assert_eq!(task.tags, ["work"]);
        assert_eq!(task.kind, Kind::Plain);
        assert!(parse_task("no brackets").is_none());
    }
}
