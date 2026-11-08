// Lesson 14: constexpr code can run while compiling, and static_assert checks a fact then. A fact
// that's wrong stops the build, so it can never ship.
// BUG=14: a static_assert that fails. The program never builds.

#pragma once
#include "concepts.hpp"
#include "lesson_05_decisions.cpp"  // Status
#include "lesson_06_functions.cpp"  // bar, for comparison

constexpr std::size_t CHART_WIDTH = 20;  // a true constant, with a type (no #define)

// Lesson 06's bar length in whole numbers only, so it can run at compile time: count * width /
// most, with halves going to the even neighbour, as nearbyint does.
constexpr std::size_t bar_blocks(std::size_t count, std::size_t most, std::size_t width = CHART_WIDTH) {
    if (most == 0) return 0;
    std::size_t blocks = count * width / most;
    std::size_t left = count * width % most;
    if (2 * left > most || (2 * left == most && blocks % 2 == 1)) blocks++;
    return blocks;
}

// The contract's own cases, checked by the compiler on every build:
static_assert(bar_blocks(1, 8) == 2, "2.5 blocks rounds to 2, not 3");
static_assert(bar_blocks(2, 3) == 13, "13.33 blocks rounds down");
static_assert(bar_blocks(3, 3) == CHART_WIDTH, "the top tag fills the chart");
static_assert(sizeof(Status) == 1, "enum class Status : unsigned char takes one byte");

// A table built while compiling: the blocks for 0 to 8 out of 8.
constexpr auto EIGHTHS = [] {
    std::array<std::size_t, 9> out{};
    for (std::size_t i = 0; i < out.size(); i++) out[i] = bar_blocks(i, 8);
    return out;
}();

void lesson_14() {
    std::println("bar_blocks for 0..8 of 8, worked out by the compiler: {}", EIGHTHS);
    bool agree = true;
    for (std::size_t i = 0; i <= 8; i++) agree = agree && bar(i, 8).size() == EIGHTHS[i] * BLOCK.size();
    std::println("the same as lesson 06's bar, which runs while the program runs? {}", agree);
    constexpr auto width = CHART_WIDTH;  // constexpr variables must be known while compiling
    std::println("CHART_WIDTH = {}", width);
#if BUG == 14
    static_assert(bar_blocks(1, 8) == 3, "this check fails on purpose: halves go to even");
#endif
}
