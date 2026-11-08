// Safe C concepts, one lesson per file. This file pulls every lesson in with #include, which pastes
// each .c file here, so the whole thing compiles as one. Each lesson also includes concepts.h and
// the earlier lessons it uses, with #pragma once so nothing is pasted twice; that's why any lesson
// builds alone too (make solo-07). Real projects use headers instead; that's the modules video.
//
//   make          build/concepts, every lesson     make 07         just lesson 7
//   make 07 BUG=1 lesson 7 with its Safe C bug compiled in, to watch the tools catch it
//   make solo-07  lesson 7 built on its own, from solo.c

#include "concepts.h"  // the standard library, and BUG

#include "lesson_01_hello.c"
#include "lesson_02_types.c"
#include "lesson_03_numbers.c"
#include "lesson_04_control.c"
#include "lesson_05_functions.c"
#include "lesson_06_arrays.c"
#include "lesson_07_pointers.c"
#include "lesson_08_strings.c"
#include "lesson_09_memory.c"
#include "lesson_10_structs.c"
#include "lesson_11_growing.c"
#include "lesson_12_files.c"
#include "lesson_13_function_pointers.c"
#include "lesson_14_preprocessor.c"

typedef struct lesson {
    const char *title;
    void (*run)(void);                 // a function pointer: each lesson's run function
} Lesson;

static const Lesson LESSONS[] = {
    {"Hello", lesson_01}, {"Types and sizes", lesson_02}, {"Numbers", lesson_03},
    {"Decisions and loops", lesson_04}, {"Functions", lesson_05}, {"Arrays", lesson_06},
    {"Pointers", lesson_07}, {"Strings", lesson_08}, {"Memory", lesson_09},
    {"Structs and enums", lesson_10}, {"Growing arrays", lesson_11}, {"Files and errors", lesson_12},
    {"Function pointers", lesson_13}, {"The preprocessor and C23", lesson_14},
};
constexpr size_t LESSON_COUNT = sizeof LESSONS / sizeof LESSONS[0];

static void run(size_t number) {
    printf("\n=== %02zu %s ===\n", number, LESSONS[number - 1].title);
    LESSONS[number - 1].run();
}

int main(int argc, char **argv) {
    if (argc == 1) {
        for (size_t i = 1; i <= LESSON_COUNT; i++) run(i);
        return 0;
    }
    for (int a = 1; a < argc; a++) {
        long long n = 0;
        if (!parse_whole_number(argv[a], &n) || n < 1 || (size_t)n > LESSON_COUNT) fail("No lesson %s", argv[a]);
        run((size_t)n);
    }
    return 0;
}
