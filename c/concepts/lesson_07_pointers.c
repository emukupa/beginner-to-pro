// Lesson 07: a pointer holds the address of a value. & takes an address, * follows one.
// BUG=7: following a null pointer. The sanitizers stop the program and say where.

#pragma once
#include "concepts.h"

static void swap(int *a, int *b) {     // with pointers, a function can change the caller's values
    int held = *a;
    *a = *b;
    *b = held;
}

static void lesson_07(void) {
    int x = 1, y = 2;
    int *p = &x;
    printf("x = %d, *p = %d, p points at x? %s\n", x, *p, p == &x ? "yes" : "no");
    swap(&x, &y);
    printf("after swap: x = %d, y = %d\n", x, y);
    int counts[3] = {4, 2, 2};
    int *first = counts;               // an array name becomes a pointer to its first item
    printf("*(first + 1) = %d, same as counts[1] = %d\n", *(first + 1), counts[1]);
    int *nothing = nullptr;            // C23: nullptr means "points at nothing"
    printf("nothing is %s\n", nothing == nullptr ? "null" : "set");
#if BUG == 7
    printf("%d\n", *nothing);          // following nothing
#endif
}
