// C++ concepts, one lesson per file. This file pulls every lesson in with #include, which pastes
// each .cpp file here, so the whole thing compiles as one translation unit and later lessons can
// use earlier ones' functions and classes. Each lesson also includes concepts.hpp and the earlier
// lessons it uses, with #pragma once so nothing is pasted twice; that's why clangd understands any
// lesson file on its own. It's the simplest setup that always works: no headers to keep in step,
// no link step, no build system beyond make. Real projects split into headers and source files
// (chapter 02); C++20 named modules are the newer way, shown there once the tools are steady.
//
//   make          build/concepts, every lesson     make 07         just lesson 7
//   make 07 BUG=1 lesson 7 with its deliberate mistake compiled in, to watch the tools catch it

#include "concepts.hpp"  // the standard library, and BUG

#include "lesson_01_hello.cpp"
#include "lesson_02_types.cpp"
#include "lesson_03_numbers.cpp"
#include "lesson_04_strings.cpp"
#include "lesson_05_decisions.cpp"
#include "lesson_06_functions.cpp"
#include "lesson_07_collections.cpp"
#include "lesson_08_classes.cpp"
#include "lesson_09_ownership.cpp"
#include "lesson_10_errors.cpp"
#include "lesson_11_files.cpp"
#include "lesson_12_templates.cpp"
#include "lesson_13_ranges.cpp"
#include "lesson_14_constexpr.cpp"

struct Lesson {
    std::string_view title;
    void (*run)();                    // a function pointer: each lesson's run function
};

constexpr std::array LESSONS = {
    Lesson{"Hello", lesson_01},
    Lesson{"Types", lesson_02},
    Lesson{"Numbers", lesson_03},
    Lesson{"Strings and views", lesson_04},
    Lesson{"Decisions, loops and enum class", lesson_05},
    Lesson{"Functions and lambdas", lesson_06},
    Lesson{"Collections", lesson_07},
    Lesson{"Classes and inheritance", lesson_08},
    Lesson{"Ownership", lesson_09},
    Lesson{"Errors", lesson_10},
    Lesson{"Files", lesson_11},
    Lesson{"Templates and concepts", lesson_12},
    Lesson{"Ranges, views and a mini tracker", lesson_13},
    Lesson{"constexpr and static_assert", lesson_14},
};

void run(std::size_t number) {
    std::println("\n=== {:02} {} ===", number, LESSONS[number - 1].title);
    LESSONS[number - 1].run();
}

int main(int argc, char** argv) {
    if (argc == 1) {
        for (std::size_t i = 1; i <= LESSONS.size(); i++) run(i);
        return 0;
    }
    for (std::string_view arg : std::span(argv + 1, static_cast<std::size_t>(argc - 1))) {
        auto n = parse_whole_number(arg);  // lesson 10
        if (!n || *n < 1 || static_cast<std::size_t>(*n) > LESSONS.size()) {
            std::println(stderr, "No lesson {}", arg);
            return 1;
        }
        run(static_cast<std::size_t>(*n));
    }
    return 0;
}
