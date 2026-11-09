import { test } from "node:test";
import assert from "node:assert/strict";

import { parseLine } from "./parsing.ts";
import { topTags, summarize } from "./tasklist.ts";
import type { Task } from "./models.ts";

const load = (...lines: string[]): Task[] => lines.map(parseLine).filter((t) => t !== null);

test("ties keep first-seen order", () => {
  const tasks = load("[todo] a #work #home", "[todo] b #home #work", "[todo] c #play");
  assert.deepEqual(topTags(tasks, 3).map(([tag]) => tag), ["work", "home", "play"]);
});

test("zero top tags is refused", () => {
  assert.throws(() => topTags([], 0), RangeError);
});

test("halves round to even", () => {
  const tasks = load("[done] a", ...Array.from({ length: 7 }, (_, i) => `[todo] t${i}`));
  assert.equal(summarize(tasks).percent, 12); // 12.5 -> 12, like Python's round()
});
