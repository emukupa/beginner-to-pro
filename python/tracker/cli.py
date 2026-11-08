"""The program the user talks to. The only module that reads input, prints, or exits."""
import os
import sys
from datetime import date
from typing import NamedTuple

from .chart import draw_chart
from .models import UrgentTask
from .storage import append_titles, load_tasks, set_status
from .tasklist import add_tasks, find_task, summary, top_tags


class Change(NamedTuple):
    """What a status command does: the status it sets, and what it prints."""
    status: str    # the line's bracket becomes [status]
    changed: str   # printed after changing it
    already: str   # printed when the task already had that status


CHANGES = {
    "done": Change("done", "Done", "Already done"),
    "undo": Change("todo", "Undone", "Not done yet"),
}


def change_command(name, words):
    """tasks.py done|undo "title": sets one task's status. Returns the exit code."""
    change = CHANGES[name]
    title = " ".join(words).strip()
    if not title:
        print(f'Usage: {name} "task title"', file=sys.stderr)
        return 2
    path = os.getenv("TASKS_FILE", "tasks.txt")
    try:
        tasks = load_tasks(path)
    except FileNotFoundError:
        print(f"Couldn't find {path}", file=sys.stderr)
        return 1
    task = find_task(tasks, title)
    if task is None:
        print(f'No task called "{title}"', file=sys.stderr)
        return 1
    if task.status == change.status:
        print(f"{change.already}: {task.title}")
        return 0
    try:
        set_status(path, task, change.status)
    except OSError:
        print(f"Couldn't write {path}", file=sys.stderr)
        return 1
    print(f"{change.changed}: {task.title}")
    return 0


def main():
    if len(sys.argv) > 1 and sys.argv[1] in CHANGES:   # tasks.py done "title", tasks.py undo "title"
        sys.exit(change_command(sys.argv[1], sys.argv[2:]))

    if len(sys.argv) > 1:
        path = sys.argv[1]
    else:
        path = os.getenv("TASKS_FILE", "tasks.txt")

    try:
        tasks = load_tasks(path)
    except FileNotFoundError:
        print(f"Couldn't find {path}", file=sys.stderr)
        sys.exit(1)

    new_titles = []
    while True:
        title = input("New task (Enter to finish): ").strip()
        if not title:
            break
        if title.startswith("#"):
            print("A task needs a title, not just tags.")
            continue
        new_titles.append(title)

    if add_tasks(tasks, *new_titles, created=str(date.today())):
        append_titles(path, new_titles)

    try:
        n = int(input("How many top tags? [3]: ") or 3)
        pairs = top_tags(tasks, n)
    except ValueError:
        print("Need a whole number of at least 1 — using 3.")
        pairs = top_tags(tasks)

    total, done, percent, tags = summary(tasks)
    print(f"\n{total} tasks, {done} done ({percent:.0f}%), {tags} tags")
    for task in tasks:
        if isinstance(task, UrgentTask) and not task.is_done():
            print(task)

    print("\nTop tags")
    draw_chart(pairs)
