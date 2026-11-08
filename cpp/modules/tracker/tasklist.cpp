#include "tasklist.hpp"

#include "parsing.hpp"
#include "text.hpp"

namespace tracker {

std::size_t add_tasks(TaskList& tasks, const std::vector<std::string>& titles, const std::string& created) {
    std::size_t added = 0;
    for (const auto& title : titles) {
        if (auto task = parse_line("[todo] " + title)) {
            task->created = created;
            tasks.push_back(std::move(task));
            added++;
        }
    }
    return added;
}

Task* find_task(const TaskList& tasks, std::string_view title) {
    std::string wanted;
    for (std::string_view word : words(title)) {
        if (!wanted.empty()) wanted += ' ';
        wanted += word;
    }
    wanted = lower(wanted);
    auto found = std::ranges::find_if(tasks, [&](const auto& task) { return lower(task->title()) == wanted; });
    return found == tasks.end() ? nullptr : found->get();
}

std::vector<TagCount> count_tags(const TaskList& tasks, bool include_done) {
    std::vector<TagCount> counts;
    for (const auto& task : tasks) {
        if (!include_done && task->is_done()) continue;
        for (const auto& tag : task->tags()) {
            auto found = std::ranges::find(counts, std::string_view{tag}, &TagCount::tag);
            if (found == counts.end()) counts.push_back({tag, 1});
            else found->count++;
        }
    }
    return counts;
}

}  // namespace tracker
