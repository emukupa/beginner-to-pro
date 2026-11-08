"""Reading and writing the tasks file. The only module that opens files."""
from .parsing import parse_line


def load_tasks(path="tasks.txt"):
    tasks = []
    with open(path, encoding="utf-8") as f:
        for line in f:
            task = parse_line(line)
            if task:
                tasks.append(task)
    return tasks


def append_titles(path, titles, status="todo"):
    with open(path, "a", encoding="utf-8") as f:
        for title in titles:
            f.write(f"[{status}] {title}\n")
