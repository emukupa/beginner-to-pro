// One line of text into a task: the only place that knows the file format.
#pragma once
#include <memory>
#include <string_view>

#include "models.hpp"

namespace tracker {

constexpr char TAG_MARKER = '#';  // marks a word as a tag: "#work"

// "[done.] Call mom #family" -> a task, or an empty pointer if the line isn't one.
std::unique_ptr<Task> parse_line(std::string_view line);

}  // namespace tracker
