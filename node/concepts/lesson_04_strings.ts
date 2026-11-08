// Lesson 04: strings. Text never changes in place; every method hands back a new string.
// And .length counts UTF-16 code units, not characters: an emoji is 2. Real data is messy.
// Bug: a misspelt method, toLowercase. tsc knows every method a string has.

export const TITLE = "Strings";

// "[ DONE. ]" -> "done". Lesson 08's parser uses it. JavaScript's trim() only removes spaces,
// so stripping brackets and dots too needs a regular expression: ^[...]+ at the start, [...]+$ at the end.
export function cleanStatus(text: string): string {
    return text.replace(/^[\[\] .]+|[\[\] .]+$/g, "").toLowerCase();
}

// How many characters a person sees: code points, not code units. [...text] splits by code point.
// Lesson 13 pads chart labels with it, as the contract says (by characters, not bytes).
export function textWidth(text: string): number {
    return [...text].length;
}

export function run(): void {
    const done: string = "done";          // ": string", or tsc sees two different literals and says they can never match
    console.log('"done" === "done." ->', done === "done.", '   "done" === "DONE" ->', done === "DONE");
    console.log('"  done  ".trim()  ->', JSON.stringify("  done  ".trim()));
    console.log('"Call mom #family".split(" ") ->', "Call mom #family".split(" "));
    const line = "[done.] Call mom";
    const end = line.indexOf("]");
    console.log(`indexOf("]") -> ${end}, slice(0, end + 1) -> ${line.slice(0, end + 1)}, slice(end + 1) -> "${line.slice(end + 1)}"`);
    for (const messy of ["[done]", "[done.]", "[DONE]", "[ todo ]"]) {
        console.log(`cleanStatus(${JSON.stringify(messy).padStart(10)}) -> ${JSON.stringify(cleanStatus(messy))}`);
    }
    console.log(`aligned: |${"work".padEnd(8)}|${"home".padStart(8)}|   repeated: ${"█".repeat(5)}`);

    // Three ways to measure text, three answers. JavaScript strings are UTF-16 inside;
    // files are UTF-8 bytes; people count characters. padEnd counts code units too: see the rocket's row.
    for (const text of ["work", "█", "café", "🚀"]) {
        console.log(`${text.padEnd(5)} .length ${text.length}   code points ${textWidth(text)}   UTF-8 bytes ${Buffer.byteLength(text, "utf8")}`);
    }
    const rocket = "🚀";
    console.log("rocket[0] is half a character:", JSON.stringify(rocket[0]), "  codePointAt(0):", rocket.codePointAt(0)?.toString(16));

    const status = "DONE";
    status.toLowerCase();                 // the result is thrown away: strings never change
    console.log("after status.toLowerCase() without saving it:", status);
}
