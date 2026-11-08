"""Beyond the tracker: generators and decorators. You'll meet them in other people's code."""
import time

TITLE = "Beyond the tracker"


def lines_of(path):
    """A generator: yields one line at a time instead of building a whole list."""
    with open(path, encoding="utf-8") as f:
        for line in f:
            yield line.rstrip("\n")


def timed(function):
    """A decorator: wraps a function to add behaviour, here timing it."""
    def wrapper(*args, **kwargs):
        start = time.perf_counter()
        result = function(*args, **kwargs)
        print(f"{function.__name__} took {(time.perf_counter() - start) * 1000:.1f} ms")
        return result
    return wrapper


@timed
def count_lines(path):
    return sum(1 for _ in lines_of(path))


def run():
    first = next(lines_of("tasks.txt"))
    print("first line, read lazily:", first)
    print("lines:", count_lines("tasks.txt"))
