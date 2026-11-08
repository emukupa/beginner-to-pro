//! The task tracker, split into modules. This is the crate root: the `mod` lines below are the whole
//! program, and this file is the only one that reads input, prints to the screen or exits.
//!
//! Dependencies point one way, down this list: models <- parsing <- storage, tasklist <- chart <- cli.

mod chart;
mod models;
mod parsing;
mod storage;
mod tasklist;

use std::io::{self, BufRead, Write};

use models::Kind;
use parsing::TAG_MARKER;
use tasklist::NeedAtLeastOne;

const DEFAULT_TOP: i64 = 3; // top tags shown when the answer is empty or invalid
const _: () = assert!(DEFAULT_TOP >= 1, "the fallback must itself be a valid answer");

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

/// tracker done "title": marks one task finished. Returns the exit code.
fn done_command(words: &[String]) -> i32 {
    let joined = words.join(" ");
    let title = joined.trim();
    if title.is_empty() {
        eprintln!("Usage: done \"task title\"");
        return 2;
    }
    let path = std::env::var("TASKS_FILE").unwrap_or_else(|_| "tasks.txt".to_string());
    let tasks = match storage::load_tasks(&path) {
        Ok(tasks) => tasks,
        Err(e) => {
            eprintln!("{e}");
            return 1;
        }
    };
    let Some(task) = tasklist::find_task(&tasks, title) else {
        eprintln!("No task called \"{title}\"");
        return 1;
    };
    if task.is_done() {
        println!("Already done: {}", task.title);
        return 0;
    }
    if storage::mark_done(&path, task).is_err() {
        eprintln!("Couldn't write {path}");
        return 1;
    }
    println!("Done: {}", task.title);
    0
}

fn main() -> io::Result<()> {
    let args: Vec<String> = std::env::args().collect();
    if args.get(1).is_some_and(|a| a == "done") {
        // a second mode: tracker done "title"
        std::process::exit(done_command(&args[2..]));
    }

    let path = args.get(1).cloned().or_else(|| std::env::var("TASKS_FILE").ok()).unwrap_or_else(|| "tasks.txt".to_string());

    let mut tasks = match storage::load_tasks(&path) {
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
    if tasklist::add_tasks(&mut tasks, &new_titles) > 0 {
        storage::append_titles(&path, &new_titles)?;
    }

    let answer = ask("How many top tags? [3]: ")?;
    let n = if answer.is_empty() { DEFAULT_TOP } else { parse_whole_number(&answer).unwrap_or(0) };
    let pairs = tasklist::top_tags(&tasks, n, true).unwrap_or_else(|NeedAtLeastOne| {
        println!("Need a whole number of at least 1 — using 3.");
        tasklist::top_tags(&tasks, DEFAULT_TOP, true).expect("DEFAULT_TOP is at least 1")
    });

    let s = tasklist::summarize(&tasks);
    println!("\n{} tasks, {} done ({}%), {} tags", s.total, s.done, s.percent, s.tags);
    for task in tasks.iter().filter(|t| t.kind == Kind::Urgent && !t.is_done()) {
        println!("{task}");
    }

    println!("\nTop tags");
    chart::draw_chart(&mut io::stdout().lock(), &pairs, chart::CHART_WIDTH)
}
