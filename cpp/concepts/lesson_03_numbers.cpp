// Lesson 03: arithmetic, integer division, rounding halves, and turning text into a number.
// BUG=3: storing a size_t in an int. -Wconversion catches the silent narrowing.

#pragma once
#include "concepts.hpp"

// done out of total as a whole percentage, halves to even: 1 of 8 is 12.5%, shown as 12, the same
// as Python's round(). std::round would say 13. Lesson 13's tracker reuses this.
int whole_percent(std::size_t done, std::size_t total) {
    if (total == 0) return 0;
    double exact = 100.0 * static_cast<double>(done) / static_cast<double>(total);
    return static_cast<int>(std::nearbyint(exact));  // nearbyint rounds halves to the even neighbour
}

void lesson_03() {
    std::println("7 / 2 = {}, 7 % 2 = {}, 7.0 / 2 = {}", 7 / 2, 7 % 2, 7.0 / 2);  // int / int drops the rest
    std::println("0.1 + 0.2 = {:.17f}", 0.1 + 0.2);  // binary fractions: close, not exact
    std::println("round(2.5) = {}, nearbyint(2.5) = {}, nearbyint(3.5) = {}", std::round(2.5),
                 std::nearbyint(2.5), std::nearbyint(3.5));
    std::println("1 of 8 done: {}%", whole_percent(1, 8));

    // Text is not a number. from_chars reads one and tells you if it couldn't, with no exceptions
    // and no copies. (Lesson 10 wraps this in std::optional.)
    for (std::string_view answer : {"5", "five", "-3"}) {
        int n = 0;
        auto [end, error] = std::from_chars(answer.data(), answer.data() + answer.size(), n);
        if (error == std::errc{} && end == answer.data() + answer.size()) {
            std::println("\"{}\" -> {}, doubled {}", answer, n, n * 2);
        } else {
            std::println("\"{}\" isn't a whole number", answer);
        }
    }
#if BUG == 3
    std::string word = "hello";
    int small = word.size();          // size_t -> int may not fit: -Wconversion says so
    std::println("{}", small);
#endif
}
