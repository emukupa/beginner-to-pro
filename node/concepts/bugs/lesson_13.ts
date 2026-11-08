// Lesson 13's bug: ranking by the title instead of a count. Subtracting two strings gives NaN,
// and sort with NaN comparisons scrambles the order without any error.
// Caught by: the generic's key type, (item: T) => number.   npm run bug -- 13

import { topN } from "../lesson_13_generics.ts";

const tasks = [{ title: "Call mom", tags: 1 }, { title: "Fix login bug", tags: 2 }];
console.log(topN(tasks, 1, (task) => task.title));
