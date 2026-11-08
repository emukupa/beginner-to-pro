"""Names and values: a variable is a name pointing at a value, and every value has a type."""
TITLE = "Values and types"


def run():
    title = "Fix login bug"         # str: text
    done_count = 3                  # int: a whole number
    percent = 50.0                  # float: a number with a decimal point
    is_urgent = True                # bool: True or False
    due_date = None                 # None: "nothing here yet"
    for value in (title, done_count, percent, is_urgent, due_date):
        print(f"{value!r:>16}  is a {type(value).__name__}")

    done_count = "three"            # the same name can point at another type later
    print("done_count is now a", type(done_count).__name__)

    # == asks "equal?"; is asks "the very same object?". Use is only for None.
    print("due_date is None ->", due_date is None)
    a = [1, 2]
    b = [1, 2]
    print("a == b ->", a == b, "  a is b ->", a is b)
