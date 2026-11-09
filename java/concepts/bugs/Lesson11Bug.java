// Lesson 11's mistake: Map.get on a missing key gives null, and the code calls a method on it.
// It compiles; `make bug N=11` runs it and Java says exactly what was null.

import java.util.Map;

final class Lesson11Bug {
    private Lesson11Bug() {}

    public static void main(String[] args) {
        Map<String, String> notes = Map.of("Call mom", "Sunday");
        System.out.println(notes.get("Call dad").length());
    }
}
