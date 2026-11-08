// Lesson 08: objects, and the two ways to name their shape: interface and type alias.
// readonly marks what must not change after it's made; tsc then refuses any assignment to it.
// Bug: assigning to a readonly property. tsc refuses it before the program runs.

import { cleanStatus } from "./lesson_04_strings.ts";

export const TITLE = "Objects, interfaces and readonly";

// An interface names the shape of an object. A parsed line never changes, so every field is readonly,
// and readonly string[] means the array can't be pushed to either.
export interface ParsedLine {
    readonly status: string;
    readonly title: string;
    readonly tags: readonly string[];
}

// A type alias names any type, not only objects. Options with every field optional:
// exactOptionalPropertyTypes means "marker?" can be left out, but not set to undefined.
export type ParseOptions = { marker?: string };

// "[done.] Call mom #family" -> { status: "done", title: "Call mom", tags: ["family"] },
// or undefined if the line isn't a task. Lesson 09 sorts lines and lesson 10 makes Tasks from these.
// The options object stands in for named arguments: parseLine(line, { marker: "@" }).
export function parseLine(line: string, { marker = "#" }: ParseOptions = {}): ParsedLine | undefined {
    const text = line.trim();
    if (!text.startsWith("[")) return undefined;
    const end = text.indexOf("]");
    if (end === -1) return undefined;
    const words = text.slice(end + 1).split(/\s+/).filter((word) => word !== "");   // any run of spaces or tabs
    const tags = words
        .filter((word) => word.startsWith(marker))
        .map((word) => word.slice(marker.length).replace(/^[.,]+|[.,]+$/g, "").toLowerCase());
    const title = words.filter((word) => !word.startsWith(marker)).join(" ");
    return { status: cleanStatus(text.slice(0, end + 1)), title, tags };
}

export function run(): void {
    const task = { title: "Call mom", done: false };   // an object literal; tsc infers its shape
    task.done = true;                     // const stops task meaning another object, not changes inside it
    console.log("an object:", task, "  task.title ->", task.title, "  task['done'] ->", task["done"]);
    const { title, done } = task;         // destructuring an object, by property name
    console.log("destructured:", title, done);
    const copy = { ...task, title: "Call dad" };   // spread: a copy, with one property changed
    console.log("a changed copy:", copy, "  the original:", task.title);

    const parsed = parseLine("[done.] Call mom #family");
    console.log("parseLine('[done.] Call mom #family') ->", parsed);
    console.log("parseLine('[x] a @b', { marker: '@' }) ->", parseLine("[x] a @b", { marker: "@" }));
    console.log("parseLine('just some text')        ->", parseLine("just some text"));
    console.log("parseLine('[ todo ] Review pull request #work.') ->", parseLine("[ todo ] Review pull request #work."));

    // readonly is a promise checked by tsc only. At run time the object is ordinary;
    // Object.freeze is the run-time version, and assigning to a frozen property throws in a module.
    const frozen = Object.freeze({ title: "Fix login bug" });
    try {
        (frozen as { title: string }).title = "changed";   // a cast lies to tsc; the run time still refuses
    } catch (error) {
        console.log("Object.freeze, at run time:", error instanceof TypeError ? "TypeError" : error);
    }
    // interface or type? Both describe objects. Interfaces can be extended and merged; type aliases
    // can also name unions (lesson 09). The tracker uses interface for objects, type for the rest.
}
