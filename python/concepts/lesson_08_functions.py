"""Functions: inputs in, a result back. Defaults, keyword-only arguments, *args and **kwargs."""
from lesson_04_strings import clean_status

TITLE = "Functions"


def percent(done, total):
    return done / total * 100 if total else 0


def parse_line(line, *, marker="#"):
    """'[done.] Call mom #family' -> ('done', 'Call mom', ['family']), or None. Lesson 10 reuses it."""
    line = line.strip()
    if not line.startswith("["):
        return None
    status, _, rest = line.partition("]")
    words = rest.split()
    tags = [w.lstrip(marker).strip(".,").lower() for w in words if w.startswith(marker)]
    title = " ".join(w for w in words if not w.startswith(marker))
    return clean_status(status), title, tags


def add_titles(titles, *new, status="todo", **extra):
    """*new collects any number of titles; **extra collects any named extras."""
    for title in new:
        titles.append((status, title, extra))
    return len(new)


def add_tag(tag, tags=[]):              # the trap: this list is made once and shared by every call
    tags.append(tag)
    return tags


def run():
    print("percent(3, 6) ->", percent(3, 6))
    print("parse_line('[done.] Call mom #family') ->", parse_line("[done.] Call mom #family"))
    print("parse_line('[x] a @b', marker='@')    ->", parse_line("[x] a @b", marker="@"))
    mine = []
    print("added:", add_titles(mine, "Pay rent", "Call dad", priority="high"), mine)
    more = ["Read book", "Walk dog"]
    add_titles(mine, *more)             # * in a call spreads a list into separate arguments
    print("after spreading:", [t for _, t, _ in mine])
    first = add_tag("work")
    print("add_tag('work') ->", first)
    second = add_tag("home")
    print("add_tag('home') ->", second, "  same list both times?", first is second)
    by_count = sorted([("home", 2), ("work", 4)], key=lambda pair: pair[1], reverse=True)
    print("lambda as a sort key:", by_count)
    # Type hints (def percent(done: int, total: int) -> float) document types; Python doesn't
    # enforce them. The tracker leaves them out to stay beginner-sized; bigger code should use them.
