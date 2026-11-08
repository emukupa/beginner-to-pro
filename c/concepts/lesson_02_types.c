// Lesson 02: every value has a type with a fixed size. Sizes are why C is fast, and why it overflows.
// BUG=2: adding 1 to the biggest int. That's undefined behaviour; UBSan stops the program.

#pragma once
#include "concepts.h"

static void lesson_02(void) {
    printf("char %zu byte, int %zu, long %zu, double %zu, size_t %zu\n",
           sizeof(char), sizeof(int), sizeof(long), sizeof(double), sizeof(size_t));
    int biggest = INT_MAX;
    printf("the biggest int: %d\n", biggest);
    unsigned int counter = UINT_MAX;
    counter += 1;                      // unsigned numbers wrap around, by definition
    printf("UINT_MAX + 1 wraps to %u\n", counter);
    bool done = true;                  // C23: bool, true and false are keywords
    printf("done is %d (true is just 1)\n", done);
#if BUG == 2
    biggest += 1;                      // signed overflow: undefined, so anything could happen
    printf("INT_MAX + 1 = %d\n", biggest);
#endif
}
