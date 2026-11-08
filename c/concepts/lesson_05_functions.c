// Lesson 05: functions take copies of their arguments, return one value, and can be private (static).
// BUG=5: ignoring a [[nodiscard]] result. The compiler refuses to build it.

#pragma once
#include "concepts.h"

[[nodiscard]] static double percent(size_t done, size_t total) {
    return total ? (double)done / (double)total * 100 : 0;
}

static void try_to_change(int n) {   // gets its own copy (lesson 07 shows how to change the original)
    n = 99;
    printf("inside try_to_change, n is %d\n", n);
}

static void lesson_05(void) {
    printf("percent(3, 7) = %.0f%%\n", percent(3, 7));
    int n = 1;
    try_to_change(n);
    printf("after try_to_change(n), n is still %d\n", n);
#if BUG == 5
    percent(3, 7);                     // the answer is thrown away: [[nodiscard]] makes that an error
#endif
}
