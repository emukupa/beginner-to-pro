// The task tracker in one file of Safe C (C23). Same behaviour as python/tasks.py, byte for byte:
// contract/run.sh checks it.
//
// The Safe C rules this file follows (see chapters/01-one-file/CHAPTER.md):
//   1. Built with -Wall -Wextra -Wpedantic -Wconversion -Werror, and run under AddressSanitizer
//      and UndefinedBehaviorSanitizer, so overflows and undefined behaviour stop the program.
//   2. No gets, strcpy, strcat, sprintf, atoi. Strings are copied with an explicit length.
//   3. Every allocation is checked. Every pointer that owns memory says so, and is freed once.
//   4. Lengths travel with their buffers (size_t, never int).
//   5. A result that must be checked is marked [[nodiscard]], so ignoring it is a compile error.

#define _POSIX_C_SOURCE 200809L  // getline(), localtime_r()

#include <ctype.h>
#include <errno.h>
#include <limits.h>
#include <math.h>
#include <stdarg.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>

// ---- Settings -----------------------------------------------------------------------------------

constexpr size_t CHART_WIDTH = 20;      // the longest bar, in characters
constexpr long long DEFAULT_TOP = 3;    // top tags shown when the answer is empty or invalid
constexpr char TAG_MARKER = '#';
constexpr size_t DATE_SIZE = sizeof "YYYY-MM-DD";

static_assert(DEFAULT_TOP >= 1, "the fallback must itself be a valid answer");
static_assert(CHART_WIDTH > 0, "a chart needs room for its bars");

// ---- Errors, memory and text (Python has these built in) ----------------------------------------

// Prints a message to stderr, like printf, and stops the program with exit code 1.
[[noreturn]] static void fail(const char *format, ...) {
    va_list args;
    va_start(args, format);
    vfprintf(stderr, format, args);
    va_end(args);
    fputc('\n', stderr);
    exit(1);
}

// Every allocation goes through here: if the system is out of memory, stop cleanly.
[[nodiscard]] static void *checked(void *p) {
    if (p == nullptr) fail("Out of memory");
    return p;
}

// Adds item to the end of any growable array (a struct with items, len and cap), doubling its room
// when it's full. typeof gives the item the array's own element type, so it's evaluated once and
// type-checked like an ordinary assignment.
#define PUSH(list, item)                                                                           \
    do {                                                                                           \
        typeof((list)->items[0]) push_item_ = (item);                                              \
        if ((list)->len == (list)->cap) {                                                          \
            (list)->cap = (list)->cap ? (list)->cap * 2 : 8;                                       \
            (list)->items = checked(realloc((list)->items, (list)->cap * sizeof *(list)->items)); \
        }                                                                                          \
        (list)->items[(list)->len++] = push_item_;                                                 \
    } while (0)

// A new string holding n bytes of s. The caller owns it.
[[nodiscard]] static char *copy_text(const char *s, size_t n) {
    char *out = checked(malloc(n + 1));
    memcpy(out, s, n);
    out[n] = '\0';
    return out;
}

static bool is_space(char c) { return isspace((unsigned char)c) != 0; }

// Like Python's str.strip(chars): narrows [*s, *s + *n) without copying. chars == nullptr means
// whitespace.
static void strip(const char **s, size_t *n, const char *chars) {
    while (*n > 0 && (chars ? strchr(chars, (*s)[0]) != nullptr : is_space((*s)[0]))) {
        (*s)++;
        (*n)--;
    }
    while (*n > 0 && (chars ? strchr(chars, (*s)[*n - 1]) != nullptr : is_space((*s)[*n - 1]))) {
        (*n)--;
    }
}

static void lower(char *s) {
    for (; *s; s++) *s = (char)tolower((unsigned char)*s);
}

// Does the n bytes at s spell word, ignoring case?
static bool same_word(const char *s, size_t n, const char *word) {
    if (strlen(word) != n) return false;
    for (size_t i = 0; i < n; i++) {
        if (tolower((unsigned char)s[i]) != word[i]) return false;
    }
    return true;
}

// Characters, not bytes: "█" is three bytes of UTF-8 but one character on screen.
static size_t text_width(const char *s) {
    size_t n = 0;
    for (; *s; s++) {
        if (((unsigned char)*s & 0xC0) != 0x80) n++;
    }
    return n;
}

// Sorts like qsort, but stable: items that compare equal keep their order. compare is a function
// pointer, C's version of Python's key=lambda.
static void stable_sort(void *base, size_t count, size_t size, int (*compare)(const void *, const void *)) {
    unsigned char *items = base;
    unsigned char *held = checked(malloc(size));
    for (size_t i = 1; i < count; i++) {
        memcpy(held, items + i * size, size);
        size_t j = i;
        while (j > 0 && compare(items + (j - 1) * size, held) > 0) {
            memcpy(items + j * size, items + (j - 1) * size, size);
            j--;
        }
        memcpy(items + j * size, held, size);
    }
    free(held);
}

