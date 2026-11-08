// Lesson 01: a C++ program starts at main, and main's return value is the exit code.
// BUG=1: a format string asking for two values but given one. std::print checks the string while
// compiling, so the mistake never reaches a user.

#pragma once
#include "concepts.hpp"

void lesson_01() {
    std::println("Hello from C++");                   // println adds the newline for you
    std::print("no newline here, ");                  // print doesn't
    std::print("so this carries on\n");
    std::println("{}, {} and {}", "text", 42, 2.5);   // {} fits any type: no %s or %d to get wrong
    std::println("{:>5}|{:<5}|{:^5}|", 1, 2, 3);      // > right, < left, ^ centre, in 5 columns
#if BUG == 1
    std::println("{} of {} done", 3);                 // two {} but one value: a compile error
#endif
}
