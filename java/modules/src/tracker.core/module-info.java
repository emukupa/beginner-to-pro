// A module names itself, and says which of its packages other modules may use. A public class in a
// package that isn't exported is still out of reach from outside: Java's strongest privacy.
module tracker.core {
    exports tracker.models;
    exports tracker.text;
    exports tracker.parsing;
    exports tracker.storage;
    exports tracker.tasklist;
    exports tracker.chart;
}
