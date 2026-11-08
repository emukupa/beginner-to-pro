//! The tasks file: the only module that opens files.

use std::fmt;
use std::fs::{self, OpenOptions};
use std::io::{self, Write};

use crate::models::Task;

/// Everything that can go wrong reading the tasks file, each case carrying what the message needs.
#[derive(Debug)]
pub enum LoadError {
    NotFound(String),
    Unreadable(String),
}

impl fmt::Display for LoadError {
    fn fmt(&self, f: &mut fmt::Formatter) -> fmt::Result {
        match self {
            LoadError::NotFound(path) => write!(f, "Couldn't find {path}"),
            LoadError::Unreadable(path) => write!(f, "Couldn't read {path}"),
        }
    }
}

/// Every task in the file; lines that aren't tasks are skipped.
pub fn load_tasks(path: &str) -> Result<Vec<Task>, LoadError> {
    let text = fs::read_to_string(path).map_err(|e| match e.kind() {
        io::ErrorKind::NotFound => LoadError::NotFound(path.to_string()),
        _ => LoadError::Unreadable(path.to_string()),
    })?;
    Ok(text.lines().filter_map(|line| line.parse().ok()).collect())
}

/// "[todo] title" lines on the end of the file.
pub fn append_titles(path: &str, titles: &[String]) -> io::Result<()> {
    let mut file = OpenOptions::new().append(true).open(path)?;
    for title in titles {
        writeln!(file, "[todo] {title}")?;
    }
    Ok(())
}
