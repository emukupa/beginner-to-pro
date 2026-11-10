#!/usr/bin/env python3
"""Random inputs through the Python tracker and another version; any difference is a bug.

The contract's cases pin the behaviour at a few chosen points. This checks the space between
them: messy task files, odd answers to the prompts, done and undo with mangled titles. Python is
the reference, as it is for the contract. Each run gets its own folder (one for each version,
with the same files), and stdout, stderr, the exit code and every file left behind must match
byte for byte.

    contract/fuzz.py -- "$PWD/rust/modules/target/debug/tracker"
    contract/fuzz.py --runs 1000 --seed 7 -- node "$PWD/node/modules/tracker/cli.ts"
    contract/fuzz.py --modes add -- java "$PWD/java/one-file/Tracker.java"   # chapter 01: no done/undo
    contract/fuzz.py --seed 1 --start 212 --runs 1 -- ...                    # replay one run

Runs are deterministic: run i of seed s is the same input every time, on every machine, so a
failure prints the one command that replays it. It stops at the first mismatch.

--wild adds inputs no chapter promises to handle the same way as Python: Unicode whitespace and
capitals, digits from other scripts, huge numbers, a file without a final newline, CRLF line
endings. A mismatch there is a finding to look at, not necessarily a bug.
"""

from __future__ import annotations

import argparse
import difflib
import os
import random
import shlex
import string
import subprocess
import sys
import tempfile
from pathlib import Path

REPO = Path(__file__).resolve().parent.parent
REFERENCE = [sys.executable, str(REPO / "python" / "tasks.py")]
MODES = ("add", "done", "undo")

WORDS = [
    "buy",
    "Buy",
    "milk",
    "call",
    "mom",
    "Fix",
    "LOGIN",
    "bug",
    "book",
    "flights",
    "review",
    "pull",
    "request",
    "pay",
    "rent",
    "ship",
    "video",
    "write",
    "Script",
    "plan",
    "trip",
    "a",
    "x",
    "42",
    "done",
    "undo",
    "todo",
    "café",
    "naïve",
    "über",
    "日本",
    "smörgåsbord",
    "-",
    "!!",
    "it's",
    "v2.0",
    "[draft]",
    "]",
    "[",
]
TAGS = [
    "work",
    "home",
    "urgent",
    "URGENT",
    "Urgent",
    "family",
    "travel",
    "café",
    "日本語",
    "x",
    "a1",
    "we.ird",
    "long-tag-name",
    "",
    "#",
    "done",
]
STATUSES = [
    "done",
    "DONE",
    "Done",
    "done.",
    "done..",
    ". done",
    " done ",
    "todo",
    "TODO",
    " todo ",
    "todo.",
    "doing",
    "",
    " ",
    "x",
    "[done",
    "done]",
    "dOnE",
    "to do",
]
ANSWERS = [
    "",
    "",
    "0",
    "1",
    "2",
    "3",
    "5",
    "10",
    "-1",
    "  2  ",
    "+2",
    "-0",
    "1_0",
    "1__0",
    "_1",
    "1_",
    "five",
    "2.5",
    "007",
    " ",
    "0x10",
    "1e3",
    "3 4",
]

ASCII_UPPER = str.maketrans(string.ascii_lowercase, string.ascii_uppercase)
ASCII_LOWER = str.maketrans(string.ascii_uppercase, string.ascii_lowercase)
ASCII_SWAP = str.maketrans(
    string.ascii_letters, string.ascii_uppercase + string.ascii_lowercase
)

# Python's str.split() and str.strip() treat all of these as whitespace.
UNICODE_SPACES = [" ", " ", "　", " ", "\u0085", "\x0b", "\x0c", "\x1f"]
WILD_WORDS = ["ÉCOLE", "ÜBER", "ΣΟΦΙΑ", "İstanbul", "ǅ", "straße", "ﬁle"]
WILD_ANSWERS = ["٣", "３", "99999999999999999999", "-99999999999999999999", "1" * 40]


