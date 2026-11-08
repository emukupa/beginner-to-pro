// Lesson 07: arrays, Map and Set. Arrays hold items in order; a Map counts things by key and keeps
// keys in the order they were first added, which is exactly what the tracker's ties need.
// Bug: reading arr[0] as if it must exist. noUncheckedIndexedAccess says it may be undefined.

export const TITLE = "Arrays, Map and Set";

// Counts tags in first-seen order. Lesson 13's mini tracker ranks these.
export function countTags(tagLists: readonly (readonly string[])[]): Map<string, number> {
    const counts = new Map<string, number>();
    for (const tags of tagLists) {
        for (const tag of tags) {
            counts.set(tag, (counts.get(tag) ?? 0) + 1);   // get gives undefined for a new tag; ?? turns it into 0
        }
    }
    return counts;
}

export function run(): void {
    const tasks = ["Buy groceries", "Call mom"];
    tasks.push("Book flights");
    console.log("after push:", tasks, "- length", tasks.length);
    const removed = tasks.pop();
    console.log("pop() removed", JSON.stringify(removed), "->", tasks);
    const a = [1, 2];
    const b = a;                          // not a copy: two names, one array
    b.push(3);
    const c = [...a];                     // spreading into a new array is a real (shallow) copy
    c.push(4);
    console.log("aliasing: a is now", a, "  the copy c is", c);
    const [first, ...others] = ["work", "home", "urgent"];   // destructuring takes an array apart
    console.log("destructured:", first, others);
    console.log("tasks[10] ->", tasks[10], "  (no error: arrays answer undefined past the end)");
    console.log("includes, indexOf:", tasks.includes("Call mom"), tasks.indexOf("Call mom"));

    const tagLists = [["home"], ["work", "urgent"], ["family"], ["work"], ["travel", "home"], ["work"]];
    const counts = countTags(tagLists);
    console.log("countTags:", [...counts].map(([tag, n]) => `${tag} ${n}`).join(", "), "  (keys in first-seen order)");
    console.log("counts.get('work') ->", counts.get("work"), "  counts.get('play') ->", counts.get("play"));
    console.log("a Set drops repeats, keeping first-seen order:", [...new Set(tagLists.flat())].join(" "));

    // Why a Map and not a plain object? An object puts keys that look like whole numbers first,
    // in number order, whatever order you added them. A Map never reorders.
    const object: Record<string, number> = {};
    const map = new Map<string, number>();
    for (const key of ["work", "2024", "home", "7"]) {
        object[key] = 1;
        map.set(key, 1);
    }
    console.log("object keys:", Object.keys(object).join(" "), "   Map keys:", [...map.keys()].join(" "));
}
