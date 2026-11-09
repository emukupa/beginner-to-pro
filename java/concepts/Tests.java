// The lessons' reusable pieces, checked. No test library to download: each check is a method
// full of plain assert statements, and main below is the whole test runner.
//
//   make test     (or: java -ea -cp build Tests)
//
// assert only runs when the JVM is started with -ea ("enable assertions"). Without it every assert
// is skipped, so main refuses to run rather than pass without checking anything.

import java.util.List;
import java.util.Map;

final class Tests {
    private Tests() {}

    // A check is a name and some code that may throw. Our own interface, because Runnable can't throw IOException.
    interface Check {
        void run() throws Exception;
    }

    static final Map<String, Check> CHECKS = new java.util.LinkedHashMap<>();

    static {
        CHECKS.put("pythonRound rounds halves to even", () -> {
            assert Lesson03Numbers.pythonRound(0.5) == 0;
            assert Lesson03Numbers.pythonRound(2.5) == 2;
            assert Lesson03Numbers.pythonRound(3.5) == 4;
            assert Lesson03Numbers.pythonRound(6.67) == 7;
        });
        CHECKS.put("cleanStatus cleans messy statuses", () -> {
            assert Lesson04Strings.cleanStatus("[done.]").equals("done");
            assert Lesson04Strings.cleanStatus("[DONE]").equals("done");
            assert Lesson04Strings.cleanStatus("[ todo ]").equals("todo");
        });
        CHECKS.put("bar matches Python's chart", () -> {
            assert Lesson06Methods.bar(3, 3, 20).length() == 20;
            assert Lesson06Methods.bar(2, 3, 20).length() == 13;
            assert Lesson06Methods.bar(1, 3, 20).length() == 7;
            assert Lesson06Methods.percent(0, 0) == 0;
        });
        CHECKS.put("Status.parse knows done, todo and the rest", () -> {
            assert Lesson08Enums.Status.parse("[DONE.]") == Lesson08Enums.Status.DONE;
            assert Lesson08Enums.Status.parse("[ todo ]") == Lesson08Enums.Status.TODO;
            assert Lesson08Enums.Status.parse("[doing]") == Lesson08Enums.Status.OTHER;
        });
        CHECKS.put("parseLine reads tags, titles and urgent tasks", () -> {
            var task = Lesson11Optional.parseLine("[ todo ] Review pull request #work.").orElseThrow();
            assert task.title().equals("Review pull request") : task.title();
            assert task.tags().equals(List.of("work")) : task.tags();
            assert !task.isDone();
            var urgent = Lesson11Optional.parseLine("[todo] Finish quarterly report #work #urgent").orElseThrow();
            assert urgent instanceof Lesson10Inheritance.UrgentTask;
            assert urgent.toString().equals("[ ] Finish quarterly report  !!") : urgent;
        });
        CHECKS.put("parseLine skips lines that aren't tasks", () -> {
            assert Lesson11Optional.parseLine("").isEmpty();
            assert Lesson11Optional.parseLine("   ").isEmpty();
            assert Lesson11Optional.parseLine("no bracket here").isEmpty();
        });
        CHECKS.put("parseTop takes blank, rejects zero and words", () -> {
            assert Lesson12Exceptions.parseTop("") == 3;
            assert Lesson12Exceptions.parseTop(" 5 ") == 5;
            assert throwsIllegalArgument(() -> Lesson12Exceptions.parseTop("0"));
            assert throwsIllegalArgument(() -> Lesson12Exceptions.parseTop("three"));
        });
        CHECKS.put("tasks.txt loads six tasks, three done", () -> {
            var tasks = Lesson12Exceptions.loadTasks(Lesson12Exceptions.tasksFile());
            assert tasks.size() == 6 : tasks.size();
            assert tasks.stream().filter(Lesson09Classes.Task::isDone).count() == 3;
        });
        CHECKS.put("tags rank by count, ties in file order", () -> {
            var tasks = Lesson12Exceptions.loadTasks(Lesson12Exceptions.tasksFile());
            var ranked = Lesson14Streams.rankTags(tasks, 5);
            assert ranked.stream().map(Lesson13Collections.TagCount::tag).toList()
                    .equals(List.of("work", "home", "urgent", "family", "travel")) : ranked;
            assert ranked.get(0).equals(new Lesson13Collections.TagCount("work", 3));
        });
        CHECKS.put("commands parse into the right records", () -> {
            assert Lesson15Sealed.parse(List.of("summary")) instanceof Lesson15Sealed.Summary;
            assert Lesson15Sealed.parse(List.of("chart")).equals(new Lesson15Sealed.Chart(3));
            assert Lesson15Sealed.parse(List.of("chart", "5")).equals(new Lesson15Sealed.Chart(5));
            assert throwsIllegalArgument(() -> Lesson15Sealed.parse(List.of("tidy")));
        });
    }

    static boolean throwsIllegalArgument(Runnable code) {
        try {
            code.run();
            return false;
        } catch (IllegalArgumentException e) {
            return true;
        }
    }

    public static void main(String[] args) {
        boolean assertsOn = false;
        assert assertsOn = true; // only runs, and so only sets it, under -ea
        if (!assertsOn) {
            System.err.println("Run with -ea, or no assert will be checked: java -ea -cp build Tests");
            System.exit(2);
        }
        int failed = 0;
        for (var entry : CHECKS.entrySet()) {
            try {
                entry.getValue().run();
                System.out.println("ok    " + entry.getKey());
            } catch (Exception | AssertionError e) { // AssertionError is an Error, not an Exception
                failed++;
                System.out.println("FAIL  " + entry.getKey() + ": " + e);
            }
        }
        System.out.println((CHECKS.size() - failed) + " passed, " + failed + " failed");
        if (failed > 0) {
            System.exit(1);
        }
    }
}
