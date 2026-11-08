#include "storage.hpp"

#include <cerrno>
#include <filesystem>
#include <fstream>
#include <iterator>

#include <stdlib.h>  // mkstemp (POSIX, not standard C++)
#include <unistd.h>  // write, fsync, close

#include "parsing.hpp"

namespace tracker {

std::expected<TaskList, LoadError> load_tasks(const std::string& path) {
    std::ifstream file{path};
    if (!file) return std::unexpected(errno == ENOENT ? LoadError::NotFound : LoadError::Unreadable);
    TaskList tasks;
    for (std::string line; std::getline(file, line);) {
        if (auto task = parse_line(line)) tasks.push_back(std::move(task));  // lines that aren't tasks are skipped
    }
    return tasks;
}

void append_titles(const std::string& path, const std::vector<std::string>& titles) {
    std::ofstream file{path, std::ios::app};
    for (const auto& title : titles) file << "[todo] " << title << '\n';
}

namespace {

// A new file beside path, with a name nobody else is using. RAII: the destructor closes it, and
// deletes it unless keep() was called. Every way out of mark_done is covered, with no goto and no
// flag: C++'s answer to C's goto cleanup and C3's defer catch.
class TempFile {
public:
    explicit TempFile(const std::string& beside) : name_{beside + ".XXXXXX"}, fd_{::mkstemp(name_.data())} {}
    ~TempFile() {
        if (fd_ != -1) ::close(fd_);
        if (fd_ != -1 && !kept_) std::filesystem::remove(name_);
    }
    TempFile(const TempFile&) = delete;             // one owner of one file
    TempFile& operator=(const TempFile&) = delete;

    bool ok() const { return fd_ != -1; }
    const std::string& name() const { return name_; }
    bool write_all(std::string_view text) {
        while (!text.empty()) {
            auto n = ::write(fd_, text.data(), text.size());
            if (n <= 0) return false;
            text.remove_prefix(static_cast<std::size_t>(n));
        }
        return ::fsync(fd_) == 0;                   // on the disk before it replaces anything
    }
    void keep() { kept_ = true; }

private:
    std::string name_;
    int fd_;
    bool kept_ = false;
};

// True if this line holds the task: the same title and status after parsing.
bool holds(std::string_view line, const Task& task) {
    auto found = parse_line(line);
    return found && found->title() == task.title() && found->status() == task.status();
}

}  // namespace

bool mark_done(const std::string& path, const Task& task) {
    std::ifstream in{path, std::ios::binary};
    if (!in) return false;
    std::string data{std::istreambuf_iterator<char>{in}, {}};  // every byte, line endings and all
    std::string out;
    bool changed = false;
    for (std::size_t start = 0; start < data.size();) {
        std::size_t end = data.find('\n', start);
        end = end == std::string::npos ? data.size() : end + 1;  // keep the line's own ending
        std::string_view line{data.data() + start, end - start};
        start = end;
        auto open = line.find('[');
        auto close = open == std::string_view::npos ? open : line.find(']', open);
        if (changed || close == std::string_view::npos || !holds(line, task)) {
            out += line;
            continue;
        }
        out += line.substr(0, open);                  // any spaces before the bracket
        out += "[done]";
        out += line.substr(close + 1);                // the title, tags and line ending
        changed = true;
    }

    TempFile temp{path};
    if (!temp.ok() || !temp.write_all(out)) return false;
    std::error_code error;
    std::filesystem::permissions(temp.name(), std::filesystem::status(path).permissions(), error);  // keep them
    std::filesystem::rename(temp.name(), path, error);  // atomic: readers see the old file or the new one
    if (error) return false;
    temp.keep();
    return true;
}

}  // namespace tracker
