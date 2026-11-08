// Lesson 05: if, switch and loops. And enum class: a fixed set of named choices, so a status is
// never a misspelt string.
// BUG=5: a switch that forgets one status. -Wswitch (on with -Wall) notices, -Werror stops the build.

#pragma once
#include "concepts.hpp"

enum class Status : unsigned char { Todo, Done, Other };  // one byte each; Status::Done, never just Done

// "done" -> Status::Done. Expects lesson 04's cleaned text.
Status to_status(std::string_view cleaned) {
    if (cleaned == "done") return Status::Done;
    if (cleaned == "todo") return Status::Todo;
    return Status::Other;
}

std::string_view status_name(Status status) {
    switch (status) {                 // no default: then the compiler tells us if a case is missing
        case Status::Todo: return "todo";
        case Status::Done: return "done";
#if BUG != 5
        case Status::Other: return "other";
#endif
    }
    return "?";                       // unreachable, but every path must return
}

void lesson_05() {
    for (std::string_view word : {"done", "todo", "doing"}) {     // range-for: every item, in order
        Status s = to_status(word);
        if (s == Status::Done) {
            std::println("{:<6} -> done, well done", word);
        } else if (s == Status::Todo) {
            std::println("{:<6} -> still to do", word);
        } else {
            std::println("{:<6} -> {} (not a status we know)", word, status_name(s));
        }
    }
    std::print("counting with for:");
    for (int i = 1; i <= 3; i++) std::print(" {}", i);
    std::print("\nwhile halves 20:");
    int n = 20;
    while (n > 1) {
        n /= 2;
        if (n == 5) continue;         // skip this one
        std::print(" {}", n);
    }
    std::println("");
    if (auto left = 6 - 3; left > 0) std::println("if with a start: {} left", left);  // left lives only here
    std::println("6 tasks: {}", 6 > 5 ? "a busy week" : "a quiet week");            // ? : picks a value
}
