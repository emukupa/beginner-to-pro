// Lesson 06's mistake: a lambda that changes a local variable. `make bug N=6` compiles this in.

import java.util.List;

final class Lesson06Bug {
    private Lesson06Bug() {}

    public static void main(String[] args) {
        int total = 0;
        List.of(3, 2, 1).forEach(count -> total += count); // a lambda may only read locals that never change
        System.out.println(total);
    }
}
