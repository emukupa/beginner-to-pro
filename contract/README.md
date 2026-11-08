# The contract

The tracker's behaviour, written down as test cases. Every version in every language must pass
all of them, byte for byte.

```bash
contract/run.sh python3 "$PWD/python/tasks.py"      # Python, chapter 01 or 02
contract/run.sh "$PWD/rust/target/release/tracker"  # any compiled version: give its binary
```

Each case in `cases/` runs in a fresh folder holding [`tasks.txt`](tasks.txt) (plus any `.txt`
the case brings), with:

| File | Meaning |
| --- | --- |
| `stdin` | what the user types, one answer per line |
| `args` | command-line arguments |
| `env` | environment variables, `NAME=value` |
| `expected_stdout`, `expected_stderr` | the exact output, prompts included |
| `expected_exit` | the exit code |
| `expected_tasks.txt` | the tasks file afterwards (new tasks are appended) |

`done/` holds the done-command cases (chapter 03 onwards):
`CASES=done contract/run.sh <command...>`. Arguments are one per line in `args`, so a title with
spaces is one argument.
`undo/` holds the undo-command cases (chapter 04 onwards): `CASES=undo contract/run.sh <command...>`.

The expected files were recorded from the Python chapter 01 version with
`RECORD=1 contract/run.sh python3 "$PWD/python/tasks.py"`. Only re-record when the behaviour is
meant to change, and then for every language.

## Traps when porting

These cases pass easily in Python and catch the usual differences elsewhere:

- **Rounding halves to even.** Python's `round()` and `f"{x:.0f}"` round 2.5 to 2, not 3
  (case 08: 1 done of 8 shows `12%`, and a 2.5-block bar draws 2 blocks). Use the language's
  round-half-to-even (`math.RoundToEven` in Go, `f64::round_ties_even` in Rust, `nearbyint` in C)
  or the bars and percentages drift.
- **Ties keep file order.** Tags with the same count stay in the order they first appear
  (case 03: `home` before `work`). Use a stable sort on the count alone.
- **Prompts have no newline.** The prompt text and the answer's output share a line in
  `expected_stdout`, because piped input isn't echoed.
- **Errors go to stderr, with exit code 1.** Only the missing-file case (06) exits non-zero.
- **The bar is `█` (U+2588)**, and labels are padded by characters, not bytes.
- **Messy statuses.** `[done.]`, `[DONE]` and `[ todo ]` are all valid; only `[done]` after
  cleaning counts as done.
