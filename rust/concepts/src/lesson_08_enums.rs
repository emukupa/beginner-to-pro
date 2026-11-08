//! Lesson 08: an enum is one of a fixed set of choices, and each choice can carry data. Option is
//! an enum too (Some(value) or None): Rust's answer to null. `match` must handle every choice.
//! bug08: a match on Status that forgets Other. The compiler names the missing case.

use crate::lesson_04_strings::clean_status;

pub const TITLE: &str = "Enums and Option";

#[derive(Debug, Clone, PartialEq, Eq)] // derive: let the compiler write these traits (lesson 10)
pub enum Status {
    Todo,
    Done,
    Other(String), // carries the text we didn't recognise, instead of losing it
}

#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum Kind {
    Plain,
    Urgent,
}

/// "[done.]" -> Done, "[ todo ]" -> Todo, "[later]" -> Other("later"). Lesson 09 uses it.
pub fn parse_status(text: &str) -> Status {
    match clean_status(text).as_str() {
        "done" => Status::Done,
        "todo" => Status::Todo,
        other => Status::Other(other.to_string()),
    }
}

/// "#Work." -> Some("work"); a word that isn't a tag -> None. Lesson 09 uses it.
pub fn tag_of(word: &str) -> Option<String> {
    let Some(name) = word.strip_prefix('#') else {
        return None; // let ... else: take the value out, or leave right here
    };
    let name = name.trim_matches(['.', ',']).to_lowercase();
    if name.is_empty() { None } else { Some(name) }
}

fn describe(status: &Status) -> String {
    match status {
        Status::Todo => "still to do".to_string(),
        Status::Done => "finished".to_string(),
        Status::Other(text) => format!("unknown status {text:?}"), // the data comes out in the match
    }
}

pub fn run() {
    for text in ["[done.]", "[ todo ]", "[later]"] {
        let status = parse_status(text);
        println!("{text:>9} -> {status:?}: {}", describe(&status));
    }
    for word in ["#Work.", "#", "mom"] {
        match tag_of(word) {
            Some(tag) => println!("{word:>6} -> tag {tag:?}"),
            None => println!("{word:>6} -> not a tag"),
        }
    }
    if let Some(tag) = tag_of("#home") {
        println!("if let, for when only one case matters: {tag}");
    }
    println!(
        "unwrap_or gives a fallback: {}",
        tag_of("mom").unwrap_or("untagged".to_string())
    );
    let kind = if tag_of("#urgent").as_deref() == Some("urgent") {
        Kind::Urgent
    } else {
        Kind::Plain
    };
    println!("kind = {kind:?}, {} byte", size_of::<Kind>());

    #[cfg(feature = "bug08")]
    match parse_status("[later]") {
        Status::Todo => println!("todo"),
        Status::Done => println!("done"),
        // Status::Other(_) is missing. In C a switch would just skip it; here it won't build.
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn statuses_and_tags() {
        assert_eq!(parse_status("[DONE]"), Status::Done);
        assert_eq!(parse_status("[later]"), Status::Other("later".to_string()));
        assert_eq!(tag_of("#work."), Some("work".to_string()));
        assert_eq!(tag_of("work"), None);
    }
}
