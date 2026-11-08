// TypeScript concepts, one lesson per file. Each lesson is an ES module that exports a TITLE and a
// run function; this file imports them all, keeps them in a table, and runs the ones you ask for.
//
//   node concepts/main.ts        every lesson        (npm run concepts)
//   node concepts/main.ts 7 9    just lessons 7 and 9
//   npm run check                tsc type-checks every lesson; Node itself never does
//   npm run bug -- 7             type-check lesson 7's deliberate mistake, to watch tsc catch it

import * as lesson01 from "./lesson_01_hello.ts";
import * as lesson02 from "./lesson_02_values.ts";
import * as lesson03 from "./lesson_03_numbers.ts";
import * as lesson04 from "./lesson_04_strings.ts";
import * as lesson05 from "./lesson_05_control.ts";
import * as lesson06 from "./lesson_06_functions.ts";
import * as lesson07 from "./lesson_07_collections.ts";
import * as lesson08 from "./lesson_08_objects.ts";
import * as lesson09 from "./lesson_09_unions.ts";
import * as lesson10 from "./lesson_10_classes.ts";
import * as lesson11 from "./lesson_11_errors.ts";
import * as lesson12 from "./lesson_12_files.ts";
import * as lesson13 from "./lesson_13_generics.ts";
import * as lesson14 from "./lesson_14_beyond.ts";
import { parseWholeNumber } from "./lesson_03_numbers.ts";

// What every lesson module offers. Some run functions are async, so run may return a Promise.
interface Lesson {
    readonly TITLE: string;
    run(): void | Promise<void>;
}

const LESSONS: readonly Lesson[] = [
    lesson01, lesson02, lesson03, lesson04, lesson05, lesson06, lesson07,
    lesson08, lesson09, lesson10, lesson11, lesson12, lesson13, lesson14,
];

// process.argv is [node, this file, ...what you typed]: the lesson numbers start at index 2.
const asked = process.argv.slice(2);
const chosen = asked.length === 0 ? LESSONS.map((_, i) => i + 1) : asked.map((text) => parseWholeNumber(text) ?? 0);

for (const [i, number] of chosen.entries()) {
    const lesson = LESSONS[number - 1];   // may be undefined: noUncheckedIndexedAccess makes us check
    if (lesson === undefined) {
        console.error(`No lesson ${asked[i]}: pick 1 to ${LESSONS.length}`);
        process.exitCode = 1;
        break;
    }
    console.log(`\n=== ${String(number).padStart(2, "0")} ${lesson.TITLE} ===`);
    await lesson.run();                   // top-level await: an ES module can await outside a function
}
