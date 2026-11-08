// Lesson 13: a function pointer holds a function, so you can hand "how to compare" to a sort.
// qsort isn't stable: equal items can swap places. Our stable_sort keeps them in order.

#pragma once
#include "concepts.h"
#include "lesson_09_memory.c"     // checked

typedef struct tag_count {
    const char *tag;
    size_t count;
} TagCount;

static int most_first(const void *a, const void *b) {   // the comparator: <0, 0 or >0, like qsort's
    size_t x = ((const TagCount *)a)->count, y = ((const TagCount *)b)->count;
    return (x < y) - (x > y);
}

static void stable_sort(void *base, size_t count, size_t size, int (*compare)(const void *, const void *)) {
    unsigned char *items = base;
    unsigned char *held = checked(malloc(size));
    for (size_t i = 1; i < count; i++) {
        memcpy(held, items + i * size, size);
        size_t j = i;
        while (j > 0 && compare(items + (j - 1) * size, held) > 0) {
            memcpy(items + j * size, items + (j - 1) * size, size);
            j--;
        }
        memcpy(items + j * size, held, size);
    }
    free(held);
}

static void lesson_13(void) {
    TagCount tags[] = {{"home", 2}, {"work", 3}, {"family", 1}, {"travel", 1}, {"urgent", 1}};
    stable_sort(tags, 5, sizeof tags[0], most_first);
    for (size_t i = 0; i < 5; i++) {
        printf("%-7s ", tags[i].tag);
        for (size_t b = 0; b < tags[i].count * 4; b++) fputs("█", stdout);   // █ is 3 bytes: draw it whole
        printf(" %zu\n", tags[i].count);
    }
}
