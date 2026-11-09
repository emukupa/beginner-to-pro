// Lesson 15: a sealed interface lists every type allowed to implement it, so javac knows them all.
// A switch over one can then match each type, take its record apart into fields, and needs no
// default: forget a case and it won't build. The tracker's commands (summary, chart, and later
// done and undo) are exactly that: a fixed set of things a command line can mean.
// Everything so far comes together here: a mini tracker, run on tasks.txt.
// bug: a new command record that isn't in the permits list. javac refuses it.

import java.util.ArrayList;
import java.util.List;

final class Lesson15Sealed {
    static final String TITLE = "Sealed types: the mini tracker";

    private Lesson15Sealed() {}

    sealed interface Command permits Summary, Chart, Add {}

    record Summary() implements Command {}

    record Chart(int top) implements Command {}

    record Add(String line) implements Command {}

    static final String USAGE = """
            Commands:
              summary        tasks, done and tags
              chart [n]      the top n tags (3 if you leave it out)
              add <line>     one more task, e.g. add [todo] Water plants #home""";

    /** Words from a command line -> a Command. An unknown word is the caller's mistake: an exception. */
    static Command parse(List<String> words) {
        if (words.isEmpty()) {
            throw new IllegalArgumentException("no command\n" + USAGE);
        }
        return switch (words.get(0)) {
            case "summary" -> new Summary();
            case "chart" -> new Chart(Lesson12Exceptions.parseTop(words.size() > 1 ? words.get(1) : ""));
            case "add" -> new Add(String.join(" ", words.subList(1, words.size())));
            default -> throw new IllegalArgumentException("unknown command " + words.get(0) + "\n" + USAGE);
        };
    }

    /** The tracker's chart: labels padded to the longest, the biggest bar 20 wide. */
    static void drawChart(List<Lesson13Collections.TagCount> ranked) {
        if (ranked.isEmpty()) {
            System.out.println("No tags yet.");
            return;
        }
        int biggest = ranked.get(0).count();
        int width = ranked.stream().mapToInt(t -> t.tag().length()).max().orElse(0);
        for (Lesson13Collections.TagCount t : ranked) {
            System.out.println(("%-" + width + "s  %s %d").formatted(t.tag(), Lesson06Methods.bar(t.count(), biggest, 20), t.count()));
        }
    }

    static void summary(List<Lesson09Classes.Task> tasks) {
        long done = tasks.stream().filter(Lesson09Classes.Task::isDone).count();
        long tags = tasks.stream().flatMap(t -> t.tags().stream()).distinct().count();
        long percent = Lesson03Numbers.pythonRound(Lesson06Methods.percent((int) done, tasks.size()));
        System.out.printf("%d tasks, %d done (%d%%), %d tags%n", tasks.size(), done, percent, tags);
        for (Lesson09Classes.Task task : tasks) {
            if (task instanceof Lesson10Inheritance.UrgentTask && !task.isDone()) {
                System.out.println(task);
            }
        }
    }

    static void execute(Command command, List<Lesson09Classes.Task> tasks) {
        switch (command) { // every permitted type, and nothing else: no default needed
            case Summary() -> summary(tasks);
            case Chart(int top) -> { // a record pattern: match a Chart and take out its top
                System.out.println("\nTop tags");
                drawChart(Lesson14Streams.rankTags(tasks, top));
            }
            case Add(String line) when line.isBlank() -> System.out.println("A task needs a title.");
            case Add(String line) -> Lesson11Optional.parseLine(line).ifPresentOrElse(
                    task -> {
                        tasks.add(task);
                        System.out.println("added " + task + " (in memory only; chapter 01 writes the file)");
                    },
                    () -> System.out.println("not a task: " + line));
        }
    }

    static void run() {
        List<Lesson09Classes.Task> tasks;
        try {
            tasks = new ArrayList<>(Lesson12Exceptions.loadTasks(Lesson12Exceptions.tasksFile()));
        } catch (java.io.IOException e) {
            System.out.println("Couldn't find " + Lesson12Exceptions.tasksFile());
            return;
        }
        execute(parse(List.of("summary")), tasks);
        execute(parse(List.of("chart", "3")), tasks);

        System.out.println();
        for (List<String> words : List.of(List.of("add"), List.of("add", "[todo]", "Water", "plants", "#home"), List.of("tidy"))) {
            try {
                execute(parse(words), tasks);
            } catch (IllegalArgumentException e) {
                System.out.println("Error: " + e.getMessage());
            }
        }
        System.out.println("\nhome now ties work at 3. It came first in the file, and the sort is stable, so it stays first:");
        execute(new Chart(5), tasks);
    }
}
