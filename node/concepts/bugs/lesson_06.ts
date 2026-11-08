// Lesson 06's bug: an argument missing. JavaScript fills it in with undefined, and 3 / undefined is NaN.
// Caught by: tsc counting arguments against the parameters.   npm run bug -- 6

import { percent } from "../lesson_06_functions.ts";

console.log(`${percent(3)}% done`);
