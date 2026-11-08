// Lesson 03's bug: text where a number belongs. JavaScript would happily try "2.5" - Math.floor("2.5").
// Caught by: tsc's argument type check.   npm run bug -- 3

import { roundHalfEven } from "../lesson_03_numbers.ts";

const typed = "2.5";                      // what a user types is always text
console.log(roundHalfEven(typed));
