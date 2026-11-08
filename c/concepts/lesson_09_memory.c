// Lesson 09: the stack is automatic and small; the heap is any size, and yours to free, exactly once.
// BUG=9: freeing twice. AddressSanitizer: attempting double-free.

#pragma once
#include "concepts.h"

[[noreturn]] static void fail(const char *format, ...) {   // a variadic function: like printf
    va_list args;
    va_start(args, format);
    vfprintf(stderr, format, args);
    va_end(args);
    fputc('\n', stderr);
    exit(1);
}

[[nodiscard]] static void *checked(void *p) {   // every allocation goes through here
    if (p == nullptr) fail("Out of memory");
    return p;
}

[[nodiscard]] static char *copy_text(const char *s, size_t n) {   // a new string; the caller owns it
    char *out = checked(malloc(n + 1));
    memcpy(out, s, n);
    out[n] = '\0';
    return out;
}

static void lesson_09(void) {
    int on_the_stack = 42;             // gone when this function returns
    char *on_the_heap = copy_text("Buy milk", 8);   // stays until we free it
    printf("stack: %d, heap: \"%s\"\n", on_the_stack, on_the_heap);
    free(on_the_heap);                 // given back
#if BUG == 9
    free(on_the_heap);                 // given back... again
#endif
}
