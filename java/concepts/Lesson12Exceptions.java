// Lesson 12: when something fails, Java throws an exception, and the nearest matching catch
// handles it. Checked exceptions (IOException) are failures a program should expect, so javac
// makes you catch them or declare them with throws. Unchecked ones (NumberFormatException,
// IllegalArgumentException) mark bad input or bugs, and javac leaves them to you.
// try-with-resources closes a file (anything AutoCloseable) however the block ends.
// bug: calling loadTasks without catching or declaring its IOException. javac refuses.

import java.io.BufferedReader;
import java.io.IOException;
import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.nio.file.NoSuchFileException;
import java.nio.file.Path;
import java.util.ArrayList;
import java.util.List;

final class Lesson12Exceptions {
    static final String TITLE = "Exceptions and files";

    private Lesson12Exceptions() {}

    /** tasks.txt, whether you run from java/concepts (as make does) or from java/. */
    static Path tasksFile() {
        Path here = Path.of("tasks.txt");
        return Files.exists(here) ? here : Path.of("concepts", "tasks.txt");
    }

    /** Every task in the file, in file order. throws IOException: the caller decides what a failure means. */
    static List<Lesson09Classes.Task> loadTasks(Path path) throws IOException {
        List<Lesson09Classes.Task> tasks = new ArrayList<>();
        try (BufferedReader reader = Files.newBufferedReader(path, StandardCharsets.UTF_8)) {
            String line;
            while ((line = reader.readLine()) != null) { // null at the end of the file
                Lesson11Optional.parseLine(line).ifPresent(tasks::add);
            }
        } // reader.close() runs here, even if readLine threw
        return tasks;
    }

    /** The tracker's "How many top tags?": blank means 3, anything else must be a whole number of at least 1. */
    static int parseTop(String text) {
        if (text.isBlank()) {
            return 3;
        }
        int n = Integer.parseInt(text.strip()); // throws NumberFormatException for "three"
        if (n < 1) {
            throw new IllegalArgumentException("n must be at least 1");
        }
        return n;
    }

    /** A temporary file that deletes itself when closed: a resource of our own for try-with-resources. */
    record TempFile(Path path) implements AutoCloseable {
        static TempFile create() throws IOException {
            return new TempFile(Files.createTempFile("tasks", ".txt"));
        }

        @Override
        public void close() throws IOException {
            Files.deleteIfExists(path);
            System.out.println("  closed: temp file deleted");
        }
    }

    static void run() {
        try {
            List<Lesson09Classes.Task> tasks = loadTasks(tasksFile());
            System.out.println("loaded " + tasks.size() + " tasks from " + tasksFile() + ", first: " + tasks.get(0));
        } catch (IOException e) {
            System.out.println("Couldn't read " + tasksFile() + ": " + e);
        }

        try {
            loadTasks(Path.of("missing.txt"));
        } catch (NoSuchFileException e) { // the most specific catch goes first
            System.out.println("Couldn't find " + e.getFile());
        } catch (IOException e) {
            System.out.println("Couldn't read it: " + e);
        }

        int tried = 0;
        for (String typed : new String[] {"", "5", "three", "0"}) {
            try {
                System.out.printf("parseTop(\"%s\") = %d%n", typed, parseTop(typed));
            } catch (IllegalArgumentException e) { // NumberFormatException is a kind of IllegalArgumentException
                System.out.printf("parseTop(\"%s\") threw %s: %s, so using 3%n",
                        typed, e.getClass().getSimpleName(), e.getMessage());
            } finally {
                tried++; // finally runs whether the try worked or threw
            }
        }
        System.out.println("tried " + tried + " answers");

        try (TempFile temp = TempFile.create()) {
            Files.writeString(temp.path(), "[todo] Water plants #home\n");
            System.out.println("wrote and read back: " + loadTasks(temp.path()));
            System.out.println("  exists inside the try: " + Files.exists(temp.path()));
        } catch (IOException e) {
            System.out.println("temp file failed: " + e);
        }
    }
}
