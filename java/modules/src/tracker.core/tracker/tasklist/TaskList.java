package tracker.tasklist;

import java.util.Comparator;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.Optional;
import tracker.models.TagCount;
import tracker.models.Task;
import tracker.parsing.Parsing;
import tracker.text.Text;

// Working with the list: adding, counting, ranking, summing up. No files, no printing.
public final class TaskList {
    private TaskList() {}

    public static final int DEFAULT_TOP = 3;

    // Parses each title as a new "[todo]" task and adds it. Returns how many were added.
    public static int addTasks(List<Task> tasks, List<String> titles) {
        int before = tasks.size();
        titles.forEach(title -> Parsing.parseLine("[todo] " + title).ifPresent(tasks::add));
        return tasks.size() - before;
    }

    // The first task whose title matches, ignoring case and extra spaces; empty if there isn't one.
    public static Optional<Task> findTask(List<Task> tasks, String title) {
        String wanted = String.join(" ", Text.words(title)).toLowerCase(java.util.Locale.ROOT);
        return tasks.stream().filter(t -> t.title.toLowerCase(java.util.Locale.ROOT).equals(wanted)).findFirst();
    }

    // A LinkedHashMap keeps the order keys were first put in, so first-seen order comes free.
    public static Map<String, Integer> countTags(List<Task> tasks, boolean includeDone) {
        Map<String, Integer> counts = new LinkedHashMap<>();
        for (Task task : tasks) {
            if (!includeDone && task.isDone()) continue;
            for (String tag : task.tags) counts.merge(tag, 1, Integer::sum);
        }
        return counts;
    }

    // The n items with the biggest key, biggest first, for any type T. Stable, so ties keep order.
    public static <T> List<T> topN(List<T> items, int n, Comparator<T> byKey) {
        return items.stream().sorted(byKey.reversed()).limit(n).toList();
    }

    public static List<TagCount> topTags(List<Task> tasks, int n, boolean includeDone) {
        if (n < 1) throw new IllegalArgumentException("n must be at least 1"); // Python's ValueError
        List<TagCount> pairs = countTags(tasks, includeDone).entrySet().stream()
                .map(e -> new TagCount(e.getKey(), e.getValue()))
                .toList();
        return topN(pairs, n, Comparator.comparingInt(TagCount::count));
    }

    // The numbers on the summary line.
    public record Summary(int total, long done, long percent, int tags) {}

    public static Summary summarize(List<Task> tasks) {
        long done = tasks.stream().filter(Task::isDone).count();
        double percent = tasks.isEmpty() ? 0 : (double) done / tasks.size() * 100;
        // Math.rint rounds halves to the even neighbour, like Python's round().
        return new Summary(tasks.size(), done, (long) Math.rint(percent), countTags(tasks, true).size());
    }
}
