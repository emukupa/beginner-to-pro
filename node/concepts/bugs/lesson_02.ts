// Lesson 02's bug: using an unknown value as if we knew its shape. JSON from a file could be anything.
// Caught by: strict mode; unknown must be narrowed before use.   npm run bug -- 2

const data: unknown = JSON.parse("[1, 2, 3]");
console.log(data.title);                  // the JSON is an array: there is no title
