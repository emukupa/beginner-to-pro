// Lesson 11: a growable array: items, how many are used, how many fit. Full? Double it with realloc.
// One PUSH macro grows any of them; C23's typeof gives the new item the array's own type.

#pragma once
#include "concepts.h"
#include "lesson_09_memory.c"     // checked
#include "lesson_10_structs.c"    // Task, parse_task

#define PUSH(list, item)                                                                           \
    do {                                                                                           \
        typeof((list)->items[0]) push_item_ = (item);                                              \
        if ((list)->len == (list)->cap) {                                                          \
            (list)->cap = (list)->cap ? (list)->cap * 2 : 4;                                       \
            (list)->items = checked(realloc((list)->items, (list)->cap * sizeof *(list)->items)); \
        }                                                                                          \
        (list)->items[(list)->len++] = push_item_;                                                 \
    } while (0)

typedef struct tasklist {
    Task *items;                       // owned, and each task's title too
    size_t len, cap;
} TaskList;

static void tasklist_free(TaskList *list) {
    for (size_t i = 0; i < list->len; i++) free(list->items[i].title);
    free(list->items);
    *list = (TaskList){};
}

static void lesson_11(void) {
    TaskList list = {};
    const char *lines[] = {"[done] A", "[todo] B", "[todo] C", "[done] D", "[todo] E"};
    for (size_t i = 0; i < 5; i++) {
        Task t;
        if (parse_task(lines[i], &t)) PUSH(&list, t);
        printf("pushed %zu, room for %zu\n", list.len, list.cap);
    }
    tasklist_free(&list);
}
