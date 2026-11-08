// Lesson 13: generics. topN<T> works for any kind of item: T is a type parameter, filled in by tsc
// from the arguments, so the same function ranks tags, tasks or anything else, and stays type-safe.
// Then every piece so far, put together: a small version of the tracker.
// Bug: a key function that gives back text where topN needs a number. tsc checks it against T.

import { roundHalfEven } from "./lesson_03_numbers.ts";
import { textWidth } from "./lesson_04_strings.ts";
import { bar, percent } from "./lesson_06_functions.ts";
import { countTags } from "./lesson_07_collections.ts";
import { UrgentTask } from "./lesson_10_classes.ts";
import { parseCount } from "./lesson_11_errors.ts";
import { ask, loadTasks, TASKS } from "./lesson_12_files.ts";

export const TITLE = "Generics, and a mini tracker";

// The n items with the biggest key, biggest first. Ties keep their order, because sort is stable:
// the language promises it (since ES2019). toSorted is sort that leaves the original alone.
export function topN<T>(items: readonly T[], n: number, key: (item: T) => number): T[] {
    return items.toSorted((a, b) => key(b) - key(a)).slice(0, n);
}

// Each label padded to the widest, by characters (textWidth), then its bar and count.
function drawChart(pairs: readonly (readonly [string, number])[]): void {
    const biggest = pairs[0]?.[1];        // ?. stops at undefined: there may be no pairs at all
    if (biggest === undefined) {
        console.log("No tags yet.");
        return;
    }
    const width = Math.max(...pairs.map(([tag]) => textWidth(tag)));
    for (const [tag, count] of pairs) {
        console.log(`${tag}${" ".repeat(width - textWidth(tag))}  ${bar(count, biggest)} ${count}`);
    }
}

export async function run(): Promise<void> {
    const words = ["done", "todo", "doing", "do"];
    console.log("topN of strings, by length:", topN(words, 2, (word) => word.length));   // T is string
    const pairs: [string, number][] = [["home", 2], ["work", 3], ["family", 1], ["travel", 1], ["urgent", 1]];
    console.log("topN of pairs, by count:  ", topN(pairs, 5, ([, count]) => count).map(([tag]) => tag).join(" "),
        "  (family, travel and urgent tie: they stay in file order)");

    const loaded = await loadTasks(TASKS);
    if (!loaded.ok) {
        console.error(loaded.error);      // errors go to stderr, as the tracker's will
        return;
    }
    const tasks = loaded.value;
    const answer = await ask("How many top tags? [3]: ", "");
    const count = parseCount(answer.trim() || "3");   // || here on purpose: an empty answer means the default
    if (!count.ok) console.log("Need a whole number of at least 1 — using 3.");
    const done = tasks.filter((task) => task.isDone()).length;
    const counts = countTags(tasks.map((task) => task.tags));
    console.log(`\n${tasks.length} tasks, ${done} done (${roundHalfEven(percent(done, tasks.length))}%), ${counts.size} tags`);
    for (const task of tasks) {
        if (task instanceof UrgentTask && !task.isDone()) console.log(String(task));
    }
    console.log("\nTop tags");
    drawChart(topN([...counts], count.ok ? count.value : 3, ([, n]) => n));
}
