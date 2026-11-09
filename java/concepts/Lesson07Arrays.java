// Lesson 07: an array has a fixed length, set when it's made. A List can grow. List.of makes a
// list nobody can change; new ArrayList<>() makes one you can. Every index is checked: reading
// past the end throws an exception instead of reading whatever memory comes next (as C would).
// bug: a loop that runs one step too far. It builds, then throws ArrayIndexOutOfBoundsException.

import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;

final class Lesson07Arrays {
    static final String TITLE = "Arrays and lists";

    private Lesson07Arrays() {}

    static void run() {
        String[] titles = {"Buy groceries", "Call mom", "Book flights"};
        System.out.println(Arrays.toString(titles) + ", length " + titles.length + ", last " + titles[titles.length - 1]);
        int[] counts = new int[3]; // a new array is filled with zeros (or null, for objects)
        System.out.println("new int[3] = " + Arrays.toString(counts));

        String[] same = titles;                                // not a copy: two names, one array
        String[] copy = Arrays.copyOf(titles, titles.length);  // a real copy
        same[0] = "Buy bread";
        System.out.println("titles[0] after same[0] = ...: " + titles[0] + ", copy[0]: " + copy[0]);

        List<String> fixed = List.of("work", "home");
        try {
            fixed.add("travel");
        } catch (UnsupportedOperationException e) {
            System.out.println("List.of can't grow: UnsupportedOperationException");
        }

        List<String> tags = new ArrayList<>(fixed); // a growable copy
        tags.add("travel");
        tags.add(0, "urgent");
        tags.set(1, "WORK");
        System.out.println(tags + " size " + tags.size() + ", get(2) " + tags.get(2)
                + ", indexOf(\"travel\") " + tags.indexOf("travel") + ", contains(\"home\") " + tags.contains("home"));
        System.out.println("subList(1, 3) = " + tags.subList(1, 3) + "  (a view onto tags, not a copy)");
        tags.remove("WORK");
        System.out.println("remove(\"WORK\") -> " + tags);

        // A List holds objects, so ints are boxed into Integers. That makes remove ambiguous:
        List<Integer> numbers = new ArrayList<>(List.of(10, 20, 1));
        numbers.remove(1);                      // an int: remove the item at index 1
        numbers.remove(Integer.valueOf(1));     // an Integer: remove the value 1
        System.out.println("after remove(1) and remove(Integer.valueOf(1)): " + numbers);

        try {
            System.out.println(titles[3]);
        } catch (ArrayIndexOutOfBoundsException e) {
            System.out.println("titles[3] throws: " + e.getMessage());
        }
    }
}
