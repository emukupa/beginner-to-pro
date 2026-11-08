// Reading and writing the tasks file. The only module that opens files.
#pragma once
#include "models.h"
#include "tasklist.h"

typedef enum load_result { LOAD_OK, LOAD_NOT_FOUND, LOAD_UNREADABLE } LoadResult;

[[nodiscard]] LoadResult load_tasks(const char *path, TaskList *list);  // adds the file's tasks
void append_titles(const char *path, const StringList *titles);        // "[todo] title" lines on the end

// Rewrites the line holding this task as [todo] or [done], leaving every other byte of the file
// alone. Writes a new file beside it, then renames it over the old one, so the file is never left
// half-written. False if the file couldn't be read or replaced (the old file is then untouched), or
// if status is STATUS_OTHER, which has no one way to write it.
[[nodiscard]] bool set_status(const char *path, const Task *task, TaskStatus status);
