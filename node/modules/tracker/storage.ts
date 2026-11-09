// The tasks file: the only module that opens files.

import { appendFileSync, closeSync, fchmodSync, fsyncSync, openSync, readFileSync, renameSync, rmSync, statSync, writeSync } from "node:fs";
import { randomBytes } from "node:crypto";

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

// A new file beside another, that deletes itself when it's disposed, unless it replaced the other.
// `using temp = ...` disposes it when the block ends, however it ends: normally, or by a throw.
// That's JavaScript's explicit resource management: the cleanup belongs to the value.
class TempFile implements Disposable {
  readonly path: string;
  readonly fd: number;
  #kept = false; // # makes a field private at run time, not just to the type checker

  // "wx" opens for writing and fails if the file exists, so a random name can't be anyone else's.
  constructor(beside: string) {
    this.path = `${beside}.${randomBytes(6).toString("hex")}`;
    this.fd = openSync(this.path, "wx", 0o600);
  }

  // On the disk first, then renamed over target: readers see the old file or the new one.
  replace(target: string): void {
    fsyncSync(this.fd);
    renameSync(this.path, target);
    this.#kept = true;
  }

  [Symbol.dispose](): void {
    closeSync(this.fd);
    if (!this.#kept) rmSync(this.path, { force: true }); // never leave the half-made file behind
  }
}

// True if this line holds the task: the same title and status after parsing.
function holds(line: string, task: Task): boolean {
  const found = parseLine(line);
  return found !== null && found.title === task.title && found.status === task.status;
}

// Rewrites the line holding this task as [done], leaving every other byte of the file alone.
export function markDone(path: string, task: Task): void {
  // Each line keeps its own ending (\n, \r\n or \r), as Python's readlines() does with newline="".
  const lines = readFileSync(path, "utf8").match(/[^\r\n]*(?:\r\n|\r|\n)|[^\r\n]+$/g) ?? [];
  const at = lines.findIndex((line) => holds(line, task));
  const line = lines[at];
  if (line !== undefined) {
    const open = line.indexOf("[");
    const close = line.indexOf("]", open);
    lines[at] = `${line.slice(0, open)}[done]${line.slice(close + 1)}`; // spaces before, title and ending after
  }

  using temp = new TempFile(path);
  fchmodSync(temp.fd, statSync(path).mode & 0o7777); // keep the old file's permissions
  writeSync(temp.fd, lines.join(""));
  temp.replace(path);
} // temp is disposed here: closed, and deleted unless replace() ran
