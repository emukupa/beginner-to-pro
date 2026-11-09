// Lesson 01: every line of Java lives inside a class, and a program starts at a main method
// (Main.java has the one for these lessons). System.out.println prints a line; printf and
// formatted fill a template, the way Python's f-strings do.
// bug: println misspelt as printn. javac knows every method of every class before anything runs,
// so a typo never gets the chance to.

final class Lesson01Hello {
    static final String TITLE = "Hello";

    private Lesson01Hello() {} // only static methods here, so nobody needs a Lesson01Hello object

    static void run() {
        System.out.println("Hello, tasks!");
        System.out.print("print adds no newline, ");
        System.out.println("println does.");

        String file = "tasks.txt";
        int count = 6;
        // %s any value as text, %d a whole number, %.1f a decimal, %% a percent sign, %n a newline
        System.out.printf("%s has %d tasks, %.1f%% done%n", file, count, 50.0);
        System.out.println("|%-8s|%5d|".formatted("work", 3)); // - pads on the right: labels line up
        System.out.println("joined with +: " + count + " tasks");
        System.out.println(1 + 2 + " tasks, not " + 1 + 2); // + works left to right: 3 first, then text
        IO.println("IO.println (Java 25+) is the short way, for small scripts");

        // A program's exit code tells the shell how it went: 0 is success. Main.java calls
        // System.exit(1) when you ask for a lesson that doesn't exist.
        System.out.println("this lesson ends normally, so the exit code is 0");
    }
}