class Gen:
    """The random choices for one run."""

    def __init__(self, rng: random.Random, wild: bool):
        self.rng = rng
        self.wild = wild

    def chance(self, p: float) -> bool:
        return self.rng.random() < p

    def space(self) -> str:
        if self.wild and self.chance(0.15):
            return self.rng.choice(UNICODE_SPACES)
        return self.rng.choice([" "] * 6 + ["  ", "\t", " \t "])

    def word(self) -> str:
        if self.wild and self.chance(0.15):
            return self.rng.choice(WILD_WORDS)
        return self.rng.choice(WORDS)

    def tag(self) -> str:
        tag = self.rng.choice(TAGS)
        if self.chance(0.1):
            tag = tag.upper() if self.wild else tag[:1].translate(ASCII_UPPER) + tag[1:]
        prefix = "#" * self.rng.choice([1, 1, 1, 1, 2])
        suffix = self.rng.choice([""] * 6 + [".", ",", ".,", "..", "!"])
        return prefix + tag + suffix

    def title(self, words: int | None = None) -> str:
        """Words with tags mixed in (never first, so it's a title and not just tags)."""
        count = words if words is not None else self.rng.randint(1, 4)
        tokens = [self.word() for _ in range(count)]
        for _ in range(self.rng.choice([0, 0, 1, 1, 2, 3])):
            tokens.insert(self.rng.randint(1, len(tokens)), self.tag())
        return self.join(tokens)

    def join(self, tokens: list[str]) -> str:
        out = tokens[0]
        for token in tokens[1:]:
            out += self.space() + token
        return out

    def line(self) -> str:
        """One line of a tasks file, often messy, sometimes not a task at all."""
        kind = self.rng.random()
        if kind < 0.06:
            return ""
        if kind < 0.10:
            return self.rng.choice(
                [
                    "   ",
                    "\t",
                    "notes for later",
                    "- [ ] not a task",
                    "#work",
                    "]done[ odd",
                    "x [done] late bracket",
                ]
            )
        lead = self.rng.choice([""] * 8 + [" ", "  ", "\t"])
        status = self.rng.choice(STATUSES)
        after = self.rng.choice([" "] * 6 + ["", "  ", "\t"])
        if kind < 0.14:
            rest = self.join(
                [self.tag() for _ in range(self.rng.randint(0, 2))] or [""]
            )
        else:
            rest = self.title()
        trail = self.rng.choice([""] * 8 + [" ", "\t", "  "])
        return f"{lead}[{status}]{after}{rest}{trail}"

    def tasks_file(self) -> str:
        lines = [
            self.line() for _ in range(self.rng.choice([0, 1, 2, 3, 5, 6, 8, 10, 14]))
        ]
        if not lines:
            return ""
        newline = "\r\n" if self.wild and self.chance(0.1) else "\n"
        text = newline.join(lines) + newline
        if self.wild and self.chance(0.1):
            text = text.rstrip("\r\n")
        return text

    def new_task(self) -> str:
        """One answer to "New task": usually a task, sometimes tags only, never ending input."""
        r = self.rng.random()
        if r < 0.15:
            return self.join([self.tag() for _ in range(self.rng.randint(1, 3))])
        if r < 0.2:
            return self.space() + self.tag() + " " + self.word()
        pad = self.rng.choice([""] * 6 + [" ", "  "])
        return pad + self.title() + pad

    def answer(self) -> str:
        if self.wild and self.chance(0.2):
            return self.rng.choice(WILD_ANSWERS)
        return self.rng.choice(ANSWERS)

    def recase(self, word: str, style: str) -> str:
        """upper, lower or swap. Only ASCII letters unless --wild: the chapters match titles
        ignoring ASCII case; Unicode case mapping (ü and Ü) is beyond what they promise."""
        if self.wild:
            change = {"upper": str.upper, "lower": str.lower, "swap": str.swapcase}[
                style
            ]
            return change(word)
        table = {"upper": ASCII_UPPER, "lower": ASCII_LOWER, "swap": ASCII_SWAP}[style]
        return word.translate(table)

    def mangle(self, title: str) -> str:
        """A title as someone might type it: other capitals, other spacing."""
        words = title.split()
        if not words:
            return title
        style = self.rng.choice(["same", "upper", "lower", "swap", "spaces"])
        if style != "same" and style != "spaces":
            words = [self.recase(w, style) for w in words]
        out = self.join(words) if style == "spaces" else " ".join(words)
        return self.rng.choice(["", " ", "  "]) + out + self.rng.choice(["", " ", "  "])


