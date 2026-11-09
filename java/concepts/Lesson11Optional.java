// Lesson 11: any object reference can be null, and calling a method on null throws a
// NullPointerException. Optional<T> is a box that holds one value or none, so a method can say
// "maybe nothing" in its type, and the caller has to open the box to get at the value.
// bug: calling a method on what Map.get returned for a missing key: null. It builds, then throws.

import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.Optional;

final class Lesson11Optional {
    static final String TITLE = "Null and Optional";

    private Lesson11Optional() {}

    /**
     * "[done.] Call mom #family" -> a Task, or empty for a line that isn't one. The same steps as
     * the Python tracker's parse_line; a task tagged urgent becomes an UrgentTask.
     */
    static Optional<Lesson09Classes.Task> parseLine(String line) {
        String text = line.strip();
        if (text.isEmpty() || !text.startsWith("[")) {
            return Optional.empty();
        }
        int close = text.indexOf(']');
        String status = close < 0 ? text : text.substring(0, close);       // Python's partition("]")
        String rest = close < 0 ? "" : text.substring(close + 1).strip();
        List<String> tags = new ArrayList<>();
        List<String> words = new ArrayList<>();
        for (String word : rest.isEmpty() ? new String[0] : rest.split("\\s+")) {
            if (word.startsWith("#")) {
                String tag = Lesson04Strings.stripChars(word.replaceFirst("^#+", ""), ".,");
                tags.add(tag.toLowerCase(java.util.Locale.ROOT));
            } else {
                words.add(word);
            }
        }
        String title = String.join(" ", words);
        Lesson08Enums.Status parsed = Lesson08Enums.Status.parse(status);
        return Optional.of(tags.contains("urgent")
                ? new Lesson10Inheritance.UrgentTask(title, parsed, tags)
                : new Lesson09Classes.Task(title, parsed, tags));
    }

    static void run() {
        Map<String, String> notes = Map.of("Call mom", "Sunday");
        String note = notes.get("Call dad"); // no such key: get returns null, not an error
        System.out.println("notes.get(\"Call dad\") = " + note);
        System.out.println("getOrDefault: " + notes.getOrDefault("Call dad", "no note"));

        Optional<String> maybe = Optional.ofNullable(note); // null becomes an empty box
        System.out.println("maybe.isPresent() = " + maybe.isPresent() + ", orElse: " + maybe.orElse("no note")
                + ", map(length): " + Optional.of("Sunday").map(String::length).orElse(0));

        for (String line : new String[] {"[done.] Call mom #family", "[ todo ] Review pull request #work.",
                "", "just some words", "[todo] Finish quarterly report #work #urgent"}) {
            Optional<Lesson09Classes.Task> task = parseLine(line);
            task.ifPresentOrElse( // open the box: one lambda if a Task is in it, the other if not
                    t -> System.out.printf("%-40s -> %s %s%n", "\"" + line + "\"", t, t.tags()),
                    () -> System.out.printf("%-40s -> not a task%n", "\"" + line + "\""));
        }

        String title = parseLine("[DONE] Fix login bug #work")
                .filter(Lesson09Classes.Task::isDone)
                .map(Lesson09Classes.Task::title)
                .orElse("(none)");
        System.out.println("done title, through filter and map: " + title);
        // Optional is for results. A field, a parameter or a list never needs one: a list can just be empty.
    }
}
