// Lesson 09: unions. A union type says "one of these": "done" | "todo" lists every allowed value,
// so a typo is a type error. A discriminated union tags each shape with a `kind`, and a switch on
// kind tells tsc which shape it has. Type guards are your own checks that tsc trusts.
// Bug: a new kind of line that the switch forgets. The `never` check makes tsc notice.

import { parseLine, type ParsedLine } from "./lesson_08_objects.ts";

export const TITLE = "Unions and type guards";

// A union of two string literals: only these two values are a Status.
export type Status = "done" | "todo";

// A type guard: returns boolean, but "text is Status" tells tsc what true means.
export function isStatus(text: string): text is Status {
    return text === "done" || text === "todo";
}

// The tracker's rule: only "done" (after cleaning) counts as done; anything else is still to do.
export function toStatus(text: string): Status {
    return isStatus(text) ? text : "todo";
}

// Every line of the file is one of three shapes. `kind` is the tag that tells them apart.
export type Line =
    | { readonly kind: "task"; readonly task: ParsedLine }
    | { readonly kind: "blank" }
    | { readonly kind: "other"; readonly text: string };

export function classify(text: string): Line {
    if (text.trim() === "") return { kind: "blank" };
    const task = parseLine(text);
    return task === undefined ? { kind: "other", text } : { kind: "task", task };
}

// Nothing can reach here: if a case is missing, `line` isn't never and tsc reports it.
export function assertNever(value: never): never {
    throw new Error(`unexpected value: ${JSON.stringify(value)}`);
}

function describe(line: Line): string {
    switch (line.kind) {
        case "task":
            return `task "${line.task.title}"`;       // here tsc knows line has .task
        case "blank":
            return "blank line";
        case "other":
            return `not a task: ${JSON.stringify(line.text)}`;
        default:
            return assertNever(line);
    }
}

// The erasable alternative to an enum: a plain object, `as const` so its values stay literal,
// and a type made from its values. It is the same "done" | "todo" union.
const STATUS = { Done: "done", Todo: "todo" } as const;
type StatusFromObject = (typeof STATUS)[keyof typeof STATUS];

// typeof narrows a union too: inside each branch tsc knows which one it is.
function show(value: string | number): string {
    return typeof value === "string" ? value.toUpperCase() : value.toFixed(1);
}

export function run(): void {
    for (const text of ["done", "todo", "doing", "x"]) {
        console.log(`isStatus(${JSON.stringify(text)}) -> ${isStatus(text)}   toStatus -> ${toStatus(text)}`);
    }
    for (const text of ["[done.] Call mom #family", "   ", "Shopping list:"]) {
        console.log(describe(classify(text)));
    }
    console.log("typeof narrowing:", show("work"), show(4));
    const fromObject: StatusFromObject = STATUS.Done;
    console.log("STATUS.Done ->", fromObject, "  Object.values(STATUS) ->", Object.values(STATUS));
    // A TypeScript enum would do the same job, but enum isn't erasable: it makes JavaScript of its
    // own, which Node's type stripping won't run. See concepts/extras/status_enum.ts (npm run enum).
    console.log("an enum: npm run enum   (Node can't strip it: it needs --experimental-transform-types)");
}
