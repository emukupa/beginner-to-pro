// What a task is. Includes nothing of ours: every other module builds on this one.
#pragma once
#include <stddef.h>
#include <stdio.h>

static constexpr size_t DATE_SIZE = sizeof "YYYY-MM-DD";

// A list of strings. It owns every string in it.
typedef struct strlist {
    char **items;
    size_t len, cap;
} StringList;

void strlist_free(StringList *list);

// C23 lets an enum choose its storage: a status fits in one byte.
typedef enum task_status : unsigned char { STATUS_TODO, STATUS_DONE, STATUS_OTHER } TaskStatus;

// C has no inheritance. Python's UrgentTask(Task) becomes a field that says which kind it is.
typedef enum task_kind { TASK_PLAIN, TASK_URGENT } TaskKind;

typedef struct task {
    char *title;              // owned
    StringList tags;          // owned
    TaskStatus status;
    TaskKind kind;
    char created[DATE_SIZE];  // "YYYY-MM-DD" for tasks added this run, else ""
} Task;

bool task_is_done(const Task *t);
void task_write(const Task *t, FILE *out);  // "[ ] Title" (urgent: "  !!" on the end)
void task_free(Task *t);
