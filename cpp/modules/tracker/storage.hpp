// Reading and writing the tasks file. The only module that opens files.
#pragma once
#include <expected>
#include <string>
#include <vector>

#include "models.hpp"

namespace tracker {

enum class LoadError { NotFound, Unreadable };

std::expected<TaskList, LoadError> load_tasks(const std::string& path);             // every task in the file
void append_titles(const std::string& path, const std::vector<std::string>& titles);  // "[todo] title" lines

// Rewrites the line holding this task as [todo] or [done], leaving every other byte of the file
// alone. Writes a new file beside it, then renames it over the old one, so the file is never left
// half-written. False if the file couldn't be read or replaced (the old file is then untouched), or
// if status is Other, which has no one way to be written.
[[nodiscard]] bool set_status(const std::string& path, const Task& task, Status status);

}  // namespace tracker
