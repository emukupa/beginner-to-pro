// Lesson 01: a C program is functions; main is where it starts, and its return value is the exit code.
// BUG=1: an unused variable. -Werror turns that warning into an error, so the program never builds.

#pragma once
#include "concepts.h"

static void lesson_01(void) {
    printf("Hello from C\n");      // printf prints; \n ends the line (nothing adds it for you)
    printf("%s, %d and %.1f\n", "text", 42, 2.5);  // %s text, %d whole number, %f decimal
#if BUG == 1
    int unused = 5;
#endif
}
