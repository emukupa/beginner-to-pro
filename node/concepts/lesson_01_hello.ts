// Lesson 01: a TypeScript file is JavaScript with types written on top. Node runs it directly by
// deleting the types first ("type stripping"), so the types never change what the program does:
// they are checked separately, by tsc (`npm run check`).
// Bug: an unused variable. noUnusedLocals makes tsc refuse it.

export const TITLE = "Hello";

export function run(): void {
    console.log("Hello from TypeScript");          // console.log prints and adds the newline itself
    console.log("text", 42, 2.5);                   // several values: printed with a space between
    console.log(`a template literal: ${6 * 7}`);    // backticks put values inside text
    const greeting: string = "typed";               // ": string" is the type; Node strips it, tsc checks it
    console.log("a typed name:", greeting);
    console.log("running on Node", process.versions.node.split(".")[0]);
    // The exit code: 0 unless something sets it. process.exitCode = 1 would report failure
    // without stopping the program, which is gentler than process.exit(1).
    console.log("exit code so far:", process.exitCode ?? 0);
}
