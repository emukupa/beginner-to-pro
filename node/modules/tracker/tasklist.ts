// Working with the list: adding, counting, ranking, summing up. No files, no printing.

import type { Task } from "./models.ts";
import { parseLine } from "./parsing.ts";
import { roundHalfEven, words } from "./text.ts";

export const DEFAULT_TOP = 3; // top tags shown when the answer is empty or invalid

// Parses each title as a new "[todo]" task and adds it. Returns how many were added.
export function addTasks(tasks: Task[], titles: readonly string[]): number {
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

// The first task whose title matches, ignoring case and extra spaces; undefined if there isn't one.
export function findTask(tasks: readonly Task[], title: string): Task | undefined {
  const wanted = words(title).join(" ").toLowerCase();
  return tasks.find((task) => task.title.toLowerCase() === wanted);
}

// A Map keeps keys in the order they were first added, like a Python dict, so first-seen order is free.
export function countTags(tasks: readonly Task[], includeDone = true): Map<string, number> {
  const counts = new Map<string, number>();
  for (const task of tasks) {
    if (!includeDone && task.isDone()) continue;
    for (const tag of task.tags) counts.set(tag, (counts.get(tag) ?? 0) + 1);
  }
  return counts;
}

// [tag, count] pairs: a tuple type, two items with a type each.
export type Pair = readonly [tag: string, count: number];

// The n most used tags, most first. toSorted is stable, so ties keep first-seen order.
export function topTags(tasks: readonly Task[], n = DEFAULT_TOP, includeDone = true): Pair[] {
  if (n < 1) throw new RangeError("n must be at least 1"); // Python's ValueError
  return [...countTags(tasks, includeDone)].toSorted((a, b) => b[1] - a[1]).slice(0, n);
}

// The numbers on the summary line: an object type, written inline.
export function summarize(tasks: readonly Task[]): { total: number; done: number; percent: number; tags: number } {
  const done = tasks.filter((t) => t.isDone()).length;
  const percent = tasks.length ? roundHalfEven((done / tasks.length) * 100) : 0;
  return { total: tasks.length, done, percent, tags: countTags(tasks).size };
}
