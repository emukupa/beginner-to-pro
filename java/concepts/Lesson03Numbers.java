// Lesson 03: whole-number division drops the fraction, int overflow wraps around without a word,
// and doubles are binary fractions. Java's rounding also isn't Python's: Math.round rounds halves
// up, Python rounds them to the nearest even number. The tracker needs Python's, so: Math.rint.
// bug: putting a double into an int. Java won't drop the fraction silently; you must cast.

final class Lesson03Numbers {
    static final String TITLE = "Numbers";

    private Lesson03Numbers() {}

    /** Python's round(): halves go to the even neighbour. Lesson 06's bar uses it for every chart. */
    static long pythonRound(double x) {
        return (long) Math.rint(x);
    }

    static void run() {
        System.out.println("7 / 2 = " + 7 / 2 + ", 7 / 2.0 = " + 7 / 2.0 + ", 7 % 2 = " + 7 % 2);
        // Java divides towards zero; Python's // goes down. Math.floorDiv is Python's.
        System.out.println("-7 / 2 = " + -7 / 2 + ", Math.floorDiv(-7, 2) = " + Math.floorDiv(-7, 2)
                + ", -7 % 2 = " + -7 % 2 + ", Math.floorMod(-7, 2) = " + Math.floorMod(-7, 2));

        int max = Integer.MAX_VALUE;
        System.out.println("MAX_VALUE + 1 = " + (max + 1) + "  (wrapped round, silently)");
        try {
            System.out.println(Math.addExact(max, 1));
        } catch (ArithmeticException e) {
            System.out.println("Math.addExact(MAX_VALUE, 1) throws: " + e.getMessage());
        }

        System.out.println("0.1 + 0.2 = " + (0.1 + 0.2));
        System.out.println("(int) 3.99 = " + (int) 3.99 + "  (a cast cuts the fraction off)");

        for (double x : new double[] {0.5, 1.5, 2.5, -2.5}) {
            System.out.printf("%5.1f: Math.round %2d, Math.rint %4.1f, pythonRound %2d%n",
                    x, Math.round(x), Math.rint(x), pythonRound(x));
        }
        // The same trap hides in formatting: %.0f rounds halves up too, Python's :.0f doesn't.
        System.out.println("\"%.0f\" of 2.5 = " + "%.0f".formatted(2.5) + ", Python prints 2");

        System.out.println("Integer.parseInt(\"3\") + 1 = " + (Integer.parseInt("3") + 1));
        try {
            Integer.parseInt("three");
        } catch (NumberFormatException e) {
            System.out.println("Integer.parseInt(\"three\") throws: " + e.getMessage());
        }
    }
}
