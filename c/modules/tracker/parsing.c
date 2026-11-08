#include "parsing.h"

#include <stdlib.h>
#include <string.h>

#include "text.h"

bool parse_line(const char *line, Task *out) {
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
