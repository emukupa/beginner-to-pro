// The list of tasks: adding, counting, ranking. No printing, no files.
// The struct is opaque: other modules can only use it through these functions.
#pragma once
#include "models.h"

typedef struct tasklist TaskList;

[[nodiscard]] TaskList *tasklist_new(void);          // the caller owns it; free with tasklist_free
void tasklist_free(TaskList *list);
size_t tasklist_len(const TaskList *list);
const Task *tasklist_get(const TaskList *list, size_t i);
void tasklist_push(TaskList *list, Task owned);      // the list takes ownership of the task

// Parses each title as a new "[todo]" task and adds it. Returns how many were added.
size_t add_tasks(TaskList *list, const StringList *titles, const char *created);

// The first task whose title matches, ignoring case and extra spaces. Borrowed: the list still owns
// it. nullptr if there isn't one.
const Task *find_task(const TaskList *list, const char *title);

typedef struct tag_count {
    const char *tag;  // borrowed from a task in the list
    size_t count;
} TagCount;

typedef struct tag_list {
    TagCount *items;  // owned
    size_t len, cap;
} TagList;

// Every tag with how many tasks carry it, in first-seen order. The caller frees the items.
[[nodiscard]] TagList count_tags(const TaskList *list, bool include_done);

// The n most used tags, most first; ties keep first-seen order. The caller frees out->items.
// False when n < 1 (Python's ValueError).
[[nodiscard]] bool top_tags(const TaskList *list, long long n, bool include_done, TagList *out);

typedef struct summary {
    size_t total, done, tags;
    double percent;
} Summary;

Summary summarize(const TaskList *list);
