// Lesson 12: files, and waiting without blocking. Reading a disk or a keyboard takes time, so Node's
// file functions return a Promise: a value that arrives later. `await` pauses this function until it
// does, while the rest of the program carries on. Only an async function can await.
// Bug: using a Promise as if it were already the text. tsc asks whether you forgot to await.

import { appendFile, mkdtemp, open, readFile, rm, writeFile } from "node:fs/promises";
import { tmpdir } from "node:os";
import { basename, join } from "node:path";
import { createInterface } from "node:readline/promises";
import { parseLine } from "./lesson_08_objects.ts";
import { Task } from "./lesson_10_classes.ts";
import { type Result } from "./lesson_11_errors.ts";

export const TITLE = "Files and async/await";

// The tasks file beside this module, wherever you run it from. import.meta.dirname is the folder
// this ES module lives in.
export const TASKS = join(import.meta.dirname, "tasks.txt");

// A type guard (lesson 09) for Node's errors, which carry a code such as "ENOENT" (no such file).
function isNodeError(error: unknown): error is NodeJS.ErrnoException {
    return error instanceof Error && "code" in error;
}

// Every task in the file, read one line at a time. A missing file is an expected failure, so it
// comes back as a Result (lesson 11); anything stranger is thrown. Lesson 13 builds on this.
export async function loadTasks(path: string): Promise<Result<Task[]>> {
    let file;
    try {
        file = await open(path);
    } catch (error) {
        if (isNodeError(error) && error.code === "ENOENT") return { ok: false, error: `Couldn't find ${basename(path)}` };
        throw error;
    }
    try {
        const tasks: Task[] = [];
        for await (const line of file.readLines()) {   // for await: each line arrives when it's read
            const parsed = parseLine(line);
            if (parsed !== undefined) tasks.push(Task.from(parsed));
        }
        return { ok: true, value: tasks };
    } finally {
        await file.close();               // finally: closed whether reading worked or not
    }
}

// Asks a question and waits for the answer. When input ends without one (a pipe, or /dev/null),
// the fallback is used, so the lessons never hang waiting for a keyboard that isn't there.
export async function ask(question: string, fallback: string): Promise<string> {
    const terminal = createInterface({ input: process.stdin, output: process.stdout });
    const ended = new Promise<string>((resolve) => terminal.once("close", () => resolve(fallback)));
    try {
        return await Promise.race([terminal.question(question), ended]);   // whichever comes first
    } finally {
        terminal.close();
    }
}

export async function run(): Promise<void> {
    // Two files read at the same time: Promise.all waits for both.
    const [found, missing] = await Promise.all([loadTasks(TASKS), loadTasks(join(import.meta.dirname, "missing.txt"))]);
    if (found.ok) console.log(`loaded ${found.value.length} tasks; the first: ${found.value[0]}`);
    if (!missing.ok) console.log("missing.txt ->", missing.error);

    const folder = await mkdtemp(join(tmpdir(), "concepts-"));   // a fresh folder: nothing of yours is touched
    const scratch = join(folder, "scratch.txt");
    try {
        await writeFile(scratch, "[todo] First\n");      // write: replaces whatever was there
        await appendFile(scratch, "[todo] Second\n");    // append: adds to the end
        const text = await readFile(scratch, "utf8");    // "utf8": give back text, not bytes
        console.log("scratch.txt:", text.split("\n"), "  (the last line ends in \\n, so split leaves an empty string)");
        const bytes = await readFile(scratch);           // no encoding: a Buffer of raw bytes
        console.log("as bytes:", bytes.length, "bytes, starting", bytes.subarray(0, 6));
    } finally {
        await rm(folder, { recursive: true });
    }
    // Synchronous versions exist (readFileSync): simpler, but everything stops while the disk works.
    // Fine for a quick script; a server serving many people at once would freeze.
}
