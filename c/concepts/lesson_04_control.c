// Lesson 04: decisions and loops. Braces mark the blocks; indentation is only for people.

#pragma once
#include "concepts.h"

static void lesson_04(void) {
    for (int i = 1; i <= 3; i++) {     // start; keep going while; after each turn
        if (i == 1) {
            printf("%d: first\n", i);
        } else if (i == 2) {
            printf("%d: second\n", i);
        } else {
            printf("%d: the rest\n", i);
        }
    }
    char status = 'd';
    switch (status) {                  // switch: one value, many cases. break leaves the switch.
        case 'd': printf("done\n"); break;
        case 't': printf("todo\n"); break;
        default: printf("unknown\n");
    }
    int n = 0;
    while (n < 3) n++;                 // while checks first
    do { n--; } while (n > 10);        // do-while runs at least once
    printf("n ends at %d\n", n);
}
