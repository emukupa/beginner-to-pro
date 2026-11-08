# C3

The task tracker in [C3](https://c3-lang.org): C's model (the same types, pointers and manual
memory, and it calls C directly) with modules, slices, optionals, contracts and real macros built
in. Needs `c3c` 0.8.5 or newer (`brew install c3c`) and `make`.

| Folder | What | Chapter |
| --- | --- | --- |
| [`concepts/`](concepts/) | one module per lesson, run by `main.c3`: `make` runs them all, `make 07` one, `make 07 BUG=1` with its mistake | 00 |
| [`one-file/`](one-file/) | the whole tracker in `tracker.c3` | 01 |
| [`modules/`](modules/) | the same program split into modules, one per file in `tracker/` | 02 |

```bash
cd c3/concepts
make                 # build/concepts, then every lesson, in safe mode (-O0)
make 07 BUG=1        # lesson 7 with its mistake compiled in
```

```bash
cd c3/one-file       # or c3/modules
make check           # the contract: must match Python byte for byte
make leaks           # macOS: one full run under the leaks tool
```

| Chapter | Start | End | Video |
| --- | --- | --- | --- |
| [00 Concepts](chapters/00-concepts/CHAPTER.md) | `course/c3/00-concepts/start` | `course/c3/00-concepts/end` | `video/c3-000` |
| [01 One file](chapters/01-one-file/CHAPTER.md) | `course/c3/01-one-file/start` | `course/c3/01-one-file/end` | `video/c3-001` |
| [02 Modules](chapters/02-modules/CHAPTER.md) | `course/c3/02-modules/start` | `course/c3/02-modules/end` | `video/c3-002` |
| [03 Done](chapters/03-done/CHAPTER.md) | `course/c3/03-done/start` | `course/c3/03-done/end` | `video/c3-003` |
| [04 Undo](chapters/04-undo/CHAPTER.md) | `course/c3/04-undo/start` | `course/c3/04-undo/end` | `video/c3-004` |