def titles_in(text: str) -> list[str]:
    """The titles the Python version would see in a file (what done and undo can find)."""
    sys.path.insert(0, str(REPO / "python"))
    from tracker.parsing import parse_line  # the reference's own parser

    return [
        t.title for line in text.splitlines() if (t := parse_line(line)) and t.title
    ]


def make_case(seed: int, index: int, modes: tuple[str, ...], wild: bool) -> dict:
    """Run `index` of `seed`: the files, arguments, environment and stdin, nothing else random."""
    rng = random.Random(f"beginner-to-pro fuzz {seed}:{index}")
    g = Gen(rng, wild)
    mode = rng.choice(modes)
    files = {"tasks.txt": g.tasks_file()}
    args: list[str] = []
    env: dict[str, str] = {}
    stdin = ""

    # Which file the tracker reads: tasks.txt, another file by argument or TASKS_FILE, or none.
    where = rng.random()
    path = "tasks.txt"
    if where < 0.12:
        path = "work.txt"
        files[path] = g.tasks_file()
        env["TASKS_FILE"] = path
    elif where < 0.2 and mode == "add":
        path = "other list.txt"
        files[path] = g.tasks_file()
        args.append(path)
    elif where < 0.24:
        path = "missing.txt"
        if mode == "add" and rng.random() < 0.5:
            args.append(path)
        else:
            env["TASKS_FILE"] = path

    if mode == "add":
        lines = [g.new_task() for _ in range(rng.choice([0, 0, 1, 1, 2, 3, 5]))]
        lines += ["", g.answer()]
        stdin = "\n".join(lines) + "\n"
    else:
        known = titles_in(files.get(path, ""))
        r = rng.random()
        if known and r < 0.65:
            title = g.mangle(rng.choice(known))
        elif r < 0.85:
            title = g.title(rng.randint(1, 3))
        else:
            title = rng.choice(["", " ", "   ", None])
        args.append(mode)
        if title is not None:
            # Python joins every argument after the command, so a title may come in pieces.
            args += (
                title.split(" ") if title.strip() and rng.random() < 0.25 else [title]
            )
    return {"mode": mode, "files": files, "args": args, "env": env, "stdin": stdin}


def run(command: list[str], case: dict, timeout: float) -> dict:
    with tempfile.TemporaryDirectory(prefix="fuzz-") as work:
        for name, text in case["files"].items():
            Path(work, name).write_bytes(text.encode("utf-8"))
        env = {k: v for k, v in os.environ.items() if k != "TASKS_FILE"} | case["env"]
        try:
            done = subprocess.run(
                command + case["args"],
                cwd=work,
                env=env,
                timeout=timeout,
                input=case["stdin"].encode("utf-8"),
                capture_output=True,
                check=False,  # a non-zero exit is part of what's compared
            )
            result = {
                "stdout": done.stdout,
                "stderr": done.stderr,
                "exit": done.returncode,
            }
        except subprocess.TimeoutExpired:
            result = {
                "stdout": b"",
                "stderr": b"",
                "exit": f"timed out after {timeout}s",
            }
        result["files"] = {p.name: p.read_bytes() for p in sorted(Path(work).iterdir())}
        return result


