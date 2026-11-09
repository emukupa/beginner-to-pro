// Lesson 14's mistake: asking for the largest of a type with no natural order.
// `make bug N=14` compiles this file in.

import java.util.List;

final class Lesson14Bug {
    private Lesson14Bug() {}

    public static void main(String[] args) {
        var counts = List.of(new Lesson13Collections.TagCount("work", 3), new Lesson13Collections.TagCount("home", 2));
        System.out.println(Lesson14Streams.largest(counts)); // TagCount isn't Comparable: refused
    }
}
