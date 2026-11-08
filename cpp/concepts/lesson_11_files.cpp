// Lesson 11: file streams are RAII objects. They open when made and close when they go away, even
// if an exception flies past, so there is no close() to forget. Loading a file can fail for a
// reason worth telling the user, so it returns std::expected: the tasks, or why not.

#pragma once
#include "concepts.hpp"
#include "lesson_03_numbers.cpp"    // whole_percent
#include "lesson_10_errors.cpp"     // parse_line, make_task

using TaskList = std::vector<std::unique_ptr<Task>>;  // a short name for a long type

// Every task line in the file, or a message. Lesson 13's tracker reuses this.
std::expected<TaskList, std::string> load_tasks(const std::string& path) {
    std::ifstream file{path};
    if (!file) return std::unexpected(std::format("can't open {}", path));
    TaskList tasks;
    std::string line;
    while (std::getline(file, line)) {          // one line at a time, without its '\n'
        if (auto parsed = parse_line(line)) tasks.push_back(make_task(std::move(*parsed)));
    }
    return tasks;
}                                               // file closes here, on its own

void lesson_11() {
    for (std::string path : {"tasks.txt", "missing.txt"}) {
        auto loaded = load_tasks(path);
        if (!loaded) {                          // like optional: false when it holds an error
            std::println("{}: {}", path, loaded.error());
            continue;
        }
        const TaskList& tasks = *loaded;
        auto done = static_cast<std::size_t>(std::ranges::count_if(tasks, [](const auto& t) { return t->done(); }));
        std::println("{}: {} tasks, {} done ({}%)", path, tasks.size(), done, whole_percent(done, tasks.size()));
    }

    {
        std::ofstream out{"build/scratch.txt"};                  // write: wipes what was there
        out << "[todo] First\n";
    }
    {
        std::ofstream out{"build/scratch.txt", std::ios::app};   // app: add to the end, as the tracker does
        out << "[todo] Second\n";
    }
    std::ifstream in{"build/scratch.txt"};
    std::string line;
    std::print("build/scratch.txt:");
    while (std::getline(in, line)) std::print(" \"{}\"", line);
    std::println("");
}
