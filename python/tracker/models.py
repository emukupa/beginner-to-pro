"""What a task is. Imports nothing from the tracker, so everything else can import it."""


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
