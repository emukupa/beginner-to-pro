// Lesson 13: ranges and views. A view is a lazy recipe over a range: filter keeps some items,
// transform changes each one, and nothing is copied until you ask. With them, the earlier lessons
// add up to a small tracker: load tasks.txt, show the urgent tasks, count tags, chart the top 3.
// BUG=13: max_element on a vector made on the spot. The vector is gone before you can use the
// answer, so ranges hands back std::ranges::dangling instead of an iterator, and that won't compile.

#pragma once
#include "concepts.hpp"
#include "lesson_06_functions.cpp"  // bar
#include "lesson_11_files.cpp"      // load_tasks, whole_percent
#include "lesson_12_templates.cpp"  // top_n, count_tags

void lesson_13() {
    auto squares = std::views::iota(1, 6) | std::views::transform([](int n) { return n * n; });
    std::println("iota(1, 6) | transform(square): {}", squares);  // worked out as it's printed

    auto loaded = load_tasks("tasks.txt");
    if (!loaded) {
        std::println("{}", loaded.error());
        return;
    }
    const TaskList& tasks = *loaded;

    auto tag_lists = tasks | std::views::transform([](const auto& t) { return t->tags(); })
                     | std::ranges::to<std::vector>();             // to: now it's a real vector
    auto counts = count_tags(tag_lists);
    auto done = static_cast<std::size_t>(std::ranges::count_if(tasks, &Task::done));
    std::println("{} tasks, {} done ({}%), {} tags", tasks.size(), done, whole_percent(done, tasks.size()),
                 counts.size());

    // views::filter keeps the urgent ones; *t follows the unique_ptr, and str() is virtual.
    for (const auto& t : tasks | std::views::filter([](const auto& task) { return task->urgent(); })) {
        std::println("{}", t->str());
    }

    // std::ranges::sort may swap equal counts; top_n uses stable_sort so ties keep file order.
    auto top = top_n(counts, 3);
    if (top.empty()) return;
    std::size_t most = top.front().count;  // the first is the biggest
    auto widest = std::ranges::max(top | std::views::transform([](const TagCount& c) { return c.tag.size(); }));
    std::println("\nTop tags");
    for (const auto& [tag, count] : top) {
        std::println("{:<{}}{} {}", tag, widest + 2, bar(count, most), count);  // {:<{}}: the width is an argument too
    }
#if BUG == 13
    auto biggest = std::ranges::max_element(std::vector<int>{3, 1, 2});  // the vector dies at the ;
    std::println("{}", *biggest);
#endif
}
