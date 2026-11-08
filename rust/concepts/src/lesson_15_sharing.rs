//! Lesson 15: sometimes a value has several owners. Rc (reference counted) shares one value and
//! frees it when the last owner goes. Here every task holding "work" shares one Rc<str>: the name
//! is stored once, and unlike lesson 14's borrows, the tasks can outlive where the names came from.
//! Rc keeps its count without any locking, so it's only safe on one thread. Arc ("atomic Rc") is
//! the same idea, safe across threads, at a small cost; the tracker has no threads, so it uses Rc.
//! bug15: sending an Rc to another thread. The compiler refuses: Rc isn't Send.

use std::collections::HashSet;
use std::rc::Rc;

use crate::lesson_11_errors::load_tasks;

pub const TITLE: &str = "Sharing with Rc (and why Arc)";

/// Hands out one shared Rc<str> per distinct tag name.
#[derive(Default)]
pub struct TagNames {
    names: HashSet<Rc<str>>,
}

impl TagNames {
    pub fn get(&mut self, name: &str) -> Rc<str> {
        if let Some(existing) = self.names.get(name) {
            return Rc::clone(existing); // a new owner of the same text: just adds 1 to the count
        }
        let fresh: Rc<str> = Rc::from(name);
        self.names.insert(Rc::clone(&fresh));
        fresh
    }
}

pub struct SharedTask {
    pub title: String,
    pub tags: Vec<Rc<str>>,
}

pub fn run() {
    let tasks = load_tasks("tasks.txt").expect("run from rust/concepts, next to tasks.txt");
    let mut names = TagNames::default();
    let mut shared = Vec::new();
    for task in &tasks {
        let mut tags = Vec::new();
        for tag in &task.tags {
            tags.push(names.get(tag));
        }
        shared.push(SharedTask {
            title: task.title.clone(),
            tags,
        });
    }
    drop(tasks); // the originals are gone; the shared tasks own their tag names
    for task in shared.iter().take(2) {
        println!("{}: {:?}", task.title, task.tags);
    }

    let work = names.get("work");
    // Owners: the TagNames set, three tasks, and `work` here.
    println!(
        "\"work\" is stored once, with {} owners",
        Rc::strong_count(&work)
    );
    println!(
        "tasks 2 and 4 share it? {}",
        Rc::ptr_eq(&shared[1].tags[0], &shared[3].tags[0])
    );
    drop(shared); // three owners leave; the text stays until the count reaches 0
    println!(
        "after dropping the tasks: {} owners",
        Rc::strong_count(&work)
    );

    #[cfg(feature = "bug15")]
    {
        let tag = Rc::clone(&work);
        // Two threads changing the count at once could get it wrong and free the text too early.
        // With Arc instead of Rc, this builds and runs.
        std::thread::spawn(move || println!("{tag}"))
            .join()
            .unwrap();
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn one_name_many_owners() {
        let mut names = TagNames::default();
        let a = names.get("work");
        let b = names.get("work");
        assert!(Rc::ptr_eq(&a, &b));
        assert_eq!(Rc::strong_count(&a), 3);
    }
}
