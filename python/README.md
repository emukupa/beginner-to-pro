# Python

The task tracker in Python 3.10 or newer. Nothing to install.

```bash
cd python
python3 tasks.py              # or: python3 -m tracker (from chapter 02)
python3 tasks.py work.txt     # another tasks file
TASKS_FILE=work.txt python3 tasks.py
```

| Chapter | Start | End | Video |
| --- | --- | --- | --- |
| [01 One file](chapters/01-one-file/CHAPTER.md) | `course/python/01-one-file/start` | `course/python/01-one-file/end` | `video/python-001` |
| [02 Modules](chapters/02-modules/CHAPTER.md) | `course/python/02-modules/start` | `course/python/02-modules/end` | `video/python-002` |

Check any version against the contract from the repo root:

```bash
contract/run.sh python3 "$PWD/python/tasks.py"
```
