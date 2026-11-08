//! Lesson 14: a reference must never outlive what it points at. A lifetime ('a) is the name for
//! "as long as that lives". TagCount<'a> borrows each tag name from the tasks instead of copying
//! it, and the compiler checks no TagCount is used after the tasks are gone.
//! Everything so far comes together here: a mini tracker, run on tasks.txt.
//! bug14: keeping the ranking after its tasks are dropped. The borrow checker refuses to build.

use std::cmp::Reverse;
use std::collections::HashMap;

use crate::lesson_06_functions::percent;
use crate::lesson_08_enums::Kind;
use crate::lesson_09_structs::Task;
use crate::lesson_11_errors::{load_tasks, parse_top};
use crate::lesson_13_iterators::bar;

pub const TITLE: &str = "Lifetimes";

#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub struct TagCount<'a> {
    pub tag: &'a str, // borrowed from a Task: this TagCount can live only as long as that Task
    pub count: usize,
}

/// Lesson 12's count and lesson 13's stable sort, without copying a single tag name. `'_` says the
/// result borrows from `tasks`.
pub fn rank_tags(tasks: &[Task]) -> Vec<TagCount<'_>> {
    let mut counts: Vec<TagCount> = Vec::new();
    let mut place: HashMap<&str, usize> = HashMap::new();
    for tag in tasks.iter().flat_map(|t| &t.tags) {
        match place.get(tag.as_str()) {
            Some(&i) => counts[i].count += 1,
            None => {
                place.insert(tag, counts.len());
                counts.push(TagCount { tag, count: 1 });
            }
        }
    }
    counts.sort_by_key(|t| Reverse(t.count));
    counts
}

/// Two inputs, one borrowed result: 'a tells the compiler the result lives no longer than either.
fn longer<'a>(a: &'a str, b: &'a str) -> &'a str {
    if a.chars().count() >= b.chars().count() {
        a
    } else {
        b
    }
}

/// The tracker's chart: labels padded by characters, the biggest bar 20 wide.
pub fn draw_chart(ranked: &[TagCount], top: usize) {
    let shown = &ranked[..top.min(ranked.len())];
    let Some(first) = shown.first() else {
        println!("No tags yet.");
        return;
    };
    let width = shown
        .iter()
        .map(|t| t.tag.chars().count())
        .max()
        .unwrap_or(0);
    for t in shown {
        println!(
            "{:<width$}  {} {}",
            t.tag,
            bar(t.count, first.count, 20),
            t.count
        );
    }
}

pub fn run() {
    let tasks = load_tasks("tasks.txt").expect("run from rust/concepts, next to tasks.txt");
    let top = parse_top("3").unwrap_or(3);
    let ranked = rank_tags(&tasks);
    let done = tasks.iter().filter(|t| t.is_done()).count();
    println!(
        "{} tasks, {done} done ({:.0}%), {} tags",
        tasks.len(),
        percent(done, tasks.len()),
        ranked.len()
    );
    for task in tasks
        .iter()
        .filter(|t| t.kind == Kind::Urgent && !t.is_done())
    {
        println!("{task}");
    }
    println!("\nTop tags");
    draw_chart(&ranked, top);
    println!(
        "\nlonger(\"home\", \"travel\") = {:?}",
        longer("home", "travel")
    );

    #[cfg(feature = "bug14")]
    {
        let kept;
        {
            let local = load_tasks("tasks.txt").expect("tasks.txt");
            kept = rank_tags(&local); // kept borrows tag names from local...
        } // ...and local is dropped here
        println!("{:?}", kept[0]); // so kept would point at freed memory: refused
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn ranks_tags_with_ties_in_file_order() {
        let tasks = load_tasks("tasks.txt").unwrap();
        let ranked = rank_tags(&tasks);
        let names: Vec<&str> = ranked.iter().map(|t| t.tag).collect();
        assert_eq!(names, ["work", "home", "urgent", "family", "travel"]);
        assert_eq!(
            ranked[0],
            TagCount {
                tag: "work",
                count: 3
            }
        );
    }
}
