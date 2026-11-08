"""Collections: list, tuple, dict, set, and comprehensions."""
from collections import Counter

TITLE = "Collections"


def count_tags(tag_lists):
    """Counts tags in first-seen order, by hand. Lesson 11's tracker pieces reuse this."""
    counts = {}
    for tags in tag_lists:
        for tag in tags:
            counts[tag] = counts.get(tag, 0) + 1
    return counts


def run():
    tasks = ["Buy groceries", "Call mom"]          # list: ordered, changeable
    tasks.append("Book flights")
    print("after append:", tasks, "- len", len(tasks))
    removed = tasks.pop()
    print("pop() removed", repr(removed), "->", tasks)
    a = [1, 2]
    b = a                                           # not a copy: two names, one list
    b.append(3)
    print("aliasing: a is now", a, "  a.copy() makes a real copy")
    pair = ("work", 4)                              # tuple: fixed, unpackable
    tag, count = pair
    print("tuple unpacked:", tag, count)
    counts = {"work": 4}                            # dict: key -> value
    print("counts.get('home', 0) ->", counts.get("home", 0))
    print("set removes duplicates:", sorted({"work", "home", "work"}))
    print("comprehension:", [s for s in ["done", "todo", "done"] if s == "done"])

    tag_lists = [["home"], ["work", "urgent"], ["family"], ["work"], ["travel", "home"], ["work"]]
    by_hand = count_tags(tag_lists)
    print("count_tags:", by_hand)
    print("Counter does the same in one line:", dict(Counter(t for tags in tag_lists for t in tags)))
    # The tracker counts by hand so you see how; in real code, Counter is the right tool.
    ranked = sorted(by_hand.items(), key=lambda pair: pair[1], reverse=True)
    print("sorted by count, ties keep their order:", ranked)
