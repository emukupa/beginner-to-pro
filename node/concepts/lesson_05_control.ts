// Lesson 05: decisions and loops. if/else, the conditional operator, switch, and four loops,
// including for...in, which walks keys, not values: the classic trap.
// Bug: comparing a string with a number. tsc sees the two types never overlap.

export const TITLE = "Decisions and loops";

function describe(line: string): string {
    if (!line) {                          // "" is falsy, like 0, null, undefined and NaN
        return "blank line, skip it";
    } else if (!line.startsWith("[")) {
        return "not a task";
    } else {
        return "parse it";
    }
}

function describeStatus(status: string): string {
    switch (status) {                     // compares with ===, one case after another
        case "done":
            return "finished";
        case "todo":
        case "doing":                     // two cases sharing one answer: an empty case falls through
            return "still open";
        default:
            return "unknown status";
    }
}

export function run(): void {
    for (const line of ["", "hello", "[done] Buy milk"]) {
        console.log(`${JSON.stringify(line).padStart(17)} -> ${describe(line)}`);
    }
    console.log("falsy values:", [0, "", null, undefined, NaN].map((v) => Boolean(v)).join(" "));
    console.log("but [] and {} are truthy:", Boolean([]), Boolean({}));
    for (const status of ["done", "doing", "maybe"]) {
        console.log(`switch ${status.padStart(5)} -> ${describeStatus(status)}`);
    }
    const count = 1;
    console.log("conditional operator:", count === 1 ? "task" : "tasks");

    const tags = ["work", "home", "urgent"];
    let line = "";
    for (let i = 0; i < tags.length; i++) line += `${i}:${tags[i]} `;   // the counting loop
    console.log("for (let i ...):", line);
    for (const tag of tags) {             // for...of gives the values: what you nearly always want
        if (tag === "home") continue;     // skip this one
        if (tag === "urgent") break;      // stop the loop
        console.log("for...of:", tag);
    }
    const keys: string[] = [];
    for (const key in tags) keys.push(key);   // for...in gives the keys, as text
    console.log("for...in gives keys, as strings:", keys);
    let n = 10;
    let steps = 0;
    while (n !== 1) {                     // while: when you don't know how many times
        n = n % 2 === 0 ? n / 2 : 3 * n + 1;
        steps++;
    }
    console.log("while: 10 reaches 1 in", steps, "steps");
}
