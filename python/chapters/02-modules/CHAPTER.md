# Chapter 02 — Modules and imports (Python)

**Video:** Python: Modules and Imports (tag `video/python-002`)

**Goal:** break the 132-line `tasks.py` into a `tracker` package, one file per job, without
changing a single byte of what the program does. The contract proves it.

## Concepts

- **A module is just a `.py` file.** `import models` finds `models.py`, runs it once, and keeps
  the result in `sys.modules`. Import it again and you get the same object back; it doesn't run
  twice.
- **Two ways to import.** `import tracker.storage` keeps the module name in front
  (`tracker.storage.load_tasks`); `from tracker.storage import load_tasks` brings one name in.
  Prefer the second for a few names you use a lot, the first when the module name adds meaning.
- **A package is a folder of modules** with an `__init__.py`. What `__init__.py` imports is the
  package's public face: `from tracker import load_tasks` works no matter which file it lives in.
  `__all__` lists the names `from tracker import *` brings in.
- **Relative imports** (`from .models import Task`) say "from this package". They only work when
  the file is loaded as part of the package, which is why `python3 tracker/cli.py` fails with
  *attempted relative import with no known parent package*.
- **One job per module, dependencies one way.** `models` imports nothing; `parsing` imports
  `models`; `storage` and `tasklist` import `parsing`; `chart` imports nothing; only `cli` imports
  everything. Point an arrow back up and Python stops with *partially initialized module (most
  likely due to a circular import)*.
- **Where the side effects live.** Only `storage` opens files. Only `cli` prints, reads input or
  exits. Everything else takes values and returns values, so it can be tested and reused.
- **Running a package:** `__main__.py` is what `python3 -m tracker` runs. `tasks.py` stays as a
  five-line launcher, so the command from chapter 01 still works.
- **`__pycache__`** holds the compiled modules so the next import is faster. It's in
  `.gitignore`; never commit it.

## Tasks

Create `python/tracker/` and move the code into it, one module at a time, running the contract
after each move:

| File | Gets | Imports |
| --- | --- | --- |
| `models.py` | `Task`, `UrgentTask` | nothing |
| `parsing.py` | `parse_line` | `.models` |
| `storage.py` | `load_tasks`, and a new `append_titles(path, titles)` pulled out of `main` | `.parsing` |
| `tasklist.py` | `add_tasks`, `top_tags`, and a new `summary(tasks)` pulled out of `main` | `.parsing` |
| `chart.py` | `draw_chart` | nothing |
| `cli.py` | `main` | all of the above, plus `os`, `sys`, `datetime` |
| `__init__.py` | the public names and `__all__` | the modules above |
| `__main__.py` | calls `main()` | `.cli` |

Then shrink `tasks.py` to:

```python
from tracker.cli import main

if __name__ == "__main__":
    main()
```

## Stretch

- Add `from .parsing import parse_line` to the top of `models.py` and read the circular-import
  error. Then remove it.
- In the REPL: `import tracker, sys` then `"tracker.models" in sys.modules`.

## Done when

```bash
cd python && python3 tasks.py && python3 -m tracker
cd .. && contract/run.sh python3 "$PWD/python/tasks.py"
```

All eight contract cases pass with both commands. Compare with `git diff course/python/02-modules/end`.
