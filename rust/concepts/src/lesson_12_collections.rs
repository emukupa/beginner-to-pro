//! Lesson 12: Vec is a list that grows; a slice (&[T]) looks at part or all of one; HashMap finds
//! a value by key. Indexing checks bounds: there's no reading past the end, as there is in C.
//! bug12: reading tasks[tasks.len()], one past the end. It builds, then panics instead of
//! reading whatever memory is there.

use std::collections::{HashMap, HashSet};

use crate::lesson_09_structs::Task;
use crate::lesson_11_errors::load_tasks;

pub const TITLE: &str = "Collections";

/// Each tag and how many tasks have it, in the order tags first appear. A HashMap alone can't do
/// this: it forgets the order. So the Vec keeps the order and the HashMap finds a tag's place in it.
pub fn count_tags(tasks: &[Task]) -> Vec<(String, usize)> {
    let mut counts: Vec<(String, usize)> = Vec::new();
    let mut place: HashMap<String, usize> = HashMap::new(); // tag -> its index in `counts`
    for task in tasks {
        for tag in &task.tags {
            match place.get(tag) {
                Some(&i) => counts[i].1 += 1,
                None => {
                    place.insert(tag.clone(), counts.len());
                    counts.push((tag.clone(), 1));
                }
            }
        }
    }
    counts
}

pub fn run() {
    let mut tasks = load_tasks("tasks.txt").expect("run from rust/concepts, next to tasks.txt");
    println!("{} tasks", tasks.len());
    tasks.push(Task::new("Water plants"));
    let popped = tasks.pop(); // an Option: the list might have been empty
    println!(
        "pushed then popped: {:?}, back to {}",
        popped.map(|t| t.title),
        tasks.len()
    );

    let first_two: &[Task] = &tasks[..2]; // a slice: a view of part of the Vec, no copying
    for task in first_two {
        println!("  {task}");
    }
    println!("tasks.get(1) is {:?}", tasks.get(1).map(|t| &t.title));
    println!("tasks.get(99) is {:?}", tasks.get(99).map(|t| &t.title)); // None, not a crash

    let mut by_tag: HashMap<&str, usize> = HashMap::new();
    for task in &tasks {
        for tag in &task.tags {
            *by_tag.entry(tag).or_insert(0) += 1; // entry: find the slot, or make one at 0
        }
    }
    println!(
        "by_tag[\"work\"] = {}, by_tag.get(\"gym\") = {:?}",
        by_tag["work"],
        by_tag.get("gym")
    );
    // A HashMap's order changes from run to run (it's seeded at random, against attacks), so it's
    // never printed whole here. Tags with equal counts must keep file order, so count_tags it is.
    let distinct: HashSet<&String> = tasks.iter().flat_map(|t| &t.tags).collect();
    println!("{} distinct tags", distinct.len());
    println!("count_tags: {:?}", count_tags(&tasks));

    #[cfg(feature = "bug12")]
    println!("{}", tasks[tasks.len()]); // indexes run 0..len: this is one too far
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn counts_keep_first_seen_order() {
        let tasks = load_tasks("tasks.txt").unwrap();
        let counts = count_tags(&tasks);
        let names: Vec<&str> = counts.iter().map(|(tag, _)| tag.as_str()).collect();
        assert_eq!(names, ["home", "work", "urgent", "family", "travel"]);
        assert_eq!(counts[1].1, 3);
    }
}
