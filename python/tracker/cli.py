"""The program the user talks to. The only module that reads input, prints, or exits."""
import os
import sys
from datetime import date

from .chart import draw_chart
from .models import UrgentTask
from .storage import append_titles, load_tasks, mark_done
from .tasklist import add_tasks, find_task, summary, top_tags


def done_command(words):
    """tasks.py done "title": marks one task finished. Returns the exit code."""
    title = " ".join(words).strip()
    if not title:
        print('Usage: done "task title"', file=sys.stderr)
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
    if task.is_done():
        print(f"Already done: {task.title}")
        return 0
    mark_done(path, task)
    print(f"Done: {task.title}")
    return 0


def main():
    if len(sys.argv) > 1 and sys.argv[1] == "done":   # a second mode: tasks.py done "title"
        sys.exit(done_command(sys.argv[2:]))

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
