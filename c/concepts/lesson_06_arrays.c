// Lesson 06: an array is a row of values of one type, with a fixed size and no bounds checking.
// BUG=6: the classic off-by-one, i <= n, reads one past the end. UBSan stops it: index out of bounds.

#pragma once
#include "concepts.h"

// Passed to a function, an array arrives as a pointer to its first item: its size is lost, so the
// length has to travel with it. That's Safe C's rule "lengths travel with their buffers".
static int sum(const int *values, size_t n) {
    printf("inside sum, sizeof values is %zu: just a pointer\n", sizeof values);
    int total = 0;
    for (size_t i = 0; i < n; i++) total += values[i];
    return total;
}

static void lesson_06(void) {
    int counts[3] = {4, 2, 2};
    size_t n = sizeof counts / sizeof counts[0];   // how many: total bytes / bytes per item
    int total = 0;
    for (size_t i = 0; i < n; i++) total += counts[i];
    printf("%zu counts, total %d (sizeof counts is %zu bytes)\n", n, total, sizeof counts);
    printf("sum(counts, n) = %d\n", sum(counts, n));
#if BUG == 6
    int sum = 0;
    for (size_t i = 0; i <= n; i++) sum += counts[i];   // <= instead of <: one turn too many
    printf("sum %d\n", sum);
#endif
}
