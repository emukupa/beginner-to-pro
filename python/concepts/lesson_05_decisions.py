"""Decisions: if/elif/else, truthiness, and match (which the tracker doesn't use)."""
TITLE = "Decisions"


def describe(line):
    if not line:                         # empty text is "falsy"
        return "blank line, skip it"
    elif not line.startswith("["):
        return "not a task"
    else:
        return "parse it"


def describe_with_match(status):
    # match compares one value against patterns. Great for many fixed cases; for the tracker's
    # two checks, if/elif reads just as well, so the tracker keeps if.
    match status:
        case "done":
            return "finished"
        case "todo" | "doing":
            return "still open"
        case _:
            return "unknown status"


def run():
    for line in ("", "hello", "[done] Buy milk"):
        print(f"{line!r:>18} -> {describe(line)}")
    print("falsy values:", [bool(v) for v in (0, "", [], None)])
    for status in ("done", "doing", "maybe"):
        print(f"match {status!r:>8} -> {describe_with_match(status)}")
    count = 1
    print("conditional expression:", "task" if count == 1 else "tasks")
