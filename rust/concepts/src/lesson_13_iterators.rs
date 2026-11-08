//! Lesson 13: an iterator hands out items one at a time. Adapters like map and filter take
//! closures and do nothing until something (count, sum, collect) asks for the items. Rust's sorts
//! are stable: equal items keep their order.
//! bug13: sorting a Vec<f64> with sort(). sort() needs a total order (Ord), and floats don't have
//! one, because NaN isn't less than, equal to or greater than anything.

use std::cmp::Reverse;

use crate::lesson_06_functions::percent;
use crate::lesson_08_enums::Kind;
use crate::lesson_11_errors::load_tasks;
use crate::lesson_12_collections::count_tags;

pub const TITLE: &str = "Iterators and sorting";

/// Most-used first. sort_by_key (like sort and sort_by) is stable, so tags with the same count
/// stay in first-seen order. (sort_unstable_by_key is faster but may swap equal items, which
/// would break the tracker's ties.)
pub fn rank(mut pairs: Vec<(String, usize)>) -> Vec<(String, usize)> {
    pairs.sort_by_key(|pair| Reverse(pair.1)); // sort by the count alone; Reverse: biggest first
    pairs
}

/// A bar of █ for `count`, scaled so `biggest` is `width` long. Halves round to even, like Python.
pub fn bar(count: usize, biggest: usize, width: usize) -> String {
    let blocks = (count as f64 / biggest as f64 * width as f64).round_ties_even() as usize;
    "█".repeat(blocks)
}

pub fn run() {
    let tasks = load_tasks("tasks.txt").expect("run from rust/concepts, next to tasks.txt");
    let done = tasks.iter().filter(|t| t.is_done()).count();
    let tag_uses: usize = tasks.iter().map(|t| t.tags.len()).sum();
    println!(
        "{done} of {} done ({:.0}%), {tag_uses} tags used",
        tasks.len(),
        percent(done, tasks.len())
    );

    let titles: Vec<&str> = tasks.iter().map(|t| t.title.as_str()).collect();
    println!("titles: {titles:?}");
    for (i, task) in tasks.iter().enumerate().take(2) {
        println!("  {}. {task}", i + 1);
    }
    let first_urgent = tasks.iter().find(|t| t.kind == Kind::Urgent); // an Option<&Task>
    println!("first urgent: {:?}", first_urgent.map(|t| &t.title));
    let lengths = tasks.iter().map(|t| t.title.len()); // nothing has run yet...
    println!("longest title: {:?} bytes", lengths.max()); // ...max() runs it

    println!("ranked: {:?}", rank(count_tags(&tasks)));
    println!("bar(1, 2, 5) = {:?}: 2.5 blocks round to 2", bar(1, 2, 5));
    let mut shares = vec![0.5, 0.25, 0.75];
    shares.sort_by(f64::total_cmp); // total_cmp gives floats an order, NaN included
    println!("floats sorted with total_cmp: {shares:?}");

    #[cfg(feature = "bug13")]
    {
        let mut more: Vec<f64> = vec![0.5, 0.25];
        more.sort(); // f64 isn't Ord: the compiler won't guess what to do with NaN
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn ties_keep_their_order() {
        let pairs = vec![
            ("home".to_string(), 1),
            ("work".to_string(), 2),
            ("gym".to_string(), 1),
        ];
        let names: Vec<String> = rank(pairs).into_iter().map(|(tag, _)| tag).collect();
        assert_eq!(names, ["work", "home", "gym"]);
    }

    #[test]
    fn bars_round_halves_to_even() {
        assert_eq!(bar(1, 8, 20).chars().count(), 2); // 2.5 -> 2
        assert_eq!(bar(3, 8, 20).chars().count(), 8); // 7.5 -> 8
    }
}
