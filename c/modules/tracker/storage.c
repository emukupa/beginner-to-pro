#define _POSIX_C_SOURCE 200809L  // getline(), mkstemp(), fchmod(), fsync()
#include "storage.h"

#include <errno.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/stat.h>
#include <unistd.h>

#include "parsing.h"
#include "text.h"

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

// True if this line holds the task: the same title and status after parsing, like Python's check.
static bool holds(const char *line, const Task *task) {
    Task found;
    if (!parse_line(line, &found)) return false;
    bool same = strcmp(found.title, task->title) == 0 && found.status == task->status;
    task_free(&found);
    return same;
}

// Copies the file line by line into a new file beside it, changing one line on the way, then
// renames the new file over the old one. Every way out goes through cleanup, which closes and
// frees exactly what was opened, and deletes the new file unless it replaced the old one.
bool mark_done(const char *path, const Task *task) {
    bool replaced = false, changed = false;
    FILE *in = nullptr, *out = nullptr;
    char *line = nullptr;  // owned; getline grows it as needed
    size_t cap = 0;
    size_t size = strlen(path) + sizeof ".XXXXXX";
    char *temp = checked(malloc(size));  // owned: "tasks.txt.XXXXXX", the Xs filled in by mkstemp
    snprintf(temp, size, "%s.XXXXXX", path);
    int fd = -1;

    in = fopen(path, "r");
    if (in == nullptr) goto cleanup;
    fd = mkstemp(temp);  // creates the new file, with a name nobody else is using
    if (fd == -1) goto cleanup;
    out = fdopen(fd, "w");
    if (out == nullptr) goto cleanup;
    struct stat st;
    if (fstat(fileno(in), &st) == 0) fchmod(fd, st.st_mode & 07777);  // keep the old file's permissions

    ssize_t len;
    while ((len = getline(&line, &cap, in)) != -1) {
        size_t n = (size_t)len;  // the line's bytes, its ending included, exactly as read
        const char *open = !changed && holds(line, task) ? memchr(line, '[', n) : nullptr;
        const char *close = open ? memchr(open, ']', n - (size_t)(open - line)) : nullptr;
        if (close == nullptr) {
            fwrite(line, 1, n, out);
            continue;
        }
        fwrite(line, 1, (size_t)(open - line), out);                // any spaces before the bracket
        fputs("[done]", out);
        fwrite(close + 1, 1, n - (size_t)(close + 1 - line), out);  // the title, tags and line ending
        changed = true;
    }
    // Only swap in a file we know is complete: no read or write errors, and on the disk.
    if (ferror(in) || fflush(out) != 0 || ferror(out) || fsync(fd) != 0) goto cleanup;
    replaced = rename(temp, path) == 0;  // atomic: anyone reading sees the old file or the new one

cleanup:
    if (out != nullptr) {
        fclose(out);  // also closes fd
    } else if (fd != -1) {
        close(fd);
    }
    if (fd != -1 && !replaced) remove(temp);
    if (in != nullptr) fclose(in);
    free(line);
    free(temp);
    return replaced;
}
