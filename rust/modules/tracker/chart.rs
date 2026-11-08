//! The bar chart. It draws to any writer: the screen in main, a Vec<u8> in a test.

use std::io::{self, Write};

use crate::tasklist::TagCount;

pub const CHART_WIDTH: usize = 20; // the longest bar, in characters
const BAR: &str = "█";
const _: () = assert!(CHART_WIDTH > 0, "a chart needs room for its bars");

pub fn draw_chart(out: &mut impl Write, pairs: &[TagCount], width: usize) -> io::Result<()> {
    let Some(biggest) = pairs.first().map(|p| p.count as f64) else {
        return writeln!(out, "No tags yet.");
    };
    let label_width = pairs.iter().map(|p| p.tag.chars().count()).max().unwrap_or(0);
    for p in pairs {
        let blocks = (p.count as f64 / biggest * width as f64).round_ties_even() as usize; // like Python's round()
        let pad = " ".repeat(label_width - p.tag.chars().count()); // by characters, not bytes
        writeln!(out, "{}{pad}  {} {}", p.tag, BAR.repeat(blocks), p.count)?;
    }
    Ok(())
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn draws_into_memory() {
        let pairs = [TagCount { tag: "home", count: 2 }, TagCount { tag: "work", count: 1 }];
        let mut out = Vec::new();
        draw_chart(&mut out, &pairs, 4).unwrap();
        assert_eq!(String::from_utf8(out).unwrap(), "home  ████ 2\nwork  ██ 1\n");
    }
}
