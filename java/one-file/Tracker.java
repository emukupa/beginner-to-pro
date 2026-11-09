// The task tracker in one Java file. Same prompts, summary and chart as the Python version, byte
// for byte: contract/run.sh checks every one. Java runs a single source file directly, so there's
// no build step:
//
//   java Tracker.java                                       run it on tasks.txt here
//   ../../contract/run.sh java "$PWD/Tracker.java"          the contract
//
// Read top to bottom: what a task is, parsing a line, the file, counting and ranking, the chart,
// then main, the only part that talks to the user.

import java.io.ByteArrayOutputStream;
import java.io.FileDescriptor;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.PrintStream;
import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.nio.file.NoSuchFileException;
import java.nio.file.Path;
import java.nio.file.StandardOpenOption;
import java.util.ArrayList;
import java.util.Comparator;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Locale;
import java.util.Map;
import java.util.Optional;
import java.util.regex.Pattern;

public class Tracker {

    static final int CHART_WIDTH = 20; // the longest bar, in characters
    static final int DEFAULT_TOP = 3; // top tags shown when the answer is empty or invalid
    static final String TAG_MARKER = "#"; // marks a word as a tag: "#work"

    // UTF-8 for the bars whatever the system's locale says, with "\n" line endings.
    static final PrintStream out = new PrintStream(new FileOutputStream(FileDescriptor.out), true, StandardCharsets.UTF_8);
    static final PrintStream err = new PrintStream(new FileOutputStream(FileDescriptor.err), true, StandardCharsets.UTF_8);

    // ---- What a task is ---------------------------------------------------------------------

    // A class, as in Python. final fields are set once, in the constructor, and never again.
    static class Task {
        final String title;
        final String status;
        final List<String> tags;

        Task(String title, String status, List<String> tags) {
            this.title = title;
            this.status = status;
            this.tags = List.copyOf(tags); // an unmodifiable copy: nobody can add to it later
        }

        boolean isDone() {
            return status.equals("done");
        }

        @Override
        public String toString() {
            return "[" + (isDone() ? "x" : " ") + "] " + title;
        }
    }

    // Java has inheritance, so Python's UrgentTask(Task) stays a subclass. @Override asks the
    // compiler to check that toString really replaces a method.
    static class UrgentTask extends Task {
        UrgentTask(String title, String status, List<String> tags) {
            super(title, status, tags);
        }

        @Override
        public String toString() {
            return super.toString() + "  !!";
        }
    }

    // A record: a tag and a count, with equals, hashCode and toString written for it.
    record TagCount(String tag, int count) {}

    // ---- Python's text rules ----------------------------------------------------------------

    // Exactly what Python's str.split() and str.strip() treat as space. Java's own strip() and
    // Character.isWhitespace are close, but not the same set.
    static final String SPACE = "\\t\\n\\u000B\\f\\r\\u001C\\u001D\\u001E\\u001F \\u0085\\u00A0\\u1680\\u2000-\\u200A\\u2028\\u2029\\u202F\\u205F\\u3000";
    static final Pattern EDGE_SPACE = Pattern.compile("^[" + SPACE + "]+|[" + SPACE + "]+$");
    static final Pattern RUN_OF_SPACE = Pattern.compile("[" + SPACE + "]+");

    static String strip(String s) {
        return EDGE_SPACE.matcher(s).replaceAll("");
    }

    static List<String> words(String s) {
        String stripped = strip(s);
        return stripped.isEmpty() ? List.of() : List.of(RUN_OF_SPACE.split(stripped));
    }

    // Width in code points, as Python's len() counts: "█" is one, an emoji is one.
    static int width(String s) {
        return s.codePointCount(0, s.length());
    }

    // ---- Parsing one line -------------------------------------------------------------------

    // "[done.] Call mom #family" -> a Task, or an empty Optional if the line isn't a task.
    static Optional<Task> parseLine(String line) {
        String s = strip(line);
        if (!s.startsWith("[")) return Optional.empty();
        int close = s.indexOf(']'); // Python's partition("]")
        String raw = close < 0 ? s : s.substring(0, close);
        String rest = close < 0 ? "" : s.substring(close + 1);
        String status = raw.replaceAll("^[\\[\\] .]+|[\\[\\] .]+$", "").toLowerCase(Locale.ROOT);
        List<String> tags = new ArrayList<>();
        List<String> title = new ArrayList<>();
        for (String word : words(rest)) {
            if (word.startsWith(TAG_MARKER)) {
                tags.add(word.replaceAll("^#+", "").replaceAll("^[.,]+|[.,]+$", "").toLowerCase(Locale.ROOT));
            } else {
                title.add(word);
            }
        }
        String joined = String.join(" ", title);
        return Optional.of(tags.contains("urgent") ? new UrgentTask(joined, status, tags) : new Task(joined, status, tags));
    }

    // ---- The file ---------------------------------------------------------------------------

    // Every task in the file; lines that aren't tasks are skipped. Lines end at \n, \r\n or \r, as
    // when Python reads a text file. IOException is a checked exception: the signature must say so,
    // and every caller must catch it or pass it on.
    static List<Task> loadTasks(Path path) throws IOException {
        return Pattern.compile("\r\n|\r|\n").splitAsStream(Files.readString(path))
                .map(Tracker::parseLine)
                .flatMap(Optional::stream) // the empty ones simply disappear
                .collect(ArrayList::new, ArrayList::add, ArrayList::addAll);
    }

