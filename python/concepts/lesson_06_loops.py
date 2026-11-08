"""Loops: for walks a collection, while repeats until a condition changes."""
TITLE = "Loops"


def run():
    for word in "Call mom #family".split():
        print("word:", word)
    print("range(5) ->", list(range(5)))
    for number, title in enumerate(["Buy milk", "Call mom"], start=1):   # a counter for free
        print(f"{number}. {title}")
    for title, tag in zip(["Buy milk", "Call mom"], ["home", "family"]):  # walk two lists together
        print(f"{title} #{tag}")

    answers = iter(["Buy milk", "#home", "", "never reached"])  # stands in for input() here
    titles = []
    while True:
        title = next(answers)
        if not title:
            break                         # leave the loop
        if title.startswith("#"):
            continue                      # skip to the next turn
        titles.append(title)
    print("collected:", titles)

    for title in titles:                  # for ... else: the else runs only if no break happened.
        if "urgent" in title:             # Real Python, rarely needed, and the tracker doesn't.
            break
    else:
        print("no urgent title found")
