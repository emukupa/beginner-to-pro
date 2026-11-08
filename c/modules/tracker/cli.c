// The program the user talks to. The only module that reads input, prints to the screen, or exits.
#define _POSIX_C_SOURCE 200809L  // getline(), localtime_r()

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>

#include "chart.h"
#include "models.h"
#include "parsing.h"
#include "storage.h"
#include "tasklist.h"
#include "text.h"

static constexpr size_t CHART_WIDTH = 20;    // the longest bar, in characters
static constexpr long long DEFAULT_TOP = 3;  // top tags shown when the answer is empty or invalid

static_assert(DEFAULT_TOP >= 1, "the fallback must itself be a valid answer");
static_assert(CHART_WIDTH > 0, "a chart needs room for its bars");

// Like Python's input(): shows the prompt, reads one line, drops the newline. The caller owns the
// result. At the end of input it returns an empty line.
[[nodiscard]] static char *ask(const char *prompt) {
    fputs(prompt, stdout);
    fflush(stdout);
    char *line = nullptr;
    size_t cap = 0;
    ssize_t n = getline(&line, &cap, stdin);
    if (n < 0) {
        free(line);
        return copy_text("", 0);
    }
    if (n > 0 && line[n - 1] == '\n') line[n - 1] = '\0';
    return line;
}

int main(int argc, char **argv) {
    const char *path = argc > 1 ? argv[1] : getenv("TASKS_FILE");
    if (path == nullptr) path = "tasks.txt";

    TaskList *tasks = tasklist_new();
    switch (load_tasks(path, tasks)) {
        case LOAD_OK: break;
        case LOAD_NOT_FOUND: fail("Couldn't find %s", path);
        case LOAD_UNREADABLE: fail("Couldn't read %s", path);
    }

    StringList new_titles = {};
    for (;;) {
        char *answer = ask("New task (Enter to finish): ");
        const char *s = answer;
        size_t n = strlen(answer);
        strip(&s, &n, nullptr);
        if (n == 0) {
            free(answer);
            break;
        }
        if (s[0] == TAG_MARKER) {
            puts("A task needs a title, not just tags.");
        } else {
            PUSH(&new_titles, copy_text(s, n));
        }
        free(answer);
    }

    char today[DATE_SIZE] = "";
    time_t now = time(nullptr);
    struct tm local;
    if (localtime_r(&now, &local) != nullptr) strftime(today, sizeof today, "%Y-%m-%d", &local);
    if (add_tasks(tasks, &new_titles, today) > 0) append_titles(path, &new_titles);

    TagList pairs = {};
    char *answer = ask("How many top tags? [3]: ");
    long long n = DEFAULT_TOP;
    if ((answer[0] != '\0' && !parse_whole_number(answer, &n)) || !top_tags(tasks, n, true, &pairs)) {
        puts("Need a whole number of at least 1 — using 3.");
        if (!top_tags(tasks, DEFAULT_TOP, true, &pairs)) fail("unreachable: DEFAULT_TOP is valid");
    }
    free(answer);

    Summary s = summarize(tasks);
    printf("\n%zu tasks, %zu done (%.0f%%), %zu tags\n", s.total, s.done, s.percent, s.tags);
    for (size_t i = 0; i < tasklist_len(tasks); i++) {
        const Task *t = tasklist_get(tasks, i);
        if (t->kind == TASK_URGENT && !task_is_done(t)) task_write(t, stdout);
    }

    puts("\nTop tags");
    draw_chart(stdout, &pairs, CHART_WIDTH, "█");

    free(pairs.items);
    strlist_free(&new_titles);
    tasklist_free(tasks);
    return 0;
}
