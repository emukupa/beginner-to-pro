# Chapter 04 — The undo command (Python)

**Video:** Python: Undo (tag `video/python-004`)

**Goal:** the challenge from chapter 03. `python3 tasks.py undo "title"` sets a finished task back to
`[todo]`, in the file itself. Done and undo become one command driven by a small table, and the
file is now rewritten safely: a crash can no longer leave it half-written.

```bash
cd python
python3 tasks.py undo "Buy groceries"      # Undone: Buy groceries
python3 tasks.py undo "  fix LOGIN bug "   # [DONE] Fix login bug  ->  [todo] Fix login bug
python3 tasks.py undo "Book flights"       # Not done yet: Book flights
python3 tasks.py undo                      # Usage: undo "task title" (exit 2)
```

## Where it goes

The same modules as the done command. Nothing new: the design from chapter 02 holds.

| Module | Change | Why there |
| --- | --- | --- |
| `tasklist.py` | nothing: `find_task` already finds the task | finding is the same for both commands |
| `storage.py` | `mark_done(path, task)` becomes `set_status(path, task, status)`, and writes safely | the only module that touches files |
| `cli.py` | `done_command` becomes `change_command(name, words)`, driven by `CHANGES` | the only module that talks to the user |

## Concepts

- **Data instead of copies.** Done and undo differ only in the status they set and the words they
  print. `CHANGES` maps each command name to a `Change`, a `NamedTuple` with those three fields, so
  one function serves both, and a third status command would be one more line in the table.
- **`typing.NamedTuple`.** A tuple with field names: `change.status` reads better than `change[0]`,
  and it can't be changed by accident.
- **Rewriting a file safely.** Opening a file with `"w"` empties it at once; if the program dies
  before it finishes writing, the tasks are gone. `set_status` writes a new file beside the old one
  (`tempfile.NamedTemporaryFile(dir=..., delete=False)`), `os.fsync`s it to the disk, copies the old
  file's permissions (`shutil.copymode`), then `os.replace`s the old file with it. A replace is
  atomic: anyone reading sees the old file or the new one, never half of each. If anything fails,
  the new file is deleted and the old one is untouched. The C version does the same with `mkstemp`
  and `rename` (C chapter 03).
- **`except BaseException: ... raise`.** Clean up, then let the error carry on: even Ctrl-C can't
  leave the temporary file behind.
- **New contract cases.** `contract/undo/` holds six; run them with
  `CASES=undo contract/run.sh python3 "$PWD/python/tasks.py"`. The other fourteen must still pass.

## Done when

```bash
contract/run.sh python3 "$PWD/python/tasks.py"              # 8 passes
CASES=done contract/run.sh python3 "$PWD/python/tasks.py"   # 6 passes
CASES=undo contract/run.sh python3 "$PWD/python/tasks.py"   # 6 passes
```
