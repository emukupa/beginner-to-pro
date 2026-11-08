// Lesson 11: errors. throw stops the function and unwinds until a catch. Anything can be thrown,
// so a caught error is `unknown` until you check it. For failures the caller should expect,
// a Result union is often clearer: the failure is part of the return type, and can't be ignored.
// Bug: using error.message without checking what was caught. strict makes caught errors unknown.

import { parseWholeNumber } from "./lesson_03_numbers.ts";

export const TITLE = "Errors";

// Your own kind of error: a name to catch by, and the file it was about.
export class TaskFileError extends Error {
    readonly path: string;

    constructor(path: string, message: string, options?: ErrorOptions) {
        super(message, options);          // options.cause keeps the original error attached
        this.name = "TaskFileError";
        this.path = path;
    }
}

// A Result is either a value or an error, and `ok` says which: a discriminated union (lesson 09).
export type Result<T, E = string> =
    | { readonly ok: true; readonly value: T }
    | { readonly ok: false; readonly error: E };

// How many top tags to show: a whole number of at least 1. Lesson 13 asks the user for it.
export function parseCount(text: string): Result<number> {
    const n = parseWholeNumber(text);
    if (n === undefined) return { ok: false, error: `${JSON.stringify(text)} isn't a whole number` };
    if (n < 1) return { ok: false, error: "need at least 1" };
    return { ok: true, value: n };
}

function topN(counts: readonly number[], n: number): readonly number[] {
    if (n < 1) throw new RangeError("n must be at least 1");
    return counts.slice(0, n);
}

export function run(): void {
    for (const n of [2, 0]) {
        try {
            console.log(`topN(n = ${n}) ->`, topN([4, 2, 1], n));
        } catch (error) {                 // error is unknown: anything could have been thrown
            if (error instanceof RangeError) console.log(`topN(n = ${n}) -> RangeError: ${error.message}`);
            else throw error;             // not ours to handle: send it on
        } finally {
            // finally runs either way: the place to close files or release anything you opened
        }
    }
    try {
        throw new TaskFileError("tasks.txt", "couldn't read tasks.txt", { cause: new Error("ENOENT") });
    } catch (error) {
        if (error instanceof TaskFileError) {
            console.log(`caught ${error.name}: ${error.message} (path ${error.path}, cause: ${String(error.cause)})`);
        }
    }
    try {
        JSON.parse("{not json");
    } catch (error) {
        console.log("JSON.parse throws:", error instanceof SyntaxError ? "SyntaxError" : "something else");
    }
    for (const text of ["3", "three", "0"]) {
        const result = parseCount(text);
        // The type won't let you reach result.value until you've checked result.ok.
        console.log(`parseCount(${JSON.stringify(text).padStart(7)}) ->`, result.ok ? `ok ${result.value}` : `error: ${result.error}`);
    }
    // throw or Result? Throw for the unexpected (a bug, a disk failing); return a Result when
    // failing is a normal answer, like a user typing "three".
}
