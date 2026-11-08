// The task tracker in one C++23 file. Same prompts, summary and chart as the Python version, byte
// for byte: contract/run.sh checks every one. Read top to bottom: settings, text helpers, what a task
// is, parsing a line, the file, counting and ranking, the chart, then main, the only part that talks
// to the user.
//
// Who owns the memory? The task list owns its tasks through std::unique_ptr, and everything else is
// a value or a view. Nothing is freed by hand: each owner cleans up when it goes out of scope.

#include <algorithm>
#include <cerrno>
#include <climits>
#include <cmath>
#include <concepts>
#include <cstdlib>
#include <ctime>
#include <expected>
#include <fstream>
#include <iostream>
#include <memory>
#include <optional>
#include <print>
#include <ranges>
#include <string>
#include <string_view>
#include <vector>

// ---- Settings ----------------------------------------------------------------------------------

constexpr std::size_t CHART_WIDTH = 20;    // the longest bar, in characters
constexpr long long DEFAULT_TOP = 3;       // top tags shown when the answer is empty or invalid
constexpr char TAG_MARKER = '#';           // marks a word as a tag: "#work"
constexpr std::string_view BAR = "█";
static_assert(DEFAULT_TOP >= 1, "the fallback must itself be a valid answer");
static_assert(CHART_WIDTH > 0, "a chart needs room for its bars");

// ---- Text --------------------------------------------------------------------------------------

constexpr bool is_space(char c) { return c == ' ' || c == '\t' || c == '\n' || c == '\r' || c == '\v' || c == '\f'; }

// Python's str.strip(chars): a view of the same text, no copy.
std::string_view strip(std::string_view s, std::string_view chars = " \t\n\r\v\f") {
    auto first = s.find_first_not_of(chars);
    if (first == std::string_view::npos) return {};
    return s.substr(first, s.find_last_not_of(chars) - first + 1);
}

std::string lower(std::string_view s) {
    std::string out{s};
    std::ranges::transform(out, out.begin(), [](char c) { return c >= 'A' && c <= 'Z' ? char(c - 'A' + 'a') : c; });
    return out;
}

// Python's split(): the words of text, split on any whitespace. Views into text.
std::vector<std::string_view> words(std::string_view text) {
    std::vector<std::string_view> out;
    std::size_t i = 0;
    while (i < text.size()) {
        while (i < text.size() && is_space(text[i])) i++;
        std::size_t start = i;
        while (i < text.size() && !is_space(text[i])) i++;
        if (i > start) out.push_back(text.substr(start, i - start));
    }
    return out;
}

// Characters on screen, not bytes: "█" is three bytes of UTF-8 but one character.
std::size_t text_width(std::string_view s) {
    return static_cast<std::size_t>(std::ranges::count_if(s, [](char c) { return (static_cast<unsigned char>(c) & 0xC0) != 0x80; }));
}

// ---- What a task is ----------------------------------------------------------------------------

enum class Status : unsigned char { Todo, Done, Other };

class Task {
public:
    Task(std::string title, Status status, std::vector<std::string> tags)
        : title_{std::move(title)}, status_{status}, tags_{std::move(tags)} {}
    virtual ~Task() = default;  // deleted through a Task pointer, so the destructor is virtual

    const std::string& title() const { return title_; }
    const std::vector<std::string>& tags() const { return tags_; }
    bool is_done() const { return status_ == Status::Done; }
    virtual bool urgent() const { return false; }
    virtual std::string str() const { return std::format("[{}] {}", is_done() ? 'x' : ' ', title_); }

    std::string created;  // "YYYY-MM-DD" for tasks added this run, else ""

private:
    std::string title_;
    Status status_;
    std::vector<std::string> tags_;
};

// Python's UrgentTask(Task): the same task, printed with "  !!" on the end.
class UrgentTask : public Task {
public:
    using Task::Task;
    bool urgent() const override { return true; }
    std::string str() const override { return Task::str() + "  !!"; }
};

using TaskList = std::vector<std::unique_ptr<Task>>;  // the list owns its tasks, of either kind

// ---- Parsing one line --------------------------------------------------------------------------

Status status_of(std::string_view word) {
    std::string w = lower(strip(word, "[] ."));
    return w == "done" ? Status::Done : w == "todo" ? Status::Todo : Status::Other;
}

// "[done.] Call mom #family" -> a task, or nothing if the line isn't one (Python's None).
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

// ---- The file ----------------------------------------------------------------------------------

enum class LoadError { NotFound, Unreadable };

// Every task in the file, or why it couldn't be read. The stream closes itself when it goes.
std::expected<TaskList, LoadError> load_tasks(const std::string& path) {
    std::ifstream file{path};
    if (!file) return std::unexpected(errno == ENOENT ? LoadError::NotFound : LoadError::Unreadable);
    TaskList tasks;
    for (std::string line; std::getline(file, line);) {
        if (auto task = parse_line(line)) tasks.push_back(std::move(task));  // lines that aren't tasks are skipped
    }
    return tasks;
}

// Parses each title as a new "[todo]" task and adds it. Returns how many were added.
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

void append_titles(const std::string& path, const std::vector<std::string>& titles) {
    std::ofstream file{path, std::ios::app};
    for (const auto& title : titles) file << "[todo] " << title << '\n';
}

// ---- Counting and ranking ----------------------------------------------------------------------

struct TagCount {
    std::string_view tag;  // borrowed from a task in the list
    std::size_t count;
};

// Every tag with how many tasks carry it, in the order each tag first appears.
std::vector<TagCount> count_tags(const TaskList& tasks, bool include_done = true) {
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

// Anything with a count can be ranked.
template <typename T>
concept Counted = requires(const T& item) {
    { item.count } -> std::convertible_to<std::size_t>;
};

// The n with the biggest counts, most first. stable_sort keeps ties in their first-seen order.
// Nothing when n < 1 (Python's ValueError).
template <Counted T>
std::optional<std::vector<T>> top_n(std::vector<T> items, long long n) {
    if (n < 1) return std::nullopt;
    std::ranges::stable_sort(items, std::ranges::greater{}, &T::count);
    if (static_cast<unsigned long long>(n) < items.size()) items.resize(static_cast<std::size_t>(n));
    return items;
}

// ---- The chart ---------------------------------------------------------------------------------

void draw_chart(std::ostream& out, const std::vector<TagCount>& pairs, std::size_t width, std::string_view bar) {
    if (pairs.empty()) {
        std::println(out, "No tags yet.");
        return;
    }
    double biggest = static_cast<double>(pairs.front().count);
    std::size_t label_width = std::ranges::max(pairs | std::views::transform([](const TagCount& p) { return text_width(p.tag); }));
    for (const auto& p : pairs) {
        auto blocks = static_cast<std::size_t>(std::nearbyint(static_cast<double>(p.count) / biggest * static_cast<double>(width)));
        std::print(out, "{}{}  ", p.tag, std::string(label_width - text_width(p.tag), ' '));
        for (std::size_t b = 0; b < blocks; b++) out << bar;
        std::println(out, " {}", p.count);
    }
}

// ---- Talking to the user -----------------------------------------------------------------------

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

int main(int argc, char** argv) {
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
    draw_chart(std::cout, *pairs, CHART_WIDTH, BAR);
    return 0;
}
