"""Strings: text is a sequence of characters, with methods to clean it. Real data is messy."""
TITLE = "Strings"


def clean_status(text):
    """'[ DONE. ]' -> 'done'. Used again by lesson 8's parser."""
    return text.strip("[] .").lower()


def run():
    print('"done" == "done." ->', "done" == "done.")
    print('"done" == "DONE"  ->', "done" == "DONE")
    print('"  done  ".strip() ->', repr("  done  ".strip()))
    print('"DONE".lower()     ->', "DONE".lower())
    print('"Call mom #family".split() ->', "Call mom #family".split())
    print('"[done.] Call mom".partition("]") ->', "[done.] Call mom".partition("]"))
    for messy in ("[done]", "[done.]", "[DONE]", "[ todo ]"):
        print(f"clean_status({messy!r:>10}) -> {clean_status(messy)!r}")

    title = "Fix login bug"
    print("title[0], title[0:3], title[-3:] ->", title[0], title[0:3], title[-3:])
    print(f"an f-string: [x] {title}")
    print(f"aligned: |{'work':<8}|{'home':>8}|")
    print("repeated:", "█" * 5)
    status = "DONE"
    status.lower()                       # strings never change: this result is thrown away
    print("after status.lower() without saving it:", status)
