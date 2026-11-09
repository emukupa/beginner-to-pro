// The task tracker in one TypeScript file. Same prompts, summary and chart as the Python version,
// byte for byte: contract/run.sh checks every one. Read top to bottom: settings, what a task is,
// parsing a line, the file, counting and ranking, the chart, then main, the only part that talks to
// the user.
//
//   cd node
//   node one-file/tracker.ts                                  run it (Node strips the types)
//   npm run check                                             tsc: the strict type check
//   ../contract/run.sh node "$PWD/one-file/tracker.ts"        the contract

import { readFileSync, appendFileSync } from "node:fs";
import { createInterface } from "node:readline";

// ---- Settings -------------------------------------------------------------------------------

const CHART_WIDTH = 20; // the longest bar, in characters
const DEFAULT_TOP = 3; // top tags shown when the answer is empty or invalid
const TAG_MARKER = "#"; // marks a word as a tag: "#work"
const BAR = "█";

// Python's whitespace, exactly: what str.split() and str.strip() treat as space. JavaScript's \s is
// almost the same, but not quite (it has ﻿, and lacks \x85 and \x1c-\x1f).
const SPACE = "\\t\\n\\v\\f\\r\\x1c-\\x1f \\x85\\xa0\\u1680\\u2000-\\u200a\\u2028\\u2029\\u202f\\u205f\\u3000";
const EDGE_SPACE = new RegExp(`^[${SPACE}]+|[${SPACE}]+$`, "g");
const RUN_OF_SPACE = new RegExp(`[${SPACE}]+`);

const strip = (s: string): string => s.replace(EDGE_SPACE, "");
const words = (s: string): string[] => strip(s).split(RUN_OF_SPACE).filter((w) => w !== "");

// ---- What a task is -------------------------------------------------------------------------

// A class, as in Python. readonly fields can be set once, in the constructor, and never again.
class Task {
  readonly title: string;
  readonly status: string;
  readonly tags: readonly string[];

  constructor(title: string, status: string, tags: readonly string[]) {
    this.title = title;
    this.status = status;
    this.tags = tags;
  }

  isDone(): boolean {
    return this.status === "done";
  }

  toString(): string {
    return `[${this.isDone() ? "x" : " "}] ${this.title}`;
  }
}

// TypeScript has inheritance, so Python's UrgentTask(Task) stays a subclass. `override` is
// required (noImplicitOverride): a typo in the name would otherwise add a new method silently.
class UrgentTask extends Task {
  override toString(): string {
    return `${super.toString()}  !!`;
  }
}

// ---- Parsing one line -----------------------------------------------------------------------

