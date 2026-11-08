//! Lesson 05: `if` and `match` decide, `for`, `while` and `loop` repeat. In Rust, `if`, `match`
//! and `loop` are expressions: they give back a value you can store.
//! bug05: an `if` used as a value, with no `else`. What would it be when the test is false?
//! The compiler refuses to guess.

pub const TITLE: &str = "Control flow";

pub fn run() {
    let done = 3;
    let total = 6;
    let verdict = if done == total {
        "all done"
    } else if done == 0 {
        "not started"
    } else {
        "in progress"
    };
    println!("{done} of {total}: {verdict}");

    print!("1..=3 includes the end:");
    for n in 1..=3 {
        print!(" {n}");
    }
    print!(", 1..3 stops before it:");
    for n in 1..3 {
        print!(" {n}");
    }
    println!();

    let mut left = 3;
    while left > 0 {
        left -= 1;
    }
    let mut tries = 0;
    let first_square_over_10 = loop {
        tries += 1;
        if tries * tries > 10 {
            break tries; // break can carry the loop's answer out
        }
    };
    println!("while counted down to {left}; loop found {first_square_over_10}");

    // match checks the cases in order. It must cover every possible value (lesson 08 leans on that).
    for count in [0, 1, 4, 9, 12] {
        let size = match count {
            0 => "none",
            1 => "one",
            2..=4 => "a few",               // a range
            n if n % 2 == 1 => "lots, odd", // a guard: an extra condition
            _ => "lots",                    // _ matches anything left
        };
        println!("{count:>2} -> {size}");
    }
    for word in ["done", "todo", "later"] {
        match word {
            "done" => println!("{word}: finished"),
            "todo" | "later" => println!("{word}: still open"), // | means either
            _ => println!("{word}: unknown"),
        }
    }

    'rows: for row in 1..=3 {
        for col in 1..=3 {
            if row * col == 6 {
                println!("{row} x {col} = 6, so break out of both loops at once");
                break 'rows; // a label names which loop to leave
            }
        }
    }

    #[cfg(feature = "bug05")]
    {
        let mark = if done == total {
            "x"
        }; // and when it isn't? An if-value needs an else
        println!("{mark}");
    }
}
