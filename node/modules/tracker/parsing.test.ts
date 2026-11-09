// Tests beside the code: `npm test` (node --test) finds every *.test.ts and runs it.
import { test } from "node:test";
import assert from "node:assert/strict";

import { parseLine } from "./parsing.ts";
import { UrgentTask } from "./models.ts";

test("reads the status, title and tags", () => {
  const task = parseLine("[DONE.] Call mom #Family #urgent,");
  assert.ok(task instanceof UrgentTask);
  assert.equal(task.status, "done");
  assert.equal(task.title, "Call mom");
  assert.deepEqual(task.tags, ["family", "urgent"]);
});

test("keeps an unknown status, and skips a line without a bracket", () => {
  assert.equal(parseLine("  [ later ] Water plants")?.status, "later");
  assert.equal(parseLine("Buy milk #home"), null);
});
