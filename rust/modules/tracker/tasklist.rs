//! Working with the list: adding, counting, ranking, summing up. No files, no printing.

use std::collections::HashMap;

use crate::models::Task;

/// Parses each title as a new "[todo]" task and adds it. Returns how many were added.
pub fn add_tasks(tasks: &mut Vec<Task>, titles: &[String]) -> usize {
    let before = tasks.len();
    tasks.extend(titles.iter().filter_map(|title| format!("[todo] {title}").parse().ok()));
    tasks.len() - before
}

/// A tag and how many tasks carry it. The 'a says the tag is borrowed from the tasks: a count can't
/// outlive the list it was counted from, and the compiler checks that.
#[derive(Debug, Clone, Copy)]
pub struct TagCount<'a> {
    pub tag: &'a str,
    pub count: usize,
}

/// Every tag with how many tasks carry it, in the order each tag first appears. The HashMap finds a
/// tag's place fast; the Vec keeps the order, which a HashMap doesn't.
pub fn count_tags(tasks: &[Task], include_done: bool) -> Vec<TagCount<'_>> {
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
pub struct NeedAtLeastOne;

/// The n most used tags, most first. Rust's sort is stable, so ties keep first-seen order.
pub fn top_tags(tasks: &[Task], n: i64, include_done: bool) -> Result<Vec<TagCount<'_>>, NeedAtLeastOne> {
    if n < 1 {
        return Err(NeedAtLeastOne);
    }
    let mut counts = count_tags(tasks, include_done);
    counts.sort_by_key(|c| std::cmp::Reverse(c.count));
    counts.truncate(usize::try_from(n).unwrap_or(usize::MAX));
    Ok(counts)
}

/// The numbers on the summary line.
pub struct Summary {
    pub total: usize,
    pub done: usize,
    pub percent: f64,
    pub tags: usize,
}

pub fn summarize(tasks: &[Task]) -> Summary {
    let done = tasks.iter().filter(|t| t.is_done()).count();
    let percent = if tasks.is_empty() { 0.0 } else { done as f64 / tasks.len() as f64 * 100.0 };
    Summary { total: tasks.len(), done, percent: percent.round_ties_even(), tags: count_tags(tasks, true).len() }
}

#[cfg(test)]
mod tests {
    use super::*;

    fn tasks(lines: &[&str]) -> Vec<Task> {
        lines.iter().filter_map(|l| l.parse().ok()).collect()
    }

    #[test]
    fn ties_keep_first_seen_order() {
        let list = tasks(&["[todo] a #work #home", "[todo] b #home #work", "[todo] c #play"]);
        let top: Vec<&str> = top_tags(&list, 3, true).unwrap().iter().map(|c| c.tag).collect();
        assert_eq!(top, ["work", "home", "play"]);
    }

    #[test]
    fn zero_is_refused() {
        assert!(top_tags(&[], 0, true).is_err());
    }

    #[test]
    fn halves_round_to_even() {
        let list = tasks(&["[done] a", "[todo] b", "[todo] c", "[todo] d", "[todo] e", "[todo] f", "[todo] g", "[todo] h"]);
        assert_eq!(summarize(&list).percent, 12.0); // 12.5 -> 12, like Python's round()
    }
}