def differences(want: dict, got: dict) -> list[str]:
    out = []
    if want["exit"] != got["exit"]:
        out.append(f"exit code: Python {want['exit']}, this version {got['exit']}")
    pairs = [
        ("stdout", want["stdout"], got["stdout"]),
        ("stderr", want["stderr"], got["stderr"]),
    ]
    for name in sorted(set(want["files"]) | set(got["files"])):
        pairs.append((name, want["files"].get(name), got["files"].get(name)))
    for name, a, b in pairs:
        if a == b:
            continue
        if a is None or b is None:
            out.append(
                f"{name}: only {'this version' if a is None else 'Python'} left this file"
            )
            continue
        diff = difflib.unified_diff(
            a.decode("utf-8", "replace").splitlines(keepends=True),
            b.decode("utf-8", "replace").splitlines(keepends=True),
            f"{name} (Python)",
            f"{name} (this version)",
        )
        text = "".join(diff)
        if not text.strip() or a.decode("utf-8", "replace") == b.decode(
            "utf-8", "replace"
        ):
            text = f"  Python:       {a!r}\n  this version: {b!r}\n"
        out.append(f"{name} differs:\n{text.rstrip()}")
    return out


def describe(case: dict) -> str:
    lines = [
        f"  mode:  {case['mode']}",
        f"  args:  {case['args']!r}",
        f"  env:   {case['env']!r}",
        f"  stdin: {case['stdin']!r}",
    ]
    for name, text in case["files"].items():
        lines.append(f"  {name}: {text!r}")
    return "\n".join(lines)


def main() -> int:
    parser = argparse.ArgumentParser(
        description="Fuzz a tracker against the Python reference.",
        usage="contract/fuzz.py [options] -- <command...>",
    )
    parser.add_argument(
        "--runs",
        type=int,
        default=int(os.getenv("N", "400")),
        help="how many runs (default 400, or $N)",
    )
    parser.add_argument(
        "--seed",
        type=int,
        default=int(os.getenv("SEED", "1")),
        help="which runs (default 1, or $SEED)",
    )
    parser.add_argument(
        "--start", type=int, default=0, help="first run index (to replay one)"
    )
    parser.add_argument(
        "--modes",
        default=",".join(MODES),
        help="add, done, undo: comma-separated (chapters 01 and 02: add)",
    )
    parser.add_argument(
        "--wild", action="store_true", help="inputs beyond what the chapters promise"
    )
    parser.add_argument(
        "--reference",
        default=shlex.join(REFERENCE),
        help="the reference command (default: the Python tracker)",
    )
    parser.add_argument("--timeout", type=float, default=30.0, help="seconds per run")
    parser.add_argument(
        "command", nargs=argparse.REMAINDER, help="the version under test"
    )
    opts = parser.parse_args()

    command = opts.command[1:] if opts.command[:1] == ["--"] else opts.command
    if not command:
        parser.error("give the command to test after --")
    modes = tuple(m.strip() for m in opts.modes.split(",") if m.strip())
    if not modes or set(modes) - set(MODES):
        parser.error(f"--modes takes some of: {', '.join(MODES)}")
    reference = shlex.split(opts.reference)

    print(
        f"fuzz: {opts.runs} runs from {opts.start}, seed {opts.seed}, modes {','.join(modes)}"
        f"{', wild' if opts.wild else ''}\n  reference: {shlex.join(reference)}\n"
        f"  testing:   {shlex.join(command)}",
        flush=True,
    )
    counts = dict.fromkeys(modes, 0)
    for i in range(opts.start, opts.start + opts.runs):
        case = make_case(opts.seed, i, modes, opts.wild)
        want = run(reference, case, opts.timeout)
        got = run(command, case, opts.timeout)
        found = differences(want, got)
        if found:
            print(
                f"\nMISMATCH on run {i} (after {i - opts.start} identical runs). The input:"
            )
            print(describe(case))
            print("\n".join(found))
            replay = (
                [
                    "contract/fuzz.py",
                    "--seed",
                    str(opts.seed),
                    "--start",
                    str(i),
                    "--runs",
                    "1",
                    "--modes",
                    ",".join(modes),
                ]
                + (["--wild"] if opts.wild else [])
                + ["--"]
            )
            print(f"\nReplay it: {shlex.join(replay + command)}")
            return 1
        counts[case["mode"]] += 1
        if (i - opts.start + 1) % 50 == 0:
            print(f"  {i - opts.start + 1} runs identical", flush=True)
    detail = ", ".join(f"{n} {m}" for m, n in counts.items())
    print(f"pass  {opts.runs} runs identical to Python ({detail})")
    return 0


if __name__ == "__main__":
    sys.exit(main())
