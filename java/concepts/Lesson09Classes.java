// Lesson 09: a class bundles data (fields) with the methods that work on it. private fields can
// only be touched by the class's own code, so a Task can promise its title is never null and its
// tag list never changes. A constructor runs once, when new makes the object.
// bug: changing a private field from outside the class. javac refuses.

import java.util.List;
import java.util.Objects;

final class Lesson09Classes {
    static final String TITLE = "Classes";

    private Lesson09Classes() {}

    /** One line of the tasks file. Not final: lesson 10's UrgentTask extends it. */
    static class Task {
        private static int made = 0; // static: one counter shared by every Task, not one each

        private final String title;  // final fields: set in the constructor, then never again
        private final Lesson08Enums.Status status;
        private final List<String> tags;

        Task(String title, Lesson08Enums.Status status, List<String> tags) {
            this.title = Objects.requireNonNull(title); // this.title is the field, title the parameter
            this.status = status;
            this.tags = List.copyOf(tags); // our own copy, which nobody can change
            made++;
        }

        Task(String title) { // a second constructor, for a plain todo with no tags
            this(title, Lesson08Enums.Status.TODO, List.of());
        }

        String title() {
            return title;
        }

        Lesson08Enums.Status status() {
            return status;
        }

        List<String> tags() {
            return tags;
        }

        boolean isDone() {
            return status == Lesson08Enums.Status.DONE;
        }

        static int made() {
            return made;
        }

        // Every class has a toString (from Object, lesson 10); this one replaces it. println calls it.
        @Override
        public String toString() {
            return "[" + status.mark() + "] " + title;
        }
    }

    static void run() {
        Task call = new Task("Call mom", Lesson08Enums.Status.DONE, List.of("family"));
        Task book = new Task("Book flights");
        System.out.println(call + " done? " + call.isDone() + ", tags " + call.tags());
        System.out.println(book + " done? " + book.isDone() + ", status " + book.status());
        System.out.println("Tasks made so far: " + Task.made());

        Task same = call; // a variable holds a reference: same and call are one object
        Task twin = new Task("Call mom", Lesson08Enums.Status.DONE, List.of("family"));
        System.out.println("same == call: " + (same == call) + ", twin == call: " + (twin == call)
                + ", twin.equals(call): " + twin.equals(call));
        // equals, unless a class replaces it, means ==. A record (lesson 13) compares fields for you.

        try {
            call.tags().add("home");
        } catch (UnsupportedOperationException e) {
            System.out.println("tags().add throws: the Task's list can't be changed from outside");
        }
    }
}
