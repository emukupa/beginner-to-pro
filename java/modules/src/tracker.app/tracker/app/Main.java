package tracker.app;

import java.io.ByteArrayOutputStream;
import java.io.FileDescriptor;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.PrintStream;
import java.nio.charset.StandardCharsets;
import java.nio.file.NoSuchFileException;
import java.nio.file.Path;
import java.util.ArrayList;
import java.util.List;
import java.util.Optional;
import java.util.regex.Pattern;
import tracker.chart.Chart;
import java.util.Arrays;
import java.util.Locale;
import tracker.models.Status;
import tracker.models.TagCount;
import tracker.models.Task;
import tracker.models.UrgentTask;
import tracker.parsing.Parsing;
import tracker.storage.Storage;
import tracker.tasklist.TaskList;
import tracker.text.Text;

// The program: the only class that reads input, prints to the screen or exits. Everything else
// comes from the tracker.core module.
public final class Main {
    private Main() {}

    static final PrintStream out = new PrintStream(new FileOutputStream(FileDescriptor.out), true, StandardCharsets.UTF_8);
    static final PrintStream err = new PrintStream(new FileOutputStream(FileDescriptor.err), true, StandardCharsets.UTF_8);

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
        var match = Pattern.compile("([+-]?)([0-9]+(?:_[0-9]+)*)").matcher(Text.strip(text));
        if (!match.matches()) return Optional.empty();
        String digits = match.group(2).replace("_", "").replaceFirst("^0+(?=.)", "");
        int value = digits.length() > 9 ? Integer.MAX_VALUE : Integer.parseInt(digits);
        return Optional.of(match.group(1).equals("-") ? -value : value);
    }

    // What a status command does: an enum whose constants carry the status they set and what they
    // print. Python's CHANGES dict, with the command words as the constants' names.
    enum Change {
        DONE(Status.DONE, "Done", "Already done"),
        UNDO(Status.TODO, "Undone", "Not done yet");

        final Status sets;
        final String changed; // printed after changing it
        final String already; // printed when the task already had that status

        Change(Status sets, String changed, String already) {
            this.sets = sets;
            this.changed = changed;
            this.already = already;
        }

        // The word typed for it: "done" or "undo".
        String word() {
            return name().toLowerCase(Locale.ROOT);
        }

        static Optional<Change> of(String word) {
            return Arrays.stream(values()).filter(c -> c.word().equals(word)).findFirst();
        }
    }

    // tracker done|undo "title": sets one task's status. Returns the exit code.
    static int change(Change change, List<String> words) throws IOException {
        String title = Text.strip(String.join(" ", words));
        if (title.isEmpty()) {
            err.println("Usage: " + change.word() + " \"task title\"");
            return 2;
        }
        String env = System.getenv("TASKS_FILE");
        Path path = Path.of(env != null ? env : "tasks.txt");
        List<Task> tasks;
        try {
            tasks = Storage.loadTasks(path);
        } catch (NoSuchFileException e) {
            err.println("Couldn't find " + path);
            return 1;
        } catch (IOException e) {
            err.println("Couldn't read " + path);
            return 1;
        }
        Optional<Task> found = TaskList.findTask(tasks, title);
        if (found.isEmpty()) {
            err.println("No task called \"" + title + "\"");
            return 1;
        }
        Task task = found.get();
        if (task.status.equals(change.sets.word())) {
            out.println(change.already + ": " + task.title);
            return 0;
        }
        try {
            Storage.setStatus(path, task, change.sets);
        } catch (IOException e) {
            err.println("Couldn't write " + path);
            return 1;
        }
        out.println(change.changed + ": " + task.title);
        return 0;
    }

    public static void main(String[] args) throws IOException {
        if (args.length > 0) { // a second mode: tracker done "title", tracker undo "title"
            Optional<Change> change = Change.of(args[0]);
            if (change.isPresent()) System.exit(change(change.get(), List.of(args).subList(1, args.length)));
        }
        String env = System.getenv("TASKS_FILE");
        Path path = Path.of(args.length > 0 ? args[0] : env != null ? env : "tasks.txt");

        List<Task> tasks;
        try {
            tasks = Storage.loadTasks(path);
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
            String title = Text.strip(ask("New task (Enter to finish): "));
            if (title.isEmpty()) break;
            if (title.startsWith(Parsing.TAG_MARKER)) {
                out.println("A task needs a title, not just tags.");
                continue;
            }
            newTitles.add(title);
        }
        if (TaskList.addTasks(tasks, newTitles) > 0) Storage.appendTitles(path, newTitles);

        List<TagCount> pairs;
        try {
            String answer = ask("How many top tags? [3]: ");
            pairs = TaskList.topTags(tasks, answer.isEmpty() ? TaskList.DEFAULT_TOP : parseWholeNumber(answer).orElse(0), true);
        } catch (IllegalArgumentException e) {
            out.println("Need a whole number of at least 1 — using 3.");
            pairs = TaskList.topTags(tasks, TaskList.DEFAULT_TOP, true);
        }

        TaskList.Summary s = TaskList.summarize(tasks);
        out.println("\n" + s.total() + " tasks, " + s.done() + " done (" + s.percent() + "%), " + s.tags() + " tags");
        for (Task task : tasks) {
            if (task instanceof UrgentTask urgent && !urgent.isDone()) out.println(urgent);
        }

        out.println("\nTop tags");
        Chart.draw(out, pairs, Chart.WIDTH);
    }
}
