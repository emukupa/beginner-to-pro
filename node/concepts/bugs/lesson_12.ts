// Lesson 12's bug: a forgotten await. readFile gives back a Promise of the text, not the text,
// and a Promise has no split method.
// Caught by: tsc's property check, which asks "Did you forget to use 'await'?".   npm run bug -- 12

import { readFile } from "node:fs/promises";
import { TASKS } from "../lesson_12_files.ts";

const text = readFile(TASKS, "utf8");
console.log(text.split("\n").length, "lines");
