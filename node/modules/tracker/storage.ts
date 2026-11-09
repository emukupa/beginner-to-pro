// The tasks file: the only module that opens files.

import { readFileSync, appendFileSync } from "node:fs";

import type { Task } from "./models.ts"; // only used as a type: `import type` says so, and Node erases it
import { parseLine } from "./parsing.ts";

// Every task in the file; lines that aren't tasks are skipped. Lines end at \n, \r\n or \r, as when
// Python reads a text file. Errors are thrown, as in Python.
export function loadTasks(path: string): Task[] {
  return readFileSync(path, "utf8")
    .split(/\r\n|\r|\n/)
    .map(parseLine)
    .filter((task) => task !== null);
}

// "[todo] title" lines on the end of the file.
export function appendTitles(path: string, titles: readonly string[]): void {
  appendFileSync(path, titles.map((title) => `[todo] ${title}\n`).join(""));
}
