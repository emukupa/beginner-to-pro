// Lesson 10: structs bundle fields; enums name a fixed set of choices. C has no classes or
// inheritance: a field says what kind of task it is.

#pragma once
#include "concepts.h"
#include "lesson_08_strings.c"    // strip, same_word
#include "lesson_09_memory.c"     // copy_text

typedef enum task_status : unsigned char { STATUS_TODO, STATUS_DONE, STATUS_OTHER } TaskStatus;  // C23: one byte
typedef enum task_kind { TASK_PLAIN, TASK_URGENT } TaskKind;

typedef struct task {
    char *title;                       // owned
    TaskStatus status;
    TaskKind kind;
} Task;

// "[done.] Call mom" -> a Task, using lesson 08's strip and same_word and lesson 09's copy_text.
[[nodiscard]] static bool parse_task(const char *line, Task *out) {
    const char *close = strchr(line, ']');
    if (line[0] != '[' || close == nullptr) return false;
    const char *status = line;
    size_t status_len = (size_t)(close - line);
    strip(&status, &status_len, "[] .");
    const char *title = close + 1;
    size_t title_len = strlen(title);
    strip(&title, &title_len, nullptr);
    *out = (Task){
        .title = copy_text(title, title_len),
        .status = same_word(status, status_len, "done") ? STATUS_DONE
                  : same_word(status, status_len, "todo") ? STATUS_TODO : STATUS_OTHER,
        .kind = strstr(line, "#urgent") ? TASK_URGENT : TASK_PLAIN,
    };
    return true;
}

static void lesson_10(void) {
    Task t;
    if (parse_task("[DONE.] Call mom", &t)) {
        printf("title \"%s\", done? %s, %zu byte for the status\n", t.title,
               t.status == STATUS_DONE ? "yes" : "no", sizeof t.status);
        Task *p = &t;                  // through a pointer, -> reaches a field: p->title is (*p).title
        printf("through a pointer: p->title is \"%s\"\n", p->title);
        free(t.title);
    }
}
