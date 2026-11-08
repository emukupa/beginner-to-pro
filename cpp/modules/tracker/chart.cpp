#include "chart.hpp"

#include <cmath>
#include <print>
#include <ranges>
#include <string>

#include "text.hpp"

namespace tracker {

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

}  // namespace tracker
