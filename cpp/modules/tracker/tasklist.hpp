// The list of tasks: adding, counting, ranking. No printing, no files.
#pragma once
#include <algorithm>
#include <concepts>
#include <optional>
#include <string>
#include <string_view>
#include <vector>

#include "models.hpp"

namespace tracker {

// Parses each title as a new "[todo]" task and adds it. Returns how many were added.
std::size_t add_tasks(TaskList& tasks, const std::vector<std::string>& titles, const std::string& created);

// The first task whose title matches, ignoring case and extra spaces: Python's
// " ".join(title.split()).lower(). A plain pointer: borrowed, the list still owns it. nullptr if none.
Task* find_task(const TaskList& tasks, std::string_view title);

struct TagCount {
    std::string_view tag;  // borrowed from a task in the list
    std::size_t count;
};

// Every tag with how many tasks carry it, in the order each tag first appears.
std::vector<TagCount> count_tags(const TaskList& tasks, bool include_done = true);

// Anything with a count can be ranked.
template <typename T>
concept Counted = requires(const T& item) {
    { item.count } -> std::convertible_to<std::size_t>;
};

// The n with the biggest counts, most first; ties keep their order. Nothing when n < 1.
// A template lives in its header: the compiler needs the whole body wherever it's used, to write
// the version for that type.
template <Counted T>
std::optional<std::vector<T>> top_n(std::vector<T> items, long long n) {
    if (n < 1) return std::nullopt;
    std::ranges::stable_sort(items, std::ranges::greater{}, &T::count);
    if (static_cast<unsigned long long>(n) < items.size()) items.resize(static_cast<std::size_t>(n));
    return items;
}

}  // namespace tracker
