// Drawing (label, count) pairs as bars. Knows nothing about tasks, and draws to any output stream.
#pragma once
#include <ostream>
#include <string_view>
#include <vector>

#include "tasklist.hpp"

namespace tracker {

void draw_chart(std::ostream& out, const std::vector<TagCount>& pairs, std::size_t width, std::string_view bar);

}  // namespace tracker
