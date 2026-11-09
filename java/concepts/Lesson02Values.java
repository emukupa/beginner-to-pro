// Lesson 02: every variable has a type, fixed when the program is compiled. The primitive types
// (int, long, double, boolean, char) hold a value directly; everything else, String included, is
// an object, and the variable holds a reference to it. var lets javac work the type out for you.
// bug: assigning to a final variable. final means "set once", and javac holds you to it.

final class Lesson02Values {
    static final String TITLE = "Values and types";

    private Lesson02Values() {}

    static void run() {
        int tasks = 6;               // 32 bits, whole numbers
        long big = 3_000_000_000L;   // 64 bits; underscores are only for reading
        double percent = 50.0;       // 64-bit floating point
        boolean done = false;
        char mark = 'x';             // one UTF-16 unit, in single quotes; "x" would be a String
        System.out.println(tasks + " " + big + " " + percent + " " + done + " " + mark);
        System.out.println("int is " + Integer.BYTES + " bytes, long " + Long.BYTES
                + ", max int " + Integer.MAX_VALUE);

        var title = "Call mom"; // var: javac sees a String on the right, so title is a String
        var count = 3;          // ...and this is an int. The type is still fixed; var only saves typing
        System.out.println(title + " has type String, count + 1 = " + (count + 1));

        final int width = 20; // final: this name can never point at another value
        System.out.println("chart width " + width);

        char next = (char) (mark + 1); // a char is a number underneath: 'x' + 1 is 'y'
        System.out.println("'x' + 1 as a char = " + next + ", as a number = " + (mark + 1));

        // Each primitive has an object twin (int -> Integer) so it can go in a List. Java converts
        // between them for you ("boxing"). == on objects asks "same object?", not "same value?".
        Integer small1 = 127, small2 = 127, large1 = 1000, large2 = 1000;
        System.out.println("127 == 127: " + (small1 == small2) + ", 1000 == 1000: " + (large1 == large2)
                + ", 1000 equals 1000: " + large1.equals(large2));
        // Java keeps one shared Integer for each small number, so the first == happens to be true.
        // Compare objects with equals, always.

        String nothing = null; // a reference can point at nothing. Lesson 11 deals with that
        System.out.println("a null String prints as " + nothing);
    }
}
