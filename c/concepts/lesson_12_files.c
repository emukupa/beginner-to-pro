// Lesson 12: files are opened, read line by line with getline (it grows its own buffer), and closed.
// Errors are values: an enum says what went wrong.

#pragma once
#include "concepts.h"
#include "lesson_05_functions.c"  // percent
#include "lesson_10_structs.c"    // Task, parse_task
#include "lesson_11_growing.c"    // TaskList, PUSH, tasklist_free

typedef enum load_result { LOAD_OK, LOAD_NOT_FOUND, LOAD_UNREADABLE } LoadResult;

[[nodiscard]] static LoadResult load_tasks(const char *path, TaskList *list) {
    FILE *f = fopen(path, "r");
    if (f == nullptr) return errno == ENOENT ? LOAD_NOT_FOUND : LOAD_UNREADABLE;
    char *line = nullptr;              // owned; getline grows it
    size_t cap = 0;
    ssize_t n;
    while ((n = getline(&line, &cap, f)) != -1) {
        if (n > 0 && line[n - 1] == '\n') line[n - 1] = '\0';
        Task t;
        if (parse_task(line, &t)) PUSH(list, t);
    }
    free(line);
    fclose(f);
    return LOAD_OK;
}

static void lesson_12(void) {
    const char *paths[] = {"tasks.txt", "missing.txt"};
    for (size_t i = 0; i < 2; i++) {
        TaskList list = {};
        switch (load_tasks(paths[i], &list)) {
            case LOAD_OK: {
                size_t done = 0;
                for (size_t j = 0; j < list.len; j++) done += list.items[j].status == STATUS_DONE;
                printf("%s: %zu tasks, %zu done (%.0f%%)\n", paths[i], list.len, done, percent(done, list.len));
                break;
            }
            case LOAD_NOT_FOUND: printf("%s: not found\n", paths[i]); break;
            case LOAD_UNREADABLE: printf("%s: can't be read\n", paths[i]); break;
        }
        tasklist_free(&list);
    }
}
