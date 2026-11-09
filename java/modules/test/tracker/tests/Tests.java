package tracker.tests;

import java.io.ByteArrayOutputStream;
import java.io.PrintStream;
import java.nio.charset.StandardCharsets;
import java.util.List;
import java.util.Optional;
import tracker.chart.Chart;
import tracker.models.TagCount;
import tracker.models.Task;
import tracker.models.UrgentTask;
import tracker.parsing.Parsing;
import tracker.tasklist.TaskList;

// The tests: named checks made of plain assert statements, and a tiny runner. Run with java -ea, or
// the asserts are skipped: the runner refuses to pass without them.
public final class Tests {
    private Tests() {}

    static List<Task> load(String... lines) {
        return java.util.Arrays.stream(lines).map(Parsing::parseLine).flatMap(Optional::stream).toList();
    }

    record Check(String name, Runnable body) {}

    static final List<Check> CHECKS = List.of(
        new Check("reads the status, title and tags", () -> {
            Task task = Parsing.parseLine("[DONE.] Call mom #Family #urgent,").orElseThrow();
            assert task instanceof UrgentTask;
            assert task.status.equals("done") && task.title.equals("Call mom");
            assert task.tags.equals(List.of("family", "urgent"));
        }),
        new Check("a line without a bracket is not a task", () -> {
            assert Parsing.parseLine("Buy milk #home").isEmpty();
        }),
        new Check("finds a messy title", () -> {
            var tasks = load("[todo] Review pull request #work");
            assert TaskList.findTask(tasks, "  review PULL   request ").orElseThrow().title.equals("Review pull request");
            assert TaskList.findTask(tasks, "Walk dog").isEmpty();
        }),
        new Check("ties keep first-seen order", () -> {
            var top = TaskList.topTags(new java.util.ArrayList<>(load("[todo] a #work #home", "[todo] b #home #work", "[todo] c #play")), 3, true);
            assert top.stream().map(TagCount::tag).toList().equals(List.of("work", "home", "play"));
        }),
        new Check("zero top tags is refused", () -> {
            try {
                TaskList.topTags(List.of(), 0, true);
                assert false : "no exception";
            } catch (IllegalArgumentException expected) {
                // what Python's ValueError became
            }
        }),
        new Check("halves round to even", () -> {
            assert TaskList.summarize(load("[done] a", "[todo] b", "[todo] c", "[todo] d", "[todo] e", "[todo] f", "[todo] g", "[todo] h")).percent() == 12;
        }),
        new Check("the chart draws into a buffer", () -> {
            var buffer = new ByteArrayOutputStream();
            Chart.draw(new PrintStream(buffer, true, StandardCharsets.UTF_8), List.of(new TagCount("home", 2), new TagCount("work", 1)), 4);
            assert buffer.toString(StandardCharsets.UTF_8).equals("home  ████ 2\nwork  ██ 1\n");
        })
    );

    public static void main(String[] args) {
        boolean asserts = false;
        assert asserts = true; // only runs with -ea
        if (!asserts) {
            System.out.println("Run with java -ea, or nothing is checked.");
            System.exit(2);
        }
        int failed = 0;
        for (Check check : CHECKS) {
            try {
                check.body().run();
                System.out.println("ok    " + check.name());
            } catch (AssertionError | RuntimeException e) {
                failed++;
                System.out.println("FAIL  " + check.name() + ": " + e);
            }
        }
        System.out.println((CHECKS.size() - failed) + " passed, " + failed + " failed");
        System.exit(failed == 0 ? 0 : 1);
    }
}
