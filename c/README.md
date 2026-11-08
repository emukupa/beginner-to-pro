# Safe C

The task tracker in C23, written to rules that make C safe to learn on: strict warnings as errors,
AddressSanitizer and UBSan on every test run, a leak check, no unbounded string functions. Needs a
C23 compiler (clang 19+ or gcc 14+: `constexpr` and `typeof` arrived there) and `make`.

Three folders, each with its own Makefile: the language first, then two complete versions of the
tracker side by side.

| Folder | What | Chapter |
| --- | --- | --- |
| [`concepts/`](concepts/) | one file per concept, run by `main.c`: `make` runs them all, `make 07` one, `make 07 BUG=1` with its bug | 00 |
| [`one-file/`](one-file/) | the whole tracker in `tracker.c` | 01 |
| [`modules/`](modules/) | the same program split into `tracker/*.h` and `tracker/*.c` | 02 |

```bash
cd c/one-file        # or c/modules
make                 # build/tracker, with the sanitizers on
make run             # build if needed, then run it on tasks.txt here
make check           # the contract: must match Python byte for byte
make leaks           # macOS: one full run under the leaks tool
```

| Chapter | Start | End | Video |
| --- | --- | --- | --- |
| [00 Concepts](chapters/00-concepts/CHAPTER.md) | `course/c/00-concepts/start` | `course/c/00-concepts/end` | `video/c-000` |
| [01 One file](chapters/01-one-file/CHAPTER.md) | `course/c/01-one-file/start` | `course/c/01-one-file/end` | `video/c-001` |
| [02 Modules](chapters/02-modules/CHAPTER.md) | `course/c/02-modules/start` | `course/c/02-modules/end` | `video/c-002` |

VS Code: install the recommended **clangd** extension. It reads `compile_flags.txt` and understands
C23; the repo's `.vscode/settings.json` turns the Microsoft C/C++ extension's IntelliSense off here,
because it doesn't understand C23 yet (its debugger still works).
