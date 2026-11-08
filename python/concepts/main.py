"""Python concepts, one lesson per file. Each lesson is a module with a TITLE and a run().

    python3 main.py        every lesson, in order
    python3 main.py 4 7    just lessons 4 and 7

Later lessons reuse what earlier ones built: the pieces add up to the task tracker.
"""
import sys

import lesson_01_hello
import lesson_02_values
import lesson_03_numbers
import lesson_04_strings
import lesson_05_decisions
import lesson_06_loops
import lesson_07_collections
import lesson_08_functions
import lesson_09_errors
import lesson_10_files
import lesson_11_classes
import lesson_12_modules
import lesson_13_beyond

LESSONS = {
    1: lesson_01_hello, 2: lesson_02_values, 3: lesson_03_numbers, 4: lesson_04_strings,
    5: lesson_05_decisions, 6: lesson_06_loops, 7: lesson_07_collections, 8: lesson_08_functions,
    9: lesson_09_errors, 10: lesson_10_files, 11: lesson_11_classes, 12: lesson_12_modules,
    13: lesson_13_beyond,
}


def main():
    chosen = [int(arg) for arg in sys.argv[1:]] or sorted(LESSONS)
    for number in chosen:
        lesson = LESSONS[number]
        print(f"\n=== {number:02d} {lesson.TITLE} ===")
        lesson.run()


if __name__ == "__main__":
    main()
