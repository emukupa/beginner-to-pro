// Lesson 03: arithmetic, integer division, conversions, rounding, and turning text into a number.
// BUG=3: storing a size_t in an int. -Wconversion catches the silent narrowing.

#pragma once
#include "concepts.h"

// int(text), done by hand: an optional sign, then digits. False if it isn't a whole number.
// (strtol exists, but checking it properly takes as many lines; lesson 12's tracker reuses this.)
[[nodiscard]] static bool parse_whole_number(const char *text, long long *out) {
    size_t i = 0;
    bool negative = false;
    if (text[i] == '+' || text[i] == '-') negative = text[i++] == '-';
    if (!isdigit((unsigned char)text[i])) return false;
    long long value = 0;
    for (; text[i] != '\0'; i++) {
        if (!isdigit((unsigned char)text[i])) return false;
        int digit = text[i] - '0';
        value = value > (LLONG_MAX - digit) / 10 ? LLONG_MAX : value * 10 + digit;  // cap, never overflow
    }
    *out = negative ? -value : value;
    return true;
}

static void lesson_03(void) {
    printf("7 / 2 = %d, 7 %% 2 = %d, 7.0 / 2 = %.1f\n", 7 / 2, 7 % 2, 7.0 / 2);  // int / int drops the rest
    printf("0.1 + 0.2 = %.17f\n", 0.1 + 0.2);
    printf("round(2.5) = %.0f, nearbyint(2.5) = %.0f\n", round(2.5), nearbyint(2.5));  // halves: away vs even
    const char *answers[] = {"5", "five", "-3"};
    for (size_t i = 0; i < 3; i++) {
        long long n = 0;
        if (parse_whole_number(answers[i], &n)) {
            printf("\"%s\" -> %lld\n", answers[i], n);
        } else {
            printf("\"%s\" isn't a whole number\n", answers[i]);
        }
    }
#if BUG == 3
    size_t count = strlen("hello");
    int small = count;                 // size_t -> int may not fit: -Wconversion says so
    printf("%d\n", small);
#endif
}
