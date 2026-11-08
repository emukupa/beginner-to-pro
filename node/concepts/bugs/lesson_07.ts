// Lesson 07's bug: assuming an array has a first item. With no tasks, tags[0] is undefined, and
// calling a method on it throws a TypeError.
// Caught by: noUncheckedIndexedAccess (tags[0] is string | undefined).   npm run bug -- 7

const tags: string[] = [];
const first = tags[0];
console.log(first.toUpperCase());
