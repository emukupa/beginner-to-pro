"""Classes: your own types, with data and methods. Plus the two alternatives the tracker skips."""
from dataclasses import dataclass, field
from enum import Enum

from lesson_07_collections import count_tags
from lesson_10_files import load

TITLE = "Classes"


class Task:
    def __init__(self, title, status="todo", tags=None):
        self.title = title
        self.status = status
        self.tags = tags or []           # None, then a fresh list: avoids lesson 8's shared-list trap

    def is_done(self):
        return self.status == "done"

    def __str__(self):
        return f"[{'x' if self.is_done() else ' '}] {self.title}"


class UrgentTask(Task):                  # inherits everything from Task...
    def __str__(self):
        return super().__str__() + "  !!"   # ...and changes one thing


@dataclass
class TaskRecord:                        # a dataclass writes __init__, __repr__ and == for you
    title: str
    status: str = "todo"
    tags: list = field(default_factory=list)


class Status(Enum):                      # an enum: a fixed set of named values instead of strings
    TODO = "todo"
    DONE = "done"


def run():
    tasks = [(UrgentTask if "urgent" in tags else Task)(title, status, tags) for status, title, tags in load()]
    for task in tasks:
        print(task)
    print("done:", sum(t.is_done() for t in tasks), "of", len(tasks))
    print("tags:", count_tags(t.tags for t in tasks))
    print("a dataclass:", TaskRecord("Buy milk"))
    print("an enum:", Status("done"), "is", Status.DONE.value)
    # The tracker writes its class by hand, to show what a dataclass does for you, and keeps status
    # as a string because the file is text. In your own code, reach for both.
