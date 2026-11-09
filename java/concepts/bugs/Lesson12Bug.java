// Lesson 12's mistake: calling a method that throws IOException, without catch or throws.
// `make bug N=12` compiles this file in.

import java.nio.file.Path;

final class Lesson12Bug {
    private Lesson12Bug() {}

    public static void main(String[] args) {
        var tasks = Lesson12Exceptions.loadTasks(Path.of("tasks.txt")); // the IOException goes nowhere: refused
        System.out.println(tasks.size());
    }
}
