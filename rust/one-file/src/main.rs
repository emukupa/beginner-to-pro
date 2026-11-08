//! The task tracker in one Rust file. Same prompts, summary and chart as the Python version, byte
//! for byte: contract/run.sh checks every one. Read top to bottom: settings, what a task is,
//! parsing a line, the file, counting and ranking, the chart, then main, the only part that talks
//! to the user.
//!
//! Who owns the memory? Every value has exactly one owner, and the compiler checks it: the list owns
//! its tasks, each task owns its title and tags, and a tag count only borrows a tag's name. Nothing
//! is freed by hand, and nothing can be used after it's gone.

use std::collections::HashMap;
use std::fmt;
use std::fs::{self, OpenOptions};
use std::io::{self, BufRead, Write};
use std::str::FromStr;

// ---- Settings -------------------------------------------------------------------------------

const CHART_WIDTH: usize = 20; // the longest bar, in characters
const DEFAULT_TOP: i64 = 3; // top tags shown when the answer is empty or invalid
const TAG_MARKER: char = '#'; // marks a word as a tag: "#work"
const BAR: &str = "█";
const _: () = assert!(DEFAULT_TOP >= 1, "the fallback must itself be a valid answer");
const _: () = assert!(CHART_WIDTH > 0, "a chart needs room for its bars");

// ---- What a task is -------------------------------------------------------------------------

/// The status, cleaned the moment we read it. An enum can carry data: an unknown status keeps its word.
#[derive(Debug, Clone, PartialEq)]
enum Status {
    Todo,
    Done,
    Other(String),
}

/// Rust has no inheritance; Python's UrgentTask(Task) is a kind field.
#[derive(Debug, Clone, Copy, PartialEq)]
enum Kind {
    Plain,
    Urgent,
}

#[derive(Debug, Clone)]
struct Task {
    title: String,
    tags: Vec<String>,
    status: Status,
    kind: Kind,
}

impl Task {
    fn is_done(&self) -> bool {
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

// ---- Parsing one line -----------------------------------------------------------------------

/// Why a line isn't a task. Python returned None; here the reason has a name.
#[derive(Debug)]
struct NotATask;

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
        let status = match status.trim_matches(|c| "[] .".contains(c)).to_lowercase().as_str() {
            "done" => Status::Done,
            "todo" => Status::Todo,
            other => Status::Other(other.to_string()),
        };
        let (tags, words): (Vec<&str>, Vec<&str>) = rest.split_whitespace().partition(|w| w.starts_with(TAG_MARKER));
        let tags: Vec<String> = tags
            .iter()
            .map(|t| t.trim_start_matches(TAG_MARKER).trim_matches(['.', ',']).to_lowercase())
            .collect();
        let kind = if tags.iter().any(|t| t == "urgent") { Kind::Urgent } else { Kind::Plain };
        Ok(Task { title: words.join(" "), tags, status, kind })
    }
}

// ---- The file -------------------------------------------------------------------------------

/// Everything that can go wrong with the tasks file, each case carrying what the message needs.
#[derive(Debug)]
enum LoadError {
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
fn load_tasks(path: &str) -> Result<Vec<Task>, LoadError> {
    let text = fs::read_to_string(path).map_err(|e| match e.kind() {
        io::ErrorKind::NotFound => LoadError::NotFound(path.to_string()),
        _ => LoadError::Unreadable(path.to_string()),
    })?;
    Ok(text.lines().filter_map(|line| line.parse().ok()).collect())
}

/// Parses each title as a new "[todo]" task and adds it. Returns how many were added.
fn add_tasks(tasks: &mut Vec<Task>, titles: &[String]) -> usize {
    let before = tasks.len();
    tasks.extend(titles.iter().filter_map(|title| format!("[todo] {title}").parse().ok()));
    tasks.len() - before
}

/// "[todo] title" lines on the end of the file.
fn append_titles(path: &str, titles: &[String]) -> io::Result<()> {
    let mut file = OpenOptions::new().append(true).open(path)?;
    for title in titles {
        writeln!(file, "[todo] {title}")?;
    }
    Ok(())
}

// ---- Counting and ranking -------------------------------------------------------------------

/// A tag and how many tasks carry it. The 'a says the tag is borrowed from the tasks: a count can't
/// outlive the list it was counted from, and the compiler checks that.
#[derive(Debug, Clone, Copy)]
struct TagCount<'a> {
    tag: &'a str,
    count: usize,
}

/// Every tag with how many tasks carry it, in the order each tag first appears. The HashMap finds a
/// tag's place fast; the Vec keeps the order, which a HashMap doesn't.
fn count_tags(tasks: &[Task], include_done: bool) -> Vec<TagCount<'_>> {
    let mut counts: Vec<TagCount> = Vec::new();
    let mut place: HashMap<&str, usize> = HashMap::new();
    for task in tasks.iter().filter(|t| include_done || !t.is_done()) {
        for tag in &task.tags {
            let i = *place.entry(tag.as_str()).or_insert_with(|| {
                counts.push(TagCount { tag, count: 0 });
                counts.len() - 1
            });
            counts[i].count += 1;
        }
    }
    counts
}

