// Lesson 07: std::vector is the list you'll use most. std::map keeps keys sorted, unordered_map
// keeps them in hash order. Neither remembers the order keys first arrived, and the tracker
// needs that: tags with equal counts must stay in file order.
// BUG=7: reading one past the end with [ ]. [ ] doesn't check; AddressSanitizer does.

#pragma once
#include "concepts.hpp"

struct TagCount {                     // a plain struct: two public fields, nothing to hide
    std::string tag;
    std::size_t count = 0;
};

// Counts tags in the order they first appear. A vector and a search: fine for a handful of tags.
// Lesson 13's tracker reuses this.
std::vector<TagCount> count_tags(const std::vector<std::vector<std::string>>& tag_lists) {
    std::vector<TagCount> counts;
    for (const auto& tags : tag_lists) {
        for (const auto& tag : tags) {
            auto found = std::ranges::find(counts, tag, &TagCount::tag);  // look at each .tag
            if (found != counts.end()) {
                found->count++;
            } else {
                counts.push_back({tag, 1});
            }
        }
    }
    return counts;
}

void lesson_07() {
    std::vector<std::string> titles = {"Buy groceries", "Call mom"};
    titles.push_back("Book flights");
    std::println("{} titles, the first \"{}\", the last \"{}\"", titles.size(), titles[0], titles.back());
    std::vector<std::string> copy = titles;  // a real copy: vectors are values, not shared
    copy.pop_back();
    std::println("copy has {}, titles still has {}", copy.size(), titles.size());
    try {
        std::println("{}", titles.at(9));    // at() checks the index and throws...
    } catch (const std::out_of_range&) {
        std::println("titles.at(9) threw std::out_of_range");  // ...[ ] wouldn't (see BUG=7)
    }

    std::vector<std::vector<std::string>> tag_lists = {
        {"home"}, {"work", "urgent"}, {"family"}, {"work"}, {"travel", "home"}, {"work"}};
    std::map<std::string, std::size_t> sorted;
    std::unordered_map<std::string, std::size_t> hashed;
    for (const auto& tags : tag_lists) {
        for (const auto& tag : tags) {
            sorted[tag]++;                   // [ ] on a map adds the key at 0 if it's missing
            hashed[tag]++;
        }
    }
    std::print("std::map, sorted by key:");
    for (const auto& [tag, count] : sorted) std::print(" {} {}", tag, count);  // unpack each pair
    std::println("");
    std::println("unordered_map: {} keys, in an order that depends on the hash; work = {}", hashed.size(), hashed["work"]);
    std::print("count_tags, first seen:  ");
    for (const auto& [tag, count] : count_tags(tag_lists)) std::print(" {} {}", tag, count);
    std::println("");
#if BUG == 7
    std::vector<int> counts = {3, 2, 1};
    for (std::size_t i = 0; i <= counts.size(); i++) std::print("{} ", counts[i]);  // <= goes one too far
#endif
}
