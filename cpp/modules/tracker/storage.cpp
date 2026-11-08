#include "storage.hpp"

#include <cerrno>
#include <fstream>

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

}  // namespace tracker
