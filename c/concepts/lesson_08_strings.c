// Lesson 08: a string is an array of char ending in a zero byte. No length, no methods.
// BUG=8: strcpy into a buffer that's too small. AddressSanitizer catches the overflow; Safe C bans
// strcpy and copies with an explicit length instead.

#pragma once
#include "concepts.h"

// str.strip(): narrows [*s, *s + *n) without copying. chars == nullptr means whitespace.
static void strip(const char **s, size_t *n, const char *chars) {
    while (*n > 0 && (chars ? strchr(chars, (*s)[0]) != nullptr : isspace((unsigned char)(*s)[0]))) {
        (*s)++;
        (*n)--;
    }
    while (*n > 0 && (chars ? strchr(chars, (*s)[*n - 1]) != nullptr : isspace((unsigned char)(*s)[*n - 1]))) {
        (*n)--;
    }
}

// Does the n bytes at s spell word, ignoring case? Lesson 10 uses it for the status.
static bool same_word(const char *s, size_t n, const char *word) {
    if (strlen(word) != n) return false;
    for (size_t i = 0; i < n; i++) {
        if (tolower((unsigned char)s[i]) != word[i]) return false;
    }
    return true;
}

static void lesson_08(void) {
    char word[] = "done";
    printf("\"%s\": strlen %zu, sizeof %zu (the zero byte)\n", word, strlen(word), sizeof word);
    const char *messy = "[ DONE. ]";
    const char *s = messy;
    size_t n = strlen(messy);
    strip(&s, &n, "[] .");
    printf("strip(\"%s\") -> \"%.*s\", same_word done? %s\n", messy, (int)n, s, same_word(s, n, "done") ? "yes" : "no");
    char small[8];
    snprintf(small, sizeof small, "%s", "Finish quarterly report");   // never writes past the end
    printf("snprintf into 8 bytes: \"%s\"\n", small);
#if BUG == 8
    const char *title = getenv("HOME") ? "Finish quarterly report" : "x";  // known only at run time
    strcpy(small, title);                                              // writes 24 bytes into 8
#endif
}
