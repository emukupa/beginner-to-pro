// Lesson 13's mistake: putting a number into a list of Strings. `make bug N=13` compiles this in.

import java.util.ArrayList;
import java.util.List;

final class Lesson13Bug {
    private Lesson13Bug() {}

    public static void main(String[] args) {
        List<String> tags = new ArrayList<>();
        tags.add("work");
        tags.add(3); // List<String> takes Strings only: javac refuses
        System.out.println(tags);
    }
}