    // Parses each title as a new "[todo]" task and adds it. Returns how many were added.
    static int addTasks(List<Task> tasks, List<String> titles) {
        int before = tasks.size();
        titles.forEach(title -> parseLine("[todo] " + title).ifPresent(tasks::add));
        return tasks.size() - before;
    }

    // "[todo] title" lines on the end of the file.
    static void appendTitles(Path path, List<String> titles) throws IOException {
        StringBuilder text = new StringBuilder();
        titles.forEach(title -> text.append("[todo] ").append(title).append('\n'));
        Files.writeString(path, text, StandardOpenOption.APPEND);
    }

    // ---- Counting and ranking ---------------------------------------------------------------

    // A LinkedHashMap remembers the order keys were first put in, so first-seen order comes free.
    // (A plain HashMap would give its own order.)
    static Map<String, Integer> countTags(List<Task> tasks, boolean includeDone) {
        Map<String, Integer> counts = new LinkedHashMap<>();
        for (Task task : tasks) {
            if (!includeDone && task.isDone()) continue;
            for (String tag : task.tags) counts.merge(tag, 1, Integer::sum);
        }
        return counts;
    }

    // The n items with the biggest key, biggest first, for any type T. Stream.sorted is stable on
    // an ordered stream, so ties keep their order.
    static <T> List<T> topN(List<T> items, int n, Comparator<T> byKey) {
        return items.stream().sorted(byKey.reversed()).limit(n).toList();
    }

    static List<TagCount> topTags(List<Task> tasks, int n, boolean includeDone) {
        if (n < 1) throw new IllegalArgumentException("n must be at least 1"); // Python's ValueError
        List<TagCount> pairs = countTags(tasks, includeDone).entrySet().stream()
                .map(e -> new TagCount(e.getKey(), e.getValue()))
                .toList();
        return topN(pairs, n, Comparator.comparingInt(TagCount::count));
    }

    // ---- The chart --------------------------------------------------------------------------

    static void drawChart(List<TagCount> pairs) {
        if (pairs.isEmpty()) {
            out.println("No tags yet.");
            return;
        }
        double biggest = pairs.getFirst().count();
        int labelWidth = pairs.stream().mapToInt(p -> width(p.tag())).max().orElse(0);
        for (TagCount p : pairs) {
            // Math.rint rounds halves to the even neighbour, like Python's round(). Math.round doesn't.
            int blocks = (int) Math.rint(p.count() / biggest * CHART_WIDTH);
            out.println(p.tag() + " ".repeat(labelWidth - width(p.tag())) + "  " + "█".repeat(blocks) + " " + p.count());
        }
    }

    // ---- Talking to the user ----------------------------------------------------------------

    // Python's input(): shows the prompt, reads up to the next \n. An empty line at the end of input.
    static String ask(String prompt) throws IOException {
        out.print(prompt);
        out.flush();
        ByteArrayOutputStream line = new ByteArrayOutputStream();
        int b;
        while ((b = System.in.read()) != -1 && b != '\n') line.write(b);
        return line.toString(StandardCharsets.UTF_8);
    }

    // Python's int(text): optional spaces, an optional sign, digits with single underscores between
    // them, optional spaces. Integer.parseInt takes no spaces or underscores. Capped.
    static Optional<Integer> parseWholeNumber(String text) {
        var match = Pattern.compile("([+-]?)([0-9]+(?:_[0-9]+)*)").matcher(strip(text));
        if (!match.matches()) return Optional.empty();
        String digits = match.group(2).replace("_", "").replaceFirst("^0+(?=.)", "");
        int value = digits.length() > 9 ? Integer.MAX_VALUE : Integer.parseInt(digits);
        return Optional.of(match.group(1).equals("-") ? -value : value);
    }

    public static void main(String[] args) throws IOException {
        String env = System.getenv("TASKS_FILE");
        Path path = Path.of(args.length > 0 ? args[0] : env != null ? env : "tasks.txt");

        List<Task> tasks;
        try {
            tasks = loadTasks(path);
        } catch (NoSuchFileException e) {
            err.println("Couldn't find " + path);
            System.exit(1);
            return;
        } catch (IOException e) {
            err.println("Couldn't read " + path);
            System.exit(1);
            return;
        }

        List<String> newTitles = new ArrayList<>();
        while (true) {
            String title = strip(ask("New task (Enter to finish): "));
            if (title.isEmpty()) break;
            if (title.startsWith(TAG_MARKER)) {
                out.println("A task needs a title, not just tags.");
                continue;
            }
            newTitles.add(title);
        }
        if (addTasks(tasks, newTitles) > 0) appendTitles(path, newTitles);

        List<TagCount> pairs;
        try {
            String answer = ask("How many top tags? [3]: ");
            pairs = topTags(tasks, answer.isEmpty() ? DEFAULT_TOP : parseWholeNumber(answer).orElse(0), true);
        } catch (IllegalArgumentException e) {
            out.println("Need a whole number of at least 1 — using 3.");
            pairs = topTags(tasks, DEFAULT_TOP, true);
        }

        long done = tasks.stream().filter(Task::isDone).count();
        double percent = tasks.isEmpty() ? 0 : (double) done / tasks.size() * 100;
        out.println("\n" + tasks.size() + " tasks, " + done + " done (" + (long) Math.rint(percent) + "%), "
                + countTags(tasks, true).size() + " tags");
        for (Task task : tasks) {
            if (task instanceof UrgentTask urgent && !urgent.isDone()) out.println(urgent);
        }

        out.println("\nTop tags");
        drawChart(pairs);
    }
}
