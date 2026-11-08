"""Working with a list of tasks: adding, counting, ranking. No printing, no files."""
from .parsing import parse_line


def add_tasks(tasks, *titles, status="todo", **extra):
    added = 0
    for title in titles:
        task = parse_line(f"[{status}] {title}")
        if task:
            task.extra.update(extra)
            tasks.append(task)
            added += 1
    return added


def find_task(tasks, title):
    """The first task whose title matches, ignoring case and extra spaces; None if there isn't one."""
    wanted = " ".join(title.split()).lower()
    return next((task for task in tasks if task.title.lower() == wanted), None)


def top_tags(tasks, n=3, *, include_done=True):
    if n < 1:
        raise ValueError("n must be at least 1")
    counts = {}
    for task in tasks:
        if not include_done and task.is_done():
            continue
        for tag in task.tags:
            counts[tag] = counts.get(tag, 0) + 1
    return sorted(counts.items(), key=lambda pair: pair[1], reverse=True)[:n]


def summary(tasks):
    """(how many tasks, how many done, percent done, how many different tags)"""
    done = [t for t in tasks if t.is_done()]
    unique_tags = {tag for t in tasks for tag in t.tags}
    percent = len(done) / len(tasks) * 100 if tasks else 0
    return len(tasks), len(done), percent, len(unique_tags)
