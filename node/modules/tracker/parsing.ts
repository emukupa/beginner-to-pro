// Turning one line of text into a Task. No files, no printing: text in, a Task out.

import { Task, UrgentTask } from "./models.ts";
import { strip, words } from "./text.ts";

export const TAG_MARKER = "#"; // marks a word as a tag: "#work"

// Not exported: only this module can call it.
function statusOf(raw: string): string {
  return raw.replace(/^[[\] .]+|[[\] .]+$/g, "").toLowerCase();
}

// "[done.] Call mom #family" -> a Task, or null if the line isn't a task.
export function parseLine(line: string): Task | null {
  const s = strip(line);
  if (!s.startsWith("[")) return null;
  const close = s.indexOf("]"); // Python's partition("]")
  const [raw, rest] = close === -1 ? [s, ""] : [s.slice(0, close), s.slice(close + 1)];
  const all = words(rest);
  const tags = all
    .filter((w) => w.startsWith(TAG_MARKER))
    .map((w) => w.replace(/^#+/, "").replace(/^[.,]+|[.,]+$/g, "").toLowerCase());
  const title = all.filter((w) => !w.startsWith(TAG_MARKER)).join(" ");
  const status = statusOf(raw);
  return tags.includes("urgent") ? new UrgentTask(title, status, tags) : new Task(title, status, tags);
}
