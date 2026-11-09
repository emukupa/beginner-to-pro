# Chapter 01 — The whole tracker in one file (Python)

**Video:** [Build a Task Tracker in 132 Lines of Python](https://youtu.be/0PIOCYxFeB8) on YouTube

**Goal:** write `python/tasks.py`, a task tracker that reads the messy `tasks.txt`, lets you add
tasks, flags urgent ones, and charts your top tags, using every core feature of Python for a
reason.

## Concepts

- **Variables and types:** strings, integers, floats, booleans, `None`. A name can point at a
  different type later.
- **Input and math:** `input()` always returns text; wrap it in `int()`. `//`, `%`, `**`.
- **Strings:** real data is messy. `"done" != "done."`, so clean it at the door with `strip()`,
  `lower()`, `partition()`. Slices, f-strings, `"█" * 5`.
- **Decisions and loops:** `if`/`elif`/`else`, truthiness (`if not line:`), `for`, `while`,
  `break`, `continue`.
- **Collections:** lists (and the aliasing trap), tuples, dictionaries with `.get(key, 0)`, sets,
  comprehensions.
- **Functions:** defaults, keyword-only arguments after `*`, `*args` collects, `*` in a call
  spreads, `**kwargs`, `lambda` as a sort key. Functions return data; only `main` talks to the
  user.
- **Exceptions:** `try`/`except`, and raising your own `ValueError`.
- **Files:** modes `r`, `w`, `a`; always `with open(...)`.
- **Modules from the standard library:** `os`, `sys`, `datetime`. Never name a file `random.py`.
- **Classes:** `__init__`, `self`, methods, `__str__`, the shared-default-list bug, inheritance
  with `super()`.

## Tasks

1. `Task` and `UrgentTask` classes.
2. `parse_line(line, *, marker="#")`: one messy line into a task, or `None`.
3. `load_tasks(path="tasks.txt")`.
4. `add_tasks(tasks, *titles, status="todo", **extra)`.
5. `top_tags(tasks, n=3, *, include_done=True)`, raising `ValueError` when `n < 1`.
6. `draw_chart(pairs, width=20, char="█")`.
7. `main()`: the file from the command line, then `TASKS_FILE`, then `tasks.txt`; the input loop;
   the summary; the chart.

## Done when

```bash
cd python && python3 tasks.py        # 6 tasks, 3 done (50%) — not 1
cd .. && contract/run.sh python3 "$PWD/python/tasks.py"
```

All eight contract cases pass. Compare with `git diff course/python/01-one-file/end`.
