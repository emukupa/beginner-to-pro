#include "text.hpp"

#include <algorithm>

namespace tracker {

std::string_view strip(std::string_view s, std::string_view chars) {
    auto first = s.find_first_not_of(chars);
    if (first == std::string_view::npos) return {};
    return s.substr(first, s.find_last_not_of(chars) - first + 1);
}

std::string lower(std::string_view s) {
    std::string out{s};
    std::ranges::transform(out, out.begin(), [](char c) { return c >= 'A' && c <= 'Z' ? char(c - 'A' + 'a') : c; });
    return out;
}

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

std::size_t text_width(std::string_view s) {
    return static_cast<std::size_t>(std::ranges::count_if(s, [](char c) { return (static_cast<unsigned char>(c) & 0xC0) != 0x80; }));
}

}  // namespace tracker
