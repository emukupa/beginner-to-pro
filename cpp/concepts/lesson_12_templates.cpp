// Lesson 12: a template is a function written once for many types; the compiler writes a copy for
// each type you use. A concept says what a type must offer, so a wrong type gets a clear message
// at the call, not pages of errors from inside the template.
// BUG=12: top_n on a vector of int. An int has no .count, so the concept refuses it.

#pragma once
#include "concepts.hpp"
#include "lesson_07_collections.cpp"  // TagCount

template <typename T>
T larger(T a, T b) { return a < b ? b : a; }  // works for anything with <

// Anything with a .count that is a size: TagCount, and lesson 12's WordCount below.
template <typename T>
concept Counted = requires(const T& item) {
    { item.count } -> std::convertible_to<std::size_t>;
};

// The n with the highest counts, most first. stable_sort keeps equal counts in the order they came
// in, so ties stay in file order. Lesson 13's tracker reuses this.
template <Counted T>
std::vector<T> top_n(std::vector<T> items, std::size_t n) {  // a copy: the caller keeps theirs
    std::ranges::stable_sort(items, std::greater{}, &T::count);  // compare .count, biggest first
    if (items.size() > n) items.resize(n);
    return items;
}

struct WordCount {                    // a different type with a .count: top_n takes it too
    std::string_view word;
    int count = 0;
};

void lesson_12() {
    std::println("larger(3, 7) = {}, larger(string \"apple\", string \"pear\") = {}", larger(3, 7),
                 larger(std::string{"apple"}, std::string{"pear"}));
    std::vector<TagCount> tags = {{"home", 2}, {"work", 3}, {"urgent", 1}, {"family", 1}, {"travel", 1}};
    std::print("top_n(tags, 3):");
    for (const auto& [tag, count] : top_n(tags, 3)) std::print(" {} {}", tag, count);
    std::println("   (urgent before family: the order they came in)");
    std::vector<WordCount> words = {{"the", 4}, {"task", 2}, {"list", 7}};
    std::println("top_n(words, 1): {}", top_n(words, 1).front().word);
#if BUG == 12
    std::vector<int> numbers = {3, 1, 2};
    top_n(numbers, 2);                // int doesn't satisfy Counted
#endif
}
