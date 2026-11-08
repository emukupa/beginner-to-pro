// Errors, memory and text: the things Python has built in, written once for every module.
#pragma once
#include <stddef.h>

[[noreturn]] void fail(const char *format, ...);                    // message to stderr, exit 1
[[nodiscard]] void *checked(void *p);                                // stops cleanly if allocation failed
[[nodiscard]] char *copy_text(const char *s, size_t n);              // a new owned string of n bytes of s
bool is_space(char c);
void strip(const char **s, size_t *n, const char *chars);            // str.strip(chars); nullptr = whitespace
void lower(char *s);                                                 // ASCII lowercase, in place
bool same_word(const char *s, size_t n, const char *word);           // n bytes at s == word, any case
size_t text_width(const char *s);                                    // characters, not bytes (UTF-8)
[[nodiscard]] bool parse_whole_number(const char *text, long long *out);  // int(text), huge numbers capped

// Sorts like qsort, but stable: items that compare equal keep their order. compare is a function
// pointer, C's version of Python's key=lambda.
void stable_sort(void *base, size_t count, size_t size, int (*compare)(const void *, const void *));

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
