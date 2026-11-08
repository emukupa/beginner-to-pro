//! Lesson 04: text comes in two forms. `String` owns its text and can grow; `&str` looks at text
//! someone else owns. Both are always valid UTF-8, so one character can take several bytes.
//! bug04: `title[0]`. The compiler won't index text by number, because byte 0 might be half a
//! character.

pub const TITLE: &str = "Strings";

/// "[ DONE. ]" -> "done". Lesson 08's parse_status uses it on every status in the file.
pub fn clean_status(text: &str) -> String {
    text.trim_matches(['[', ']', ' ', '.']).to_lowercase()
}

pub fn run() {
    let owned: String = String::from("Call mom"); // a String, on the heap: it can grow
    let literal: &str = "#family"; // a literal is a &str: the text is built into the program
    let mut line = owned.clone();
    line.push(' ');
    line.push_str(literal);
    let view: &str = &line; // &line lends a &str view of the String, without copying it
    println!("line = {view:?}");

    println!("\"done\" == \"done.\" -> {}", "done" == "done.");
    println!("\"DONE\".to_lowercase() -> {:?}", "DONE".to_lowercase()); // a new String; the old text is unchanged
    println!("\"  done  \".trim() -> {:?}", "  done  ".trim());
    println!(
        "split_whitespace -> {:?}",
        view.split_whitespace().collect::<Vec<_>>()
    );
    println!(
        "split_once(']') -> {:?}",
        "[done.] Call mom".split_once(']')
    );
    for messy in ["[done]", "[done.]", "[DONE]", "[ todo ]"] {
        let quoted = format!("{messy:?}"); // {:?} ignores widths, so quote first, then pad
        println!("clean_status({quoted:>10}) -> {:?}", clean_status(messy));
    }

    // len() counts bytes. A █ is 3 bytes in UTF-8 but one character on screen.
    println!(
        "\"█\".len() = {}, \"█\".chars().count() = {}",
        "█".len(),
        "█".chars().count()
    );
    println!(
        "\"café\".len() = {}, chars = {}",
        "café".len(),
        "café".chars().count()
    );
    // Width in {:<8} counts characters, not bytes, so labels line up even with é in them.
    println!("aligned: |{:<8}|{:>8}|", "café", "work");
    println!("repeated: {}", "█".repeat(5));

    let title = "Fix login bug";
    // Slices are byte ranges. Fine here, all ASCII; slicing through the middle of a █ would panic.
    println!(
        "&title[0..3] = {:?}, first char = {:?}",
        &title[0..3],
        title.chars().next()
    );

    #[cfg(feature = "bug04")]
    {
        let first = title[0]; // which byte? which character? Rust makes you say: chars() or a range
        println!("{first}");
    }
}

#[cfg(test)]
mod tests {
    use super::clean_status;

    #[test]
    fn cleans_messy_statuses() {
        assert_eq!(clean_status("[done.]"), "done");
        assert_eq!(clean_status("[DONE]"), "done");
        assert_eq!(clean_status("[ todo ]"), "todo");
    }
}
