//! Lesson 06: functions declare the types they take and give back. A closure is a function
//! written inline, and it can use the values around it.
//! bug06: calling percent and throwing the answer away. percent is #[must_use], and Cargo.toml
//! makes ignoring that an error (like C's [[nodiscard]] with -Werror).

pub const TITLE: &str = "Functions and closures";

/// Done as a percentage of total, 0 for an empty list. Lessons 13 and 14 use it for the summary.
#[must_use]
pub fn percent(done: usize, total: usize) -> f64 {
    if total == 0 {
        0.0
    } else {
        done as f64 / total as f64 * 100.0 // the last expression, with no semicolon, is the result
    }
}

fn try_to_change(mut n: i32) {
    n += 98; // the function got its own copy (lesson 07 shows how to lend the original)
    println!("inside try_to_change, n is {n}");
}

/// Counts the words that `keep` says yes to. `impl Fn(&str) -> bool` accepts any function or
/// closure with that shape, so the caller decides what counts.
fn count_matching(words: &[&str], keep: impl Fn(&str) -> bool) -> usize {
    let mut n = 0;
    for word in words {
        if keep(word) {
            n += 1;
        }
    }
    n
}

/// Gives back a closure. `move` makes the closure keep its own copy of `block`.
fn bar_maker(block: char) -> impl Fn(usize) -> String {
    move |n| block.to_string().repeat(n)
}

pub fn run() {
    println!("percent(3, 7) = {:.0}%", percent(3, 7));
    println!(
        "percent(1, 8) = {}, shown as {:.0}%",
        percent(1, 8),
        percent(1, 8)
    ); // 12.5 -> 12
    let n = 1;
    try_to_change(n);
    println!("after try_to_change(n), n is still {n}");

    let marker = '#';
    let is_tag = |word: &str| word.starts_with(marker); // uses `marker` from outside: a closure
    let words = ["Call", "mom", "#family", "#home"];
    println!("tags: {}", count_matching(&words, is_tag));
    println!(
        "longer than 3 letters: {}",
        count_matching(&words, |w| w.len() > 3)
    );

    let mut letters = 0;
    let mut tally = |w: &str| letters += w.len(); // changes `letters`, so it's an FnMut closure
    for w in words {
        tally(w);
    }
    println!("letters in all words: {letters}");
    let bar = bar_maker('█');
    println!("bar(3) = {}", bar(3));

    #[cfg(feature = "bug06")]
    percent(3, 7); // the answer goes nowhere: almost certainly a mistake, so it's an error
}

#[cfg(test)]
mod tests {
    use super::percent;

    #[test]
    fn percent_of_nothing_is_zero() {
        assert_eq!(percent(0, 0), 0.0);
        assert_eq!(percent(3, 6), 50.0);
    }
}
