// The lessons' reusable pieces, tested with node:test, Node's built-in test runner: no library needed.
// `npm test` runs `node --test`, which finds every *.test.ts file. tsc checks this file too.

import assert from "node:assert/strict";
import { join } from "node:path";
import { test } from "node:test";
import { parseWholeNumber, roundHalfEven } from "./lesson_03_numbers.ts";
import { cleanStatus, textWidth } from "./lesson_04_strings.ts";
import { bar, percent } from "./lesson_06_functions.ts";
import { countTags } from "./lesson_07_collections.ts";
import { parseLine } from "./lesson_08_objects.ts";
import { classify, toStatus } from "./lesson_09_unions.ts";
import { Task, UrgentTask } from "./lesson_10_classes.ts";
import { parseCount } from "./lesson_11_errors.ts";
import { loadTasks, TASKS } from "./lesson_12_files.ts";
import { topN } from "./lesson_13_generics.ts";

test("roundHalfEven sends halves to the even neighbour", () => {
    assert.deepEqual([0.5, 1.5, 2.5, 3.5, -2.5, 2.4, 2.6].map(roundHalfEven), [0, 2, 2, 4, -2, 2, 3]);
});

test("parseWholeNumber takes whole numbers only", () => {
    assert.equal(parseWholeNumber(" 42 "), 42);
    assert.equal(parseWholeNumber("-3"), -3);
    for (const text of ["", "five", "12abc", "2.5"]) assert.equal(parseWholeNumber(text), undefined);
});

test("cleanStatus and textWidth handle messy text", () => {
    assert.deepEqual(["[done]", "[done.]", "[DONE]", "[ todo ]"].map(cleanStatus), ["done", "done", "done", "todo"]);
    assert.equal(textWidth("🚀"), 1);
});

test("percent and bar", () => {
    assert.equal(percent(1, 8), 12.5);
    assert.equal(percent(0, 0), 0);
    assert.equal(bar(1, 8), "██");        // 2.5 blocks rounds to 2
});

test("countTags keeps first-seen order", () => {
    assert.deepEqual([...countTags([["home"], ["work", "home"]])], [["home", 2], ["work", 1]]);
});

test("parseLine and classify", () => {
    assert.deepEqual(parseLine("[ todo ] Review pull request #work."), { status: "todo", title: "Review pull request", tags: ["work"] });
    assert.equal(parseLine("no bracket"), undefined);
    assert.equal(classify("").kind, "blank");
    assert.equal(toStatus("doing"), "todo");
});

test("Task.from picks the class by tag", () => {
    const task = Task.from({ status: "todo", title: "Report", tags: ["work", "urgent"] });
    assert.ok(task instanceof UrgentTask);
    assert.equal(String(task), "[ ] Report  !!");
});

test("parseCount returns a Result", () => {
    assert.deepEqual(parseCount("3"), { ok: true, value: 3 });
    assert.equal(parseCount("0").ok, false);
});

test("loadTasks reads the file, and reports a missing one", async () => {
    const loaded = await loadTasks(TASKS);
    assert.ok(loaded.ok);
    assert.equal(loaded.value.length, 6);
    assert.equal(loaded.value.filter((t) => t.isDone()).length, 3);
    assert.deepEqual(await loadTasks(join(import.meta.dirname, "missing.txt")), { ok: false, error: "Couldn't find missing.txt" });
});

test("topN is stable: ties keep their order", () => {
    const pairs: [string, number][] = [["home", 2], ["work", 3], ["family", 1], ["travel", 1], ["urgent", 1]];
    assert.deepEqual(topN(pairs, 4, ([, n]) => n).map(([tag]) => tag), ["work", "home", "family", "travel"]);
});
