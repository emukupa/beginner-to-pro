# Chapter 03 — The done command (Python)

**Video:** [Edit a Text File Safely in Python: the done Command](https://youtu.be/jhPUsdKYUWc) on YouTube

**Goal:** answer the challenge from chapters 01 and 02. `python3 tasks.py done "title"` marks one task
finished, in the tasks file itself, and leaves every other byte of the file alone.

```bash
cd python
python3 tasks.py done "Book flights"          # Done: Book flights
python3 tasks.py done "  review PULL request "  # matches "[ todo ] Review pull request #work."
python3 tasks.py done "buy groceries"         # Already done: Buy groceries
python3 tasks.py done "Walk dog"              # No task called "Walk dog" (exit 1)
python3 tasks.py done                         # Usage: done "task title" (exit 2)
```

## Where it goes

Chapter 02 asked which modules the done command belongs in. The answer, and nothing else changes:

| Module | Gets | Why there |
| --- | --- | --- |
| `tasklist.py` | `find_task(tasks, title)` | finding a task in a list: no files, no printing |
| `storage.py` | `mark_done(path, task)` | the only module that touches files |
| `cli.py` | `done_command(words)` and the check in `main` | the only module that talks to the user and exits |

## Concepts

- **A second mode.** `main` looks at `sys.argv[1]`: `done` runs the command and exits with its code;
  anything else is the original program.
- **Matching messy titles.** `" ".join(title.split()).lower()` collapses spaces and case on both
  sides, the same cleanup the statuses got in chapter 01.
- **Changing one line of a file.** Read every line, change one, write them all back.
  `newline=""` keeps each line's ending exactly as it was, so a Windows file stays a Windows file.
- **Exit codes that mean something.** 0 done (or already done), 1 not found, 2 used wrongly.
- **New contract cases.** `contract/done/` holds six of them; run them with
  `CASES=done contract/run.sh python3 "$PWD/python/tasks.py"`. The original eight must still pass.

## Done when

```bash
contract/run.sh python3 "$PWD/python/tasks.py"              # 8 passes
CASES=done contract/run.sh python3 "$PWD/python/tasks.py"   # 6 passes
```
