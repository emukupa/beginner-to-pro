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

}  // namespace tracker
