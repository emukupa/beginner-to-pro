package tracker.storage;

import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.StandardOpenOption;
import java.util.ArrayList;
import java.util.List;
import java.util.Optional;
import java.util.regex.Pattern;
import tracker.models.Task;
import tracker.parsing.Parsing;

// The tasks file: the only package that opens files.
public final class Storage {
    private Storage() {}

    // Every task in the file; lines that aren't tasks are skipped. Lines end at \n, \r\n or \r.
    public static List<Task> loadTasks(Path path) throws IOException {
        return Pattern.compile("\r\n|\r|\n").splitAsStream(Files.readString(path))
                .map(Parsing::parseLine)
                .flatMap(Optional::stream)
                .collect(ArrayList::new, ArrayList::add, ArrayList::addAll);
    }

    // "[todo] title" lines on the end of the file.
    public static void appendTitles(Path path, List<String> titles) throws IOException {
        StringBuilder text = new StringBuilder();
        titles.forEach(title -> text.append("[todo] ").append(title).append('\n'));
        Files.writeString(path, text, StandardOpenOption.APPEND);
    }
}
