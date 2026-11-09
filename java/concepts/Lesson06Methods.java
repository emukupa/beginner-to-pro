// Lesson 06: a method takes typed parameters and returns a typed result. Java always passes a
// copy: of the number, or of the reference, so a method can change the object you hand it but
// never your variable. Lambdas are small unnamed methods you can pass around.
// bug: a lambda changing a local variable. Lambdas may only read locals that never change.

import java.util.ArrayList;
import java.util.Comparator;
import java.util.List;
import java.util.function.Function;
import java.util.function.Predicate;

final class Lesson06Methods {
    static final String TITLE = "Methods and lambdas";

    private Lesson06Methods() {}

    /** done out of total, as a percent. 0 when there are no tasks, instead of dividing by zero. */
    static double percent(int done, int total) {
        return total == 0 ? 0 : done * 100.0 / total;
    }

    /** The tracker's bar: the biggest count gets width blocks, the rest in proportion, rounded like Python. */
    static String bar(int count, int biggest, int width) {
        return "█".repeat((int) Lesson03Numbers.pythonRound((double) count / biggest * width));
    }

    // Overloading: the same name with different parameters. javac picks by the argument types.
    static String describe(int count) {
        return count + (count == 1 ? " task" : " tasks");
    }

    static String describe(String title) {
        return "\"" + title + "\"";
    }

    // Varargs: String... lets a caller pass any number of Strings; inside, tags is an array.
    static int countAll(String... tags) {
        return tags.length;
    }

    static void reassign(int number, List<String> list) {
        number = 99;          // changes only this method's copy
        list.add("added");    // the copied reference still points at the caller's list
    }

    static void run() {
        System.out.printf("percent(3, 6) = %.1f, percent(0, 0) = %.1f%n", percent(3, 6), percent(0, 0));
        System.out.println("bar(2, 3, 20) = " + bar(2, 3, 20) + " (13.33 rounds to 13)");
        System.out.println(describe(1) + ", " + describe(6) + ", " + describe("Call mom"));
        System.out.println("countAll() = " + countAll() + ", countAll(\"a\", \"b\") = " + countAll("a", "b"));

        int number = 1;
        List<String> list = new ArrayList<>();
        reassign(number, list);
        System.out.println("after reassign: number = " + number + ", list = " + list);

        // A lambda: parameters -> result. Its type is an interface with one method, like Predicate.
        Predicate<String> isTag = word -> word.startsWith("#");
        Function<String, String> shout = String::toUpperCase; // a method reference: an existing method as a lambda
        System.out.println("isTag(\"#work\") = " + isTag.test("#work") + ", shout(\"done\") = " + shout.apply("done"));

        String marker = "#"; // never changes, so a lambda may read it
        Predicate<String> hasMarker = word -> word.startsWith(marker);
        List<String> words = new ArrayList<>(List.of("Call", "#family", "mom", "#home"));
        words.removeIf(hasMarker.negate());
        System.out.println("only tags: " + words);

        List<String> titles = new ArrayList<>(List.of("Call mom", "Buy groceries", "Fix login bug"));
        titles.sort(Comparator.comparing(String::length)); // a Comparator is a lambda too
        System.out.println("sorted by length: " + titles);
    }
}
