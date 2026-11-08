// Text helpers C++'s standard library doesn't have: Python's strip, lower and split.
#pragma once
#include <string>
#include <string_view>
#include <vector>

namespace tracker {

constexpr bool is_space(char c) { return c == ' ' || c == '\t' || c == '\n' || c == '\r' || c == '\v' || c == '\f'; }

std::string_view strip(std::string_view s, std::string_view chars = " \t\n\r\v\f");  // a view: no copy
std::string lower(std::string_view s);                                              // ASCII lowercase
std::vector<std::string_view> words(std::string_view text);                          // split(): views into text
std::size_t text_width(std::string_view s);                                          // characters, not bytes

}  // namespace tracker
