// Reading and writing the tasks file. The only module that opens files.
#pragma once
#include "models.h"
#include "tasklist.h"

typedef enum load_result { LOAD_OK, LOAD_NOT_FOUND, LOAD_UNREADABLE } LoadResult;

[[nodiscard]] LoadResult load_tasks(const char *path, TaskList *list);  // adds the file's tasks
void append_titles(const char *path, const StringList *titles);        // "[todo] title" lines on the end
