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

import { UrgentTask } from "./models.ts";
import { TAG_MARKER } from "./parsing.ts";
import { appendTitles, loadTasks } from "./storage.ts";
import { addTasks, DEFAULT_TOP, summarize, topTags, type Pair } from "./tasklist.ts";
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

async function main(): Promise<number> {
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
