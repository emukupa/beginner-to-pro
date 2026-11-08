#define _POSIX_C_SOURCE 200809L  // getline()
#include "storage.h"

#include <errno.h>
#include <stdio.h>
#include <stdlib.h>

#include "parsing.h"

LoadResult load_tasks(const char *path, TaskList *list) {
    FILE *f = fopen(path, "r");
    if (f == nullptr) return errno == ENOENT ? LOAD_NOT_FOUND : LOAD_UNREADABLE;
    char *line = nullptr;  // owned; getline grows it as needed
    size_t cap = 0;
    while (getline(&line, &cap, f) != -1) {
        Task t;
        if (parse_line(line, &t)) tasklist_push(list, t);
    }
    free(line);
    fclose(f);
    return LOAD_OK;
}

void append_titles(const char *path, const StringList *titles) {
    FILE *f = fopen(path, "a");
    if (f == nullptr) return;
    for (size_t i = 0; i < titles->len; i++) fprintf(f, "[todo] %s\n", titles->items[i]);
    fclose(f);
}
