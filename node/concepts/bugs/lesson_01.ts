// Lesson 01's bug: a variable made and never used. Often a sign of a typo or a half-finished edit.
// Caught by: noUnusedLocals in tsconfig.json.   npm run bug -- 1

export function run(): void {
    const unused = 5;
    console.log("Hello from TypeScript");
}
