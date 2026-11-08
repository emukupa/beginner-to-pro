# Chapter 00 — Python concepts

**Video:** Python: Concepts (tag `video/python-000`)

**Goal:** learn the language before building anything with it. `python/concepts/` holds one small
lesson per file. `main.py` imports them all and runs the ones you ask for:

```bash
cd python/concepts
python3 main.py        # every lesson, in order
python3 main.py 4 7    # just lessons 4 and 7
```

Later lessons reuse what earlier ones built, so by lesson 11 the pieces add up to a working,
small version of the task tracker you'll build in chapter 01.

## The lessons

| # | File | Concepts | Reused later |
| --- | --- | --- | --- |
| 01 | `lesson_01_hello.py` | `print`, comments, running a file | |
| 02 | `lesson_02_values.py` | names and values, `str` `int` `float` `bool` `None`, `type()`, `==` vs `is` | |
| 03 | `lesson_03_numbers.py` | arithmetic, `//` `%` `**`, float precision, `round()` halves to even, `input()` gives text, `int()` | |
| 04 | `lesson_04_strings.py` | `strip` `lower` `split` `partition`, slices, f-strings, alignment, immutability | `clean_status` |
| 05 | `lesson_05_decisions.py` | `if`/`elif`/`else`, truthiness, conditional expressions, `match` | |
| 06 | `lesson_06_loops.py` | `for`, `range`, `enumerate`, `zip`, `while`, `break`/`continue`, `for`...`else` | |
| 07 | `lesson_07_collections.py` | list, tuple, dict, set, aliasing, unpacking, comprehensions, `sorted(key=)`, `Counter` | `count_tags` |
| 08 | `lesson_08_functions.py` | defaults, keyword-only `*`, `*args`, `**kwargs`, spreading, the shared-default trap, `lambda` | `parse_line` |
| 09 | `lesson_09_errors.py` | `try`/`except`/`else`/`finally`, `raise`, your own exception class | |
| 10 | `lesson_10_files.py` | `open` modes, `with`, newlines, `pathlib` | `load` |
| 11 | `lesson_11_classes.py` | classes, `__init__`, `self`, `__str__`, inheritance, `super()`, `@dataclass`, `Enum` | |
| 12 | `lesson_12_modules.py` | `sys.argv`, `os.getenv`, `datetime`, `argparse`, `__name__` | |
| 13 | `lesson_13_beyond.py` | generators, decorators | |

## Choices the tracker doesn't make, and why

Each lesson shows the alternative and says when you'd pick it:

- **`match`** reads well for many fixed cases; the tracker's two checks read just as well as `if`.
- **`Counter`** counts in one line; the tracker counts by hand so you see how.
- **Type hints** document types; the tracker leaves them out to stay beginner-sized.
- **Your own exception class**; the built-in `ValueError` is enough for the tracker.
- **`pathlib`** is the modern way to handle paths; the tracker uses `open()`, which you'll meet everywhere.
- **`@dataclass` and `Enum`** write boilerplate for you; the tracker writes its class by hand to show what they do.
- **`argparse`** is right for programs with options; one optional file name only needs `sys.argv`.
- **Generators and decorators** aren't needed in the tracker, but you'll read them in other people's code.

## Done when

```bash
cd python/concepts && python3 main.py
```

runs every lesson (it asks one question in lesson 03).
