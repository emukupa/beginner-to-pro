// Lesson 13: a Map finds a value by its key; a Set keeps each value once. HashMap and HashSet keep
// no order you can rely on. LinkedHashMap remembers the order keys were first put in, which is
// exactly what the tracker's ties need. A record is a class that just holds values: javac writes
// its constructor, accessors, equals, hashCode and toString for you.
// bug: an int added to a List<String>. Generics let javac check what goes into a collection.

import java.util.ArrayList;
import java.util.HashMap;
import java.util.HashSet;
import java.util.LinkedHashMap;
import java.util.LinkedHashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.TreeSet;

final class Lesson13Collections {
    static final String TITLE = "Maps, sets and records";

    private Lesson13Collections() {}

    /** One row of the tag chart. The part in brackets is the whole class. */
    record TagCount(String tag, int count) {
        TagCount { // a compact constructor: checks run before the fields are set
            if (count < 1) {
                throw new IllegalArgumentException("a tag is counted at least once");
            }
        }
    }

    /** Each tag and how many tasks have it, in the order tags first appear in the file. */
    static List<TagCount> countTags(List<Lesson09Classes.Task> tasks) {
        Map<String, Integer> counts = new LinkedHashMap<>(); // keeps first-seen order
        for (Lesson09Classes.Task task : tasks) {
            for (String tag : task.tags()) {
                counts.merge(tag, 1, Integer::sum); // missing: put 1; there: add 1 to what's there
            }
        }
        List<TagCount> result = new ArrayList<>();
        for (Map.Entry<String, Integer> entry : counts.entrySet()) {
            result.add(new TagCount(entry.getKey(), entry.getValue()));
        }
        return result;
    }

    static void run() {
        List<Lesson09Classes.Task> tasks;
        try {
            tasks = Lesson12Exceptions.loadTasks(Lesson12Exceptions.tasksFile());
        } catch (java.io.IOException e) {
            System.out.println("Couldn't read tasks.txt: " + e);
            return;
        }

        Map<String, Integer> hashed = new HashMap<>();
        Map<String, Integer> linked = new LinkedHashMap<>();
        for (Lesson09Classes.Task task : tasks) {
            for (String tag : task.tags()) {
                hashed.merge(tag, 1, Integer::sum);
                linked.merge(tag, 1, Integer::sum);
            }
        }
        System.out.println("HashMap:       " + hashed + "  (its own order)");
        System.out.println("LinkedHashMap: " + linked + "  (file order)");
        System.out.println("get(\"work\") = " + linked.get("work") + ", containsKey(\"gym\") = " + linked.containsKey("gym")
                + ", getOrDefault(\"gym\", 0) = " + linked.getOrDefault("gym", 0));

        List<String> all = new ArrayList<>();
        tasks.forEach(task -> all.addAll(task.tags()));
        System.out.println("every tag: " + all);
        Set<String> unique = new HashSet<>(all);
        System.out.println("HashSet " + unique.size() + " " + unique + ", LinkedHashSet " + new LinkedHashSet<>(all)
                + ", TreeSet (sorted) " + new TreeSet<>(all));

        List<TagCount> counts = countTags(tasks);
        System.out.println("countTags: " + counts);
        TagCount first = counts.get(0);
        System.out.println("first.tag() = " + first.tag() + ", first.count() = " + first.count()
                + "  (first in the file; lesson 14 ranks them)");
        System.out.println("equals a new TagCount(\"home\", 2): " + first.equals(new TagCount("home", 2))
                + "  (a record compares its fields)");
        try {
            new TagCount("gym", 0);
        } catch (IllegalArgumentException e) {
            System.out.println("new TagCount(\"gym\", 0) throws: " + e.getMessage());
        }
    }
}
