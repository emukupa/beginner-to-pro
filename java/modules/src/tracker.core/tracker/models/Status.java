package tracker.models;

// The statuses a command can set. A task read from the file keeps whatever word it had, as a string.
public enum Status {
    TODO,
    DONE;

    // How it's spelled between the brackets. A switch expression must cover every constant: add
    // one to the enum and the build stops here.
    public String word() {
        return switch (this) {
            case TODO -> "todo";
            case DONE -> "done";
        };
    }
}
