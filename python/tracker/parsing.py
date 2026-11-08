"""Turning one line of text into a Task: the only place that knows the file format."""
from .models import Task, UrgentTask


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
