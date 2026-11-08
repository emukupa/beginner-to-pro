// A TypeScript enum, kept apart from the lessons because Node can't run it by stripping types:
// an enum isn't only a type, it makes a real JavaScript object. `node concepts/extras/status_enum.ts` fails
// with ERR_UNSUPPORTED_TYPESCRIPT_SYNTAX; `npm run enum` runs it with --experimental-transform-types,
// which rewrites the enum into JavaScript first. Lesson 09's union does the same job with neither.
// Type-checked by its own tsconfig.json here, the one place erasableSyntaxOnly is off.

enum Status {                             // a numeric enum: Todo is 0, Done is 1
    Todo,
    Done,
}

enum Label {                              // a string enum: each member names its own value
    Todo = "todo",
    Done = "done",
}

function describe(status: Status): string {
    return status === Status.Done ? "finished" : "still open";
}

console.log("Status.Done ->", Status.Done, "  describe(Status.Done) ->", describe(Status.Done));
// A numeric enum also maps backwards, so its object holds twice as many keys as members.
console.log("Status[1] ->", Status[1], "  Object.keys(Status) ->", Object.keys(Status));
console.log("Label.Done ->", Label.Done);
// The file says "done", a string. A string enum won't accept it without a cast, even though
// Label.Done is "done": enums are compared by name, not value. The union "done" | "todo" just takes it.
const fromFile = "done";
console.log('"done" as Label === Label.Done ->', (fromFile as Label) === Label.Done);
