// Lesson 10: three ways to say "that didn't work". std::optional: a value or nothing, for when
// "nothing" is ordinary (a line that isn't a task). std::expected (lesson 11): a value or a reason.
// Exceptions: for the truly unexpected, thrown far and caught where someone can act on it.
// BUG=10: .value() on an empty optional. It throws, nothing catches it, and the program aborts.

#pragma once
#include "concepts.hpp"
#include "lesson_04_strings.cpp"    // strip, lower, clean_status
#include "lesson_09_ownership.cpp"  // Task, UrgentTask, Status

// Lesson 03's from_chars, wrapped: a number, or std::nullopt. The runner (main.cpp) uses it too.
std::optional<int> parse_whole_number(std::string_view text) {
    int n = 0;
    auto [end, error] = std::from_chars(text.data(), text.data() + text.size(), n);
    if (error != std::errc{} || end != text.data() + text.size()) return std::nullopt;
    return n;
}

struct TaskLine {                     // what one line of the file says, before it becomes a Task
    std::string title;
    Status status = Status::Other;
    std::vector<std::string> tags;
};

// "[done.] Call mom #family" -> {"Call mom", Done, {"family"}}, or nothing if it isn't a task.
// Works on views of the line: the only copies are the title and tags it keeps.
std::optional<TaskLine> parse_line(std::string_view line) {
    line = strip(line);
    auto close = line.find(']');
    if (!line.starts_with('[') || close == std::string_view::npos) return std::nullopt;
    TaskLine task;
    task.status = to_status(clean_status(line.substr(0, close + 1)));
    std::string_view rest = line.substr(close + 1);
    while (!(rest = strip(rest)).empty()) {   // one word at a time
        auto space = rest.find(' ');
        std::string_view word = rest.substr(0, space);
        rest = space == std::string_view::npos ? std::string_view{} : rest.substr(space);
        if (word.starts_with('#')) {
            task.tags.push_back(lower(strip(word.substr(1), ".,")));  // "#work." -> "work"
        } else {
            if (!task.title.empty()) task.title += ' ';
            task.title += word;
        }
    }
    return task;
}

// A TaskLine becomes the right kind of Task, owned by a unique_ptr.
std::unique_ptr<Task> make_task(TaskLine line) {
    if (std::ranges::contains(line.tags, "urgent")) {
        return std::make_unique<UrgentTask>(std::move(line.title), line.status, std::move(line.tags));
    }
    return std::make_unique<Task>(std::move(line.title), line.status, std::move(line.tags));
}

void lesson_10() {
    for (std::string_view line : {"[done.] Call mom #family", "[ todo ] Review pull request #work.", "no brackets"}) {
        if (auto task = parse_line(line)) {  // an optional is true when it holds a value
            std::println("\"{}\" -> \"{}\", {}, {} tag(s)", line, task->title, status_name(task->status), task->tags.size());
        } else {
            std::println("\"{}\" -> not a task", line);
        }
    }
    std::println("parse_whole_number(\"3\") = {}, (\"three\") is empty? {}", parse_whole_number("3").value_or(-1),
                 !parse_whole_number("three").has_value());
    std::cout << "make_task: " << *make_task(*parse_line("[todo] Finish quarterly report #work #urgent")) << '\n';

    try {
        int n = std::stoi("three");   // the standard library's older parser throws instead
        std::println("{}", n);
    } catch (const std::invalid_argument& e) {
        std::println("std::stoi threw std::invalid_argument ({})", e.what());
    }
#if BUG == 10
    std::println("{}", parse_whole_number("three").value());  // empty: throws, and nobody catches it
#endif
}
