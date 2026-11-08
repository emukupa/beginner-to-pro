// The program the user talks to. The only module that reads input, prints to the screen, or exits.
#include <climits>
#include <cmath>
#include <cstdlib>
#include <ctime>
#include <iostream>
#include <optional>
#include <print>
#include <ranges>
#include <span>
#include <string>

#include "chart.hpp"
#include "models.hpp"
#include "parsing.hpp"
#include "storage.hpp"
#include "tasklist.hpp"
#include "text.hpp"

using namespace tracker;

constexpr std::size_t CHART_WIDTH = 20;    // the longest bar, in characters
constexpr long long DEFAULT_TOP = 3;       // top tags shown when the answer is empty or invalid
static_assert(DEFAULT_TOP >= 1, "the fallback must itself be a valid answer");
static_assert(CHART_WIDTH > 0, "a chart needs room for its bars");

namespace {  // private to this file

// Like Python's input(): shows the prompt, reads one line. An empty line at the end of input.
std::string ask(std::string_view prompt) {
    std::print("{}", prompt);
    std::cout.flush();
    std::string line;
    if (!std::getline(std::cin, line)) return "";
    return line;
}

// Python's int(text): optional spaces, an optional sign, digits with single underscores between
// them, optional spaces. Nothing if it isn't a whole number. Huge numbers are capped.
std::optional<long long> parse_whole_number(std::string_view text) {
    std::string_view s = strip(text);
    std::size_t i = 0;
    bool negative = false;
    auto digit = [](char c) { return c >= '0' && c <= '9'; };
    if (i < s.size() && (s[i] == '+' || s[i] == '-')) negative = s[i++] == '-';
    if (i == s.size() || !digit(s[i])) return std::nullopt;
    long long value = 0;
    for (; i < s.size(); i++) {
        if (s[i] == '_' && i + 1 < s.size() && digit(s[i + 1]) && digit(s[i - 1])) continue;
        if (!digit(s[i])) return std::nullopt;
        long long d = s[i] - '0';
        value = value > (LLONG_MAX - d) / 10 ? LLONG_MAX : value * 10 + d;
    }
    return negative ? -value : value;
}

// Today's local date. libc++ has no time-zone database yet (std::chrono::current_zone), so the
// local time comes from C's localtime_r, as in the C version.
std::string today() {
    std::time_t now = std::time(nullptr);
    std::tm local{};
    if (localtime_r(&now, &local) == nullptr) return "";
    char text[sizeof "YYYY-MM-DD"];
    return std::strftime(text, sizeof text, "%Y-%m-%d", &local) ? text : "";
}

// tracker done "title": marks one task finished. Returns the exit code: 0 done (or already done),
// 1 no such file or task, 2 used wrongly.
int done_command(std::span<char*> words) {
    std::string joined;                                // Python's " ".join(words).strip()
    for (std::size_t i = 0; i < words.size(); i++) {
        if (i > 0) joined += ' ';
        joined += words[i];
    }
    std::string title{strip(joined)};
    if (title.empty()) {
        std::println(std::cerr, "Usage: done \"task title\"");
        return 2;
    }
    const char* env = std::getenv("TASKS_FILE");
    std::string path = env ? env : "tasks.txt";
    auto loaded = load_tasks(path);
    if (!loaded) {
        std::println(std::cerr, "Couldn't {} {}", loaded.error() == LoadError::NotFound ? "find" : "read", path);
        return 1;
    }
    Task* task = find_task(*loaded, title);           // borrowed from the list
    if (task == nullptr) {
        std::println(std::cerr, "No task called \"{}\"", title);
        return 1;
    }
    if (task->is_done()) {
        std::println("Already done: {}", task->title());
        return 0;
    }
    if (!mark_done(path, *task)) {
        std::println(std::cerr, "Couldn't write {}", path);
        return 1;
    }
    std::println("Done: {}", task->title());
    return 0;
}

}  // namespace

int main(int argc, char** argv) {
    if (argc > 1 && std::string_view{argv[1]} == "done") {   // a second mode: tracker done "title"
        return done_command(std::span{argv + 2, argv + argc});
    }
    const char* env = std::getenv("TASKS_FILE");
    std::string path = argc > 1 ? argv[1] : env ? env : "tasks.txt";

    auto loaded = load_tasks(path);
    if (!loaded) {
        std::println(std::cerr, "Couldn't {} {}", loaded.error() == LoadError::NotFound ? "find" : "read", path);
        return 1;
    }
    TaskList tasks = std::move(*loaded);

    std::vector<std::string> new_titles;
    for (;;) {
        std::string answer = ask("New task (Enter to finish): ");
        std::string_view title = strip(answer);
        if (title.empty()) break;
        if (title.front() == TAG_MARKER) {
            std::println("A task needs a title, not just tags.");
            continue;
        }
        new_titles.emplace_back(title);
    }
    if (add_tasks(tasks, new_titles, today()) > 0) append_titles(path, new_titles);

    std::string answer = ask("How many top tags? [3]: ");
    long long n = answer.empty() ? DEFAULT_TOP : parse_whole_number(answer).value_or(0);
    auto pairs = top_n(count_tags(tasks), n);
    if (!pairs) {
        std::println("Need a whole number of at least 1 — using 3.");
        pairs = top_n(count_tags(tasks), DEFAULT_TOP);
    }

    auto done = std::ranges::count_if(tasks, [](const auto& t) { return t->is_done(); });
    double percent = tasks.empty() ? 0 : static_cast<double>(done) / static_cast<double>(tasks.size()) * 100;
    std::println("\n{} tasks, {} done ({}%), {} tags", tasks.size(), done, std::nearbyint(percent), count_tags(tasks).size());
    for (const auto& t : tasks | std::views::filter([](const auto& task) { return task->urgent() && !task->is_done(); })) {
        std::println("{}", t->str());
    }

    std::println("\nTop tags");
    draw_chart(std::cout, *pairs, CHART_WIDTH, "█");
    return 0;
}
