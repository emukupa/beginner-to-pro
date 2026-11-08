//! The tasks file: the only module that opens files.

use std::collections::hash_map::RandomState;
use std::fmt;
use std::fs::{self, File, OpenOptions};
use std::hash::{BuildHasher, Hasher};
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

/// A new file beside another, that deletes itself when it's dropped, unless it replaced the other.
/// This is how Rust undoes half-finished work: the cleanup belongs to a value, and runs whenever that
/// value goes away, whether the function returned normally or left early with `?`.
struct TempFile {
    path: String,
    file: File,
    kept: bool,
}

impl TempFile {
    /// Creates it with a random name, and `create_new`, so it can't be anyone else's file.
    fn beside(path: &str) -> io::Result<TempFile> {
        loop {
            let random = RandomState::new().build_hasher().finish(); // std's own random keys
            let name = format!("{path}.{random:016x}");
            match OpenOptions::new().write(true).create_new(true).open(&name) {
                Ok(file) => return Ok(TempFile { path: name, file, kept: false }),
                Err(e) if e.kind() == io::ErrorKind::AlreadyExists => continue,
                Err(e) => return Err(e),
            }
        }
    }

    /// On the disk first, then renamed over `target`: readers see the old file or the new one, never
    /// half of one. It takes `self`, not `&self`: once it's replaced, the TempFile is gone.
    fn replace(mut self, target: &str) -> io::Result<()> {
        self.file.sync_all()?;
        fs::rename(&self.path, target)?;
        self.kept = true;
        Ok(())
    }
}

impl Drop for TempFile {
    fn drop(&mut self) {
        if !self.kept {
            let _ = fs::remove_file(&self.path); // nothing more to do if even this fails
        }
    }
}

/// True if this line holds the task: the same title and status after parsing.
fn holds(line: &str, task: &Task) -> bool {
    line.parse::<Task>().is_ok_and(|found| found.title == task.title && found.status == task.status)
}

/// Where the status bracket is: the first [ and the first ] after it.
fn bracket(line: &str) -> Option<(usize, usize)> {
    let open = line.find('[')?;
    let close = open + line[open..].find(']')?;
    Some((open, close))
}

/// Rewrites the line holding this task as [done], leaving every other byte of the file alone.
pub fn mark_done(path: &str, task: &Task) -> io::Result<()> {
    let text = fs::read_to_string(path)?;
    let mut out = String::with_capacity(text.len());
    let mut changed = false;
    for line in text.split_inclusive('\n') {
        // split_inclusive keeps each line's own ending, so a Windows file keeps its \r\n.
        match bracket(line) {
            Some((open, close)) if !changed && holds(line, task) => {
                out.push_str(&line[..open]); // any spaces before the bracket
                out.push_str("[done]");
                out.push_str(&line[close + 1..]); // the title, tags and line ending
                changed = true;
            }
            _ => out.push_str(line),
        }
    }

    let mut temp = TempFile::beside(path)?;
    temp.file.set_permissions(fs::metadata(path)?.permissions())?; // keep the old file's
    temp.file.write_all(out.as_bytes())?;
    temp.replace(path)
} // any `?` above that fails drops `temp`, and Drop deletes the half-made file
