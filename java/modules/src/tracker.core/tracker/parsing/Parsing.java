package tracker.parsing;

import java.util.ArrayList;
import java.util.List;
import java.util.Locale;
import java.util.Optional;
import tracker.models.Task;
import tracker.models.UrgentTask;
import tracker.text.Text;

// Turning one line of text into a task. No files, no printing: text in, a Task out.
public final class Parsing {
    private Parsing() {}

    public static final String TAG_MARKER = "#";

    // No modifier: package-private, so only classes in tracker.parsing can call it.
    static String statusOf(String raw) {
        return raw.replaceAll("^[\\[\\] .]+|[\\[\\] .]+$", "").toLowerCase(Locale.ROOT);
    }

    // "[done.] Call mom #family" -> a Task, or an empty Optional if the line isn't a task.
    public static Optional<Task> parseLine(String line) {
        String s = Text.strip(line);
        if (!s.startsWith("[")) return Optional.empty();
        int close = s.indexOf(']'); // Python's partition("]")
        String raw = close < 0 ? s : s.substring(0, close);
        String rest = close < 0 ? "" : s.substring(close + 1);
        List<String> tags = new ArrayList<>();
        List<String> title = new ArrayList<>();
        for (String word : Text.words(rest)) {
            if (word.startsWith(TAG_MARKER)) {
                tags.add(word.replaceAll("^#+", "").replaceAll("^[.,]+|[.,]+$", "").toLowerCase(Locale.ROOT));
            } else {
                title.add(word);
            }
        }
        String joined = String.join(" ", title);
        String status = statusOf(raw);
        return Optional.of(tags.contains("urgent") ? new UrgentTask(joined, status, tags) : new Task(joined, status, tags));
    }
}
