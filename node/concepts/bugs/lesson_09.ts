// Lesson 09's bug: a new kind of line, "comment", added to the union but forgotten by the switch.
// The default branch hands the leftover to a never parameter, and a comment isn't never.
// Caught by: the exhaustiveness check with never.   npm run bug -- 9

import { assertNever, type Line as TaskLine } from "../lesson_09_unions.ts";

type Line = TaskLine | { readonly kind: "comment"; readonly text: string };

function describe(line: Line): string {
    switch (line.kind) {
        case "task":
            return `task "${line.task.title}"`;
        case "blank":
            return "blank line";
        case "other":
            return "not a task";
        default:
            return assertNever(line);
    }
}
console.log(describe({ kind: "comment", text: "# shopping" }));
