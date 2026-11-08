//! What a task is. Every other module uses these; this one uses none of ours.

use std::fmt;

/// The status, cleaned the moment we read it. An enum can carry data: an unknown status keeps its word.
#[derive(Debug, Clone, PartialEq)]
pub enum Status {
    Todo,
    Done,
    Other(String),
}

/// Rust has no inheritance; Python's UrgentTask(Task) is a kind field.
#[derive(Debug, Clone, Copy, PartialEq)]
pub enum Kind {
    Plain,
    Urgent,
}

/// `pub struct` makes the type visible; each field needs its own `pub` too.
#[derive(Debug, Clone)]
pub struct Task {
    pub title: String,
    pub tags: Vec<String>,
    pub status: Status,
    pub kind: Kind,
}

impl Task {
    pub fn is_done(&self) -> bool {
        self.status == Status::Done
    }
}

/// How a task prints: "[ ] Title", and "  !!" on the end of an urgent one.
impl fmt::Display for Task {
    fn fmt(&self, f: &mut fmt::Formatter) -> fmt::Result {
        let mark = if self.is_done() { 'x' } else { ' ' };
        let urgent = if self.kind == Kind::Urgent { "  !!" } else { "" };
        write!(f, "[{mark}] {}{urgent}", self.title)
    }
}
