// Lesson 05's bug: comparing a string with a number. === never converts, so this is always false
// and the "done" branch can never run.
// Caught by: tsc's comparison check (the types have no overlap).   npm run bug -- 5

function describe(status: string): string {
    if (status === 1) return "finished";
    return "still open";
}
console.log(describe("done"));
