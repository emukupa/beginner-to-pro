package tracker.models;

import java.util.List;

// Python's UrgentTask(Task): a subclass, with toString replaced.
public class UrgentTask extends Task {
    public UrgentTask(String title, String status, List<String> tags) {
        super(title, status, tags);
    }

    @Override
    public String toString() {
        return super.toString() + "  !!";
    }
}
