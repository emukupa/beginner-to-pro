"""Running Python: a file of statements, run top to bottom."""
TITLE = "Hello"


def run():
    print("Hello from Python")      # print shows a value
    # A comment: Python ignores everything after the hash sign.
    print("one", "two", 3)          # several values, separated by spaces
    print("no newline here", end="")
    print(" ... so this joins the same line")
