#include "text.h"

#include <ctype.h>
#include <limits.h>
#include <stdarg.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

void fail(const char *format, ...) {
    va_list args;
    va_start(args, format);
    vfprintf(stderr, format, args);
    va_end(args);
    fputc('\n', stderr);
    exit(1);
}

void *checked(void *p) {
    if (p == nullptr) fail("Out of memory");
    return p;
}

char *copy_text(const char *s, size_t n) {
    char *out = checked(malloc(n + 1));
    memcpy(out, s, n);
    out[n] = '\0';
    return out;
}

bool is_space(char c) { return isspace((unsigned char)c) != 0; }

void strip(const char **s, size_t *n, const char *chars) {
    while (*n > 0 && (chars ? strchr(chars, (*s)[0]) != nullptr : is_space((*s)[0]))) {
        (*s)++;
        (*n)--;
    }
    while (*n > 0 && (chars ? strchr(chars, (*s)[*n - 1]) != nullptr : is_space((*s)[*n - 1]))) {
        (*n)--;
    }
}

void lower(char *s) {
    for (; *s; s++) *s = (char)tolower((unsigned char)*s);
}

bool same_word(const char *s, size_t n, const char *word) {
    if (strlen(word) != n) return false;
    for (size_t i = 0; i < n; i++) {
        if (tolower((unsigned char)s[i]) != (unsigned char)word[i]) return false;
    }
    return true;
}

size_t text_width(const char *s) {
    size_t n = 0;
    for (; *s; s++) {
        if (((unsigned char)*s & 0xC0) != 0x80) n++;
    }
    return n;
}

void stable_sort(void *base, size_t count, size_t size, int (*compare)(const void *, const void *)) {
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

// Optional spaces, an optional sign, digits (single underscores allowed between them), optional
// spaces. Anything else is an error, like Python's int().
bool parse_whole_number(const char *text, long long *out) {
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
