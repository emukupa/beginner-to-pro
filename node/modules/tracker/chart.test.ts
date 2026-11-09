import { test } from "node:test";
import assert from "node:assert/strict";

import { drawChart } from "./chart.ts";

test("draws into an array", () => {
  const lines: string[] = [];
  drawChart([["home", 2], ["work", 1]], (line) => lines.push(line), 4);
  assert.deepEqual(lines, ["home  ████ 2", "work  ██ 1"]);
});
