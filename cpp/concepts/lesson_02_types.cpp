// Lesson 02: every value has a type, fixed when you compile. auto lets the compiler work it out,
// and braces { } refuse to lose information.
// BUG=2: int whole{2.5}. Braces won't quietly drop the .5, so the compiler stops.

#pragma once
#include "concepts.hpp"

void lesson_02() {
    int tasks = 6;                    // a whole number
    double share = 0.5;               // a number with a fraction
    bool done = true;
    char mark = 'x';                  // one character, in single quotes
    std::string title = "Call mom";   // text that owns its characters
    std::println("{} {} {} {} \"{}\"", tasks, share, done, mark, title);

    std::println("sizeof: int {}, long long {}, double {}, bool {}, size_t {}", sizeof(int),
                 sizeof(long long), sizeof(double), sizeof(bool), sizeof(std::size_t));
    std::println("biggest int: {}", std::numeric_limits<int>::max());

    auto count = title.size();        // auto: the compiler picks std::size_t, the type of sizes
    std::size_t none = 0;
    std::println("title.size() is {}; size_t 0 - 1 wraps round to {}", count, none - 1);  // unsigned: no negatives

    const int top = 3;                // const: can't change after this line
    int copied{top};                  // brace initialisation: the safe default
    std::println("top {}, copied {}", top, copied);
#if BUG == 2
    int whole{2.5};                   // braces refuse to narrow a double to an int
    std::println("{}", whole);
#endif
}
