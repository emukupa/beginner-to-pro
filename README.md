# Beginner to Pro

One small program, a command-line task tracker, built from zero in several languages. Every
language takes the same path:

1. **One file.** The whole tracker in a single file, every core feature of the language used for a
   reason.
2. **Modules.** The same tracker broken into files, each with one job, using that language's
   module system. Nothing about its behaviour changes.

Each step is a video, and each video points at a branch you can check out.

| Language | Folder | 01 One file | 02 Modules |
| --- | --- | --- | --- |
| Python | [`python/`](python/) | ready | ready |
| Safe C | [`c/`](c/) | ready | ready |
| C3 | `c3/` | planned | planned |
| C++ | `cpp/` | planned | planned |
| Rust | `rust/` | planned | planned |
| Go | `go/` | planned | planned |
| TypeScript (Node) | `ts/` | planned | planned |

The plan for every language is in [docs/languages.md](docs/languages.md).

## What the tracker does

It reads a messy to-do file ([`contract/tasks.txt`](contract/tasks.txt)), lets you add tasks,
flags anything `#urgent`, and charts your top tags:

```
7 tasks, 3 done (43%), 5 tags
[ ] Finish quarterly report  !!
[ ] Write video script  !!

Top tags
work    ████████████████████ 4
home    ██████████ 2
urgent  ██████████ 2
```

## Taking the course

```bash
git clone https://github.com/emukupa/beginner-to-pro.git
cd beginner-to-pro
git switch course/python/01-one-file/start
cat python/chapters/01-one-file/CHAPTER.md
# ...do the work...
git diff course/python/01-one-file/end     # compare with the solution
git switch course/python/02-modules/start
```

`main` always holds the latest finished code for every language.

## One behaviour, every language

[`contract/`](contract/) holds the tracker's behaviour as test cases: the input typed, the
arguments, and the exact output and file contents expected. Every version, in every language,
must pass it:

```bash
contract/run.sh python3 "$PWD/python/tasks.py"
```

## Branches

Course branches are generated from one linear history, never edited by hand. See
[docs/git-strategy.md](docs/git-strategy.md).

## License

[MIT](LICENSE)
