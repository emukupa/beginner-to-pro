// Lesson 14: a stream runs a list through steps (filter, map, sorted, limit) and collects the
// result, the way Python's comprehensions do. Nothing runs until the last step asks for it.
// Generics let one method work on any type: topN ranks TagCounts here, and anything else later.
// bug: largest() given TagCounts, which have no natural order. The generic's bound refuses them.

import java.util.Comparator;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.function.Function;
import java.util.stream.Collectors;

final class Lesson14Streams {
    static final String TITLE = "Streams and generics";

    private Lesson14Streams() {}

    /**
     * The first n items in this order. T is any type; the comparator says how to order it. The sort
     * is stable, so items that tie stay in the order they came: tied tags stay in file order.
     */
    static <T> List<T> topN(List<T> items, Comparator<? super T> order, int n) {
        if (n < 1) {
            throw new IllegalArgumentException("n must be at least 1");
        }
        return items.stream().sorted(order).limit(n).toList();
    }

    /** The biggest item. T extends Comparable: only types that know how to compare themselves. */
    static <T extends Comparable<? super T>> T largest(List<T> items) {
        return items.stream().max(Comparator.naturalOrder()).orElseThrow();
    }

    /** The tracker's top tags: most-used first, ties in file order. */
    static List<Lesson13Collections.TagCount> rankTags(List<Lesson09Classes.Task> tasks, int n) {
        Comparator<Lesson13Collections.TagCount> byCount =
                Comparator.comparingInt(Lesson13Collections.TagCount::count).reversed();
        return topN(Lesson13Collections.countTags(tasks), byCount, n);
    }

    static void run() {
        List<Lesson09Classes.Task> tasks;
        try {
            tasks = Lesson12Exceptions.loadTasks(Lesson12Exceptions.tasksFile());
        } catch (java.io.IOException e) {
            System.out.println("Couldn't read tasks.txt: " + e);
            return;
        }

        long done = tasks.stream().filter(Lesson09Classes.Task::isDone).count();
        List<String> todo = tasks.stream().filter(t -> !t.isDone()).map(Lesson09Classes.Task::title).toList();
        System.out.println(done + " done; still to do: " + todo);
        int letters = tasks.stream().mapToInt(t -> t.title().length()).sum();
        System.out.println("letters in all titles: " + letters);
        System.out.println("tags, flattened and joined: "
                + tasks.stream().flatMap(t -> t.tags().stream()).distinct().collect(Collectors.joining(", ")));

        Map<String, Long> grouped = tasks.stream()
                .flatMap(t -> t.tags().stream())
                .collect(Collectors.groupingBy(Function.identity(), LinkedHashMap::new, Collectors.counting()));
        System.out.println("groupingBy into a LinkedHashMap: " + grouped);

        var steps = List.of("a", "b", "c").stream().peek(s -> System.out.print("[saw " + s + "] "));
        System.out.print("nothing yet... ");
        System.out.println(steps.limit(2).toList()); // the work happens now, and stops after two

        System.out.println("rankTags(3): " + rankTags(tasks, 3));
        System.out.println("topN of numbers: " + topN(List.of(5, 1, 4, 2), Comparator.reverseOrder(), 2)
                + ", of words by length: " + topN(List.of("home", "travel", "work"), Comparator.comparing(String::length), 1));
        System.out.println("largest(3, 9, 4) = " + largest(List.of(3, 9, 4)) + ", largest of words = "
                + largest(List.of("home", "work", "family")));
        try {
            topN(List.of(1), Comparator.naturalOrder(), 0);
        } catch (IllegalArgumentException e) {
            System.out.println("topN(..., 0) throws: " + e.getMessage());
        }
    }
}
