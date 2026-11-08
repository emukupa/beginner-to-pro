// Lesson 14's bug: a misspelt key in a table of column widths. The real "title" width is missing,
// and the typo would sit there unused.
// Caught by: satisfies (only the type's keys are allowed, and all of them are needed).   npm run bug -- 14

type Column = "status" | "title";

const COLUMNS = { status: 7, titel: 25 } satisfies Record<Column, number>;
console.log(COLUMNS);
