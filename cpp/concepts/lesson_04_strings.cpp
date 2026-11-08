// Lesson 04: std::string owns its characters; std::string_view only looks at someone else's.
// Views make parsing cheap (no copies), but a view must never outlive the string it looks at.
// BUG=4: a view of a temporary string, gone at the end of the line. Clang spots it (-Wdangling-gsl).

#pragma once
#include "concepts.hpp"

// Python's str.strip(chars): a narrower view of the same characters. Nothing is copied.
std::string_view strip(std::string_view text, std::string_view chars = " \t\r\n") {
    auto first = text.find_first_not_of(chars);
    if (first == std::string_view::npos) return {};
    auto last = text.find_last_not_of(chars);
    return text.substr(first, last - first + 1);
}

// A lower-case copy. This one has to own its characters, so it returns a std::string.
std::string lower(std::string_view text) {
    std::string out{text};
    for (char& c : out) c = static_cast<char>(std::tolower(static_cast<unsigned char>(c)));
    return out;
}

// "[ DONE. ]" -> "done". Lesson 10's parser reuses it.
std::string clean_status(std::string_view text) { return lower(strip(text, "[] .")); }

void lesson_04() {
    std::string title = "Finish";
    title += " quarterly report";     // a std::string grows as you add to it
    std::println("\"{}\" has {} characters; find(\"report\") -> {}", title, title.size(), title.find("report"));
    std::println("substr(7, 9) -> \"{}\", starts_with(\"Fin\")? {}", title.substr(7, 9), title.starts_with("Fin"));

    std::string_view view = title;    // no copy: a pointer and a length into title
    view.remove_prefix(7);
    std::println("a view after remove_prefix(7): \"{}\" (title is unchanged: \"{}\")", view, title);

    std::println("strip(\"  done  \") -> \"{}\"", strip("  done  "));
    std::println("clean_status(\"[ DONE. ]\") -> \"{}\"", clean_status("[ DONE. ]"));
    std::println("\"done\" == \"DONE\"? {}  lower first? {}", std::string_view{"done"} == "DONE", lower("DONE") == "done");
    std::println("[{:<6}] [{:<6}]  format pads by characters, not bytes", "cafe", "café");
#if BUG == 4
    std::string_view gone = std::string("built for this line only") + "!";  // the string dies here...
    std::println("{}", gone);                                                // ...and the view is left pointing at it
#endif
}