// ---- What a task is -----------------------------------------------------------------------------

// A list of strings. It owns every string in it.
typedef struct strlist {
    char **items;
    size_t len, cap;
} StringList;

static void strlist_free(StringList *list) {
    for (size_t i = 0; i < list->len; i++) free(list->items[i]);
    free(list->items);
    *list = (StringList){};
}

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

static bool task_is_done(const Task *t) { return t->status == STATUS_DONE; }

static void task_print(const Task *t) {
    printf("[%c] %s%s\n", task_is_done(t) ? 'x' : ' ', t->title, t->kind == TASK_URGENT ? "  !!" : "");
}

static void task_free(Task *t) {
    free(t->title);
    strlist_free(&t->tags);
}

// A growable array of tasks. It owns every task in it.
typedef struct tasklist {
    Task *items;
    size_t len, cap;
} TaskList;

static void tasklist_free(TaskList *list) {
    for (size_t i = 0; i < list->len; i++) task_free(&list->items[i]);
    free(list->items);
    *list = (TaskList){};
}

// ---- One line of text into a task ---------------------------------------------------------------

// Turns "[done.] Call mom #family" into *out, which the caller then owns. False for lines that
// aren't tasks.
[[nodiscard]] static bool parse_line(const char *line, Task *out) {
    const char *s = line;
    size_t n = strlen(line);
    strip(&s, &n, nullptr);
    if (n == 0 || s[0] != '[') return false;

    // Python's partition("]"): what's before the first ], and what's after it.
    const char *close = memchr(s, ']', n);
    size_t status_len = close ? (size_t)(close - s) : n;
    const char *rest = close ? close + 1 : s + n;
    size_t rest_len = n - (size_t)(rest - s);

    const char *status = s;
    strip(&status, &status_len, "[] .");
    *out = (Task){
        .status = same_word(status, status_len, "done")   ? STATUS_DONE
                  : same_word(status, status_len, "todo") ? STATUS_TODO
                                                          : STATUS_OTHER,
        .kind = TASK_PLAIN,
    };

    // Split the rest into words: #words are tags, the others make the title.
    char *title = checked(calloc(rest_len + 1, 1));
    size_t title_len = 0;
    size_t i = 0;
    while (i < rest_len) {
        while (i < rest_len && is_space(rest[i])) i++;
        size_t start = i;
        while (i < rest_len && !is_space(rest[i])) i++;
        if (i == start) break;
        const char *word = rest + start;
        size_t word_len = i - start;
        if (word[0] == TAG_MARKER) {
            while (word_len > 0 && word[0] == TAG_MARKER) {  // lstrip("#")
                word++;
                word_len--;
            }
            strip(&word, &word_len, ".,");
            char *tag = copy_text(word, word_len);
            lower(tag);
            if (strcmp(tag, "urgent") == 0) out->kind = TASK_URGENT;
            PUSH(&out->tags, tag);
        } else {
            if (title_len > 0) title[title_len++] = ' ';
            memcpy(title + title_len, word, word_len);
            title_len += word_len;
        }
    }
    out->title = title;
    return true;
}

// ---- The tasks file -----------------------------------------------------------------------------

typedef enum load_result { LOAD_OK, LOAD_NOT_FOUND, LOAD_UNREADABLE } LoadResult;

// Adds every task in the file at path to tasks, and says whether it could.
[[nodiscard]] static LoadResult load_tasks(const char *path, TaskList *tasks) {
    FILE *f = fopen(path, "r");
    if (f == nullptr) return errno == ENOENT ? LOAD_NOT_FOUND : LOAD_UNREADABLE;
    char *line = nullptr;  // owned; getline grows it as needed
    size_t cap = 0;
    while (getline(&line, &cap, f) != -1) {
        Task t;
        if (parse_line(line, &t)) PUSH(tasks, t);
    }
    free(line);
    fclose(f);
    return LOAD_OK;
}

// Parses each title as a new "[todo]" task and adds it. Returns how many were added.
static size_t add_tasks(TaskList *tasks, const StringList *titles, const char *created) {
    size_t added = 0;
    for (size_t i = 0; i < titles->len; i++) {
        size_t n = strlen(titles->items[i]) + sizeof "[todo] ";
        char *line = checked(malloc(n));
        snprintf(line, n, "[todo] %s", titles->items[i]);
        Task t;
        if (parse_line(line, &t)) {
            snprintf(t.created, sizeof t.created, "%s", created);
            PUSH(tasks, t);
            added++;
        }
        free(line);
    }
    return added;
}

static void append_titles(const char *path, const StringList *titles) {
    FILE *f = fopen(path, "a");
    if (f == nullptr) return;
    for (size_t i = 0; i < titles->len; i++) fprintf(f, "[todo] %s\n", titles->items[i]);
    fclose(f);
}

