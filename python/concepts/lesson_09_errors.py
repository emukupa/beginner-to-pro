"""Errors: exceptions, try/except/else/finally, raising your own."""
TITLE = "Errors"


class NoTitleError(ValueError):
    """Your own kind of error. The tracker uses the built-in ValueError instead: simpler, and enough."""


def top_n(counts, n):
    if n < 1:
        raise ValueError("n must be at least 1")
    return counts[:n]


def run():
    for text in ("5", "five", "0"):
        try:
            n = int(text)
            top_n([("work", 4)], n)
        except ValueError as error:
            print(f"{text!r:>7} -> ValueError: {error}")
        else:
            print(f"{text!r:>7} -> fine, n = {n}")
        finally:
            pass                      # finally runs either way: the place for cleanup
    try:
        raise NoTitleError("a task needs a title")
    except ValueError as error:      # catching the parent class catches the child too
        print("caught", type(error).__name__, "->", error)
    # Ask forgiveness (try it, catch the error) or look before you leap (check first)?
    # Python usually prefers try/except: the check and the action can't drift apart.
