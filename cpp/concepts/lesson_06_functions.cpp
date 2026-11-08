// Lesson 06: functions take copies unless you ask for a reference. const& reads without copying,
// & lets a function change the caller's value. Lambdas are functions you write in place.
// BUG=6: ignoring a [[nodiscard]] result. The warning becomes an error with -Werror.

#pragma once
#include "concepts.hpp"

constexpr std::string_view BLOCK = "█";  // U+2588: three bytes, one character

// A bar of blocks, count out of most, most filling width. Halves go to even, as in lesson 03.
// width has a default, so most callers leave it out. Lesson 13's chart reuses this.
[[nodiscard]] std::string bar(std::size_t count, std::size_t most, std::size_t width = 20) {
    if (most == 0) return "";
    double exact = static_cast<double>(count * width) / static_cast<double>(most);
    auto blocks = static_cast<std::size_t>(std::nearbyint(exact));
    std::string out;
    for (std::size_t i = 0; i < blocks; i++) out += BLOCK;
    return out;
}

int add_one_copy(int n) { n += 1; return n; }  // changes its own copy: the caller never sees it
void add_one(int& n) { n += 1; }             // a reference: the caller's own variable
std::size_t length(const std::string& s) { return s.size(); }  // const&: no copy, no changes

// Overloading: the same name, told apart by the argument types.
std::string describe(int n) { return std::format("the number {}", n); }
std::string describe(std::string_view s) { return std::format("the text \"{}\"", s); }

void lesson_06() {
    int n = 1;
    std::println("add_one_copy(n) gives {}, but n is still {}", add_one_copy(n), n);
    add_one(n);
    std::println("after add_one(n), n is {}", n);
    std::println("length(\"Call mom\") = {}", length("Call mom"));
    std::println("{}; {}", describe(7), describe("seven"));
    std::println("bar(2, 3) = {}  bar(1, 8) = {}  bar(1, 8, 10) = {}", bar(2, 3), bar(1, 8), bar(1, 8, 10));

    // A lambda: [captures](parameters) { body }. [=] copies what it uses, [&] refers to it.
    auto is_long = [](std::string_view title) { return title.size() > 10; };
    int limit = 2;
    auto under_limit = [limit](int count) { return count < limit; };  // limit is copied in now
    int seen = 0;
    auto count_it = [&seen] { seen++; };                             // seen is the real variable
    count_it();
    count_it();
    std::println("is_long(\"Call mom\")? {}  under_limit(1)? {}  seen = {}", is_long("Call mom"),
                 under_limit(1), seen);
#if BUG == 6
    bar(3, 3);                        // the bar is built, then thrown away: [[nodiscard]] objects
#endif
}
