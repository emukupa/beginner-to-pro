// Lesson 02: names, values and their types. JavaScript has seven primitive types; TypeScript
// describes them, works most of them out by itself, and adds `unknown` for "check before use".
// Bug: using an unknown value without checking what it is. strict mode stops it.

export const TITLE = "Values and types";

export function run(): void {
    const title = "Buy groceries";       // const: this name always means this value
    let count = 3;                        // let: the name can be given a new value
    count += 1;
    console.log("const and let:", title, count);
    // No annotation needed: tsc infers string and number from the values.
    const samples = ["text", 42, true, null, undefined, 10n, Symbol("id")];
    console.log("typeof:", samples.map((value) => typeof value).join(" "));
    console.log("typeof null is", typeof null, "(an old mistake in JavaScript, kept forever)");
    console.log("null vs undefined:", "null means 'no value on purpose', undefined means 'never set'");
    const zero: unknown = 0, digit: unknown = "0", empty: unknown = "";   // unknown: so tsc lets us compare
    console.log('== converts first:  0 == "0" ->', zero == digit, '  "" == 0 ->', empty == zero);
    console.log('=== does not:       0 === "0" ->', zero === digit, '  so always use ===');

    // any switches the checker off: tsc lets you do anything, and you find out at run time.
    const loose: any = JSON.parse('{"title": "Call mom"}');   // JSON.parse gives back any
    console.log("any lets you write loose.titel ->", loose.titel);   // typo, no warning, undefined
    // unknown is the safe version: you must check what it is before using it.
    const data: unknown = JSON.parse('{"title": "Call mom"}');
    if (typeof data === "object" && data !== null && "title" in data && typeof data.title === "string") {
        console.log("unknown, after checking ->", data.title.toUpperCase());
    }
}
