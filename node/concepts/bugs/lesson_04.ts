// Lesson 04's bug: a misspelt method. At run time it's "toLowercase is not a function", but only
// when this line runs; tsc finds it without running anything.
// Caught by: tsc's property check (it even suggests the right name).   npm run bug -- 4

const status = "DONE";
console.log(status.toLowercase());
