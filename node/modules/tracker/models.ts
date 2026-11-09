// What a task is. Every other module imports from this one; it imports none of ours.
//
// Nothing in a module is visible outside it unless it says `export`.

export class Task {
  readonly title: string;
  readonly status: string;
  readonly tags: readonly string[];

  constructor(title: string, status: string, tags: readonly string[]) {
    this.title = title;
    this.status = status;
    this.tags = tags;
  }

  isDone(): boolean {
    return this.status === "done";
  }

  toString(): string {
    return `[${this.isDone() ? "x" : " "}] ${this.title}`;
  }
}

// Python's UrgentTask(Task): TypeScript has inheritance, and `override` is required.
export class UrgentTask extends Task {
  override toString(): string {
    return `${super.toString()}  !!`;
  }
}
