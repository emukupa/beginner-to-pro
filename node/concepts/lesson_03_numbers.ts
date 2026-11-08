// Lesson 03: JavaScript has one number type, a 64-bit float, for whole numbers and fractions alike.
// Math.round sends halves up; the tracker needs halves to go to the even number, so we write it.
// Bug: passing text where a number belongs. tsc checks the argument's type.

export const TITLE = "Numbers";

// Round to the nearest whole number; a half goes to the even neighbour (2.5 -> 2, 3.5 -> 4),
// like Python's round(). Math.round(2.5) is 3 and Math.round(-2.5) is -2: halves always go up.
export function roundHalfEven(x: number): number {
    const down = Math.floor(x);
    const rest = x - down;
    if (rest < 0.5) return down;
    if (rest > 0.5) return down + 1;
    return down % 2 === 0 ? down : down + 1;     // exactly half: pick the even one
}

// A whole number from text, or undefined. Number("") is 0 and parseInt("12abc") is 12,
// so neither is strict enough on its own: we check the text first, then convert it.
export function parseWholeNumber(text: string): number | undefined {
    const trimmed = text.trim();
    if (!/^[+-]?\d+$/.test(trimmed)) return undefined;
    const n = Number(trimmed);
    return Number.isSafeInteger(n) ? n : undefined;
}

export function run(): void {
    console.log("7 / 2 =", 7 / 2, "  Math.trunc(7 / 2) =", Math.trunc(7 / 2), "  7 % 2 =", 7 % 2, "  2 ** 10 =", 2 ** 10);
    console.log("0.1 + 0.2 =", 0.1 + 0.2);      // binary fractions: close, not exact
    console.log("Number.isInteger(4.0) ->", Number.isInteger(4.0), "  (there is no separate int type)");
    console.log("largest safe whole number:", Number.MAX_SAFE_INTEGER, "  beyond it, bigint:", 2n ** 64n);
    const nan = 0 / 0;                    // "not a number", and not equal to anything, itself included
    console.log("1 / 0 =", 1 / 0, "  0 / 0 =", nan, "  nan === nan ->", nan === nan, "  Number.isNaN(nan) ->", Number.isNaN(nan));
    for (const x of [0.5, 1.5, 2.5, 3.5, -2.5]) {
        console.log(`${String(x).padStart(4)}: Math.round -> ${String(Math.round(x)).padStart(2)}   roundHalfEven -> ${roundHalfEven(x)}`);
    }
    console.log("(2.5).toFixed(0) ->", (2.5).toFixed(0), "  toFixed sends halves up too");
    for (const text of ["5", "five", "-3", "", "12abc"]) {
        console.log(`${JSON.stringify(text).padStart(7)} -> parseWholeNumber: ${parseWholeNumber(text)},  Number: ${Number(text)},  parseInt: ${parseInt(text)}`);
    }
}
