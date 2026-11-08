// Lesson 06: functions. Declarations and arrow functions, default, optional and rest parameters,
// functions passed around as values, and closures that remember where they were made.
// Bug: calling a function with an argument missing. tsc counts them.

import { roundHalfEven } from "./lesson_03_numbers.ts";

export const TITLE = "Functions";

// The share done, as a percentage. No tasks means 0%, not 0 / 0 = NaN.
export function percent(done: number, total: number): number {
    return total === 0 ? 0 : (done / total) * 100;
}

// A bar of blocks, scaled so the biggest count gets the full width. Lesson 13's chart draws these.
// width = 20 is a default: leave it out and you get 20.
export function bar(count: number, biggest: number, width = 20): string {
    return "█".repeat(roundHalfEven((count / biggest) * width));
}

// An arrow function: shorter, and the usual choice for small functions handed to other functions.
const double = (n: number): number => n * 2;

// tag?: an optional parameter. Inside, its type is string | undefined, so we must handle both.
function label(title: string, tag?: string): string {
    return tag === undefined ? title : `${title} #${tag}`;
}

// ...titles: a rest parameter collects any number of arguments into an array.
function addTitles(list: string[], ...titles: string[]): number {
    list.push(...titles);                 // ... in a call spreads an array back out into arguments
    return titles.length;
}

// A closure: the returned function keeps `next` alive between calls, so each counter has its own.
function makeCounter(): () => number {
    let next = 0;
    return () => ++next;
}

export function run(): void {
    console.log("percent(3, 6) ->", percent(3, 6), "  percent(0, 0) ->", percent(0, 0));
    console.log("bar(1, 2) ->", bar(1, 2), "  bar(1, 8, 20) ->", bar(1, 8, 20), "(2.5 blocks: halves to even)");
    console.log("double(21) ->", double(21));
    console.log("label('Call mom') ->", label("Call mom"), "  label('Call mom', 'family') ->", label("Call mom", "family"));
    const mine: string[] = [];
    const more = ["Read book", "Walk dog"];
    console.log("addTitles(mine, 'Pay rent', 'Call dad') ->", addTitles(mine, "Pay rent", "Call dad"));
    addTitles(mine, ...more);
    console.log("after spreading:", mine);
    const ids = makeCounter();
    const other = makeCounter();
    console.log("closures:", ids(), ids(), ids(), " another counter starts again:", other());
    // Functions are values: map takes one and calls it on every item.
    console.log("map with an arrow:", [1, 2, 3].map(double), "  filter:", [1, 2, 3, 4].filter((n) => n % 2 === 0));
}
