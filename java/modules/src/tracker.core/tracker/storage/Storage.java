package tracker.storage;

import java.io.IOException;
import java.nio.ByteBuffer;
import java.nio.channels.FileChannel;
import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.StandardCopyOption;
import java.nio.file.StandardOpenOption;
import java.util.regex.Matcher;
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

    // True if this line holds the task: the same title and status after parsing.
    private static boolean holds(String line, Task task) {
        return Parsing.parseLine(line).filter(found -> found.title.equals(task.title) && found.status.equals(task.status)).isPresent();
    }

    // Rewrites the line holding this task as [done], leaving every other byte of the file alone.
    public static void markDone(Path path, Task task) throws IOException {
        // Each line keeps its own ending (\n, \r\n or \r), as Python's readlines() does with newline="".
        List<String> lines = new ArrayList<>();
        Matcher m = Pattern.compile("[^\r\n]*(?:\r\n|\r|\n)|[^\r\n]+$").matcher(Files.readString(path));
        while (m.find()) lines.add(m.group());
        for (int i = 0; i < lines.size(); i++) {
            String line = lines.get(i);
            if (holds(line, task)) {
                int open = line.indexOf('['), close = line.indexOf(']', open);
                lines.set(i, line.substring(0, open) + "[done]" + line.substring(close + 1));
                break;
            }
        }

        // try-with-resources: temp.close() runs when the block ends, however it ends.
        try (TempFile temp = new TempFile(path)) {
            Files.setPosixFilePermissions(temp.path, Files.getPosixFilePermissions(path)); // keep them
            temp.channel.write(ByteBuffer.wrap(String.join("", lines).getBytes(StandardCharsets.UTF_8)));
            temp.replace(path);
        }
    }

    // A new file beside another, deleted when it's closed unless it replaced the other.
    private static final class TempFile implements AutoCloseable {
        final Path path;
        final FileChannel channel;
        private boolean kept;

        // createTempFile makes a new file with a random name, and fails rather than reuse one.
        TempFile(Path beside) throws IOException {
            Path folder = beside.toAbsolutePath().getParent();
            path = Files.createTempFile(folder, beside.getFileName() + ".", "");
            channel = FileChannel.open(path, StandardOpenOption.WRITE);
        }

        // On the disk first, then moved over the target: readers see the old file or the new one.
        void replace(Path target) throws IOException {
            channel.force(true);
            channel.close();
            Files.move(path, target, StandardCopyOption.ATOMIC_MOVE, StandardCopyOption.REPLACE_EXISTING);
            kept = true;
        }

        @Override
        public void close() throws IOException {
            channel.close();
            if (!kept) Files.deleteIfExists(path); // never leave the half-made file behind
        }
    }
}
