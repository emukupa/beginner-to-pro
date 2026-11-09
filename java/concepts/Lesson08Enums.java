// Lesson 08: an enum is a type with a fixed set of values. A Java enum is a real class: each value
// can carry fields and the enum can have methods. A switch expression over an enum must cover
// every value, so adding one later points javac at every switch that needs updating.
// bug: a switch that forgets Status.OTHER. javac refuses to build.

import java.util.EnumMap;
import java.util.Map;

final class Lesson08Enums {
    static final String TITLE = "Enums";

    private Lesson08Enums() {}

    /** A task's status, cleaned. Each value carries its label and the mark the tracker prints. */
    enum Status {
        TODO("todo", ' '),
        DONE("done", 'x'),
        OTHER("other", ' '); // anything else ("doing", "?"): not done

        private final String label;
        private final char mark;

        Status(String label, char mark) { // runs once per value, when the enum is first used
            this.label = label;
            this.mark = mark;
        }

        String label() {
            return label;
        }

        char mark() {
            return mark;
        }

        /** "[DONE.]" -> DONE. Lesson 11's parseLine uses it on every line. */
        static Status parse(String messy) {
            String clean = Lesson04Strings.cleanStatus(messy);
            for (Status status : values()) { // values(): every Status, in the order declared
                if (status != OTHER && status.label.equals(clean)) {
                    return status;
                }
            }
            return OTHER;
        }
    }

    static String describe(Status status) {
        return switch (status) { // no default: javac checks all three are here
            case TODO -> "still to do";
            case DONE -> "finished";
            case OTHER -> "something else";
        };
    }

    static void run() {
        for (String messy : new String[] {"[done]", "[DONE.]", "[ todo ]", "[doing]"}) {
            Status status = Status.parse(messy);
            System.out.printf("%-10s -> %-5s [%c] %s%n", messy, status, status.mark(), describe(status));
        }
        System.out.println("Status.DONE.label() = " + Status.DONE.label() + ", name() = " + Status.DONE.name()
                + ", ordinal() = " + Status.DONE.ordinal());
        System.out.println("Status.valueOf(\"TODO\") = " + Status.valueOf("TODO")
                + ", and == works: " + (Status.parse("[todo]") == Status.TODO));
        // Rust's enum Status can carry the unknown text in Other(String); a Java enum value is one
        // fixed object, so it can't. A sealed interface with records (lesson 15) can.

        Map<Status, Integer> tally = new EnumMap<>(Status.class); // a map keyed by an enum, kept in declared order
        for (String messy : new String[] {"[done]", "[todo]", "[done.]", "[DONE]", "[todo]", "[ todo ]"}) {
            tally.merge(Status.parse(messy), 1, Integer::sum);
        }
        System.out.println("statuses in tasks.txt: " + tally);
    }
}
