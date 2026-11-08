#include "tasklist.h"

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "parsing.h"
#include "text.h"

typedef struct tasklist {
    Task *items;
    size_t len, cap;
} TaskList;

TaskList *tasklist_new(void) { return checked(calloc(1, sizeof(TaskList))); }

void tasklist_free(TaskList *list) {
    if (list == nullptr) return;
    for (size_t i = 0; i < list->len; i++) task_free(&list->items[i]);
    free(list->items);
    free(list);
}

size_t tasklist_len(const TaskList *list) { return list->len; }

const Task *tasklist_get(const TaskList *list, size_t i) { return i < list->len ? &list->items[i] : nullptr; }

void tasklist_push(TaskList *list, Task owned) { PUSH(list, owned); }

size_t add_tasks(TaskList *list, const StringList *titles, const char *created) {
    size_t added = 0;
    for (size_t i = 0; i < titles->len; i++) {
        size_t n = strlen(titles->items[i]) + sizeof "[todo] ";
        char *line = checked(malloc(n));
        snprintf(line, n, "[todo] %s", titles->items[i]);
        Task t;
        if (parse_line(line, &t)) {
            snprintf(t.created, sizeof t.created, "%s", created);
            PUSH(list, t);
            added++;
        }
        free(line);
    }
    return added;
}

TagList count_tags(const TaskList *list, bool include_done) {
    TagList counts = {};
    for (size_t i = 0; i < list->len; i++) {
        auto t = &list->items[i];  // C23 auto: the compiler works out const Task *
        if (!include_done && task_is_done(t)) continue;
        for (size_t j = 0; j < t->tags.len; j++) {
            size_t k = 0;
            while (k < counts.len && strcmp(counts.items[k].tag, t->tags.items[j]) != 0) k++;
            if (k == counts.len) PUSH(&counts, ((TagCount){t->tags.items[j], 0}));
            counts.items[k].count++;
        }
    }
    return counts;
}

// The comparator for stable_sort: more first. Returns <0, 0 or >0, like qsort's.
static int most_first(const void *a, const void *b) {
    size_t x = ((const TagCount *)a)->count, y = ((const TagCount *)b)->count;
    return (x < y) - (x > y);
}

bool top_tags(const TaskList *list, long long n, bool include_done, TagList *out) {
    if (n < 1) return false;
    TagList counts = count_tags(list, include_done);
    stable_sort(counts.items, counts.len, sizeof *counts.items, most_first);
    if ((unsigned long long)n < counts.len) counts.len = (size_t)n;
    *out = counts;
    return true;
}

Summary summarize(const TaskList *list) {
    Summary s = {.total = list->len};
    for (size_t i = 0; i < list->len; i++) s.done += task_is_done(&list->items[i]);
    TagList tags = count_tags(list, true);
    s.tags = tags.len;
    free(tags.items);
    s.percent = s.total ? (double)s.done / (double)s.total * 100 : 0;
    return s;
}
