package tracker.models;

import java.util.List;

// What a task is. A class, as in Python; final fields are set once, in the constructor.
public class Task {
    public final String title;
    public final String status;
    public final List<String> tags;

    public Task(String title, String status, List<String> tags) {
        this.title = title;
        this.status = status;
        this.tags = List.copyOf(tags);
    }

    public boolean isDone() {
        return status.equals("done");
    }

    @Override
    public String toString() {
        return "[" + (isDone() ? "x" : " ") + "] " + title;
    }
}
