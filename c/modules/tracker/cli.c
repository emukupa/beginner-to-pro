// The program the user talks to. The only module that reads input, prints to the screen, or exits.
#define _POSIX_C_SOURCE 200809L  // getline(), localtime_r()

#include <stddef.h>  // unreachable()
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

// What the command line asked for: one of two things, never both. A tagged union: kind says which
// member of the union holds the data, and only that member may be read.
typedef struct command {
    enum command_kind { COMMAND_TRACK, COMMAND_DONE } kind;
    union {
        struct {
            const char *path;  // argv[1], else $TASKS_FILE, else tasks.txt
        } track;
        struct {
            const char *path;  // $TASKS_FILE, else tasks.txt
            char *title;       // owned: the words after "done", joined and stripped; may be empty
        } done;
    };
} Command;

static Command read_command(int argc, char **argv) {
    const char *path = getenv("TASKS_FILE");
    if (path == nullptr) path = "tasks.txt";
    if (argc < 2 || strcmp(argv[1], "done") != 0) {
        return (Command){.kind = COMMAND_TRACK, .track.path = argc > 1 ? argv[1] : path};
    }
    // Python's " ".join(words).strip(): every word after "done", one space between each.
    size_t size = 1;
    for (int i = 2; i < argc; i++) size += strlen(argv[i]) + 1;
    char *joined = checked(malloc(size));  // owned, freed below
    size_t len = 0;
    for (int i = 2; i < argc; i++) {
        if (i > 2) joined[len++] = ' ';
        size_t n = strlen(argv[i]);
        memcpy(joined + len, argv[i], n);
        len += n;
    }
    const char *s = joined;
    strip(&s, &len, nullptr);
    Command command = {.kind = COMMAND_DONE, .done = {.path = path, .title = copy_text(s, len)}};
    free(joined);
    return command;
}

// tracker done "title": marks one task finished. Returns the exit code: 0 done (or already done),
// 1 no such file or task, 2 used wrongly.
static int done_command(const char *path, const char *title) {
    if (title[0] == '\0') {
        fputs("Usage: done \"task title\"\n", stderr);
        return 2;
    }
    TaskList *tasks = tasklist_new();
    LoadResult loaded = load_tasks(path, tasks);
    const Task *task = loaded == LOAD_OK ? find_task(tasks, title) : nullptr;  // borrowed from tasks
    int code = 0;
    if (loaded != LOAD_OK) {
        fprintf(stderr, "Couldn't %s %s\n", loaded == LOAD_NOT_FOUND ? "find" : "read", path);
        code = 1;
    } else if (task == nullptr) {
        fprintf(stderr, "No task called \"%s\"\n", title);
        code = 1;
    } else if (task_is_done(task)) {
        printf("Already done: %s\n", task->title);
    } else if (mark_done(path, task)) {
        printf("Done: %s\n", task->title);
    } else {
        fprintf(stderr, "Couldn't write %s\n", path);
        code = 1;
    }
    tasklist_free(tasks);
    return code;
}

// The program from chapter 01: ask for new tasks, then show the summary and the chart.
static int track_command(const char *path) {
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

int main(int argc, char **argv) {
    Command command = read_command(argc, argv);
    switch (command.kind) {
        case COMMAND_TRACK: return track_command(command.track.path);
        case COMMAND_DONE: {
            int code = done_command(command.done.path, command.done.title);
            free(command.done.title);
            return code;
        }
    }
    unreachable();  // C23: every kind returned above; -Wswitch flags a kind added without a case
}
