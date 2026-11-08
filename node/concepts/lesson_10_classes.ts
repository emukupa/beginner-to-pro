// Lesson 10: classes. A class bundles data with the methods that use it; `extends` makes a new
// class from an old one, and `override` says, out loud, which method you're replacing.
// Bug: replacing a method without writing override. noImplicitOverride makes tsc ask for it.

import { type ParsedLine } from "./lesson_08_objects.ts";
import { toStatus, type Status } from "./lesson_09_unions.ts";

export const TITLE = "Classes and inheritance";

// What any printable thing must offer. A class that `implements` it promises to.
interface Printable {
    toString(): string;
}

export class Task implements Printable {
    // Fields are declared, then set in the constructor. TypeScript's shortcut,
    // constructor(readonly title: string), isn't erasable syntax, so Node can't strip it.
    readonly title: string;
    readonly tags: readonly string[];
    #status: Status;                      // # makes it private at run time too, not only to tsc

    constructor(title: string, status: Status = "todo", tags: readonly string[] = []) {
        this.title = title;
        this.#status = status;
        this.tags = tags;
    }

    get status(): Status {                // a getter: read like a field, but nobody can assign it
        return this.#status;
    }

    isDone(): boolean {
        return this.#status === "done";
    }

    markDone(): void {
        this.#status = "done";
    }

    toString(): string {
        return `[${this.isDone() ? "x" : " "}] ${this.title}`;
    }

    // A static method belongs to the class, not to one task: a second way to make a Task.
    static from(line: ParsedLine): Task {
        const Kind = line.tags.includes("urgent") ? UrgentTask : Task;   // classes are values too
        return new Kind(line.title, toStatus(line.status), line.tags);
    }
}

export class UrgentTask extends Task {    // inherits everything from Task...
    override toString(): string {         // ...and replaces one thing
        return `${super.toString()}  !!`;
    }
}

export function run(): void {
    const task = new Task("Buy groceries", "todo", ["home"]);
    console.log(String(task), "  status:", task.status, "  isDone:", task.isDone());
    task.markDone();
    console.log(String(task), "  after markDone(); its status can only change through a method");
    const lines: ParsedLine[] = [
        { status: "todo", title: "Finish quarterly report", tags: ["work", "urgent"] },
        { status: "done", title: "Fix login bug", tags: ["work"] },
    ];
    for (const line of lines.map(Task.from)) {
        const kind = line instanceof UrgentTask ? "UrgentTask" : "Task";   // instanceof checks the class
        console.log(`${kind.padEnd(10)} ${line}`);   // ${} calls toString(), the overridden one for UrgentTask
    }
    const urgent = new UrgentTask("Fix the build");
    console.log("an UrgentTask is a Task too:", urgent instanceof Task);
    console.log("the private field is hidden even from JavaScript:", Object.keys(task));
}
