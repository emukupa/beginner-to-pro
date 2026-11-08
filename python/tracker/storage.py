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


def mark_done(path, task):
    """Rewrites the line holding this task as [done], leaving every other byte of the file alone."""
    with open(path, encoding="utf-8", newline="") as f:
        lines = f.readlines()
    for i, line in enumerate(lines):
        found = parse_line(line)
        if found and found.title == task.title and found.status == task.status:
            start = line.index("[")                  # keep any spaces before the bracket
            end = line.index("]", start) + 1
            lines[i] = line[:start] + "[done]" + line[end:]
            break
    with open(path, "w", encoding="utf-8", newline="") as f:
        f.writelines(lines)
