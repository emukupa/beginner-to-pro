// Lesson 08's bug: changing a parsed line after the fact. ParsedLine's fields are readonly, so nobody
// can quietly edit a title another part of the program is relying on.
// Caught by: readonly.   npm run bug -- 8

import { parseLine } from "../lesson_08_objects.ts";

const line = parseLine("[todo] Call mom #family");
if (line !== undefined) {
    line.title = "Call dad";
    console.log(line);
}