/// Why there are no top tags: Python's ValueError.
#[derive(Debug)]
struct NeedAtLeastOne;

/// The n most used tags, most first. Rust's sort is stable, so ties keep first-seen order.
fn top_tags(tasks: &[Task], n: i64, include_done: bool) -> Result<Vec<TagCount<'_>>, NeedAtLeastOne> {
    if n < 1 {
        return Err(NeedAtLeastOne);
    }
    let mut counts = count_tags(tasks, include_done);
    counts.sort_by_key(|c| std::cmp::Reverse(c.count));
    counts.truncate(usize::try_from(n).unwrap_or(usize::MAX));
    Ok(counts)
}

// ---- The chart ------------------------------------------------------------------------------

fn draw_chart(out: &mut impl Write, pairs: &[TagCount], width: usize) -> io::Result<()> {
    let Some(biggest) = pairs.first().map(|p| p.count as f64) else {
        return writeln!(out, "No tags yet.");
    };
    let label_width = pairs.iter().map(|p| p.tag.chars().count()).max().unwrap_or(0);
    for p in pairs {
        let blocks = (p.count as f64 / biggest * width as f64).round_ties_even() as usize; // like Python's round()
        let pad = " ".repeat(label_width - p.tag.chars().count()); // by characters, not bytes
        writeln!(out, "{}{pad}  {} {}", p.tag, BAR.repeat(blocks), p.count)?;
    }
    Ok(())
}

// ---- Talking to the user --------------------------------------------------------------------

/// Like Python's input(): shows the prompt, reads one line. An empty line at the end of input.
fn ask(prompt: &str) -> io::Result<String> {
    print!("{prompt}");
    io::stdout().flush()?;
    let mut line = String::new();
    io::stdin().lock().read_line(&mut line)?;
    Ok(line.strip_suffix('\n').unwrap_or(&line).to_string())
}

/// Python's int(text): optional spaces, an optional sign, digits with single underscores between
/// them, optional spaces. None for anything else. Huge numbers are capped.
fn parse_whole_number(text: &str) -> Option<i64> {
    let s = text.trim().as_bytes();
    let (negative, digits) = match s.first() {
        Some(b'-') => (true, &s[1..]),
        Some(b'+') => (false, &s[1..]),
        _ => (false, s),
    };
    if !digits.first()?.is_ascii_digit() {
        return None;
    }
    let mut value: i64 = 0;
    for (i, &b) in digits.iter().enumerate() {
        if b == b'_' && i + 1 < digits.len() && digits[i + 1].is_ascii_digit() && digits[i - 1].is_ascii_digit() {
            continue;
        }
        if !b.is_ascii_digit() {
            return None;
        }
        value = value.saturating_mul(10).saturating_add(i64::from(b - b'0'));
    }
    Some(if negative { -value } else { value })
}

fn main() -> io::Result<()> {
    let path = std::env::args().nth(1).or_else(|| std::env::var("TASKS_FILE").ok()).unwrap_or_else(|| "tasks.txt".to_string());

    let mut tasks = match load_tasks(&path) {
        Ok(tasks) => tasks,
        Err(e) => {
            eprintln!("{e}");
            std::process::exit(1);
        }
    };

    let mut new_titles = Vec::new();
    loop {
        let answer = ask("New task (Enter to finish): ")?;
        let title = answer.trim();
        if title.is_empty() {
            break;
        }
        if title.starts_with(TAG_MARKER) {
            println!("A task needs a title, not just tags.");
            continue;
        }
        new_titles.push(title.to_string());
    }
    if add_tasks(&mut tasks, &new_titles) > 0 {
        append_titles(&path, &new_titles)?;
    }

    let answer = ask("How many top tags? [3]: ")?;
    let n = if answer.is_empty() { DEFAULT_TOP } else { parse_whole_number(&answer).unwrap_or(0) };
    let pairs = top_tags(&tasks, n, true).unwrap_or_else(|NeedAtLeastOne| {
        println!("Need a whole number of at least 1 — using 3.");
        top_tags(&tasks, DEFAULT_TOP, true).expect("DEFAULT_TOP is at least 1")
    });

    let done = tasks.iter().filter(|t| t.is_done()).count();
    let percent = if tasks.is_empty() { 0.0 } else { done as f64 / tasks.len() as f64 * 100.0 };
    println!("\n{} tasks, {done} done ({}%), {} tags", tasks.len(), percent.round_ties_even(), count_tags(&tasks, true).len());
    for task in tasks.iter().filter(|t| t.kind == Kind::Urgent && !t.is_done()) {
        println!("{task}");
    }

    println!("\nTop tags");
    draw_chart(&mut io::stdout().lock(), &pairs, CHART_WIDTH)
}