// "[done.] Call mom #family" -> a Task, or null if the line isn't a task. The return type says both.
function parseLine(line: string): Task | null {
  const s = strip(line);
  if (!s.startsWith("[")) return null;
  const close = s.indexOf("]"); // Python's partition("]")
  const [raw, rest] = close === -1 ? [s, ""] : [s.slice(0, close), s.slice(close + 1)];
  const status = raw.replace(/^[[\] .]+|[[\] .]+$/g, "").toLowerCase();
  const all = words(rest);
  const tags = all
    .filter((w) => w.startsWith(TAG_MARKER))
    .map((w) => w.replace(/^#+/, "").replace(/^[.,]+|[.,]+$/g, "").toLowerCase());
  const title = all.filter((w) => !w.startsWith(TAG_MARKER)).join(" ");
  return tags.includes("urgent") ? new UrgentTask(title, status, tags) : new Task(title, status, tags);
}

// ---- The file -------------------------------------------------------------------------------

// Every task in the file; lines that aren't tasks are skipped. Lines end at \n, \r\n or \r, as when
// Python reads a text file. Errors are thrown, as in Python.
function loadTasks(path: string): Task[] {
  const text = readFileSync(path, "utf8");
  return text
    .split(/\r\n|\r|\n/)
    .map(parseLine)
    .filter((task) => task !== null); // TypeScript works out that the result is Task[]
}

// Parses each title as a new "[todo]" task and adds it. Returns how many were added.
function addTasks(tasks: Task[], titles: readonly string[]): number {
  let added = 0;
  for (const title of titles) {
    const task = parseLine(`[todo] ${title}`);
    if (task) {
      tasks.push(task);
      added++;
    }
  }
  return added;
}

// ---- Counting and ranking -------------------------------------------------------------------

// A Map keeps keys in the order they were first added, like a Python dict, so first-seen order is free.
function countTags(tasks: readonly Task[], includeDone = true): Map<string, number> {
  const counts = new Map<string, number>();
  for (const task of tasks) {
    if (!includeDone && task.isDone()) continue;
    for (const tag of task.tags) counts.set(tag, (counts.get(tag) ?? 0) + 1);
  }
  return counts;
}

// [tag, count] pairs: a tuple type, two items with a type each.
type Pair = readonly [tag: string, count: number];

// The n most used tags, most first. toSorted is stable, so ties keep first-seen order; it returns a
// new array and leaves the old one alone.
function topTags(tasks: readonly Task[], n = DEFAULT_TOP, includeDone = true): Pair[] {
  if (n < 1) throw new RangeError("n must be at least 1"); // Python's ValueError
  return [...countTags(tasks, includeDone)].toSorted((a, b) => b[1] - a[1]).slice(0, n);
}

// ---- Numbers --------------------------------------------------------------------------------

// Python's round(): halves go to the even neighbour. Math.round and toFixed both send halves up.
function roundHalfEven(x: number): number {
  const floor = Math.floor(x);
  const diff = x - floor;
  if (diff !== 0.5) return Math.round(x);
  return floor % 2 === 0 ? floor : floor + 1;
}

// Python's int(text): optional spaces, an optional sign, digits with single underscores between
// them, optional spaces. Number("1_000") is NaN and Number("") is 0, so it's written here.
function parseWholeNumber(text: string): number | null {
  const match = /^([+-]?)(\d+(?:_\d+)*)$/.exec(strip(text));
  if (!match) return null;
  const [, sign = "", digits = ""] = match;
  return Math.min(Number(digits.replaceAll("_", "")), 2 ** 31) * (sign === "-" ? -1 : 1);
}

// ---- The chart ------------------------------------------------------------------------------

function drawChart(pairs: readonly Pair[], width = CHART_WIDTH, char = BAR): void {
  const first = pairs[0]; // Pair | undefined: noUncheckedIndexedAccess makes us check
  if (!first) {
    console.log("No tags yet.");
    return;
  }
  const length = (s: string) => [...s].length; // characters, not UTF-16 code units
  const labelWidth = Math.max(...pairs.map(([tag]) => length(tag)));
  for (const [tag, count] of pairs) {
    const bar = char.repeat(roundHalfEven((count / first[1]) * width));
    console.log(`${tag}${" ".repeat(labelWidth - length(tag))}  ${bar} ${count}`);
  }
}

// ---- Talking to the user --------------------------------------------------------------------

// Like Python's input(): shows the prompt, waits for one line. An empty line at the end of input.
const lines = createInterface({ input: process.stdin, crlfDelay: Infinity, terminal: false })[Symbol.asyncIterator]();

async function ask(prompt: string): Promise<string> {
  process.stdout.write(prompt);
  const next = await lines.next();
  return next.done ? "" : next.value;
}

async function main(): Promise<number> {
  const path = process.argv[2] ?? process.env["TASKS_FILE"] ?? "tasks.txt";

  let tasks: Task[];
  try {
    tasks = loadTasks(path);
  } catch (error) {
    // catch gives `unknown`: we check what it is before using it.
    const code = error instanceof Error && "code" in error ? error.code : undefined;
    console.error(code === "ENOENT" ? `Couldn't find ${path}` : `Couldn't read ${path}`);
    return 1;
  }

  const newTitles: string[] = [];
  while (true) {
    const title = strip(await ask("New task (Enter to finish): "));
    if (!title) break;
    if (title.startsWith(TAG_MARKER)) {
      console.log("A task needs a title, not just tags.");
      continue;
    }
    newTitles.push(title);
  }
  if (addTasks(tasks, newTitles) > 0) {
    appendFileSync(path, newTitles.map((title) => `[todo] ${title}\n`).join(""));
  }

  let pairs: Pair[];
  try {
    const answer = await ask("How many top tags? [3]: ");
    pairs = topTags(tasks, answer === "" ? DEFAULT_TOP : (parseWholeNumber(answer) ?? 0));
  } catch (error) {
    if (!(error instanceof RangeError)) throw error;
    console.log("Need a whole number of at least 1 — using 3.");
    pairs = topTags(tasks);
  }

  const done = tasks.filter((t) => t.isDone()).length;
  const percent = tasks.length ? (done / tasks.length) * 100 : 0;
  console.log(`\n${tasks.length} tasks, ${done} done (${roundHalfEven(percent)}%), ${countTags(tasks).size} tags`);
  for (const task of tasks) {
    if (task instanceof UrgentTask && !task.isDone()) console.log(String(task));
  }

  console.log("\nTop tags");
  drawChart(pairs);
  return 0;
}

// Setting exitCode, not calling process.exit(), lets Node finish writing to a pipe before it quits.
process.exitCode = await main();
lines.return?.();
process.stdin.destroy();
