// Lesson 10: UrgentTask extends Task, so it has everything a Task has, and it can replace a method
// with its own version. @Override asks javac to check you really are replacing one. A variable of
// type Task can hold an UrgentTask, and calls go to the object's own version: that's polymorphism.
// bug: @Override on a misspelt method name. Without @Override it would quietly be a new method.

import java.util.List;

final class Lesson10Inheritance {
    static final String TITLE = "Inheritance";

    private Lesson10Inheritance() {}

    /** The tracker's urgent task: prints like a Task, with "  !!" after it. */
    static class UrgentTask extends Lesson09Classes.Task {
        UrgentTask(String title, Lesson08Enums.Status status, List<String> tags) {
            super(title, status, tags); // run Task's constructor first
        }

        @Override
        public String toString() {
            return super.toString() + "  !!"; // super.toString(): Task's version
        }
    }

    static void run() {
        List<Lesson09Classes.Task> tasks = List.of(
                new Lesson09Classes.Task("Book flights"),
                new UrgentTask("Finish quarterly report", Lesson08Enums.Status.TODO, List.of("work", "urgent")));
        for (Lesson09Classes.Task task : tasks) {
            // the same call, two behaviours: Java picks the method by what the object really is
            System.out.println(task + "   (" + task.getClass().getSimpleName() + ")");
        }

        for (Lesson09Classes.Task task : tasks) {
            // instanceof with a pattern: test the type and name the result in one go
            if (task instanceof UrgentTask urgent && !urgent.isDone()) {
                System.out.println("urgent and not done: " + urgent.title());
            }
        }

        Object anything = tasks.get(0); // every class extends Object in the end
        System.out.println("an Object variable still calls Task's toString: " + anything);
        System.out.println("UrgentTask's parent: " + UrgentTask.class.getSuperclass().getSimpleName()
                + ", and its parent: " + UrgentTask.class.getSuperclass().getSuperclass().getSimpleName());
    }
}
