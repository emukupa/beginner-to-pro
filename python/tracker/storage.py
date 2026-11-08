"""Reading and writing the tasks file. The only module that opens files."""
import os
import shutil
import tempfile

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


def set_status(path, task, status):
    """Rewrites the line holding this task as [status], leaving every other byte of the file alone.
    Writes a new file beside the old one, then swaps them, so the file is never left half-written."""
    with open(path, encoding="utf-8", newline="") as f:
        lines = f.readlines()
    for i, line in enumerate(lines):
        found = parse_line(line)
        if found and found.title == task.title and found.status == task.status:
            start = line.index("[")                  # keep any spaces before the bracket
            end = line.index("]", start) + 1
            lines[i] = line[:start] + f"[{status}]" + line[end:]
            break
    folder = os.path.dirname(os.path.abspath(path))  # beside it: os.replace needs the same disk
    with tempfile.NamedTemporaryFile("w", encoding="utf-8", newline="", dir=folder, delete=False) as f:
        try:
            f.writelines(lines)
            f.flush()
            os.fsync(f.fileno())                     # on the disk before it replaces anything
            shutil.copymode(path, f.name)            # keep the old file's permissions
        except BaseException:
            f.close()
            os.remove(f.name)                        # never leave the half-made file behind
            raise
    os.replace(f.name, path)                         # atomic: readers see the old file or the new one
