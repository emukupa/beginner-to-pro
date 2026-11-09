// Lesson 05: if, loops and switch. A switch with arrows (->) never falls through to the next case,
// and a switch expression gives back a value, so javac checks that every input has an answer.
// bug: reading a variable that might never have been set. javac follows every path to make sure.

final class Lesson05Control {
    static final String TITLE = "Decisions and loops";

    private Lesson05Control() {}

    static void run() {
        int done = 3;
        int total = 6;
        if (done == total) {
            System.out.println("all done");
        } else if (done == 0) {
            System.out.println("nothing done");
        } else {
            System.out.println("some done");
        }
        String word = done == 1 ? "task" : "tasks"; // the ternary: an if that gives back a value
        System.out.println(done + " " + word + " done");

        for (int i = 1; i <= 3; i++) { // start; keep going while; step
            System.out.print("i=" + i + " ");
        }
        System.out.println();
        for (String tag : new String[] {"work", "home", "work"}) { // for-each: no index to get wrong
            System.out.print(tag + " ");
        }
        System.out.println();

        int left = 3;
        while (left > 0) {
            left--;
        }
        System.out.println("while counted down to " + left);

        String[][] lists = {{"home", "work"}, {"travel", "urgent", "family"}};
        search:                       // a label names the outer loop...
        for (String[] list : lists) {
            for (String tag : list) {
                if (tag.equals("urgent")) {
                    System.out.println("found urgent, stopping both loops");
                    break search;     // ...so break can leave both at once
                }
            }
        }

        for (String status : new String[] {"done", "todo", "Done", "doing"}) {
            String mark = switch (status) {
                case "done" -> "x";
                case "todo", "" -> " ";   // several labels share one answer
                default -> {
                    String lower = status.toLowerCase(java.util.Locale.ROOT);
                    yield lower.equals("done") ? "x?" : "?"; // a block gives its value with yield
                }
            };
            System.out.printf("%-6s -> [%s]%n", status, mark);
        }
        // A String can be anything, so a switch expression over one must have a default. Over an
        // enum (lesson 08) or a sealed type (lesson 15), javac can see every case and needs none.
    }
}
