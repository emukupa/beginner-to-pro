#include "tasklist.hpp"

#include "parsing.hpp"

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
