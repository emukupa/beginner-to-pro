"""Files: open, read, write, append, always inside with."""
import os
from pathlib import Path

from lesson_08_functions import parse_line

TITLE = "Files"


def load(path="tasks.txt"):
    """Every task line in the file, parsed by lesson 8's parse_line. Lesson 11 reuses this."""
    with open(path, encoding="utf-8") as f:   # with closes the file, even if something fails
        return [task for task in (parse_line(line) for line in f) if task]


def run():
    tasks = load()
    print(f"loaded {len(tasks)} tasks; the first: {tasks[0]}")
    with open("scratch.txt", "w", encoding="utf-8") as f:   # w: write, wiping what was there
        f.write("[todo] First\n")
    with open("scratch.txt", "a", encoding="utf-8") as f:   # a: append to the end
        f.write("[todo] Second\n")
    with open("scratch.txt", encoding="utf-8") as f:        # r (the default): read
        print("scratch.txt:", f.read().splitlines())
    print("each line still ends in a newline:", repr(open("tasks.txt").readline()))
    # pathlib does the same with objects instead of strings. The tracker uses open() because
    # every tutorial and library you'll meet does too; pathlib is the modern choice for paths.
    print("pathlib:", Path("scratch.txt").read_text().count("\n"), "lines")
    os.remove("scratch.txt")
