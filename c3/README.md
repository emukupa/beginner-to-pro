# C3

The task tracker in [C3](https://c3-lang.org): C's model (the same types, pointers and manual
memory, and it calls C directly) with modules, slices, optionals, contracts and real macros built
in. Needs `c3c` 0.8.5 or newer (`brew install c3c`) and `make`.

| Folder | What | Chapter |
| --- | --- | --- |
| [`concepts/`](concepts/) | one module per lesson, run by `main.c3`: `make` runs them all, `make 07` one, `make 07 BUG=1` with its mistake | 00 |

```bash
cd c3/concepts
make                 # build/concepts, then every lesson, in safe mode (-O0)
make 07 BUG=1        # lesson 7 with its mistake compiled in
```

| Chapter | Start | End | Video |
| --- | --- | --- | --- |
| [00 Concepts](chapters/00-concepts/CHAPTER.md) | `course/c3/00-concepts/start` | `course/c3/00-concepts/end` | `video/c3-000` |
