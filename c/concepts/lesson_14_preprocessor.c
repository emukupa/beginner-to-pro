// Lesson 14: the preprocessor rewrites text before compiling. Macros are powerful and easy to get
// wrong, so C23 gives real alternatives: constexpr for constants, static_assert for checks.
// BUG=14: a static_assert that fails. The program never builds.

#pragma once
#include "concepts.h"

#define SQUARE_BAD(x) x * x            // pasted text, not a function
#define SQUARE(x) ((x) * (x))          // brackets everywhere: the fix

constexpr size_t CHART_WIDTH = 20;     // a true constant, with a type
static_assert(CHART_WIDTH > 0, "a chart needs room for its bars");

static void lesson_14(void) {
    printf("SQUARE_BAD(1 + 2) = %d, SQUARE(1 + 2) = %d\n", SQUARE_BAD(1 + 2), SQUARE(1 + 2));
    auto width = CHART_WIDTH;          // C23 auto: the compiler works out size_t
    printf("CHART_WIDTH = %zu (sizeof width: %zu)\n", width, sizeof width);
#if BUG == 14
    static_assert(CHART_WIDTH == 0, "this check fails on purpose");
#endif
}
