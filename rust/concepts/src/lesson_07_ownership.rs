//! Lesson 07: every value has one owner, and is freed when its owner goes out of scope. Assigning
//! a String moves it to a new owner; `&` lends it out instead. This is how Rust frees memory
//! exactly once without free() or a garbage collector.
//! bug07: using a String after it moved. The borrow checker refuses to build.

pub const TITLE: &str = "Ownership and borrowing";

fn length(text: &str) -> usize {
    text.len() // borrows: looks, then hands it back when it returns
}

fn add_bang(text: &mut String) {
    text.push('!'); // a mutable borrow: may change the caller's String
}

fn consume(text: String) -> usize {
    text.len() // takes ownership: `text` is freed here, at the end of the function
}

/// Prints when it's dropped (freed), so you can see where that happens.
struct Noisy(&'static str);

impl Drop for Noisy {
    fn drop(&mut self) {
        println!("dropping {}", self.0);
    }
}

pub fn run() {
    let title = String::from("Fix login bug");
    let moved = title; // the String moves: `moved` owns it now, and `title` can't be used again
    println!("moved = {moved:?}");
    let copy = moved.clone(); // clone: a real second copy, when you need one
    let n = 6;
    let m = n; // small plain values (numbers, bool, char) are Copy: copied, not moved
    println!("n = {n}, m = {m}, copy = {copy:?}");

    println!(
        "length(&copy) = {}, and copy is still ours: {copy:?}",
        length(&copy)
    );
    let mut note = String::from("call mom");
    add_bang(&mut note);
    println!("after add_bang(&mut note): {note:?}");

    // Many readers, or one writer: never both at once. That rule is what stops data races.
    let r1 = &note;
    let r2 = &note;
    println!("two readers: {r1:?} {r2:?}");
    let writer = &mut note; // fine: the readers are finished with
    writer.push('?');
    println!("one writer: {note:?}");

    println!("consume(copy) = {}", consume(copy)); // copy moved into consume, and is gone
    {
        let _inner = Noisy("inner");
        println!("inside the block");
    } // _inner's owner, the block, ends here
    println!("after the block");

    #[cfg(feature = "bug07")]
    println!("{title}"); // title moved to `moved` above: there's nothing here to print
}