// ---- Counting and ranking -----------------------------------------------------------------------

typedef struct tag_count {
    const char *tag;  // borrowed from a task
    size_t count;
} TagCount;

typedef struct tag_list {
    TagCount *items;  // owned
    size_t len, cap;
} TagList;

// Every tag with how many tasks carry it, in the order the tags first appear. The caller frees
// the items.
[[nodiscard]] static TagList count_tags(const TaskList *tasks, bool include_done) {
    TagList counts = {};
    for (size_t i = 0; i < tasks->len; i++) {
        auto t = &tasks->items[i];  // C23 auto: the compiler works out const Task *
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

// The n most used tags, most first; ties keep the order the tags first appear in. The caller
// frees out->items. False (and nothing set) when n < 1, like Python's ValueError.
[[nodiscard]] static bool top_tags(const TaskList *tasks, long long n, bool include_done, TagList *out) {
    if (n < 1) return false;
    TagList counts = count_tags(tasks, include_done);
    stable_sort(counts.items, counts.len, sizeof *counts.items, most_first);
    if ((unsigned long long)n < counts.len) counts.len = (size_t)n;
    *out = counts;
    return true;
}

// ---- Drawing the chart --------------------------------------------------------------------------

static void draw_chart(const TagList *pairs, size_t width, const char *bar_char) {
    if (pairs->len == 0) {
        puts("No tags yet.");
        return;
    }
    size_t biggest = pairs->items[0].count;
    size_t label_width = 0;
    for (size_t i = 0; i < pairs->len; i++) {
        size_t w = text_width(pairs->items[i].tag);
        if (w > label_width) label_width = w;
    }
    for (size_t i = 0; i < pairs->len; i++) {
        const TagCount *p = &pairs->items[i];
        // nearbyint rounds halves to even, like Python's round(): 2.5 -> 2
        size_t bar = (size_t)nearbyint((double)p->count / (double)biggest * (double)width);
        printf("%s%*s  ", p->tag, (int)(label_width - text_width(p->tag)), "");
        for (size_t b = 0; b < bar; b++) fputs(bar_char, stdout);
        printf(" %zu\n", p->count);
    }
}

// ---- Talking to the user ------------------------------------------------------------------------

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

// Like Python's int(text): optional spaces, an optional sign, digits (single underscores allowed
// between them), optional spaces. Anything else is an error. Huge numbers are capped.
[[nodiscard]] static bool parse_whole_number(const char *text, long long *out) {
    const char *s = text;
    size_t n = strlen(text);
    strip(&s, &n, nullptr);
    size_t i = 0;
    bool negative = false;
    if (i < n && (s[i] == '+' || s[i] == '-')) negative = s[i++] == '-';
    if (i == n || !isdigit((unsigned char)s[i])) return false;
    long long value = 0;
    for (; i < n; i++) {
        if (s[i] == '_' && i + 1 < n && isdigit((unsigned char)s[i + 1]) && isdigit((unsigned char)s[i - 1])) continue;
        if (!isdigit((unsigned char)s[i])) return false;
        int digit = s[i] - '0';
        value = value > (LLONG_MAX - digit) / 10 ? LLONG_MAX : value * 10 + digit;
    }
    *out = negative ? -value : value;
    return true;
}

int main(int argc, char **argv) {
    const char *path = argc > 1 ? argv[1] : getenv("TASKS_FILE");
    if (path == nullptr) path = "tasks.txt";

    TaskList tasks = {};
    switch (load_tasks(path, &tasks)) {
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
    if (add_tasks(&tasks, &new_titles, today) > 0) append_titles(path, &new_titles);

    TagList pairs = {};
    char *answer = ask("How many top tags? [3]: ");
    long long n = DEFAULT_TOP;
    if ((answer[0] != '\0' && !parse_whole_number(answer, &n)) || !top_tags(&tasks, n, true, &pairs)) {
        puts("Need a whole number of at least 1 — using 3.");
        if (!top_tags(&tasks, DEFAULT_TOP, true, &pairs)) fail("unreachable: DEFAULT_TOP is valid");
    }
    free(answer);

    size_t done = 0;
    for (size_t i = 0; i < tasks.len; i++) done += task_is_done(&tasks.items[i]);
    TagList all_tags = count_tags(&tasks, true);
    double percent = tasks.len ? (double)done / (double)tasks.len * 100 : 0;

    printf("\n%zu tasks, %zu done (%.0f%%), %zu tags\n", tasks.len, done, percent, all_tags.len);
    for (size_t i = 0; i < tasks.len; i++) {
        if (tasks.items[i].kind == TASK_URGENT && !task_is_done(&tasks.items[i])) task_print(&tasks.items[i]);
    }

    puts("\nTop tags");
    draw_chart(&pairs, CHART_WIDTH, "█");

    free(all_tags.items);
    free(pairs.items);
    strlist_free(&new_titles);
    tasklist_free(&tasks);
    return 0;
}
