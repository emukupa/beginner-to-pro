// The task tracker, split into ES modules: one file per job in tracker/, and this one, the only one
// that reads input, prints to the screen or sets the exit code.
//
// Imports point one way: models <- parsing <- storage, tasklist <- chart <- cli. ES modules allow a
// cycle, but a module in a cycle can run before the one it needs has finished, so we keep it a line.
//
//   cd node
//   node modules/tracker/cli.ts
//   npm test

import { createInterface } from "node:readline";

import { UrgentTask, type Status } from "./models.ts";
import { TAG_MARKER } from "./parsing.ts";
import { appendTitles, loadTasks, setStatus } from "./storage.ts";
import { addTasks, DEFAULT_TOP, findTask, summarize, topTags, type Pair } from "./tasklist.ts";
import { drawChart } from "./chart.ts";
import { strip } from "./text.ts";

// Like Python's input(): shows the prompt, waits for one line. An empty line at the end of input.
const lines = createInterface({ input: process.stdin, crlfDelay: Infinity, terminal: false })[Symbol.asyncIterator]();

async function ask(prompt: string): Promise<string> {
  process.stdout.write(prompt);
  const next = await lines.next();
  return next.done ? "" : next.value;
}

// Python's int(text): optional spaces, an optional sign, digits with single underscores between
// them, optional spaces. Number("1_000") is NaN and Number("") is 0, so it's written here.
function parseWholeNumber(text: string): number | null {
  const match = /^([+-]?)(\d+(?:_\d+)*)$/.exec(strip(text));
  if (!match) return null;
  const [, sign = "", digits = ""] = match;
  return Math.min(Number(digits.replaceAll("_", "")), 2 ** 31) * (sign === "-" ? -1 : 1);
}

// What a status command does: the status it sets, and what it prints.
type Change = { readonly sets: Status; readonly changed: string; readonly already: string };

// Python's CHANGES dict. `as const` keeps the exact words; `satisfies` checks every entry is a Change
// without widening them, so a typo, or a status that isn't a Status, stops the type check.
const CHANGES = {
  done: { sets: "done", changed: "Done", already: "Already done" },
  undo: { sets: "todo", changed: "Undone", already: "Not done yet" },
} as const satisfies Record<string, Change>;

type Command = keyof typeof CHANGES; // "done" | "undo", worked out from the table

// A type guard: when it returns true, TypeScript knows `word` is a Command, not just a string.
function isCommand(word: string | undefined): word is Command {
  return word !== undefined && Object.hasOwn(CHANGES, word);
}

// tracker done|undo "title": sets one task's status. Returns the exit code.
function changeCommand(name: Command, words: readonly string[]): number {
  const change = CHANGES[name];
  const title = strip(words.join(" "));
  if (!title) {
    console.error(`Usage: ${name} "task title"`);
    return 2;
  }
  const path = process.env["TASKS_FILE"] ?? "tasks.txt";
  let tasks;
  try {
    tasks = loadTasks(path);
  } catch (error) {
    const code = error instanceof Error && "code" in error ? error.code : undefined;
    console.error(code === "ENOENT" ? `Couldn't find ${path}` : `Couldn't read ${path}`);
    return 1;
  }
  const task = findTask(tasks, title);
  if (!task) {
    console.error(`No task called "${title}"`);
    return 1;
  }
  if (task.status === change.sets) {
    console.log(`${change.already}: ${task.title}`);
    return 0;
  }
  try {
    setStatus(path, task, change.sets);
  } catch {
    console.error(`Couldn't write ${path}`);
    return 1;
  }
  console.log(`${change.changed}: ${task.title}`);
  return 0;
}

async function main(): Promise<number> {
  const command = process.argv[2];
  if (isCommand(command)) return changeCommand(command, process.argv.slice(3)); // tracker done|undo "title"

  const path = process.argv[2] ?? process.env["TASKS_FILE"] ?? "tasks.txt";

  let tasks;
  try {
    tasks = loadTasks(path);
  } catch (error) {
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
  if (addTasks(tasks, newTitles) > 0) appendTitles(path, newTitles);

  let pairs: Pair[];
  try {
    const answer = await ask("How many top tags? [3]: ");
    pairs = topTags(tasks, answer === "" ? DEFAULT_TOP : (parseWholeNumber(answer) ?? 0));
  } catch (error) {
    if (!(error instanceof RangeError)) throw error;
    console.log("Need a whole number of at least 1 — using 3.");
    pairs = topTags(tasks);
  }

  const s = summarize(tasks);
  console.log(`\n${s.total} tasks, ${s.done} done (${s.percent}%), ${s.tags} tags`);
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
