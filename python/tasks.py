import os
import sys
from datetime import date


class Task:
    def __init__(self, title, status="todo", tags=None, **extra):
        self.title = title
        self.status = status
        self.tags = tags or []
        self.extra = extra

    def is_done(self):
        return self.status == "done"

    def __str__(self):
        mark = "x" if self.is_done() else " "
        return f"[{mark}] {self.title}"


class UrgentTask(Task):
    def __str__(self):
        return super().__str__() + "  !!"


def parse_line(line, *, marker="#"):
    """Turn '[done.] Call mom #family' into a Task, or None."""
    line = line.strip()
    if not line or not line.startswith("["):
        return None
    status, _, rest = line.partition("]")
    status = status.strip("[] .").lower()
    words = rest.split()
    tags = [w.lstrip(marker).strip(".,").lower() for w in words if w.startswith(marker)]
    title = " ".join(w for w in words if not w.startswith(marker))
    cls = UrgentTask if "urgent" in tags else Task
    return cls(title, status=status, tags=tags)


def load_tasks(path="tasks.txt"):
    tasks = []
    with open(path, encoding="utf-8") as f:
        for line in f:
            task = parse_line(line)
            if task:
                tasks.append(task)
    return tasks


def add_tasks(tasks, *titles, status="todo", **extra):
    added = 0
    for title in titles:
        task = parse_line(f"[{status}] {title}")
        if task:
            task.extra.update(extra)
            tasks.append(task)
            added += 1
    return added


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


def draw_chart(pairs, width=20, char="█"):
    if not pairs:
        print("No tags yet.")
        return
    biggest = pairs[0][1]
    label_width = max(len(tag) for tag, _ in pairs)
    for tag, count in pairs:
        bar = char * round(count / biggest * width)
        print(f"{tag:<{label_width}}  {bar} {count}")


def main():
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
        with open(path, "a", encoding="utf-8") as f:
            for title in new_titles:
                f.write(f"[todo] {title}\n")

    try:
        n = int(input("How many top tags? [3]: ") or 3)
        pairs = top_tags(tasks, n)
    except ValueError:
        print("Need a whole number of at least 1 — using 3.")
        pairs = top_tags(tasks)

    done = [t for t in tasks if t.is_done()]
    unique_tags = {tag for t in tasks for tag in t.tags}
    percent = len(done) / len(tasks) * 100 if tasks else 0

    print(f"\n{len(tasks)} tasks, {len(done)} done ({percent:.0f}%), {len(unique_tags)} tags")
    for task in tasks:
        if isinstance(task, UrgentTask) and not task.is_done():
            print(task)

    print("\nTop tags")
    draw_chart(pairs)


if __name__ == "__main__":
    main()
