#include "parsing.hpp"

#include <algorithm>

#include "text.hpp"

namespace tracker {

namespace {  // an anonymous namespace: only this file can see what's inside, like C's static

Status status_of(std::string_view word) {
    std::string w = lower(strip(word, "[] ."));
    return w == "done" ? Status::Done : w == "todo" ? Status::Todo : Status::Other;
}

}  // namespace

std::unique_ptr<Task> parse_line(std::string_view line) {
    std::string_view s = strip(line);
    if (s.empty() || s.front() != '[') return nullptr;

    // Python's partition("]"): what's before the first ], and what's after it.
    auto close = s.find(']');
    std::string_view status = s.substr(0, close);
    std::string_view rest = close == std::string_view::npos ? "" : s.substr(close + 1);

    std::string title;
    std::vector<std::string> tags;
    for (std::string_view word : words(rest)) {
        if (word.front() == TAG_MARKER) {
            while (!word.empty() && word.front() == TAG_MARKER) word.remove_prefix(1);  // lstrip("#")
            tags.push_back(lower(strip(word, ".,")));
        } else {
            if (!title.empty()) title += ' ';
            title += word;
        }
    }
    bool urgent = std::ranges::contains(tags, std::string{"urgent"});
    if (urgent) return std::make_unique<UrgentTask>(std::move(title), status_of(status), std::move(tags));
    return std::make_unique<Task>(std::move(title), status_of(status), std::move(tags));
}

}  // namespace tracker
