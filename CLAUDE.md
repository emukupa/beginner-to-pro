# Beginner to Pro: project rules

Read at the start of every session. Keep it short; the docs carry the detail.

## What this is

One small program, a command-line task tracker, built from zero in twelve languages: Python, Safe
C, C3, Zig, C++, Rust, Go, TypeScript (Node), C#, Java, Kotlin, Swift. Every language takes the
same five chapters (00 Concepts, 01 One file, 02 Modules, 03 Done, 04 Undo), and each chapter is a
video on the Polyglot Code channel.

Read before working on an area:

- **Overview and the video table:** `README.md`.
- **Branches, chapter commits, fixing a chapter:** `docs/git-strategy.md`.
- **A language's plan, features and traps:** `docs/languages.md`, then `<lang>/README.md`.
- **The behaviour every version must match:** `contract/README.md`.

## The git model (docs/git-strategy.md)

- `course/authoring` is linear: one commit per chapter start and end, subjects exactly
  `chapter(<lang>/NN-slug): start` and `chapter(<lang>/NN-slug): end`, plus occasional `docs:`
  commits.
- `main` and every `course/<lang>/NN-slug/start|end` branch are generated. Never edit or commit
  on them by hand.
  - `scripts/course-branches.sh` (`make branches`) moves the course branches.
  - `git branch -f main course/authoring` moves `main`.
- No rebase and no force-push, except the documented "Fixing an earlier chapter" flow
  (`rebase -i --root`, regenerate the branches, `push --force-with-lease`).
- Video tags (`video/<lang>-NNN`) never move. They point at the code that was on screen, even
  after a chapter is fixed.

## Decided (don't relitigate without the owner)

- **The contract is the definition of done.** Every `end` commit passes `contract/run.sh` for its
  language: the 8 cases from chapter 01, plus `CASES=done` (6) from 03 and `CASES=undo` (6) from
  04. Byte for byte, prompts and stderr included.
- **Python is the reference.** The expected files were recorded from it. Re-record
  (`RECORD=1 contract/run.sh ...`) only when the behaviour is meant to change, and then for every
  language.
- **Languages never import from each other.** Each lives in its own folder with its own build,
  so a fix in one language's chapter can't break another's.
- **The module split is the same everywhere:** models, parsing, storage, tasklist, chart, cli.
  Dependencies point one way (`docs/languages.md`).
- **Each version uses its whole language.** It's a tour of that language, not a copy of the
  Python, and the contract still passes byte for byte.

## Make targets

`make` lists them. `L=<lang>` picks one language: python c c3 zig cpp rust go node csharp java
kotlin swift.

- `make contract [L=<lang>]`: one-file (8 cases) and modules (8 + 6 + 6), using the commands each
  language's README and chapter 04 document.
- `make test [L=<lang>]`: the languages' own tests, where they have them (Python, C, C3 and C++
  have none; the contract checks them).
- `make fuzz L=<lang> [N=400] [SEED=1]`: `contract/fuzz.py`. Random task files, prompt answers
  and done/undo titles, run through Python and that language's modules version, compared byte for
  byte. Stops at the first mismatch and prints the command that replays it. `--wild` (run the
  script directly) adds inputs no chapter promises to handle like Python.
- `make check`: what CI runs, the contract for all twelve. Needs every toolchain installed.
- `make ci`: the GitHub Actions workflow (`.github/workflows/contract.yml`, one job per language)
  locally with act.
- `make branches`: **moves branches** (see the git model). Only after changing `course/authoring`.

## Toolchains

- CI's pins are the `env:` block of `.github/workflows/contract.yml`. Each is the version the
  language's README says the course was written with. Never `latest`.
- Change a pin there, and in that language's README, after running `make contract L=<lang>` on the
  new version.

## Not this repo

- The video studio, `../polyglot-code`, is a separate tree: scripts, voice, renders and
  its `LOG.md`. Nothing here depends on it, and changes there don't belong in commits here.

## Conventions

- Commit subjects: the chapter subjects above on `course/authoring`; conventional ones (`docs:`,
  `chore:`, `ci:`) for everything else.
- Comments explain *why*. Names and wording are plain, in the course's voice.
