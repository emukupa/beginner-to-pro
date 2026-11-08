//! Turning one line of text into a Task. No files, no printing: just text in, a Task out.

use std::str::FromStr;

use crate::models::{Kind, Status, Task};

pub const TAG_MARKER: char = '#'; // marks a word as a tag: "#work"

/// Why a line isn't a task. Python returned None; here the reason has a name.
#[derive(Debug)]
pub struct NotATask;

/// No `pub`: only this file can call it. Everything in Rust is private unless it says otherwise.
fn status_of(word: &str) -> Status {
    match word.trim_matches(|c| "[] .".contains(c)).to_lowercase().as_str() {
        "done" => Status::Done,
        "todo" => Status::Todo,
        other => Status::Other(other.to_string()),
    }
}

/// "[done.] Call mom #family" -> a Task. `"...".parse::<Task>()` calls this.
impl FromStr for Task {
    type Err = NotATask;

    fn from_str(line: &str) -> Result<Task, NotATask> {
        let s = line.trim();
        if !s.starts_with('[') {
            return Err(NotATask);
        }
        // Python's partition("]"): what's before the first ], and what's after it.
        let (status, rest) = s.split_once(']').unwrap_or((s, ""));
        let (tags, words): (Vec<&str>, Vec<&str>) = rest.split_whitespace().partition(|w| w.starts_with(TAG_MARKER));
        let tags: Vec<String> = tags
            .iter()
            .map(|t| t.trim_start_matches(TAG_MARKER).trim_matches(['.', ',']).to_lowercase())
            .collect();
        let kind = if tags.iter().any(|t| t == "urgent") { Kind::Urgent } else { Kind::Plain };
        Ok(Task { title: words.join(" "), tags, status: status_of(status), kind })
    }
}

/// Tests live beside the code they test, and are only compiled by `cargo test`. Being inside this
/// file, they can see its private functions too.
#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn reads_status_title_and_tags() {
        let task: Task = "[DONE.] Call mom #Family #urgent,".parse().unwrap();
        assert_eq!(task.status, Status::Done);
        assert_eq!(task.title, "Call mom");
        assert_eq!(task.tags, ["family", "urgent"]);
        assert_eq!(task.kind, Kind::Urgent);
    }

    #[test]
    fn keeps_an_unknown_status() {
        assert_eq!(status_of("[later]"), Status::Other("later".to_string()));
    }

    #[test]
    fn a_line_without_a_bracket_is_not_a_task() {
        assert!("Buy milk #home".parse::<Task>().is_err());
    }
}
