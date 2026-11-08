// Lesson 14: beyond the tracker. Generators make values one at a time, only when asked;
// satisfies checks a value against a type without forgetting what the value actually is;
// ?. and ?? deal with "maybe missing" in one step each. You'll meet all three in other people's code.
// Bug: a misspelt key in a satisfies-checked object. tsc knows the keys the type allows.

import { readFile } from "node:fs/promises";
import { parseLine } from "./lesson_08_objects.ts";
import { Task } from "./lesson_10_classes.ts";
import { TASKS } from "./lesson_12_files.ts";

export const TITLE = "Generators, satisfies, ?. and ??";

// A generator: function* and yield. Calling it runs nothing yet; each next() runs to the next yield.
function* tasksIn(text: string): Generator<Task> {
    for (const line of text.split("\n")) {
        const parsed = parseLine(line);
        if (parsed !== undefined) yield Task.from(parsed);
    }
}

// Never ends, and that's fine: the caller takes only what it needs.
function* ids(): Generator<number> {
    for (let n = 1; ; n++) yield n;
}

type Column = "status" | "title";      // the padded columns; tags come last, unpadded

// satisfies checks every column has a width, yet COLUMNS keeps its exact keys. An annotation,
// `const COLUMNS: Record<string, number>`, would forget them and let COLUMNS.titel through.
const COLUMNS = { status: 7, title: 25 } satisfies Record<Column, number>;

export async function run(): Promise<void> {
    const text = await readFile(TASKS, "utf8");
    const tasks = tasksIn(text);
    console.log("first task, read lazily:", String(tasks.next().value));
    console.log("the rest:", [...tasks].length, "more   (spreading runs the generator to the end)");
    const counter = ids();
    console.log("three ids from an endless generator:", counter.next().value, counter.next().value, counter.next().value);

    console.log(`${"status".padEnd(COLUMNS.status)}${"title".padEnd(COLUMNS.title)}tags`);
    for (const task of tasksIn(text)) {
        if (task.tags.includes("work")) {
            console.log(`${task.status.padEnd(COLUMNS.status)}${task.title.padEnd(COLUMNS.title)}${task.tags.join(" ")}`);
        }
    }

    // ?. stops and gives undefined if the left side is null or undefined, instead of throwing.
    const untagged = new Task("Water plants");
    const tagged = new Task("Book flights", "todo", ["travel", "home"]);
    const empty: Task | undefined = [...tasksIn("")][0];
    for (const task of [tagged, untagged, empty]) {
        // ?? gives the right side only for null or undefined. || would also replace 0 and "".
        console.log(`first tag of ${task?.title ?? "(no task)"}: ${task?.tags[0]?.toUpperCase() ?? "none"}`);
    }
    const settings = new Map([["top", 0]]);   // someone asked for zero, on purpose
    console.log(`settings.get("top") || 3 -> ${settings.get("top") || 3}   ?? 3 -> ${settings.get("top") ?? 3}   (?? keeps a real 0)`);
}
