//! Lesson 03: arithmetic, integer division, overflow, rounding, and turning text into a number.
//! bug03: adding 1 to the biggest u8. Debug builds check every addition and panic: the program
//! stops with a message instead of carrying on with a wrong number. (Release builds wrap to 0, so
//! code that means to wrap says so with wrapping_add.)

pub const TITLE: &str = "Numbers";

pub fn run() {
    println!(
        "7 / 2 = {}, 7 % 2 = {}, 7.0 / 2.0 = {}",
        7 / 2,
        7 % 2,
        7.0 / 2.0
    ); // whole / whole drops the rest
    println!("0.1 + 0.2 = {}", 0.1 + 0.2); // floats are binary fractions: close, not exact

    // The tracker rounds halves to even, like Python: 2.5 -> 2. round() goes away from zero.
    println!(
        "2.5.round() = {}, 2.5.round_ties_even() = {}",
        2.5_f64.round(),
        2.5_f64.round_ties_even()
    );
    println!("12.5 shown with no decimals: {:.0}", 12.5); // formatting rounds halves to even too

    // A u8 holds 0..=255. When a sum won't fit, you choose what happens; the default is a panic.
    let small: u8 = 250;
    println!(
        "250 + 10 as u8: checked {:?}, wrapping {}, saturating {}",
        small.checked_add(10),    // None: "it didn't fit", for you to handle
        small.wrapping_add(10),   // 4: round the clock, on purpose
        small.saturating_add(10)  // 255: stop at the top
    );
    // `as` converts silently and can lose data; try_from refuses instead.
    println!(
        "300 as u8 = {}, u8::try_from(300) = {:?}",
        300_i32 as u8,
        u8::try_from(300_i32)
    );

    // parse() turns text into a number, or says why it couldn't (Result, lesson 11).
    for text in ["5", "five", "-3"] {
        match text.parse::<i64>() {
            Ok(n) => println!("{text:?} -> {n}"),
            Err(e) => println!("{text:?} isn't a whole number: {e}"),
        }
    }

    #[cfg(feature = "bug03")]
    {
        let biggest: u8 = std::hint::black_box(255); // black_box: hide the value so the compiler can't spot it early
        println!("{}", biggest + 1); // 256 doesn't fit in a u8: panics in a debug build
    }
}

#[cfg(test)]
mod tests {
    #[test]
    fn halves_round_to_even() {
        assert_eq!(0.5_f64.round_ties_even(), 0.0);
        assert_eq!(2.5_f64.round_ties_even(), 2.0);
        assert_eq!(3.5_f64.round_ties_even(), 4.0);
        assert_eq!(format!("{:.0}", 12.5), "12");
    }
}
