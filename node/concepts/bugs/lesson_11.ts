// Lesson 11's bug: assuming whatever was caught is an Error. Anything can be thrown (here, a string),
// and a string has no .message.
// Caught by: strict mode (useUnknownInCatchVariables): a caught error is unknown.   npm run bug -- 11

try {
    throw "tasks.txt is missing";
} catch (error) {
    console.log(error.message.toUpperCase());
}
