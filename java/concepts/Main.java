// Java concepts, one lesson per class. Each lesson is a file here with a TITLE and a run();
// Main keeps them in a table, and later lessons use what earlier ones built, by class name:
// Lesson04Strings.cleanStatus(...), Lesson09Classes.Task.
//
//   make                 build, then run every lesson
//   make run N=7         just lesson 7          (or: java -cp build Main 7, or several: Main 4 7)
//   make bug N=7         lesson 7 with its mistake compiled in, to watch Java catch it
//   make test            the checks in Tests.java, with assertions switched on
//
// Without make, the same build is one line:
//   javac -Xlint:all -Werror -d build *.java && java -cp build Main 7

import java.util.List;

final class Main {
    // A lesson is a title and something to run. A record is a class that only holds values (lesson 13);
    // Runnable is the interface for "a method with no arguments and no result", so Lesson01Hello::run fits.
    record Lesson(String title, Runnable run) {}

    static final List<Lesson> LESSONS = List.of(
            new Lesson(Lesson01Hello.TITLE, Lesson01Hello::run),
            new Lesson(Lesson02Values.TITLE, Lesson02Values::run),
            new Lesson(Lesson03Numbers.TITLE, Lesson03Numbers::run),
            new Lesson(Lesson04Strings.TITLE, Lesson04Strings::run),
            new Lesson(Lesson05Control.TITLE, Lesson05Control::run),
            new Lesson(Lesson06Methods.TITLE, Lesson06Methods::run),
            new Lesson(Lesson07Arrays.TITLE, Lesson07Arrays::run),
            new Lesson(Lesson08Enums.TITLE, Lesson08Enums::run),
            new Lesson(Lesson09Classes.TITLE, Lesson09Classes::run),
            new Lesson(Lesson10Inheritance.TITLE, Lesson10Inheritance::run),
            new Lesson(Lesson11Optional.TITLE, Lesson11Optional::run),
            new Lesson(Lesson12Exceptions.TITLE, Lesson12Exceptions::run),
            new Lesson(Lesson13Collections.TITLE, Lesson13Collections::run),
            new Lesson(Lesson14Streams.TITLE, Lesson14Streams::run),
            new Lesson(Lesson15Sealed.TITLE, Lesson15Sealed::run));

    private Main() {}

    static void run(int number) {
        Lesson lesson = LESSONS.get(number - 1);
        System.out.printf("%n=== %02d %s ===%n", number, lesson.title());
        lesson.run().run();
    }

    public static void main(String[] args) {
        if (args.length == 0) {
            for (int n = 1; n <= LESSONS.size(); n++) {
                run(n);
            }
            return;
        }
        for (String arg : args) {
            int n;
            try {
                n = Integer.parseInt(arg);
            } catch (NumberFormatException e) {
                n = 0; // not a number: no such lesson either
            }
            if (n < 1 || n > LESSONS.size()) {
                System.err.println("No lesson " + arg);
                System.exit(1);
            }
            run(n);
        }
    }
}
