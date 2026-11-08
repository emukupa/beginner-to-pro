// Lesson 10's bug: replacing a method without saying so. If Task's toString were renamed, this one
// would silently become a new method instead of a replacement; override makes the intent checkable.
// Caught by: noImplicitOverride.   npm run bug -- 10

import { Task } from "../lesson_10_classes.ts";

class UrgentTask extends Task {
    toString(): string {
        return `${super.toString()}  !!`;
    }
}
console.log(String(new UrgentTask("Fix the build")));
